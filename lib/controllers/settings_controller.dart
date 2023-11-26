import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RouteListController _routeListController =
      Get.find<RouteListController>();

  final _homeController = Get.find<HomeController>();
  Future<void> removeData() async {
    await DatabaseCommands.clearTables();
    _homeController.getStops();
  }

  void resetData() async {
    await removeData();
    await _routeListController.loadFromApi();
    _restoreFavorites();
  }

  void _restoreFavorites() async {
    for (var fermata in _homeController.fermate) {
      DatabaseCommands.insertStop(fermata);
    }
  }
}
