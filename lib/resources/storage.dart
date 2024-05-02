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
  showBetaFeatures,
  isFirstTime,
}

class Storage {
  static Color chosenColor = initialColor;
  static bool isFermataShowing = true;
  static bool isRouteWithoutPassagesShowing = true;
  static bool showSecondsInUpdates = false;
  static DateTime lastUpdate = DateTime.now();
  static const _storage = FlutterSecureStorage();
  static bool isFavoritesRoutesShowing = true;
  static bool showBetaFeatures = false;
  static bool isFirstTime = true;
  static void loadSettings() async {
    chosenColor =
        stringToColor(await getParam(StorageParam.color)) ?? initialColor;

    isFermataShowing = bool.parse(
        await getParam(StorageParam.fermataMap) ?? isFermataShowing.toString());

    isRouteWithoutPassagesShowing = bool.parse(
        await getParam(StorageParam.routeWithoutPassagesMap) ??
            isRouteWithoutPassagesShowing.toString());

    showSecondsInUpdates = bool.parse(
        await getParam(StorageParam.showSecondsInUpdates) ??
            showSecondsInUpdates.toString());

    //very ugly
    lastUpdate = Utils.stringToDate(await getParam(StorageParam.lastUpdate) ??
        Utils.dateToString(DateTime.now()));

    isFavoritesRoutesShowing = bool.parse(
      await getParam(StorageParam.isFavoritesRoutesShowing) ??
          isFavoritesRoutesShowing.toString(),
    );

    showBetaFeatures = bool.parse(
        await getParam(StorageParam.showBetaFeatures) ??
            showBetaFeatures.toString());

    isFirstTime = bool.parse(
        await getParam(StorageParam.isFirstTime) ?? isFirstTime.toString());
  }

  static String colorToString(Color color) =>
      '${color.alpha}/${color.red}/${color.green}/${color.blue}';

  static Color? stringToColor(String? colorString) {
    int clamped(int value) => value.clamp(0, 255);

    if (colorString == null) return null;
    colorString = colorString.trim();
    final split = colorString.split('/');
    if (split.length != 4) return null;
    List<int> values = split
        .where((e) => int.tryParse(e) != null)
        .map((e) => int.parse(e))
        .toList();

    if (values.length != 4) return null;

    return Color.fromARGB(
      clamped(values[0]),
      clamped(values[1]),
      clamped(values[2]),
      clamped(values[3]),
    );
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
