import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/pages/home_page.dart';
import 'package:get/get.dart';

class LoadingController extends GetxController {
  RxBool isShowingMessage = false.obs;
  final bool isFirstTime = Get.arguments?['first-time'] ?? true;
  @override
  void onInit() {
    super.onInit();
    checkAndLoad();
  }

  void checkAndLoad() async {
    final RouteListController routeListController;
    routeListController = isFirstTime
        ? Get.put(RouteListController())
        : Get.find<RouteListController>();
    await routeListController.getAgencies();
    Duration duration = const Duration(milliseconds: 1000);
    if (routeListController.agencies.isEmpty) {
      isShowingMessage.value = true;
      await routeListController.loadFromApi();
      duration = const Duration(milliseconds: 1);
    }
    await Future.delayed(duration);
    Get.off(() => HomePage());
  }
}
