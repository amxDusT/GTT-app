import 'package:flutter_gtt/controllers/map/map_address.dart';
import 'package:flutter_gtt/controllers/map/map_animation.dart';
import 'package:flutter_gtt/controllers/map/map_global_controller.dart';
import 'package:flutter_gtt/controllers/map/map_travel_controller.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:get/get.dart';

import '../controllers/map/map_location.dart';

class MapGlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(MapLocation(), permanent: true);
    var globalController = MapGlobalController();
    Get.put(
      MapAnimation(
          controller: globalController.mapController, vsync: globalController),
      tag: 'globalAnimation',
    );
    Get.put(MapAddressController());
    Get.put(MapSearchController());
    Get.put(globalController);
    Get.lazyPut(() => MapTravelController());
    //Get.lazyPut(() => TravelAppBarController());
  }
}
