import 'dart:math';

import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CustomPicker extends CommonPickerModel {
  DateTime? maxTime;
  DateTime? minTime;
  bool isInitialized = false;
  CustomPicker({
    DateTime? currentTime,
    DateTime? maxTime,
    DateTime? minTime,
    super.locale,
  }) {
    if (currentTime != null) {
      this.currentTime = currentTime;
      if (maxTime != null && currentTime.isAfter(maxTime)) {
        this.currentTime = maxTime;
      }
      if (minTime != null && currentTime.isBefore(minTime)) {
        this.currentTime = minTime;
      }
      this.maxTime = maxTime;
      this.minTime = minTime;
    } else {
      this.maxTime = maxTime;
      this.minTime = minTime;
      var now = DateTime.now();
      if (this.minTime != null && this.minTime!.isAfter(now)) {
        this.currentTime = this.minTime!;
      } else if (this.maxTime != null && this.maxTime!.isBefore(now)) {
        this.currentTime = this.maxTime!;
      } else {
        this.currentTime = now;
      }
    }
    if (this.minTime != null &&
        this.maxTime != null &&
        this.maxTime!.isBefore(this.minTime!)) {
      // invalid
      this.minTime = null;
      this.maxTime = null;
    }

    setLeftIndex(0);
    setMiddleIndex(this.currentTime.hour);

    setRightIndex(this.currentTime.minute);
    isInitialized = true;
    if (this.minTime != null && isAtSameDay(this.minTime!, this.currentTime)) {
      setMiddleIndex(this.currentTime.hour - this.minTime!.hour);
      if (currentMiddleIndex() == 0) {
        setRightIndex(this.currentTime.minute - this.minTime!.minute);
      }
    }
  }

  bool isAtSameDay(DateTime? day1, DateTime? day2) {
    return isInitialized == true &&
        day1 != null &&
        day2 != null &&
        day1.difference(day2).inDays == 0 &&
        day1.day == day2.day;
  }

  @override
  void setLeftIndex(int index) {
    //print(index);
    super.setLeftIndex(index);
    DateTime time = currentTime.add(Duration(days: index));

    if (isAtSameDay(minTime, time) ||
        (minTime != null && minTime!.isAfter(time))) {
      var index = min(24 - minTime!.hour - 1, currentMiddleIndex());
      setMiddleIndex(index);
    } else if (isAtSameDay(maxTime, time)) {
      var index = min(maxTime!.hour, currentMiddleIndex());
      setMiddleIndex(index);
    }
  }

  @override
  void setMiddleIndex(int index) {
    super.setMiddleIndex(index);
    DateTime time = currentTime.add(Duration(days: currentLeftIndex()));
    if (isAtSameDay(minTime, time) && index == 0) {
      var maxIndex = 60 - minTime!.minute - 1;
      if (currentRightIndex() > maxIndex) {
        setRightIndex(maxIndex);
      }
    } else if (isAtSameDay(maxTime, time) &&
        currentMiddleIndex() == maxTime!.hour) {
      var maxIndex = maxTime!.minute;
      if (currentRightIndex() > maxIndex) {
        setRightIndex(maxIndex);
      }
    }
  }

  @override
  String? leftStringAtIndex(int index) {
    DateTime time = currentTime.add(Duration(days: index));

    if (minTime != null &&
        time.isBefore(minTime!) &&
        !isAtSameDay(minTime!, time)) {
      return null;
    } else if (maxTime != null &&
        time.isAfter(maxTime!) &&
        !isAtSameDay(maxTime, time)) {
      return null;
    }
    final now = DateTime.now();
    if (isAtSameDay(time, now)) {
      return 'Oggi';
    } else if (isAtSameDay(time, now.add(const Duration(days: 1)))) {
      return 'Domani';
    } else if (isAtSameDay(time, now.subtract(const Duration(days: 1)))) {
      return 'Ieri';
    }

    return DateFormat.MMMEd(Get.locale?.languageCode)
        .format(time)
        .capitalizeFirst;
    //return formatDate(time, [ymdw], locale);
  }

  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      DateTime time = currentTime.add(Duration(days: currentLeftIndex()));
      if (isAtSameDay(minTime, time)) {
        if (index >= 0 && index < 24 - minTime!.hour) {
          return digits(minTime!.hour + index, 2);
        } else {
          return null;
        }
      } else if (isAtSameDay(maxTime, time)) {
        if (index >= 0 && index <= maxTime!.hour) {
          return digits(index, 2);
        } else {
          return null;
        }
      }
      return digits(index, 2);
    }

    return null;
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      DateTime time = currentTime.add(Duration(days: currentLeftIndex()));
      if (isAtSameDay(minTime, time) && currentMiddleIndex() == 0) {
        if (index >= 0 && index < 60 - minTime!.minute) {
          return digits(minTime!.minute + index, 2);
        } else {
          return null;
        }
      } else if (isAtSameDay(maxTime, time) &&
          currentMiddleIndex() >= maxTime!.hour) {
        if (index >= 0 && index <= maxTime!.minute) {
          return digits(index, 2);
        } else {
          return null;
        }
      }
      return digits(index, 2);
    }

    return null;
  }

  @override
  DateTime finalTime() {
    DateTime time = currentTime.add(Duration(days: currentLeftIndex()));
    var hour = currentMiddleIndex();
    var minute = currentRightIndex();
    if (isAtSameDay(minTime, time)) {
      hour += minTime!.hour;
      if (minTime!.hour == hour) {
        minute += minTime!.minute;
      }
    }

    return currentTime.isUtc
        ? DateTime.utc(time.year, time.month, time.day, hour, minute)
        : DateTime(time.year, time.month, time.day, hour, minute);
  }

  @override
  List<int> layoutProportions() {
    return [3, 1, 1];
  }

  @override
  String rightDivider() {
    return ':';
  }
}
