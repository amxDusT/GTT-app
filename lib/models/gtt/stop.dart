import 'dart:ui';

import 'package:flutter_gtt/models/gtt/stoptime.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/models/gtt/pattern.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/storage.dart';

class StopWithDetails extends Stop {
  List<Route> vehicles;
  StopWithDetails({
    required this.vehicles,
    required super.gtfsId,
    required super.code,
    required super.name,
    required super.lat,
    required super.lon,
  });

  static Future<StopWithDetails> decodeJson(
    Map<String, dynamic> json,
    int stopNum,
  ) async {
    Stop stop = (await DatabaseCommands.getStop(stopNum))!;

    Map<String, RouteWithDetails> routesWithDetails = {};
    for (Route route in await DatabaseCommands.getRouteFromStop(stop)) {
      RouteWithDetails routeWithDetails = RouteWithDetails.fromData(
        route: route,
        stoptimes: [],
        pattern: (await DatabaseCommands.getPatterns(route)).first,
      );
      routesWithDetails.putIfAbsent(route.gtfsId, () => routeWithDetails);
    }
    for (var js in (json['stopTimes'] as List)) {
      String patternCode = js['pattern']['code'];
      String routeId =
          '${patternCode.split(':')[0]}:${patternCode.split(':')[1]}';
      Pattern pattern = await DatabaseCommands.getPatternFromCode(patternCode);

      /*
      sometimes the query returns different patterns and stoptimes for the same route
      so we keep the pattern with most stoptimes and add the stoptimes to it
      */
      routesWithDetails.update(routesWithDetails[routeId]!.gtfsId, (route) {
        RouteWithDetails r = routesWithDetails[routeId]!;

        if (r.stoptimes.isEmpty ||
            r.stoptimes.length < js['stoptimes'].length) {
          r.pattern = pattern;
        }

        r.stoptimes.addAll((js['stoptimes'] as List)
            .map((stoptimeJs) => Stoptime.fromJson(stoptimeJs))
            .toList());

        r.stoptimes
            .sort((a, b) => a.realtimeDeparture.compareTo(b.realtimeDeparture));
        return r;
      });
    }
    return StopWithDetails(
      vehicles: routesWithDetails.values.toList(),
      gtfsId: stop.gtfsId,
      code: stop.code,
      name: stop.name,
      lat: stop.lat,
      lon: stop.lon,
    );
  }

  factory StopWithDetails.fromStop({
    required Stop stop,
    List<Route>? vehicles,
  }) {
    return StopWithDetails(
      vehicles: vehicles ?? [],
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
    required super.gtfsId,
    required super.code,
    required super.name,
    required super.lat,
    required super.lon,
  });
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

  @override
  int get hashCode => code.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Stop && other.code == code;
  }
}
