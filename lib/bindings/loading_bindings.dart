import 'package:torino_mobility/controllers/app_status_controller.dart';
import 'package:torino_mobility/controllers/loading_controller.dart';
import 'package:get/get.dart';

class LoadingBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(
      LoadingController(),
      permanent: true,
    );
    Get.put(
      AppStatusController(),
      permanent: true,
    );
  }
}
