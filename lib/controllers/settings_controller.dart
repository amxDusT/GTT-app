import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/controllers/loading_controller.dart';
import 'package:flutter_gtt/pages/loading_page.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsController extends GetxController {
  final _homeController = Get.find<HomeController>();

  final RxBool showSecondsInUpdates = Storage.showSecondsInUpdates.obs;
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

  void switchShowSecondsInUpdates() {
    showSecondsInUpdates.value = !showSecondsInUpdates.value;
    Storage.setParam(StorageParam.showSecondsInUpdates,
        showSecondsInUpdates.value.toString());
  }

  void resetData() async {
    Get.offAll(() => LoadingPage(), arguments: {'first-time': false});
    Get.find<LoadingController>().resetData();
    _restoreFavorites();
  }

  void _restoreFavorites() async {
    for (var fermata in _homeController.fermate) {
      DatabaseCommands.insertStop(fermata);
    }
  }

  void infoApp() {
    Get.defaultDialog(
      title: 'Informazioni app',
      content: Column(
        children: [
          Text('Versione: $version'),
          const Text('Sviluppato da: Kevin Kolaveri'),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Github: '),
              InkWell(
                onTap: () async {
                  String url = 'https://github.com/amxDusT/GTT-app/';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    throw 'Could not open the link.';
                  }
                },
                child: const Text(
                  '@amxDusT',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
