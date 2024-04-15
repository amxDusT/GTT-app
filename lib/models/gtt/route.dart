import 'package:flutter_gtt/models/gtt/stoptime.dart';
import 'package:flutter_gtt/models/gtt/pattern.dart';

class RouteWithDetails extends Route {
  final List<Stoptime> stoptimes;
  //TODO: remove alerts => always empty
  final List<String> alerts;
  Pattern pattern;
  RouteWithDetails({
    required super.agencyId,
    required super.shortName,
    required super.longName,
    required super.type,
    required super.desc,
    required super.gtfsId,
    required this.stoptimes,
    required this.alerts,
    required this.pattern,
  });

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
    //print(jsonDecode(json['desc'] ?? ''));
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

  @override
  int get hashCode =>
      Object.hash(gtfsId, agencyId, shortName, longName, type, desc);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Route &&
        other.gtfsId == gtfsId &&
        other.agencyId == agencyId &&
        other.shortName == shortName &&
        other.longName == longName &&
        other.type == type &&
        other.desc == desc;
  }
}
