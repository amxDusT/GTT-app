import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/gtt_models.dart' as gtt;
import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/controllers/settings_controller.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/resources/api.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:get/get.dart';

class InfoController extends GetxController {
  final RxBool isBacking = false.obs;
  late final Rx<DateTime> lastUpdate;
  final RxBool isLoading = false.obs;
  late Rx<StopWithDetails> fermata;
  late RxString fermataName;
  final HomeController _homeController = Get.find<HomeController>();
  final RxBool isSaved = false.obs;

  // select elements to be displayed in map
  final RxList<gtt.RouteWithDetails> selectedRoutes =
      <gtt.RouteWithDetails>[].obs;
  final RxBool isSelecting = false.obs;

  bool get canShowMap =>
      isSelecting.isTrue &&
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
        Get
          ..closeAllSnackbars()
          ..snackbar("Attenzione",
              "Puoi selezionare al massimo $maxRoutesInMap veicoli");
        return;
      }
      selectedRoutes.add(route);
    }

    if (selectedRoutes.isEmpty) {
      isSelecting.value = false;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    Stop stop = Get.arguments['fermata'];
    //print(stop);
    fermataName = stop.name.obs;
    lastUpdate = DateTime.now().obs;
    fermata = StopWithDetails.fromStop(stop: stop).obs;

    getFermata();
    isSaved.value = (await DatabaseCommands.hasStop(fermata.value));
  }

  void switchAddDeleteFermata() async {
    if (isSaved.isTrue) {
      DatabaseCommands.deleteStop(fermata.value);
    } else {
      DatabaseCommands.insertStop(fermata.value);
    }
    _homeController.getStops();
    isSaved.value = !isSaved.value;
  }

  Future<void> getFermata() async {
    isLoading.value = true;
    try {
      final StopWithDetails newFermata = await Api.getStop(fermata.value.code);
      lastUpdate.value = DateTime.now();
      fermata = newFermata.obs;
      fermataName.value = fermata.value.name;
    } on ApiException catch (e) {
      Get.snackbar("Errore ${e.statusCode}", e.message);
    } on Error {
      Get.defaultDialog(
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
                    "Riprova, o prova a resettare i dati di GTT nelle impostazioni."),
              ],
            ),
          ),
        ),
        textConfirm: "Resetta",
        onConfirm: () {
          Get.back();
          Get.put(SettingsController()).resetData();
        },
        textCancel: "Annulla",
      );
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
