import 'package:torino_mobility/models/gtt/agency.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:torino_mobility/resources/database.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:get/get.dart';

enum RouteFilter { all, favorites, tram, bus }

class RouteListController extends GetxController {
  List<Agency> agencies = [];
  Map<String, List<Route>> routesMap = {};
  List<Route> favorites = [];
  RouteFilter activeFilter = RouteFilter.all;

  List<Route> get filteredRoutes {
    final all = routesMap.values.expand((r) => r).toList();
    Utils.sort(all);
    switch (activeFilter) {
      case RouteFilter.all:
        return all;
      case RouteFilter.favorites:
        return favorites;
      case RouteFilter.tram:
        return all.where((r) => r.type == 0).toList();
      case RouteFilter.bus:
        return all.where((r) => r.type == 3).toList();
    }
  }

  void setFilter(RouteFilter filter) {
    if (activeFilter == filter) return;
    activeFilter = filter;
    update();
  }

  Future<void> getFavorites() async {
    favorites = await DatabaseCommands.instance.favoriteRoutes;
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
      DatabaseCommands.instance.addFavoriteRoute(route);
      if (route is RouteWithDetails) {
        getFavorites();
      } else {
        favorites.add(route);
      }
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
