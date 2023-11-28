import 'dart:ui';

import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/storage.dart';
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

class StopWithDetails extends Stop {
  List<RouteWithDetails> vehicles;
  StopWithDetails({
    required this.vehicles,
    required gtfsId,
    required code,
    required name,
    required lat,
    required lon,
  }) : super(
          gtfsId: gtfsId,
          code: code,
          name: name,
          lat: lat,
          lon: lon,
        );

  static Future<StopWithDetails> decodeJson(
    Map<String, dynamic> json,
    int stopNum,
  ) async {
    Stop stop = (await DatabaseCommands.getStop(stopNum))!;
    Map<String, Route> routesMapId = {
      for (var route in await DatabaseCommands.getRouteFromStop(stop))
        route.gtfsId: route
    };
    List<RouteWithDetails> routesWithDetails = [];
    for (var js in (json['stopTimes'] as List)) {
      String patternCode = js['pattern']['code'];
      String routeId =
          '${patternCode.split(':')[0]}:${patternCode.split(':')[1]}';
      Pattern pattern = await DatabaseCommands.getPatternFromCode(patternCode);
      routesWithDetails.add(
        RouteWithDetails.fromData(
          route: routesMapId[routeId]!,
          stoptimes: (js['stoptimes'] as List)
              .map((stoptimeJs) => Stoptime.fromJson(stoptimeJs))
              .toList(),
          pattern: pattern,
        ),
      );
    }
    return StopWithDetails(
      vehicles: routesWithDetails,
      gtfsId: stop.gtfsId,
      code: stop.code,
      name: stop.name,
      lat: stop.lat,
      lon: stop.lon,
    );
  }

  factory StopWithDetails.fromStop({
    required Stop stop,
  }) {
    return StopWithDetails(
      vehicles: [],
      gtfsId: stop.gtfsId,
      code: stop.code,
      name: stop.name,
      lat: stop.lat,
      lon: stop.lon,
    );
  }
  factory StopWithDetails.fromJson(Map<String, dynamic> json) {
    return StopWithDetails(
      vehicles: (json['vehicles'] as List<dynamic>)
          .map((vehicle) => RouteWithDetails.fromJson(vehicle))
          .toList(),
      gtfsId: json['gtfsId'],
      code: json['code'],
      name: json['name'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}

class FavStop extends Stop {
  final DateTime dateTime;
  final Color color;
  final String? descrizione;
  FavStop({
    required this.dateTime,
    required this.color,
    this.descrizione,
    required gtfsId,
    required code,
    required name,
    required lat,
    required lon,
  }) : super(
          code: code,
          gtfsId: gtfsId,
          name: name,
          lat: lat,
          lon: lon,
        );
  factory FavStop.fromStop({
    required Stop stop,
    DateTime? dateTime,
    Color? color,
    String? descrizione,
  }) {
    return FavStop(
      descrizione: descrizione,
      dateTime: dateTime ?? DateTime.now(),
      color: color ?? Storage.chosenColor,
      gtfsId: stop.gtfsId,
      code: stop.code,
      name: stop.name,
      lat: stop.lat,
      lon: stop.lon,
    );
  }
  Map<String, dynamic> toDbMap() {
    return {
      'stopId': gtfsId,
      'date': dateTime.millisecondsSinceEpoch ~/ 1000,
      'color': Storage.colorToString(color),
      'descrizione': descrizione
    };
  }

  factory FavStop.fromJson(Map<String, dynamic> js) {
    return FavStop.fromStop(
      stop: Stop.fromJson(js),
      dateTime: DateTime.fromMillisecondsSinceEpoch((js['date'] as int) * 1000),
      color: Storage.stringToColor(js['color'])!,
      descrizione: js['descrizione'],
    );
  }

  FavStop copyWith({Color? color, String? descrizione, DateTime? dateTime}) {
    return FavStop(
      descrizione: descrizione ?? this.descrizione,
      dateTime: dateTime ?? this.dateTime,
      color: color ?? this.color,
      gtfsId: gtfsId,
      code: code,
      name: name,
      lat: lat,
      lon: lon,
    );
  }
}

class Stop {
  final String gtfsId;
  final int code;
  final String name;
  final double lat;
  final double lon;

  Stop({
    required this.gtfsId,
    required this.code,
    required this.name,
    required this.lat,
    required this.lon,
  });
  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      gtfsId: json['gtfsId'],
      name: json['name'],
      code: int.parse(json['code']?.toString() ?? json['gtfsId'].split(':')[1]),
      lat: (json['lat']).toDouble(),
      lon: (json['lon']).toDouble(),
    );
  }

  // Method to convert a Stop instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'gtfsId': gtfsId,
      'code': code,
      'name': name,
      'lat': lat,
      'lon': lon,
    };
  }

  @override
  String toString() {
    return '$code - $name';
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

class FavoriteStop {
  final String nome;
  final String? descrizione;
  final double latitude;
  final double longitude;
  final int stopNum;
  final List<RouteWithDetails> vehicles;
  final DateTime dateTime;
  final Color color;
  const FavoriteStop({
    required this.stopNum,
    required this.nome,
    this.descrizione,
    required this.latitude,
    required this.longitude,
    required this.vehicles,
    required this.dateTime,
    required this.color,
  });
  factory FavoriteStop.empty(int stopNum) {
    return FavoriteStop(
      stopNum: stopNum,
      nome: '',
      latitude: 0.0,
      longitude: 0.0,
      vehicles: const [],
      dateTime: DateTime.now(),
      color: Storage.chosenColor,
    );
  }

  FavoriteStop copyWith({
    String? descrizione,
    DateTime? dateTime,
    List<RouteWithDetails>? vehicles,
    Color? color,
  }) {
    return FavoriteStop(
        stopNum: stopNum,
        nome: nome,
        latitude: latitude,
        longitude: longitude,
        vehicles: vehicles ?? this.vehicles,
        dateTime: dateTime ?? this.dateTime,
        descrizione: descrizione ?? this.descrizione,
        color: color ?? this.color);
  }

  factory FavoriteStop.fromJson(Map<String, dynamic> js, int stopNum) {
    return FavoriteStop(
      stopNum: stopNum,
      nome: js['name'],
      latitude: js['lat'] as double,
      longitude: js['lon'] as double,
      vehicles: ((js['stopTimes'] ?? []) as List)
          .map((jsData) => RouteWithDetails.fromJson(jsData))
          .toList(),
      dateTime: DateTime.now(),
      color: Storage.chosenColor,
    );
  }

  Map<String, dynamic> toDbMap() => {
        'stopNum': stopNum,
        'nome': nome,
        'descrizione': descrizione,
        'latitude': latitude,
        'longitude': longitude,
        'date': dateTime.millisecondsSinceEpoch ~/ 1000,
        'color': Storage.colorToString(color),
      };

  @override
  String toString() {
    return '$stopNum - $nome';
  }
}
