import 'package:flutter_gtt/controllers/map/map_controller.dart';
import 'package:flutter_gtt/controllers/map/map_info_controller.dart';
import 'package:flutter_gtt/controllers/map/map_location.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:get/get.dart';

class MapPageBindings extends Bindings {
  @override
  void dependencies() {
    var key =
        Get.arguments['vehicles'].map((Route route) => route.gtfsId).join();
    Get.put(MapLocation(), permanent: true);
    Get.put(MapPageController(), tag: key);
  }
}
