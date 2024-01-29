import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/pages/home_page.dart';
import 'package:flutter_gtt/resources/api.dart';
import 'package:flutter_gtt/testing/testing_page.dart';
import 'package:get/get.dart';

class LoadingController extends GetxController {
  RxBool isShowingMessage = false.obs;
  final bool isFirstTime = Get.arguments?['first-time'] ?? true;
  @override
  void onInit() async {
    super.onInit();
    await checkVersion();
    checkAndLoad();
  }

  Future<void> checkVersion() async {
    bool isDifferent = await Api.checkVersion();
    if (isDifferent) {
      RxBool isDownloading = false.obs;
      //bool isDownloading = false;
      await Get.defaultDialog(
        barrierDismissible: false,
        title: 'Nuova versione disponibile',
        content: Column(
          children: [
            const Text('È disponibile una nuova versione dell\'app'),
            const SizedBox(height: 10),
            Obx(
              () => Visibility(
                visible: isDownloading.value,
                child: const LinearProgressIndicator(),
              ),
            ),
          ],
        ),
        middleText: 'Scarica la nuova versione',
        textConfirm: 'Scarica',
        cancel: TextButton(
          style: TextButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Get.theme.colorScheme.secondary,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          onPressed: () {
            if (isDownloading.value) return;
            Get.back();
          },
          child: Text(
            'Annulla',
            style: TextStyle(color: Get.theme.colorScheme.secondary),
          ),
        ),
        onConfirm: () async {
          if (isDownloading.value) return;
          isDownloading.value = true;
          await Api.downloadNewVersion();
          Get.back();
        },
      );
    }
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
    //Get.off(() => Testing());
  }
}
