import 'package:flutter/material.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/models/gtt/route.dart' as gtt;
import 'package:torino_mobility/controllers/home_controller.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/resources/api/gtt_api.dart';
import 'package:torino_mobility/exceptions/api_exception.dart';
import 'package:torino_mobility/resources/database.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:get/get.dart';

class InfoController extends GetxController {
  late final Rx<DateTime> lastUpdate;
  final RxBool isLoading = false.obs;
  late Rx<StopWithDetails> fermata;
  final HomeController _homeController = Get.find();
  final RxBool isSaved = false.obs;

  @override
  void onInit() async {
    super.onInit();
    Stop stop = Get.arguments['fermata'];
    //print(stop);
    lastUpdate = DateTime.now().obs;
    fermata = StopWithDetails.fromStop(stop: stop).obs;

    getFermata();
    isSaved.value = (await DatabaseCommands.instance.hasStop(fermata.value));
  }

  // select elements to be displayed in map
  final RxList<gtt.RouteWithDetails> selectedRoutes =
      <gtt.RouteWithDetails>[].obs;
  final RxBool isSelecting = false.obs;

  bool get canShowMap =>
      isSelecting.isFalse ||
      selectedRoutes.isNotEmpty &&
          (Storage.instance.isRouteWithoutPassagesShowing ||
              selectedRoutes.any((route) => route.stoptimes.isNotEmpty));
  void onLongPress(gtt.RouteWithDetails route) {
    isSelecting.value = true;
    selectedRoutes.add(route);
  }

  void switchSelecting() {
    isSelecting.value = !isSelecting.value;
    if (!isSelecting.value) {
      selectedRoutes.clear();
    }
  }

  void onSelectedClick(gtt.RouteWithDetails route) {
    if (selectedRoutes.contains(route)) {
      selectedRoutes.remove(route);
    } else {
      if (selectedRoutes.length >= maxRoutesInMap) {
        Utils.showSnackBar(
          'Puoi selezionare al massimo $maxRoutesInMap veicoli',
          //title: "Attenzione",
          closePrevious: true,
        );
        return;
      }
      selectedRoutes.add(route);
    }

    if (selectedRoutes.isEmpty) {
      isSelecting.value = false;
    }
  }

  void switchAddDeleteFermata() async {
    _homeController.switchAddDeleteFermata(fermata.value);
    isSaved.toggle();
  }

  Future<void> getFermata() async {
    isLoading.value = true;
    try {
      final StopWithDetails newFermata =
          await GttApi.getStop(fermata.value.code);
      lastUpdate.value = DateTime.now();
      fermata = newFermata.obs;
    } on ApiException catch (e) {
      Utils.showSnackBar(e.message, title: 'Errore ${e.statusCode}');
    } on Error {
      // probably related to GTT data not updated
      showErrorPopup();
    } finally {
      isLoading.value = false;
      update();
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
