import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:latlong2/latlong.dart';

class Travel {
  final DateTime startTime;
  final DateTime endTime;
  final double walkDistance;
  final int duration;
  final List<TravelLegs> legs;
  Travel({
    required this.startTime,
    required this.endTime,
    required this.walkDistance,
    required this.duration,
    required this.legs,
  });

  factory Travel.fromJson(Map<String, dynamic> json) {
    return Travel(
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] * 1000),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime'] * 1000),
      walkDistance: json['walkDistance'],
      duration: json['duration'],
      legs: (json['legs'] as List).map((e) => TravelLegs.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'Travel(startTime: $startTime, endTime: $endTime, walkDistance: $walkDistance, duration: $duration, legs: $legs)';
  }
}

class TravelLegs {
  final bool transitLeg;
  final String points;
  final String mode;
  final int duration;
  final double distance;
  final SimpleAddress from;
  final SimpleAddress to;
  //final Stop? stop;
  final Route? route;
  final String? patternCode;

  TravelLegs({
    required this.transitLeg,
    required this.points,
    required this.mode,
    required this.duration,
    required this.distance,
    required this.from,
    required this.to,
    //this.stop,
    this.route,
    this.patternCode,
  });

  factory TravelLegs.fromJson(Map<String, dynamic> json) {
    return TravelLegs(
      transitLeg: json['transitLeg'],
      points: json['legGeometry']['points'],
      mode: json['mode'],
      duration: (json['duration'] as double).toInt(),
      distance: json['distance'] as double,
      from: SimpleAddress(
        label: json['from']['name'],
        position: LatLng(
          json['from']['lat'],
          json['from']['lon'],
        ),
      ),
      to: SimpleAddress(
        label: json['to']['name'],
        position: LatLng(
          json['to']['lat'],
          json['to']['lon'],
        ),
      ),
      //stop: json['stop'] != null ? Stop.fromJson(json['stop']) : null,
      route: json['route'] != null ? Route.fromJson(json['route']) : null,
      patternCode: json['trip']?['pattern']['code'],
    );
  }
  @override
  String toString() {
    return 'TravelLegs(transitLeg: $transitLeg ,points: $points, mode: $mode, duration: $duration, distance: $distance, from: $from, to: $to, route: $route, patternCode: $patternCode)';
  }
}
