import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/gtt/agency.dart';
import 'package:flutter_gtt/models/gtt/pattern.dart' as gtt;
import 'package:flutter_gtt/models/gtt/route.dart' as gtt;
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/exceptions/api_exception.dart';
import 'package:flutter_gtt/resources/api/github_api.dart';
import 'package:flutter_gtt/resources/api/gtt_api.dart';
import 'package:flutter_gtt/resources/apk_install.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:flutter_gtt/resources/utils/update_utils.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:get/get.dart';

class LoadingController extends GetxController {
  RxBool isShowingMessage = false.obs;
  @override
  void onInit() async {
    super.onInit();
    if (!kDebugMode) await checkVersion();
    checkAndLoad();
  }

  Future<void> checkVersion() async {
    bool isDifferent = await GithubApi.checkVersion();

    if (isDifferent) {
      await installVersionPopup();
    }
  }

  Future<void> installVersionPopup() async {
    final Map<String, dynamic> infoApp = await GithubApi.getAppInfo();
    RxBool isDownloading = false.obs;
    await Get.defaultDialog(
      barrierDismissible: false,
      title: 'Nuova versione disponibile (${infoApp['version']})',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('È disponibile una nuova versione dell\'app'),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '  Novità:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 150,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(infoApp['update']),
            ),
          ),
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
      textCancel: 'Annulla',
      /*cancel: TextButton(
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
      ),*/
      onConfirm: () async {
        if (isDownloading.value) return;
        isDownloading.value = true;
        await ApkInstall.downloadNewVersion();
        Get.back();
      },
    );
  }

  /*
    check if hasnt been updated in the last 30 days
    and if the database is empty (by checking the agencies table)
  */
  Future<bool> needToLoad() async {
    return Storage.lastUpdate
            .isBefore(DateTime.now().subtract(const Duration(days: 30))) &&
        (await DatabaseCommands.instance.agencies).isEmpty;
  }

  Future<void> loadFromApi() async {
    isShowingMessage.value = true;
    Storage.setParam(
        StorageParam.lastUpdate, Utils.dateToString(DateTime.now()));
    try {
      List<Agency> agencyList = await GttApi.getAgencies();
      UpdateUtils.update(agencyList);
      //DatabaseCommands.instance.bulkInsert(agencyList);
      //getAgencies(agencyList);
      List<gtt.Route> routeValues;
      List<gtt.Pattern> patternValues;
      List<Stop> stopValues;
      List<gtt.PatternStop> patternStopValues;
      (routeValues, patternValues, stopValues, patternStopValues) =
          await GttApi.routesByFeed();

      UpdateUtils.update(patternStopValues);
      UpdateUtils.update(stopValues);
      UpdateUtils.update(patternValues);
      UpdateUtils.update(routeValues);
      /* await DatabaseCommands.instance.bulkInsert(patternStopValues);
      DatabaseCommands.instance.bulkInsert(stopValues);
      DatabaseCommands.instance.bulkInsert(patternValues);
      DatabaseCommands.instance.bulkInsert(routeValues); */
    } on ApiException catch (e) {
      Utils.showSnackBar(e.message, title: 'Error ${e.statusCode}');
    } finally {
      isShowingMessage.value = false;
    }
  }

  void resetData() async {
    //await DatabaseCommands.instance.clearTables();
    await loadFromApi();
    moveToHome(const Duration(milliseconds: 1));
  }

  void checkAndLoad() async {
    Duration duration = const Duration(milliseconds: 1000);
    if (await needToLoad()) {
      await loadFromApi();
      duration = const Duration(milliseconds: 1);
    }
    moveToHome(duration);
  }

  void moveToHome(Duration duration) async {
    await Future.delayed(duration);
    Get.offNamed('/home');
  }
}
