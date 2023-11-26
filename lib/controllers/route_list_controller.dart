import 'package:flutter_gtt/models/gtt_models.dart';
import 'package:flutter_gtt/resources/api.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:get/get.dart';

class RouteListController extends GetxController {
  List<Agency> agencies = [];
  Map<String, List<Route>> routesMap = {};

  Future<void> getAgencies([List<Agency>? agencyValues]) async {
    agencies = agencyValues ?? await DatabaseCommands.agencies;
    update();
  }

  void getRoutes([List<Route>? routeValues]) async {
    List<Route> routes = routeValues ?? await DatabaseCommands.routes;
    routesMap = {};
    for (var route in routes) {
      routesMap.putIfAbsent(route.agencyId, () => []).add(route);
    }
    _sortResult();
    //_sortRoutesMap();
    //print(routesMap.length);
    update();
  }

  /*
    sorts results:
    - priority is vehicle type and if bus starts with number
    - if starts with number, numeric part is compared, otherwise string comparison
  */
  void _sortResult() {
    int extractNumericPart(String str) {
      RegExpMatch? match = RegExp(r'\d+').firstMatch(str);
      if (match != null) {
        return int.parse(match.group(0)!);
      } else {
        return 0;
      }
    }

    bool startWithNumber(String s) {
      return RegExp(r'^[0-9]').hasMatch(s);
    }

    int compareWithNumbers(Route a, Route b) {
      int numA = extractNumericPart(a.shortName);
      int numB = extractNumericPart(b.shortName);
      int compare = numA.compareTo(numB);
      if (compare == 0) {
        return a.shortName.compareTo(b.shortName);
      }
      return compare;
    }

    for (var key in routesMap.keys) {
      routesMap[key]!.sort((a, b) {
        int compareWithType = a.type.compareTo(b.type);
        if (compareWithType != 0) {
          return compareWithType;
        } else if (startWithNumber(a.shortName) &&
            startWithNumber(b.shortName)) {
          return compareWithNumbers(a, b);
        } else if (!startWithNumber(a.shortName) &&
            !startWithNumber(b.shortName)) {
          return a.shortName.compareTo(b.shortName);
        } else {
          return startWithNumber(a.shortName) ? -1 : 1;
        }
      });
    }
  }

  Future<void> loadFromApi() async {
    try {
      List<Agency> agencyList = await Api.getAgencies();
      DatabaseCommands.transaction(agencyList);
      getAgencies(agencyList);
      List<Route> routeValues;
      List<Pattern> patternValues;
      List<Stop> stopValues;
      List<PatternStop> patternStopValues;
      (routeValues, patternValues, stopValues, patternStopValues) =
          await Api.routesByFeed();
      getRoutes(routeValues);
      await DatabaseCommands.transaction(routeValues);
      await DatabaseCommands.transaction(patternValues);
      await DatabaseCommands.transaction(stopValues);
      await DatabaseCommands.transaction(patternStopValues);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
      //print(e.message);
    }
  }
}
