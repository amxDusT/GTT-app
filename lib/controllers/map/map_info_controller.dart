import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/resources/api/gtt_api.dart';
import 'package:get/get.dart';

class MapInfoController extends GetxController {
  late Rx<StopWithDetails> fermata;
  final RxBool isLoading = true.obs;

  List<String> get routesNames {
    return fermata.value.vehicles.map((route) => route.shortName).toList();
  }

  Future<void> getFermata(int fermataNum) async {
    isLoading.value = true;
    try {
      //if (kDebugMode) await Future.delayed(const Duration(seconds: 10));
      fermata = (await GttApi.getStop(fermataNum)).obs;
    } catch (e) {
      showErrorPopup();
    } finally {
      isLoading.value = false;
    }
  }

  void showErrorPopup() async {
    await Get.defaultDialog(
      title: l10n.errorTitle,
      content: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.genericErrorMessage),
              Text(l10n.retryOrUpdateDataMessage),
            ],
          ),
        ),
      ),
      textConfirm: l10n.update,
      onConfirm: () {
        Get.back();
        Get.put(SettingsController()).resetData();
      },
      textCancel: l10n.cancel,
    );
  }
}
