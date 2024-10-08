import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/controllers/loading_controller.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsController extends GetxController {
  final String betaFeatures = '''
  - mappa default senza tratte
  - map api da mapbox invece di openstreetmap
  ''';
  final RxBool showBetaFeatures = Storage.instance.showBetaFeatures.obs;
  final RxBool showSecondsInUpdates = Storage.instance.showSecondsInUpdates.obs;
  final RxBool isFermataShowing = Storage.instance.isFermataShowing.obs;
  final RxBool isRouteWithoutPassagesShowing =
      Storage.instance.isRouteWithoutPassagesShowing.obs;

  final RxBool isFavoritesRoutesShowing =
      Storage.instance.isFavoritesRoutesShowing.obs;
  final RxBool isDarkMode = Storage.instance.isDarkMode.obs;
  final RxBool isInitialHighlighted = Storage.instance.isInitialHighlighted.obs;
  final RxString version = ''.obs;

  @override
  void onInit() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    if (isDarkMode.value != Get.isDarkMode) {
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    }
    super.onInit();
  }

  void switchDarkMode() {
    isDarkMode.toggle();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    Storage.instance.setBool(StorageParam.isDarkMode, isDarkMode.value);
  }

  void switchFermataShowing() {
    isFermataShowing.toggle();
    Storage.instance.setBool(StorageParam.fermataMap, isFermataShowing.value);
  }

  void switchRouteWithoutPassagesShowing() {
    isRouteWithoutPassagesShowing.toggle();
    Storage.instance.setBool(StorageParam.routeWithoutPassagesMap,
        isRouteWithoutPassagesShowing.value);
  }

  void switchShowSecondsInUpdates() {
    showSecondsInUpdates.toggle();
    Storage.instance
        .setBool(StorageParam.showSecondsInUpdates, showSecondsInUpdates.value);
  }

  void switchFavoritesRoutesShowing() {
    isFavoritesRoutesShowing.toggle();
    Storage.instance.setBool(
        StorageParam.isFavoritesRoutesShowing, isFavoritesRoutesShowing.value);
  }

  void switchBetaFeatures() {
    showBetaFeatures.toggle();
    Storage.instance
        .setBool(StorageParam.showBetaFeatures, showBetaFeatures.value);
  }

  void switchInitialHighlighted() {
    isInitialHighlighted.toggle();
    Storage.instance
        .setBool(StorageParam.isInitialHighlighted, isInitialHighlighted.value);
  }

  void resetData() async {
    Get.until((route) => Get.currentRoute == '/home');
    Get.find<LoadingController>().loadFromApi();
  }

  Future<void> exportFavorites() async {
    String jsonResult = await DatabaseCommands.instance.exportFavorites;

    Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
    File file = File('${downloadsDirectory.path}/gtt_favorites.json');
    await file.writeAsString(jsonResult, mode: FileMode.writeOnly, flush: true);
    Utils.showSnackBar(
      'Salvato in ${file.path}',
    );
  }

  Future<void> importFavorites() async {
    try {
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
      await DatabaseCommands.instance.importFavorites(jsonMap);
      Get.find<HomeController>().getStops();
    } catch (e) {
      Utils.showSnackBar('Errore durante l\'importazione');
    }
  }

  void shareApp() {
    Share.share(
      'Sto usando questa app GTT, scaricala anche tu \nhttps://github.com/amxDusT/GTT-app/releases/latest',
      subject: 'GTT app',
    );
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

  void showTutorial() {
    Get.offAllNamed('/intro');
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
