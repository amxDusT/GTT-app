import 'package:torino_mobility/controllers/loading_controller.dart';
import 'package:torino_mobility/models/gtt/stoptime.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:torino_mobility/models/gtt/pattern.dart';
import 'package:torino_mobility/resources/database.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:get/get.dart';

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

  static void _addRoute(
    Map<String, RouteWithDetails> routesWithDetails, {
    required Route route,
    required Pattern pattern,
    required List<Stoptime> stoptimes,
  }) {
    RouteWithDetails routeWithDetails = RouteWithDetails.fromData(
      route: route,
      stoptimes: stoptimes,
      pattern: pattern,
    );
    routesWithDetails.putIfAbsent(route.gtfsId, () => routeWithDetails);
  }

  static Future<StopWithDetails> decodeJson(
    Map<String, dynamic> json,
    int stopNum,
  ) async {
    Stop stop = (await DatabaseCommands.instance.getStop(stopNum))!;

    Map<String, RouteWithDetails> routesWithDetails = {};
    for (Route route
        in await DatabaseCommands.instance.getRouteFromStop(stop)) {
      _addRoute(
        routesWithDetails,
        route: route,
        pattern: (await DatabaseCommands.instance.getPatterns(route)).first,
        stoptimes: [],
      );
      /* RouteWithDetails routeWithDetails = RouteWithDetails.fromData(
        route: route,
        stoptimes: [],
        pattern: (await DatabaseCommands.instance.getPatterns(route)).first,
      );
      print('routeIds : ${route.gtfsId}');
      routesWithDetails.putIfAbsent(route.gtfsId, () => routeWithDetails); */
    }

    for (var js in (json['stopTimes'] as List)) {
      String patternCode = js['pattern']['code'];
      String routeId =
          '${patternCode.split(':')[0]}:${patternCode.split(':')[1]}';

      Pattern pattern;
      try {
        pattern =
            await DatabaseCommands.instance.getPatternFromCode(patternCode);
      } on StateError {
        // pattern not in db, add it later
        pattern = Pattern.fromJson(js['pattern']);
        Get.find<LoadingController>().loadFromApi();
      }

      if (!routesWithDetails.containsKey(routeId)) {
        _addRoute(
          routesWithDetails,
          route: await DatabaseCommands.instance.getRoute(routeId),
          pattern: pattern,
          stoptimes: [],
        );
      }

      /*
      sometimes the query returns different patterns and stoptimes for the same route
      so we keep the pattern with most stoptimes  
      
      (not anymore)
      ---and add the stoptimes to it
      */
      routesWithDetails.update(routesWithDetails[routeId]!.gtfsId, (route) {
        RouteWithDetails r = routesWithDetails[routeId]!;

        if (r.stoptimes.isEmpty ||
            r.stoptimes.length < js['stoptimes'].length) {
          r.pattern = pattern;
          r.stoptimes.clear();
          r.stoptimes.addAll((js['stoptimes'] as List)
              .map((stoptimeJs) => Stoptime.fromJson(stoptimeJs))
              .toList());
          r.stoptimes.sort(
              (a, b) => a.realtimeDeparture.compareTo(b.realtimeDeparture));
        }

        return r;
      });
    }
    final vehicles = routesWithDetails.values.toList();
    Utils.sort(vehicles);
    vehicles.sort((a, b) {
      if (a.stoptimes.isEmpty && b.stoptimes.isNotEmpty) {
        return 1;
      } else if (a.stoptimes.isNotEmpty && b.stoptimes.isEmpty) {
        return -1;
      }
      return 0;
    });
    return StopWithDetails(
      vehicles: vehicles,
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
  int get hashCode => Object.hash(gtfsId, code, name, lat, lon);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Stop &&
        other.code == code &&
        other.name == name &&
        other.gtfsId == gtfsId &&
        other.lat == lat &&
        other.lon == lon;
  }
}
