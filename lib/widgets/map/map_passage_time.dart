import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/models/gtt/stoptime.dart';
import 'package:torino_mobility/resources/extensions/date_time.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class MapPassageTime extends StatelessWidget {
  final Stoptime stoptime;
  final bool isSelected;
  const MapPassageTime({
    super.key,
    required this.stoptime,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final live = stoptime.realtime;

    // In light mode `good` and `inkMute` land on the same luminance (1.01:1),
    // so colour alone can't separate live from scheduled — it only works in
    // dark mode, where they differ ~2:1. Weight carries the distinction in
    // both modes, and survives red-green colour blindness.
    final color = switch ((live, isSelected)) {
      (true, true) => t.bg,
      (true, false) => t.good,
      (false, _) => t.inkMute,
    };

    return RichText(
      maxLines: 1,
      text: TextSpan(
        text: stoptime.realtimeDeparture.relativeTime(false),
        style: Fonts.subtitle(
          fontSize: 12,
          fontWeight: live ? FontWeight.w700 : FontWeight.w400,
          color: color,
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
                fontWeight: live ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            )
        ],
      ),
    );
  }
}
