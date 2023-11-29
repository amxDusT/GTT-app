import 'package:flutter_gtt/resources/utils/maps.dart';
import 'package:latlong2/latlong.dart';

class Agency {
  final String gtfsId;
  final String name;
  final String url;
  final String fareUrl;
  final String phone;
  const Agency({
    required this.gtfsId,
    required this.name,
    required this.url,
    required this.fareUrl,
    required this.phone,
  });

  factory Agency.fromJson(Map<String, dynamic> js) {
    return Agency(
      gtfsId: js['gtfsId'],
      name: js['name'],
      url: js['url'],
      fareUrl: js['fareUrl'],
      phone: js['phone'],
    );
  }
  Map<String, dynamic> toMap() => {
        'gtfsId': gtfsId,
        'name': name,
        'url': url,
        'fareUrl': fareUrl,
        'phone': phone,
      };
}

class RouteWithDetails extends Route {
  final List<Stoptime> stoptimes;
  //TODO: remove alerts => always empty
  final List<String> alerts;
  final Pattern pattern;
  const RouteWithDetails({
    required agencyId,
    required shortName,
    required longName,
    required type,
    required desc,
    required gtfsId,
    required this.stoptimes,
    required this.alerts,
    required this.pattern,
  }) : super(
          agencyId: agencyId,
          shortName: shortName,
          longName: longName,
          type: type,
          desc: desc,
          gtfsId: gtfsId,
        );

  RouteWithDetails copyWith({
    Route? route,
    List<Stoptime>? stoptimes,
    Pattern? pattern,
    List<String>? alerts,
  }) {
    return RouteWithDetails(
      agencyId: route?.agencyId ?? agencyId,
      shortName: route?.shortName ?? shortName,
      longName: route?.longName ?? longName,
      type: route?.type ?? type,
      desc: route?.desc ?? desc,
      gtfsId: route?.gtfsId ?? gtfsId,
      stoptimes: stoptimes ?? this.stoptimes,
      alerts: alerts ?? this.alerts,
      pattern: pattern ?? this.pattern,
    );
  }

  factory RouteWithDetails.fromData({
    required Route route,
    required List<Stoptime> stoptimes,
    required Pattern pattern,
    List<String>? alerts,
  }) {
    return RouteWithDetails(
      agencyId: route.agencyId,
      shortName: route.shortName,
      longName: route.longName,
      type: route.type,
      desc: route.desc,
      gtfsId: route.gtfsId,
      stoptimes: stoptimes,
      alerts: alerts ?? [],
      pattern: pattern,
    );
  }
  /*
   return Vehicle(
      patternCode: js['pattern']['code'],
      directionId: js['pattern']['directionId'],
      shortName: js['pattern']['route']['shortName'],
      longName: js['pattern']['route']['longName'],
      stoptimes: ((js['stoptimes'] ?? []) as List)
          .map((jsData) => Stoptime.fromJson(jsData))
          .toList(),
      alerts: ((js['pattern']['route']['alerts'] ?? []) as List)
          .map((jsData) => jsData.toString())
          .toList(),
    );
   */
  factory RouteWithDetails.fromJson(Map<String, dynamic> json) {
    return RouteWithDetails(
      agencyId: json['agencyId'],
      shortName: json['shortName'],
      longName: json['longName'],
      type: json['type'],
      desc: json['desc'],
      gtfsId: json['gtfsId'],
      stoptimes: (json['stoptimes'] as List<dynamic>)
          .map((stoptime) => Stoptime.fromJson(stoptime))
          .toList(),
      alerts: (json['alerts'] as List<dynamic>).cast<String>(),
      pattern: Pattern.fromJson(json['pattern']),
    );
  }
}

class Route {
  final String gtfsId;
  final String agencyId;
  final String shortName;
  final String longName;
  final int type;
  final String desc;
  const Route({
    required this.agencyId,
    required this.shortName,
    required this.longName,
    required this.type,
    required this.desc,
    required this.gtfsId,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      gtfsId: json['gtfsId'] ?? '',
      agencyId: json['agency']?['gtfsId'] ?? json['agencyId'] ?? '',
      shortName: json['shortName'] ?? '',
      longName: json['longName'] ?? '',
      type: json['type'] ?? 0,
      desc: json['desc'] ?? '',
    );
  }

  // Method to convert a Route instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'gtfsId': gtfsId,
      'agencyId': agencyId,
      'shortName': shortName,
      'longName': longName,
      'type': type,
      'desc': desc,
    };
  }
}

class Pattern {
  final String routeId;
  final String code;
  final int directionId;
  final String headsign;
  final String points;
  Pattern({
    required this.routeId,
    required this.code,
    required this.directionId,
    required this.headsign,
    required this.points,
  });
  factory Pattern.fromJson(Map<String, dynamic> json) {
    return Pattern(
      routeId: json['routeId'] ??
          '${json['code'].split(':')[0]}:${json['code'].split(':')[1]}',
      code: json['code'] ?? '',
      directionId: json['directionId'] ?? 0,
      headsign: json['headsign'] ?? '',
      points: json['points'] ?? json['patternGeometry']['points'] ?? '',
    );
  }
  List<LatLng> get polylinePoints => MapUtils.decodeGooglePolyline(points);
  // Method to convert a Pattern instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'code': code,
      'directionId': directionId,
      'headsign': headsign,
      'points': points,
    };
  }
}

class PatternStop {
  final String patternCode;
  final String stopId;
  final int stopOrder;

  PatternStop({
    required this.patternCode,
    required this.stopId,
    required this.stopOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'patternCode': patternCode,
      'stopId': stopId,
      'stopOrder': stopOrder,
    };
  }

  factory PatternStop.fromJson(Map<String, dynamic> json) {
    return PatternStop(
      patternCode: json['patternCode'] ?? '',
      stopId: json['stopId'] ?? '',
      stopOrder: json['stopOrder'] ?? 0,
    );
  }
}

class Stoptime {
  final bool realtime;
  final DateTime realtimeDeparture;
  final DateTime scheduledDeparture;

  const Stoptime(
      {required this.realtime,
      required this.realtimeDeparture,
      required this.scheduledDeparture});

  static DateTime _getDate(int departure) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.add(Duration(seconds: departure));
  }

  factory Stoptime.fromJson(Map<String, dynamic> js) {
    return Stoptime(
      realtime: js['realtime'],
      realtimeDeparture: _getDate(js['realtimeDeparture'] as int),
      scheduledDeparture: _getDate(js['scheduledDeparture'] as int),
    );
  }
}
