import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/route_list_controller.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/models/gtt/agency.dart';
import 'package:torino_mobility/models/gtt/favorite_stop.dart';
import 'package:torino_mobility/models/gtt/pattern.dart' as gtt;
import 'package:torino_mobility/models/gtt/route.dart' as gtt;
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/exceptions/api_exception.dart';
import 'package:torino_mobility/resources/api/github_api.dart';
import 'package:torino_mobility/resources/api/gtt_api.dart';
import 'package:torino_mobility/resources/apk_install.dart';
import 'package:torino_mobility/resources/database.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/update_utils.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
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
      title: l10n.updateAvailableTitle(infoApp['version']),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.updateAvailableBody),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.whatsNewTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
      middleText: l10n.downloadNewVersion,
      textConfirm: l10n.download,
      textCancel: l10n.cancel,
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
          l10n.cancel,
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
    check if hasnt been updated in the last $daysBeforeAutoUpdate days
  */
  bool needsAutoUpdate() {
    return Storage.instance.lastUpdate.isBefore(
        DateTime.now().subtract(const Duration(days: daysBeforeAutoUpdate)));
  }

  /*
  check if the database is empty (by checking the agencies table)
  */
  Future<bool> isFirstLoad() async {
    return (await DatabaseCommands.instance.agencies).isEmpty;
  }

  Future<void> loadFromApi() async {
    isShowingMessage.value = true;
    Storage.instance.setLastUpdate(DateTime.now());
    try {
      List<Agency> agencyList = await GttApi.getAgencies();
      UpdateUtils.update(agencyList);

      List<gtt.Route> routeValues;
      List<gtt.Pattern> patternValues;
      List<Stop> stopValues;
      List<gtt.PatternStop> patternStopValues;
      (routeValues, patternValues, stopValues, patternStopValues) =
          await Isolate.run(() => GttApi.routesByFeed());

      UpdateUtils.update(patternStopValues);
      UpdateUtils.update(stopValues);
      UpdateUtils.update(patternValues);
      UpdateUtils.update(routeValues);

      if (Get.isRegistered<RouteListController>()) {
        Get.find<RouteListController>().getRoutes(routeValues);
      }
    } on ApiException catch (e) {
      Utils.showSnackBar(
        e.message,
        title: l10n.errorWithCode(e.statusCode),
      );
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
    bool isFirstLoad = await this.isFirstLoad();

    bool needToLoad = needsAutoUpdate() || isFirstLoad;
    if (needToLoad) {
      if (isFirstLoad) {
        await loadFromApi();
        duration = const Duration(milliseconds: 1);
      } else {
        loadFromApi();
      }
    }
    if (isFirstLoad) await _addSomeFavorites();
    moveToHome(duration);
  }

  Future<void> _addSomeFavorites() async {
    const stopCodes = [40, 472, 31];
    final stops =
        await Future.wait(stopCodes.map((code) => GttApi.getStop(code)));
    const colors = [Colors.red, Colors.green, Colors.blue];
    const descriptions = ['home > gym', 'work', 'friend\'s house'];

    await Future.wait(
      stops.asMap().entries.map((entry) {
        int i = entry.key;
        Stop stop = entry.value;
        FavStop favStop = FavStop.fromStop(
          stop: stop,
          color: Storage.instance.isDarkMode
              ? Utils.darken(colors[i], 30)
              : Utils.lighten(colors[i]),
          descrizione: descriptions[i],
        );
        return DatabaseCommands.instance.insertStop(favStop);
      }),
    );
  }

  void moveToHome(Duration duration) async {
    await Future.delayed(duration);
    if (Storage.instance.isFirstTime) {
      Storage.instance.setBool(StorageParam.isFirstTime, false);
      Get.offNamed('/intro');
    } else {
      Get.offNamed('/home');
    }
  }
}
