import 'package:torino_mobility/controllers/home_controller.dart';
import 'package:torino_mobility/controllers/route_list_controller.dart';
import 'package:torino_mobility/controllers/search/home_search_controller.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
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
