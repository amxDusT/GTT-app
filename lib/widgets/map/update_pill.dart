import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/widgets/map/pulsing_dot.dart';

// ignore: unused_element

/// "Live · adesso" / "Aggiornato Xs fa"
class UpdatePill extends StatefulWidget {
  const UpdatePill({super.key, required this.lastUpdate});
  final DateTime lastUpdate;

  @override
  State<UpdatePill> createState() => _UpdatePillState();
}

class _UpdatePillState extends State<UpdatePill> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final seconds = DateTime.now()
        .difference(widget.lastUpdate)
        .inSeconds
        .clamp(0, 1 << 31);

    final Color dotColor;
    final Color textColor;
    final String text;
    final bool pulse;
    final bool stale;
    if (seconds < 5) {
      dotColor = t.good;
      text = 'Live · adesso'.hc;
      textColor = t.ink;
      pulse = true;
      stale = false;
    } else if (seconds < 60) {
      final val = (seconds / 5).toInt();

      dotColor = t.good;
      text = 'Aggiornato ${val * 5}s fa'.hc;
      textColor = t.inkDim;
      pulse = true;
      stale = false;
    } else {
      dotColor = t.bad;
      text = 'Aggiornato ${seconds ~/ 60} min fa'.hc;
      textColor = t.bad;
      pulse = false;
      stale = true;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: stale ? t.bad.withValues(alpha: .09) : t.floating,
        borderRadius: BorderRadius.circular(100),
        border: t.hairline,
        boxShadow: t.floatingShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 7,
        children: [
          pulse
              ? PulsingDot(size: 7, color: dotColor)
              : Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Fonts.title(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
