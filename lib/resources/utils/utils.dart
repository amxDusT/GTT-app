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

  static String dateToHourString(DateTime date) {
    return Storage.showSecondsInUpdates
        ? DateFormat.Hms(Get.locale?.languageCode).format(date).capitalizeFirst!
        : DateFormat.Hm(Get.locale?.languageCode).format(date).capitalizeFirst!;
  }

  static String dateToString(DateTime date) {
    return DateFormat('d MMMM, y H:mm a', Get.locale?.languageCode)
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
}
