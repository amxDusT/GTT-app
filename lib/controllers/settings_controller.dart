import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/home_controller.dart';
import 'package:torino_mobility/controllers/loading_controller.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/resources/database.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsController extends GetxController {
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
    SharePlus.instance.share(
      ShareParams(
        text: l10n.shareAppMessage,
        subject: l10n.shareAppSubject,
      ),
    );
  }

  void infoApp() {
    Get.defaultDialog(
      title: l10n.settingsInfoTitle,
      textCancel: l10n.close,
      content: Column(
        children: [
          Text(l10n.settingsVersion(version.value)),
          Text(l10n.developedBy('Kevin Kolaveri')),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(l10n.githubLabel),
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
      title: l10n.settingsBetaFeaturesTitle,
      textCancel: l10n.close,
      content: Column(
        children: [
          Text(l10n.betaFeaturesHeading,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 150,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(l10n.betaFeaturesList),
            ),
          ),
          Text(l10n.betaFeaturesWarning,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
