import 'dart:typed_data';

import 'package:intl/intl.dart';

class GttDate {
  static DateTime? gttDate;
  static int gttDateAsSeconds = 1104534000;
  static const int oneMinuteInMillis = 60000;
  static DateTime decodeFromBytes(Uint8List minutes) {
    return addMinutesToDate(byteArrayToInt(minutes), getGttEpoch());
  }

  static DateTime decodeFromMinutes(int minutes) {
    return addMinutesToDate(minutes, getGttEpoch());
  }

  static DateTime getGttEpoch() {
    if (gttDate == null) {
      String startingDate = '05/01/01 00:00:00';
      final format = DateFormat('yy/MM/dd HH:mm:ss');
      gttDate = format.parse(startingDate);
    }
    return gttDate!;
  }

  static int getMinutesUntilEndOfService(DateTime startDate) {
    final curr = DateTime.now();
    var after = curr.add(const Duration(days: 1));
    final start = startDate;
    if ((curr.millisecondsSinceEpoch - start.millisecondsSinceEpoch) ~/
            oneMinuteInMillis >
        24 * 60) {
      return 0;
    }
    after = after
        .add(const Duration(hours: 3, minutes: 0, seconds: 0, milliseconds: 0));
    return (after.millisecondsSinceEpoch - curr.millisecondsSinceEpoch) ~/
        oneMinuteInMillis;
  }

  static DateTime addMinutesToDate(int minutes, DateTime beforeTime) {
    int curTimeInMs = beforeTime.millisecondsSinceEpoch;
    return DateTime.fromMillisecondsSinceEpoch(
        curTimeInMs + (minutes * oneMinuteInMillis));
  }


  static Uint8List fromDateToByte(DateTime date){
    return intToByteArray(((date.millisecondsSinceEpoch~/1000) - gttDateAsSeconds)~/60);
  }
  static int byteArrayToInt(Uint8List bytes) {
    int value = 0;
    for (int i = 0; i < bytes.length; i++) {
      value = (value << 8) + (bytes[i] & 0xff);
    }
    return value;
  }

  static Uint8List intToByteArray(int value) {
    List<int> bytes = [];
    while (value > 0) {
      bytes.add(value & 0xFF);
      value >>= 8;
    }
    if (bytes.isEmpty) {
      bytes.add(0);
    }
    return Uint8List.fromList(List.from(bytes.reversed));
  }

  // Only for unit testing
  static String genDate() {
    String dateStart = '05/01/01 00:00:00';
    final now = DateTime.now();
    final format = DateFormat('yy/MM/dd HH:mm:ss');
    DateTime d1 = format.parse(dateStart);
    Duration difference = now.difference(d1);
    int diffMinutes = difference.inMinutes % 60;

    String page = diffMinutes.toRadixString(16);
    for (int i = 0; i <= 8 - page.length; i++) {
      page += '0';
    }
    return page;
  }
}
