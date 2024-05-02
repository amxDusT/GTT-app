import 'package:flutter_gtt/controllers/loading_controller.dart';
import 'package:get/get.dart';

class LoadingBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(
      LoadingController(),
      permanent: true,
    );
  }
}
