import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';

extension DateTimeExt on DateTime {
  //Storage.instance.showSecondsInUpdates
  String toTimeString([bool displaySeconds = true]) => displaySeconds
      ? DateFormat.Hms().format(this)
      : DateFormat.Hm().format(this);

  String get toFullString {
    return DateFormat(
      'd MMMM, y H:mm',
    ).format(this).capitalizeFirst!;
  }

  DateTime toDate(String date) => DateFormat('d MMMM, y H:mm').parse(date);
  int get relativeTimeInMinutes {
    final diff = difference(DateTime.now());
    if (diff.isNegative) return 0;
    if (diff.inMinutes < 1) return 0;
    return diff.inMinutes;
  }

  String lastUpdateRelativeTime() {
    final diff = difference(DateTime.now());
    if (!diff.isNegative || diff.inSeconds > -10) return 'now'.hc;

    if (diff.inMinutes > -1) return '<1 min'.hc;
    return '${-diff.inMinutes} min'.hc;
  }

  String relativeTime([bool displayMinText = true]) {
    final diff = difference(DateTime.now());
    if (diff.isNegative) return 'now'.hc;
    if (diff.inMinutes < 1) return '<1 min'.hc;

    if (diff.inMinutes < 60)
      return '${diff.inMinutes}${displayMinText ? 'min' : ''}'.hc;
    if (diff.inHours < 12)
      return '${diff.inHours}h${diff.inMinutes % 60}${displayMinText ? 'min' : ''}'
          .hc;
    if (diff.inHours >= 24) {
      return subtract(const Duration(days: 1)).relativeTime(displayMinText);
    }

    return toTimeString(false);
  }

  String get formatArrival {
    final diff = difference(DateTime.now());

    if (diff.inMinutes.abs() <= 60) {
      if (diff.isNegative) return 'now'.hc;
      if (diff.inMinutes < 1) return '<1 min'.hc;
      return '${diff.inMinutes} min'.hc;
    }

    return toTimeString(false);
  }
}
