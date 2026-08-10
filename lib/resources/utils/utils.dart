import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:torino_mobility/models/gtt/route.dart' as gtt;

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

  static DateTime stringToDate(String date) =>
      DateFormat('d MMMM, y H:mm').parse(date);

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
              child: Text(l10n.close),
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

  static Directory getDownloadsDirectory() {
    if (GetPlatform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    } else if (GetPlatform.isIOS) {
      return Directory('/var/mobile/Containers/Data/Application/Documents');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
