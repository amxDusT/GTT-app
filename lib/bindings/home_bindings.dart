import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/controllers/search/home_search_controller.dart';
import 'package:flutter_gtt/controllers/settings_controller.dart';
import 'package:get/get.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(RouteListController(), permanent: true);
    Get.lazyPut(() => SettingsController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => SearchStopsController());
  }
}
