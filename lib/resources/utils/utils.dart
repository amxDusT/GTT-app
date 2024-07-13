import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gtt/bindings/home_bindings.dart';
import 'package:flutter_gtt/bindings/info_bindings.dart';
import 'package:flutter_gtt/bindings/intro_bindings.dart';
import 'package:flutter_gtt/bindings/loading_bindings.dart';
import 'package:flutter_gtt/bindings/map_global_bindings.dart';
import 'package:flutter_gtt/bindings/map_page_bindings.dart';
import 'package:flutter_gtt/pages/home_page.dart';
import 'package:flutter_gtt/pages/info_page.dart';
import 'package:flutter_gtt/pages/intro/intro_page.dart';
import 'package:flutter_gtt/pages/loading_page.dart';
import 'package:flutter_gtt/pages/map/map_global.dart';
import 'package:flutter_gtt/pages/map/map_page.dart';
import 'package:flutter_gtt/pages/nfc/nfc_page.dart';
import 'package:flutter_gtt/pages/route_list_page.dart';
import 'package:flutter_gtt/pages/settings_page.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gtt/models/gtt/route.dart' as gtt;

class Utils {
  static String getLocale() {
    return Get.locale?.languageCode ?? 'it';
  }

  static int getBytesFromPage(Uint8List page, int offset, int bytesnum) {
    final bytes = Uint8List.sublistView(page, offset, offset + bytesnum);
    int value = 0;
    for (int tmp in bytes) {
      value = (value << 8) + (tmp & 0xff);
    }
    return value;
  }

  static int bitCount(int value) {
    int count = 0;
    while (value > 0) {
      count += (value & 1);
      value >>= 1;
    }
    return count;
  }

  static String dateToHourString(DateTime date, [checkSeconds = true]) {
    return checkSeconds && Storage.instance.showSecondsInUpdates
        ? DateFormat.Hms(getLocale()).format(date)
        : DateFormat.Hm(getLocale()).format(date);
  }

  static DateTime stringToDate(String date) {
    return DateFormat('d MMMM, y H:mm', getLocale()).parse(date);
  }

  static String dateToString(DateTime date) {
    return DateFormat('d MMMM, y H:mm', getLocale())
        .format(date)
        .capitalizeFirst!;
  }

  static Color darken(Color c, [int percent = 50]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
        (c.blue * f).round());
  }

  static Color lighten(Color c, [int percent = 50]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
        c.alpha,
        c.red + ((255 - c.red) * p).round(),
        c.green + ((255 - c.green) * p).round(),
        c.blue + ((255 - c.blue) * p).round());
  }

  static void showSnackBar(
    String message, {
    String? title,
    Duration? duration,
    bool? closePrevious,
    SnackPosition? snackPosition,
    Widget? mainButton,
  }) async {
    if (closePrevious ?? false) {
      await Get.closeCurrentSnackbar();
    }

    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        duration: duration ?? const Duration(seconds: 2),
        animationDuration: const Duration(milliseconds: 300),
        snackPosition: snackPosition ?? SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
        mainButton: mainButton ??
            TextButton(
              onPressed: () async {
                await Get.closeCurrentSnackbar();
              },
              child: const Text('Chiudi'),
            ),
      ),
    );
  }

  static void sort(List<gtt.Route> routes) {
    routes.sort((a, b) {
      // compare by type
      int compareWithType = a.type.compareTo(b.type);
      if (compareWithType != 0) {
        return compareWithType;
        // compare by number
      } else if (_startWithNumberOrM(a.shortName) &&
          _startWithNumberOrM(b.shortName)) {
        return _compareWithNumbers(a, b);
        // compare by name
      } else if (!_startWithNumberOrM(a.shortName) &&
          !_startWithNumberOrM(b.shortName)) {
        return a.shortName.compareTo(b.shortName);
      } else {
        return _startWithNumberOrM(a.shortName) ? -1 : 1;
      }
    });
  }

  static int _extractNumericPart(String str) {
    RegExpMatch? match = RegExp(r'\d+').firstMatch(str);
    if (match != null) {
      return int.parse(match.group(0)!);
    } else {
      return 0;
    }
  }

  static bool _startWithNumberOrM(String s) {
    return RegExp(r'^[0-9M]').hasMatch(s);
  }

  static int _compareWithNumbers(gtt.Route a, gtt.Route b) {
    int numA = _extractNumericPart(a.shortName);
    int numB = _extractNumericPart(b.shortName);
    int compare = numA.compareTo(numB);
    if (compare == 0) {
      return a.shortName.compareTo(b.shortName);
    }
    return compare;
  }

  static String getBusIdentifier(String gtfsId) {
    return gtfsId.split(':')[1].substring(0, gtfsId.split(':')[1].length - 1);
  }

  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static List<GetPage> getPages() {
    return [
      GetPage(
        name: '/',
        page: () => LoadingPage(),
        binding: LoadingBindings(),
      ),
      GetPage(
        name: '/home',
        page: () => HomePage(),
        binding: HomeBindings(),
      ),
      GetPage(
        name: '/map',
        page: () => MapGlobal(),
        binding: MapGlobalBindings(),
      ),
      GetPage(
        name: '/routelist',
        page: () => RouteListPage(),
      ),
      GetPage(
        name: '/settings',
        page: () => SettingsPage(),
      ),
      GetPage(
        name: '/nfc',
        page: () => NfcPage(),
      ),
      GetPage(
        name: '/info',
        page: () => InfoPage(),
        binding: InfoBindings(),
      ),
      GetPage(
        name: '/mapBus',
        page: () => MapPage(),
        binding: MapPageBindings(),
      ),
      GetPage(
        name: '/intro',
        page: () => const IntroPage(),
        binding: IntroBindings(),
      )
    ];
  }
}
