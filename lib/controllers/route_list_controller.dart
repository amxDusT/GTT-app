import 'package:flutter_gtt/models/gtt/agency.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:get/get.dart';

class RouteListController extends GetxController {
  List<Agency> agencies = [];
  Map<String, List<Route>> routesMap = {};
  List<Route> favorites = [];
  Future<void> getFavorites() async {
    favorites.clear();
    favorites.addAll(await DatabaseCommands.favoriteRoutes);
    update();
  }

  @override
  void onInit() {
    getAgencies();
    getRoutes();
    getFavorites();
    super.onInit();
  }

  void toggleFavorite(Route route) async {
    if (favorites.contains(route)) {
      favorites.remove(route);
      DatabaseCommands.removeFavoriteRoute(route);
    } else {
      favorites.add(route);
      DatabaseCommands.addFavoriteRoute(route);
    }
    update();
  }

  Future<void> getAgencies([List<Agency>? agencyValues]) async {
    agencies = agencyValues ?? await DatabaseCommands.agencies;
    _sortAgencies();
    update();
  }

  void getRoutes([List<Route>? routeValues]) async {
    List<Route> routes = routeValues ?? await DatabaseCommands.routes;
    routesMap = {};
    for (var route in routes) {
      routesMap.putIfAbsent(route.agencyId, () => []).add(route);
    }
    _sortResult();
    update();
  }

  void _sortAgencies() {
    agencies.sort((a, b) => b.name.compareTo(a.name));
  }

  /*
    sorts results:
    - priority is vehicle type and if bus starts with number
    - if starts with number (or 'M', to include M1s/M1), numeric part is compared, otherwise string comparison
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

    bool startWithNumberOrM(String s) {
      return RegExp(r'^[0-9M]').hasMatch(s);
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
        // compare by type
        int compareWithType = a.type.compareTo(b.type);
        if (compareWithType != 0) {
          return compareWithType;
          // compare by number
        } else if (startWithNumberOrM(a.shortName) &&
            startWithNumberOrM(b.shortName)) {
          return compareWithNumbers(a, b);
          // compare by name
        } else if (!startWithNumberOrM(a.shortName) &&
            !startWithNumberOrM(b.shortName)) {
          return a.shortName.compareTo(b.shortName);
        } else {
          return startWithNumberOrM(a.shortName) ? -1 : 1;
        }
      });
    }
  }
}
