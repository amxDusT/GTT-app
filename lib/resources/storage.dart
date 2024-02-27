import 'package:flutter/material.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum StorageParam {
  color,
  fermataMap,
  routeWithoutPassagesMap,
  showSecondsInUpdates,
  lastUpdate,
  isFavoritesRoutesShowing,
}

class Storage {
  static Color chosenColor = initialColor;
  static bool isFermataShowing = true;
  static bool isRouteWithoutPassagesShowing = true;
  static bool showSecondsInUpdates = false;
  static DateTime lastUpdate = DateTime.now();
  static const _storage = FlutterSecureStorage();
  static bool isFavoritesRoutesShowing = false;

  static void loadSettings() async {
    chosenColor =
        stringToColor(await getParam(StorageParam.color)) ?? initialColor;

    isFermataShowing =
        bool.parse(await getParam(StorageParam.fermataMap) ?? 'true');

    isRouteWithoutPassagesShowing = bool.parse(
        await getParam(StorageParam.routeWithoutPassagesMap) ?? 'true');

    showSecondsInUpdates = bool.parse(
        await getParam(StorageParam.showSecondsInUpdates) ?? 'false');

    //very ugly
    lastUpdate = Utils.stringToDate(await getParam(StorageParam.lastUpdate) ??
        Utils.dateToString(DateTime.now()));

    isFavoritesRoutesShowing = bool.parse(
      await getParam(StorageParam.isFavoritesRoutesShowing) ?? 'false',
    );
  }

  static String colorToString(Color color) =>
      '${color.alpha}/${color.red}/${color.green}/${color.blue}';

  static Color? stringToColor(String? colorString) {
    List<int>? values =
        colorString?.split('/').map((e) => int.parse(e)).toList();
    return values == null
        ? null
        : Color.fromARGB(values[0], values[1], values[2], values[3]);
  }

  static Future<void> setParam(StorageParam key, String value) async {
    await _storage.write(key: key.toString(), value: value);
    loadSettings();
  }

  static Future<String?> getParam(StorageParam key) async =>
      await _storage.read(key: key.toString());

  static Future<void> clearParam(StorageParam key) async =>
      await _storage.delete(key: key.toString());
}
