import 'package:flutter_gtt/models/gtt/agency.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:get/get.dart';

class RouteListController extends GetxController {
  List<Agency> agencies = [];
  Map<String, List<Route>> routesMap = {};
  List<Route> favorites = [];
  Future<void> getFavorites() async {
    //favorites.clear();
    favorites = await DatabaseCommands.instance.favoriteRoutes;
    //favorites.addAll(await DatabaseCommands.instance.favoriteRoutes);
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
      DatabaseCommands.instance.removeFavoriteRoute(route);
    } else {
      favorites.add(route);
      DatabaseCommands.instance.addFavoriteRoute(route);
    }
    update();
  }

  Future<void> getAgencies([List<Agency>? agencyValues]) async {
    agencies = agencyValues ?? await DatabaseCommands.instance.agencies;
    _sortAgencies();
    update();
  }

  void getRoutes([List<Route>? routeValues]) async {
    List<Route> routes = routeValues ?? await DatabaseCommands.instance.routes;
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
    for (var key in routesMap.keys) {
      Utils.sort(routesMap[key]!);
    }
  }
}
