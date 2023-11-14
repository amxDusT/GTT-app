import 'package:flutter_gtt/resources/utils/maps.dart';
import 'package:latlong2/latlong.dart';

class ResponseId {
  final String id;
  const ResponseId({required this.id});
  //$result->data->stop->id;
  factory ResponseId.fromJson(Map<String, dynamic> json) {
    return ResponseId(id: json['data']['stop']['id'] ?? -1);
  }
}

class Stoptime {
  final bool realtime;
  final DateTime realtimeDeparture;
  final DateTime scheduledDeparture;

  Stoptime(
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

class Vehicle {
  final String patternCode;
  final String shortName;
  final String longName;
  final List<String> alerts;
  final List<Stoptime> stoptimes;
  final int directionId;
  const Vehicle({
    required this.patternCode,
    required this.shortName,
    required this.longName,
    required this.stoptimes,
    required this.alerts,
    required this.directionId,
  });
  factory Vehicle.empty() {
    return const Vehicle(
      patternCode: '',
      shortName: '',
      longName: '',
      stoptimes: [],
      alerts: [],
      directionId: 0,
    );
  }
  factory Vehicle.fromJson(Map<String, dynamic> js) {
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
  }
}

class Fermata {
  final String nome;
  String? descrizione;
  final double latitude;
  final double longitude;
  final int stopNum;
  final List<Vehicle> vehicles;

  Fermata({
    required this.stopNum,
    required this.nome,
    this.descrizione,
    required this.latitude,
    required this.longitude,
    required this.vehicles,
  });
  factory Fermata.empty(int stopNum) {
    return Fermata(
      stopNum: stopNum,
      nome: '',
      latitude: 0.0,
      longitude: 0.0,
      vehicles: [],
    );
  }

  factory Fermata.fromJson(Map<String, dynamic> js, int stopNum) {
    return Fermata(
      stopNum: stopNum,
      nome: js['name'],
      latitude: js['lat'] as double,
      longitude: js['lon'] as double,
      vehicles: ((js['stopTimes'] ?? []) as List)
          .map((jsData) => Vehicle.fromJson(jsData))
          .toList(),
    );
  }

  Map<String, dynamic> toDbMap() => {
        'stopNum': stopNum,
        'nome': nome,
        'descrizione': descrizione,
        'latitude': latitude,
        'longitude': longitude,
        'date': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

  @override
  String toString() {
    return '$stopNum - $nome';
  }
}

class PatternDetails {
  final String code;
  final String headsign;
  final Vehicle vehicle;
  late final List<LatLng> polyline;
  final List<LatLng> stopPoints;
  final List<Fermata> fermate;
  PatternDetails({
    required this.headsign,
    required this.code,
    required this.vehicle,
    String? encodedPolyline,
    List<LatLng>? polyline,
    required this.stopPoints,
    required this.fermate,
  }) {
    assert(encodedPolyline != null || polyline != null);
    if (encodedPolyline != null) {
      this.polyline = MapUtils.decodeGooglePolyline(encodedPolyline);
    } else {
      this.polyline = polyline!;
    }
  }
  PatternDetails copyWith({Vehicle? vehicle}) {
    return PatternDetails(
        headsign: headsign,
        code: code,
        vehicle: vehicle ?? this.vehicle,
        polyline: polyline,
        stopPoints: stopPoints,
        fermate: fermate);
  }

  factory PatternDetails.empty() {
    return PatternDetails(
      headsign: '',
      code: '',
      vehicle: Vehicle.empty(),
      polyline: [],
      stopPoints: [],
      fermate: [],
    );
  }
  factory PatternDetails.fromJson(Map<String, dynamic> js) {
    return PatternDetails(
      headsign: js['pattern']['headsign'],
      code: js['pattern']['code'],
      vehicle: Vehicle.fromJson(js),
      encodedPolyline: js['pattern']['patternGeometry']['points'],
      stopPoints: (js['pattern']['stops'] as List)
          .map((jsData) =>
              LatLng(jsData['lat'] as double, jsData['lon'] as double))
          .toList(),
      fermate: (js['pattern']['stops'] as List)
          .map((jsData) => Fermata.fromJson(jsData, int.parse(jsData['code'])))
          .toList(),
    );
  }
}

class MqttData {
  // [lat, lon, degrees, speed?, tripId, direction, isFull]
  final LatLng position;
  final int heading;
  final int? speed;
  final int tripId;
  final int direction;
  final bool? isFull;
  final int? nextStop;
  final int vehicleNum;
  MqttData({
    required this.vehicleNum,
    required this.position,
    required this.heading,
    required this.tripId,
    this.speed,
    required this.direction,
    this.isFull,
    this.nextStop,
  });
  MqttData copyWith({LatLng? position}) {
    return MqttData(
      vehicleNum: vehicleNum,
      position: position ?? this.position,
      heading: heading,
      tripId: tripId,
      direction: direction,
    );
  }

  factory MqttData.fromList(List<dynamic> list, int vehicleNum) {
    return MqttData(
      vehicleNum: vehicleNum,
      position: LatLng(list[0] as double, list[1] as double),
      heading: list[2] as int,
      speed: list[3] as int?,
      tripId: list[4],
      direction: list[5] as int? ?? 2,
      isFull: list.length > 7 ? list[7] : null,
      nextStop: list[6] as int?,
    );
  }
}
/*
{
  "data": {
    "stop": {
      "name",
      "desc",
      "lat",
      "lon",
      "stopTimes": [
        {
          "pattern": {
            "route": {
              "shortName",
              "longName",
              "alerts": []
            }
          },
          "stoptimes": [
            {
              "realtimeState"
              "realtimeDeparture"
              "scheduledDeparture"
              "realtimeArrival"
              "scheduledArrival"
              "realtime"
            }
          ]
        }
      ]
    }
  }
}

*/