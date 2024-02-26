import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Utils {
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
    return checkSeconds && Storage.showSecondsInUpdates
        ? DateFormat.Hms(Get.locale?.languageCode).format(date)
        : DateFormat.Hm(Get.locale?.languageCode).format(date);
  }

  static DateTime stringToDate(String date) {
    return DateFormat('d MMMM, y H:mm', Get.locale?.languageCode).parse(date);
  }

  static String dateToString(DateTime date) {
    return DateFormat('d MMMM, y H:mm', Get.locale?.languageCode)
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
        snackStyle: SnackStyle.GROUNDED,
        mainButton: mainButton ??
            TextButton(
              onPressed: () async {
                await Get.closeCurrentSnackbar();
              },
              child: const Text("Chiudi"),
            ),
      ),
    );
  }
}
