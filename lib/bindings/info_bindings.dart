import 'package:torino_mobility/controllers/info_controller.dart';
import 'package:get/get.dart';

class InfoBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InfoController(),
        tag: Get.arguments['fermata'].code.toString());
  }
}
