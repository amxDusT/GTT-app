import 'package:flutter_gtt/controllers/map/map_global_controller.dart';
import 'package:get/get.dart';

import '../controllers/map/map_location.dart';

class MapGlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(MapLocation(), permanent: true);
    Get.lazyPut<MapGlobalController>(() => MapGlobalController());
  }
}
