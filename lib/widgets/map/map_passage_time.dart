import 'package:flutter/material.dart';
import 'package:torino_mobility/models/gtt/stoptime.dart';
import 'package:torino_mobility/resources/extensions/date_time.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class MapPassageTime extends StatelessWidget {
  final Stoptime stoptime;
  final bool isSelected;
  final TextStyle? style;
  const MapPassageTime({
    super.key,
    required this.stoptime,
    this.isSelected = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
        maxLines: 1,
        text: TextSpan(
            text: stoptime.realtimeDeparture.relativeTime(false),
            style: Fonts.subtitle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: switch ((stoptime.realtime, isSelected)) {
                (true, true) => const Color(0xff1a1611),
                (true, false) =>
                  const Color(0xff3fff7a) /* .withValues(alpha: 0.8) */,
                (false, true) => const Color(0xff8a8273),
                (false, false) => const Color(0xff8a8273),
              },
            ),
            children: [
              if (stoptime.realtimeDeparture.relativeTimeInMinutes > 0 &&
                      stoptime.realtimeDeparture.relativeTimeInMinutes <
                          (12 * 60) ||
                  stoptime.realtimeDeparture.relativeTimeInMinutes >= (24 * 60))
                TextSpan(
                  text: 'min',
                  style: Fonts.subtitle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: switch ((stoptime.realtime, isSelected)) {
                      (true, true) => const Color(0xff1a1611),
                      (true, false) =>
                        const Color(0xff3fff7a) /* .withValues(alpha: 0.8) */,
                      (false, true) => const Color(0xff8a8273),
                      (false, false) => const Color(0xff8a8273),
                    },
                  ),
                )
            ]));
  }
}
