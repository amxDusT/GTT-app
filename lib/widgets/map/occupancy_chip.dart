import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class OccupancyChip extends StatelessWidget {
  const OccupancyChip({super.key, required this.isFull});
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final barColor = isFull ? t.bad : t.good;
    final activeBars = isFull ? 3 : 1;
    const barHeights = [5.0, 8.0, 11.0];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: t.bgInset,
        borderRadius: const BorderRadius.all(Radius.circular(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 7,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              for (var i = 0; i < barHeights.length; i++)
                Container(
                  width: 3,
                  height: barHeights[i],
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: i < activeBars ? barColor : t.line,
                  ),
                ),
            ],
          ),
          Text(
            isFull ? 'Affollato'.hc : 'Posti disponibili'.hc,
            style: Fonts.title(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: t.inkDim,
            ),
          ),
        ],
      ),
    );
  }
}
