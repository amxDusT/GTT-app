import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_gtt/models/gtt/agency.dart';
import 'package:flutter_gtt/models/gtt/pattern.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/models/map/travel.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_gtt/exceptions/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GttApi {
  static const String _url =
      'https://plan.muoversiatorino.it/otp/routers/mato/index/graphql';

  static Future<List<Stop>> getStopsFromPattern(Pattern pattern) async {
    final request = json.encode({
      'query':
          'query GetStopsFromPattern(\$patternCode: String!) { pattern(id:\$patternCode) {stops{ name code gtfsId lat lon}}}',
      'variables': {
        'patternCode': pattern.code,
      }
    });
    final response = await _post(request);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    return (jsonResponse['data']['pattern']['stops'] as List)
        .map((e) => Stop.fromJson(e))
        .toList();
  }

  static Future<StopWithDetails> getStop(int stopNum) async {
    final int time = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const timeRange = 60 * 60 * 2;

    final request = json.encode({
      'query':
          'query StopInfo(\$id:String!,\$startTime:Long!,\$timeRange:Int!,\$numberOfDepartures:Int!) {stop (id:\$id) {stopTimes:stoptimesForPatterns(startTime:\$startTime,timeRange:\$timeRange,numberOfDepartures:\$numberOfDepartures,omitCanceled:false) {pattern {code directionId headsign patternGeometry{points} route{alerts {alertSeverityLevel,effectiveEndDate,effectiveStartDate}}}, stoptimes{realtimeState,realtimeDeparture,scheduledDeparture,realtimeArrival,scheduledArrival,realtime}}}}',
      'variables': {
        'id': 'gtt:$stopNum',
        'startTime': time,
        'timeRange': timeRange,
        'numberOfDepartures': 100
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
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }
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
          'query AllRoutes(\$feedId: [String]){routes(feeds: \$feedId) {agency{gtfsId} gtfsId shortName longName type desc patterns{name code directionId headsign stops{ name code gtfsId lat lon} patternGeometry{points}}}}',
      'variables': {'feedId': 'gtt'}
    });
    final response = await _post(request);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return _processData(response.body);
  }

  static (List<Route>, List<Pattern>, List<Stop>, List<PatternStop>)
      _processData(String body) {
    final Map<String, dynamic> js =
        json.decode(utf8.decode(body.codeUnits, allowMalformed: true));
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

  static Future<List<Travel>> getTravels(
      {required SimpleAddress from,
      required SimpleAddress to,
      required DateTime time}) async {
    final request = json.encode({
      'query':
          'query TravelRoutes( \$fromPlace: String!, \$toPlace: String!, \$date: String!, \$time: String!, \$transportModes: [TransportMode!]!, \$maxItineraries: Int!){ plan( fromPlace: \$fromPlace toPlace: \$toPlace date: \$date time: \$time transportModes: \$transportModes numItineraries: \$maxItineraries ) { itineraries { startTime endTime walkDistance duration legs { transitLeg legGeometry { points } trip{pattern {code}} mode distance duration from { name lat lon } to { name lat lon stop { gtfsId code name lat lon}} route { gtfsId shortName longName type desc agency { gtfsId } } } } }}',
      'variables': {
        'fromPlace': from.toQueryPlace,
        'toPlace': to.toQueryPlace,
        'date': DateFormat('yyyy-MM-dd').format(time),
        'time': DateFormat.Hms().format(time),
        'transportModes': [],
        'maxItineraries': 5
      }
    });
    final response = await _post(request);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return (jsonResponse['data']['plan']['itineraries'] as List)
        .map((e) => Travel.fromJson(e))
        .toList();
  }
}
