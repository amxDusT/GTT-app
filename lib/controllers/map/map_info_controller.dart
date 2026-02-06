import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
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
      title: 'Errore',
      content: const Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ooops... Problema nel risolvere la richiesta.'),
              Text(
                  'Riprova, o prova ad aggiornare i dati di GTT nelle impostazioni.'),
            ],
          ),
        ),
      ),
      textConfirm: 'Aggiorna',
      onConfirm: () {
        Get.back();
        Get.put(SettingsController()).resetData();
      },
      textCancel: 'Annulla',
    );
  }
}
