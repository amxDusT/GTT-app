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
  final _storage = const FlutterSecureStorage();
  static Storage? _instance;
  Map<StorageParam, dynamic> params = {};
  Storage._();
  static Storage get instance => _instance ??= Storage._();

  Future<void> loadSettings() async {
    params[StorageParam.color] =
        stringToColor(await _getParam(StorageParam.color)) ?? initialColor;
    params[StorageParam.fermataMap] = bool.parse(
        await _getParam(StorageParam.fermataMap) ??
            isFermataShowing.toString());
    params[StorageParam.routeWithoutPassagesMap] = bool.parse(
        await _getParam(StorageParam.routeWithoutPassagesMap) ??
            isRouteWithoutPassagesShowing.toString());
    params[StorageParam.showSecondsInUpdates] = bool.parse(
        await _getParam(StorageParam.showSecondsInUpdates) ??
            showSecondsInUpdates.toString());
    params[StorageParam.lastUpdate] =
        stringToDate(await _getParam(StorageParam.lastUpdate));
    params[StorageParam.isFavoritesRoutesShowing] = bool.parse(
        await _getParam(StorageParam.isFavoritesRoutesShowing) ??
            isFavoritesRoutesShowing.toString());
    params[StorageParam.showBetaFeatures] = bool.parse(
        await _getParam(StorageParam.showBetaFeatures) ??
            showBetaFeatures.toString());
    params[StorageParam.isFirstTime] = bool.parse(
        await _getParam(StorageParam.isFirstTime) ?? isFirstTime.toString());
  }

  Color get chosenColor => params[StorageParam.color] ?? initialColor;
  bool get isFermataShowing => params[StorageParam.fermataMap] ?? true;
  bool get isRouteWithoutPassagesShowing =>
      params[StorageParam.routeWithoutPassagesMap] ?? true;
  bool get showSecondsInUpdates =>
      params[StorageParam.showSecondsInUpdates] ?? false;
  DateTime get lastUpdate => params[StorageParam.lastUpdate] ?? DateTime.now();
  bool get isFavoritesRoutesShowing =>
      params[StorageParam.isFavoritesRoutesShowing] ?? true;
  bool get showBetaFeatures => params[StorageParam.showBetaFeatures] ?? false;
  bool get isFirstTime => params[StorageParam.isFirstTime] ?? true;

  static String dateToString(DateTime date) {
    return date.millisecondsSinceEpoch.toString();
  }

  static DateTime stringToDate(String? date) {
    if (date == null) return DateTime.now();
    int? dateInt = int.tryParse(date);
    if (dateInt == null) {
      // for backward compatibility
      try {
        return Utils.stringToDate(date);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(dateInt);
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

  dynamic getValue(StorageParam key) => params[key];

  Future<void> setBool(StorageParam key, bool value) async {
    assert(
      key != StorageParam.color && key != StorageParam.lastUpdate,
      'Invalid key',
    );
    await _setParam(key, value.toString());
  }

  Future<void> setLastUpdate(DateTime value) async {
    await _setParam(StorageParam.lastUpdate, value);
  }

  Future<void> setColor(Color value) async {
    await _setParam(StorageParam.color, value);
  }

  Future<void> _setParam(StorageParam key, dynamic value) async {
    String valueString;

    if (value is bool) {
      valueString = value.toString();
    } else if (value is DateTime) {
      valueString = dateToString(value);
    } else if (value is Color) {
      valueString = colorToString(value);
    } else {
      throw Exception('Invalid value type');
    }
    params[key] = value;
    await _storage.write(key: key.toString(), value: valueString);
    loadSettings();
  }

  Future<String?> _getParam(StorageParam key) async =>
      await _storage.read(key: key.toString());

  Future<void> _clearParam(StorageParam key) async =>
      await _storage.delete(key: key.toString());
}
