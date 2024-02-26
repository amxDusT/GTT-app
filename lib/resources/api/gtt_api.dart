import 'dart:async';
import 'dart:convert';
import 'package:flutter_gtt/models/gtt/agency.dart';
import 'package:flutter_gtt/models/gtt/pattern.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/resources/api/api_exception.dart';
import 'package:http/http.dart' as http;

class GttApi {
  static const String _url =
      'https://plan.muoversiatorino.it/otp/routers/mato/index/graphql';

  static Future<StopWithDetails> getStop(int stopNum) async {
    final int time = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const timeRange = 60 * 60 * 2;

    final request = json.encode({
      'query':
          'query StopPageContentContainer_StopRelayQL(\$id_0:String!,\$startTime_1:Long!,\$timeRange_2:Int!,\$numberOfDepartures_3:Int!) {stop (id:\$id_0) {stopTimes:stoptimesForPatterns(startTime:\$startTime_1,timeRange:\$timeRange_2,numberOfDepartures:\$numberOfDepartures_3,omitCanceled:false) {pattern {code route{alerts {alertSeverityLevel,effectiveEndDate,effectiveStartDate}}}, stoptimes{realtimeState,realtimeDeparture,scheduledDeparture,realtimeArrival,scheduledArrival,realtime}}}}',
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
    http.Response response =
        await http.post(Uri.parse(_url), body: data, headers: {
      'Content-Type': 'application/json',
    }).timeout(
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
    return _processData(response.body);
  }

  static (List<Route>, List<Pattern>, List<Stop>, List<PatternStop>)
      _processData(String body) {
    final Map<String, dynamic> js = json.decode(utf8.decode(body.codeUnits));
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
