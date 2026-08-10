import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/models/gtt/stoptime.dart';
import 'package:torino_mobility/resources/extensions/date_time.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class PassageTime extends StatelessWidget {
  final Stoptime stoptime;
  final bool isSelected;
  const PassageTime({
    super.key,
    required this.stoptime,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: switch ((stoptime.realtime, isSelected)) {
          (true, true) => t.good,
          (true, false) => t.good.withValues(alpha: 0.22),
          (false, _) => t.inkDim.withValues(alpha: 0.18),
        },
        borderRadius: BorderRadius.circular(20),
      ),
      child: RichText(
          maxLines: 1,
          text: TextSpan(
              text: stoptime.realtimeDeparture.relativeTime(false),
              style: Fonts.subtitle(
                fontSize: 12,
                fontWeight:
                    stoptime.realtime ? FontWeight.w700 : FontWeight.w400,
                color: switch ((stoptime.realtime, isSelected)) {
                  (true, true) => t.bg,
                  (true, false) => t.good /* .withValues(alpha: 0.8) */,
                  (false, true) => t.inkDim,
                  (false, false) => t.inkDim,
                },
              ),
              children: [
                if (stoptime.realtimeDeparture.relativeTimeInMinutes > 0)
                  TextSpan(
                    text: 'min',
                    style: Fonts.subtitle(
                      fontSize: 10,
                      fontWeight:
                          stoptime.realtime ? FontWeight.w600 : FontWeight.w400,
                      color: switch ((stoptime.realtime, isSelected)) {
                        (true, true) => t.bg,
                        (true, false) => t.good /* .withValues(alpha: 0.8) */,
                        (false, true) => t.inkDim,
                        (false, false) => t.inkDim,
                      },
                    ),
                  )
              ])),
      /*   Text(
        //stoptime.realtimeDeparture.toTimeString(false),
        stoptime.realtimeDeparture.relativeTime,
        style: Fonts.subtitle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: switch ((stoptime.realtime, isSelected)) {
            (true, true) => t.bg,
            (true, false) =>
              t.good /* .withValues(alpha: 0.8) */,
            (false, true) => t.inkMute,
            (false, false) => t.inkMute,
          },
          //isSelected ? t.bg : t.inkMute,
        ),
      ), */
    );
  }
}
