import 'package:flutter_gtt/controllers/intro/intro_controller.dart';
import 'package:get/get.dart';

class IntroBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => IntroController(),
    );
  }
}
