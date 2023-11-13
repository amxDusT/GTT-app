import 'dart:typed_data';

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

  static String dateToString(DateTime date){
    return DateFormat('d MMMM, y H:mm a', 'it').format(date).capitalizeFirst!;
  }
}
