import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/controllers/loading_controller.dart';
import 'package:flutter_gtt/pages/loading_page.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsController extends GetxController {
  final String betaFeatures = '''
  - mappa default senza tratte
  - importa preferiti da backup locale
  - map api da mapbox invece di openstreetmap
  - colori personalizzati per le fermate preferite
  - posizione utente con direzione (funziona male)
  ''';
  final _homeController = Get.find<HomeController>();
  final RxBool showBetaFeatures = Storage.showBetaFeatures.obs;
  final RxBool showSecondsInUpdates = Storage.showSecondsInUpdates.obs;
  final RxBool isFermataShowing = Storage.isFermataShowing.obs;
  final RxBool isRouteWithoutPassagesShowing =
      Storage.isRouteWithoutPassagesShowing.obs;

  final RxBool isFavoritesRoutesShowing = Storage.isFavoritesRoutesShowing.obs;

  final RxString version = ''.obs;

  @override
  void onInit() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    super.onInit();
  }

  void switchFermataShowing() {
    isFermataShowing.toggle();
    Storage.setParam(
        StorageParam.fermataMap, isFermataShowing.value.toString());
  }

  void switchRouteWithoutPassagesShowing() {
    isRouteWithoutPassagesShowing.toggle();
    Storage.setParam(StorageParam.routeWithoutPassagesMap,
        isRouteWithoutPassagesShowing.value.toString());
  }

  void switchShowSecondsInUpdates() {
    showSecondsInUpdates.toggle();
    Storage.setParam(StorageParam.showSecondsInUpdates,
        showSecondsInUpdates.value.toString());
  }

  void switchFavoritesRoutesShowing() {
    isFavoritesRoutesShowing.toggle();
    Storage.setParam(StorageParam.isFavoritesRoutesShowing,
        isFavoritesRoutesShowing.value.toString());
  }

  void switchBetaFeatures() {
    showBetaFeatures.toggle();
    Storage.setParam(
        StorageParam.showBetaFeatures, showBetaFeatures.value.toString());
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

  Future<void> exportFavorites() async {
    String jsonResult = await DatabaseCommands.exportFavorites;

    Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
    File file = File('${downloadsDirectory.path}/gtt_favorites.json');
    await file.writeAsString(jsonResult, mode: FileMode.writeOnly, flush: true);
    Utils.showSnackBar(
      'Salvato in ${file.path}',
    );
  }

  Future<void> importFavorites() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Seleziona il file da importare',
      initialDirectory: '/storage/emulated/0/Download',
      allowCompression: false,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null) {
      //Utils.showSnackBar('Nessun file selezionato');
      return;
    }

    File file = File(result.files.single.path!);
    String jsonResult = await file.readAsString();
    List<dynamic> jsonMap = json.decode(jsonResult);
    await DatabaseCommands.importFavorites(jsonMap);
    _homeController.getStops();
  }

  void infoApp() {
    Get.defaultDialog(
      title: 'Informazioni app',
      textCancel: 'Chiudi',
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

  void betaFeaturesInfo() {
    Get.defaultDialog(
      title: 'Beta features',
      textCancel: 'Chiudi',
      content: Column(
        children: [
          const Text('Funzionalità in fase di test:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 150,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(betaFeatures),
            ),
          ),
          const Text(
              'ATTENZIONE! Queste funzionalità non sono ancora completamente testate e potrebbero non funzionare correttamente.',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
