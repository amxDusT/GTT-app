import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/controllers/map/map_location.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:get/get.dart';

class MapPageBindings extends Bindings {
  @override
  void dependencies() {
    var key =
        Get.arguments['vehicles'].map((Route route) => route.gtfsId).join();

    Get.put(MapLocation(), permanent: true);

    Get.create(() => MapPageController(), tag: key);
  }
}
