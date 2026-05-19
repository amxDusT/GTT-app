import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: switch ((stoptime.realtime, isSelected)) {
          (true, true) => Colors.green.withValues(alpha: 0.8),
          (true, false) => Colors.green.withValues(alpha: 0.4),
          (false, _) => Colors.grey.withValues(alpha: 0.2),
        },
        borderRadius: BorderRadius.circular(20),
      ),
      child: RichText(
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
                if (stoptime.realtimeDeparture.relativeTimeInMinutes > 0)
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
              ])),
      /*   Text(
        //stoptime.realtimeDeparture.toTimeString(false),
        stoptime.realtimeDeparture.relativeTime,
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
          //isSelected ? const Color(0xff1a1611) : const Color(0xff8a8273),
        ),
      ), */
    );
  }
}
