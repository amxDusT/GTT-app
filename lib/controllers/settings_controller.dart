import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/controllers/loading_controller.dart';
import 'package:flutter_gtt/pages/loading_page.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsController extends GetxController {
  final _homeController = Get.find<HomeController>();

  final RxBool isFermataShowing = Storage.isFermataShowing.obs;
  final RxBool isRouteWithoutPassagesShowing =
      Storage.isRouteWithoutPassagesShowing.obs;

  final RxString version = ''.obs;

  @override
  void onInit() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    super.onInit();
  }

  void switchFermataShowing() {
    isFermataShowing.value = !isFermataShowing.value;
    Storage.setParam(
        StorageParam.fermataMap, isFermataShowing.value.toString());
  }

  void switchRouteWithoutPassagesShowing() {
    isRouteWithoutPassagesShowing.value = !isRouteWithoutPassagesShowing.value;
    Storage.setParam(StorageParam.routeWithoutPassagesMap,
        isRouteWithoutPassagesShowing.value.toString());
  }

  void resetData() async {
    await DatabaseCommands.clearTables();

    Get.offAll(() => LoadingPage(), arguments: {'first-time': false});
    Get.find<LoadingController>().checkAndLoad();
    //await _routeListController.loadFromApi();
    _restoreFavorites();
  }

  void _restoreFavorites() async {
    for (var fermata in _homeController.fermate) {
      DatabaseCommands.insertStop(fermata);
    }
  }
}
