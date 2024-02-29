import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/gtt/route.dart' as gtt;
import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/controllers/settings_controller.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/resources/api/gtt_api.dart';
import 'package:flutter_gtt/resources/api/api_exception.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:get/get.dart';

class InfoController extends GetxController {
  late final Rx<DateTime> lastUpdate;
  final RxBool isLoading = false.obs;
  late Rx<StopWithDetails> fermata;
  final HomeController _homeController = Get.find<HomeController>();
  final RxBool isSaved = false.obs;

  @override
  void onInit() async {
    super.onInit();
    Stop stop = Get.arguments['fermata'];
    //print(stop);
    lastUpdate = DateTime.now().obs;
    fermata = StopWithDetails.fromStop(stop: stop).obs;

    getFermata();
    isSaved.value = (await DatabaseCommands.hasStop(fermata.value));
  }

  // select elements to be displayed in map
  final RxList<gtt.RouteWithDetails> selectedRoutes =
      <gtt.RouteWithDetails>[].obs;
  final RxBool isSelecting = false.obs;

  bool get canShowMap =>
      isSelecting.isFalse ||
      selectedRoutes.isNotEmpty &&
          (Storage.isRouteWithoutPassagesShowing ||
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
          "Puoi selezionare al massimo $maxRoutesInMap veicoli",
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
      Utils.showSnackBar(e.message, title: "Errore ${e.statusCode}");
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
      title: "Errore",
      content: const Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Ooops... Problema nel risolvere la richiesta."),
              Text(
                  "Riprova, o prova ad aggiornare i dati di GTT nelle impostazioni."),
            ],
          ),
        ),
      ),
      textConfirm: "Aggiorna",
      onConfirm: () {
        Get.back();
        Get.put(SettingsController()).resetData();
      },
      textCancel: "Annulla",
    );
  }
}
