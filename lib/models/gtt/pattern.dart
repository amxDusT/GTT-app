import 'package:torino_mobility/resources/utils/map_utils.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pattern &&
        other.routeId == routeId &&
        other.code == code &&
        other.directionId == directionId &&
        other.headsign == headsign &&
        other.points == points;
  }

  @override
  int get hashCode => Object.hash(routeId, code, directionId, headsign, points);
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatternStop &&
        other.patternCode == patternCode &&
        other.stopId == stopId &&
        other.stopOrder == stopOrder;
  }

  @override
  int get hashCode => Object.hash(patternCode, stopId, stopOrder);
}
