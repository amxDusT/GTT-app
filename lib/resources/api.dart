import 'dart:async';
import 'dart:convert';

import 'package:flutter_gtt/models/gtt_models.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/models/mqtt_data.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttController {
  final Set<String> _shortNames = {};
  late MqttServerClient _client;
  late StreamSubscription<List<MqttReceivedMessage<MqttMessage>>> _subscription;
  final StreamController<MqttVehicle> _payloadStreamController =
      StreamController<MqttVehicle>();

  MqttController() {
    _client = MqttServerClient.withPort(
        'wss://mapi.5t.torino.it/scre', 'randomNameTesting123', 443);
    _client.logging(on: false);
    _client.keepAlivePeriod = 60;
    final connMess = MqttConnectMessage().withWillQos(MqttQos.atMostOnce);

    _client.connectionMessage = connMess;
    _client.useWebSocket = true;
    _client.autoReconnect = true;

    _client.setProtocolV311();

    //connect(shortName);
  }
  void addSubscription(String shortName) {
    // remove spaces for busses like "16 CS/CD"
    shortName = shortName.replaceAll(' ', '');
    _shortNames.add(shortName);
    _client.clientIdentifier = '${_client.clientIdentifier}$shortName';
  }

  void connect() async {
    await _client.connect();
    for (String shortName in _shortNames) {
      _client.subscribe('/$shortName/#', MqttQos.atMostOnce);
    }

    // listen to subscriptions
    _subscription =
        _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      //print(c[0].topic);
      try {
        MqttVehicle data =
            MqttVehicle.fromList(json.decode(pt) as List<dynamic>, c[0].topic);
        _payloadStreamController.add(data);
      } catch (e) {
        print('Exception: ${json.decode(pt)}');
      }
    });
  }

  Stream<MqttVehicle> get payloadStream => _payloadStreamController.stream;

  Future<void> dispose() async {
    for (String shortName in _shortNames) {
      _client.unsubscribe('/$shortName/#');
    }
    await _subscription.cancel();
    _client.disconnect();
    await _payloadStreamController.close();
  }
}

class Api {
  static const String _url =
      'https://plan.muoversiatorino.it/otp/routers/mato/index/graphql';

  static Future<StopWithDetails> getStop(int stopNum) async {
    final int time = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const timeRange = 60 * 60 * 2;

    final request = json.encode({
      'id': 'q01',
      "query":
          "query StopPageContentContainer_StopRelayQL(\$id_0:String!,\$startTime_1:Long!,\$timeRange_2:Int!,\$numberOfDepartures_3:Int!) {stop (id:\$id_0) {stopTimes:stoptimesForPatterns(startTime:\$startTime_1,timeRange:\$timeRange_2,numberOfDepartures:\$numberOfDepartures_3,omitCanceled:false) {pattern {code route{alerts {alertSeverityLevel,effectiveEndDate,effectiveStartDate}}}, stoptimes{realtimeState,realtimeDeparture,scheduledDeparture,realtimeArrival,scheduledArrival,realtime}}}}",
      'variables': {
        'id_0': 'gtt:$stopNum',
        'startTime_1': time,
        'timeRange_2': timeRange,
        'numberOfDepartures_3': 100
      }
    });

    final response = await _post(request);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    return await StopWithDetails.decodeJson(
        jsonResponse['data']['stop'], stopNum);
  }

  static Future<http.Response> _post(dynamic data) async {
    http.Response response = await http.post(Uri.parse(_url),
        body: data, headers: {'Content-Type': 'application/json'}).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        return http.Response('Time out', 408);
      },
    );
    return response;
  }

  static Future<List<Agency>> getAgencies() async {
    final request = json.encode({
      'query':
          'query AllFeeds{feeds{feedId agencies{ gtfsId name url fareUrl phone } }}'
    });
    final response = await _post(request);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    for (Map<String, dynamic> data in jsonResponse['data']['feeds']) {
      if (data['feedId'] != 'gtt') continue;
      //print(data['agencies']);
      return (data['agencies'] as List)
          .map((agency) => Agency.fromJson(agency))
          .toList();
    }
    return [];
  }

  static Future<(List<Route>, List<Pattern>, List<Stop>, List<PatternStop>)>
      routesByFeed() async {
    final request = json.encode({
      'query':
          'query AllRoutes(\$feed_id: [String]){routes(feeds: \$feed_id) {agency{gtfsId} gtfsId shortName longName type desc patterns{name code directionId headsign stops{ name code gtfsId lat lon} patternGeometry{points}}}}',
      'variables': {'feed_id': 'gtt'}
    });
    final response = await _post(request);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }

    //compute(_processData2, response.body);
    //_processData(response.body);
    return _processData2(response.body);
    //DatabaseCommands.bulkInsert(json.decode(response.body));
  }

  static (List<Route>, List<Pattern>, List<Stop>, List<PatternStop>)
      _processData2(String body) {
    final Map<String, dynamic> js = json.decode(body);
    final List<Route> routes = [];
    final List<Pattern> patterns = [];
    final Set<Stop> stops = {};
    final List<PatternStop> patternStops = [];
    for (var route in (js['data']['routes'] as List)) {
      Route r = Route.fromJson(route);
      routes.add(r);
      for (var pattern in (route['patterns'] as List)) {
        Pattern p = Pattern.fromJson(pattern);
        patterns.add(p);
        for (final (index, stop) in (pattern['stops'] as List).indexed) {
          Stop s = Stop.fromJson(stop);
          stops.add(s);
          PatternStop ps = PatternStop(
            patternCode: p.code,
            stopId: s.gtfsId,
            stopOrder: index,
          );
          patternStops.add(ps);
        }
      }
    }
    return (routes, patterns, stops.toList(), patternStops);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);
}
