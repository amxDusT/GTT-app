import 'dart:async';
import 'dart:convert';

import 'package:flutter_gtt/models/fermata.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttController {
  static late String _shortName;
  late MqttServerClient _client;
  late StreamSubscription<List<MqttReceivedMessage<MqttMessage>>> _subscription;
  final StreamController<MqttData> _payloadStreamController =
      StreamController<MqttData>();

  MqttController(String shortName) {
    _shortName = shortName;
    _client = MqttServerClient.withPort(
        "wss://mapi.5t.torino.it/scre", "randomNameTesting$shortName", 443);
    _client.logging(on: false);
    _client.keepAlivePeriod = 60;
    final connMess = MqttConnectMessage().withWillQos(MqttQos.atMostOnce);

    _client.connectionMessage = connMess;
    _client.useWebSocket = true;
    _client.setProtocolV311();

    connect(shortName);
  }
  void connect(String shortName) async {
    await _client.connect();

    _client.subscribe("/$shortName/#", MqttQos.atMostOnce);

    // Set up the subscription
    _subscription =
        _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      //print(c[0].topic);
      MqttData data =
          MqttData.fromList(jsonDecode(pt) as List<dynamic>, c[0].topic);
      _payloadStreamController.add(data);
    });
  }

  Stream<MqttData> get payloadStream => _payloadStreamController.stream;

  void dispose() {
    _subscription.cancel();
    _client.unsubscribe("/$_shortName/#");
    _client.disconnect();
    _payloadStreamController.close();
  }
}

class Api {
  static const String _url =
      "https://plan.muoversiatorino.it/otp/routers/mato/index/graphql";
  //static const String _urlBackup =
  //    "https://mapi.5t.torino.it/routing/v1/routers/mato/index/graphql";

  static Future<PatternDetails> getPatternDetails(String patternCode) async {
    final request = json.encode({
      "id": "q02",
      "query":
          "query GetPatternDetails(\$patternCode:String!) {pattern(id: \$patternCode){code directionId headsign stops{name code lat lon} patternGeometry{points} route{shortName longName}}}",
      "variables": {"patternCode": patternCode}
    });
    final response = await _post(request);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    //print(json.decode(response.body));
    return PatternDetails.fromJson(json.decode(response.body)['data']);
  }

  static Future<Fermata> getStop(int stopNum) async {
    final int time = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const range2 = 60 * 60 * 2;

    final request = json.encode({
      "id": "q01",
      "query":
          "query StopPageContentContainer_StopRelayQL(\$id_0:String!,\$startTime_1:Long!,\$timeRange_2:Int!,\$numberOfDepartures_3:Int!) {stop (id:\$id_0) {name, desc, lat, lon, stopTimes:stoptimesForPatterns(startTime:\$startTime_1,timeRange:\$timeRange_2,numberOfDepartures:\$numberOfDepartures_3,omitCanceled:false) {...F1}}} fragment F0 on Route {alerts {alertSeverityLevel,effectiveEndDate,effectiveStartDate,trip {pattern {code}}}} fragment F1 on StoptimesInPattern {pattern {code, directionId, route {shortName, longName,...F0}}, stoptimes{realtimeState,realtimeDeparture,scheduledDeparture,realtimeArrival,scheduledArrival,realtime}}",
      "variables": {
        "id_0": "gtt:$stopNum",
        "startTime_1": time,
        "timeRange_2": range2,
        "numberOfDepartures_3": 100
      }
    });

    final response = await _post(request);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return Fermata.fromJson(jsonResponse['data']['stop'], stopNum);
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
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);
}
