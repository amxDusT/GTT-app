import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/widgets/map/pulsing_dot.dart';

const _bgInset = Color(0xff13100c);
const _ink = Color(0xfff3ede0);
const _inkDim = Color(0xffa89e89);
// ignore: unused_element
const _inkMute = Color(0xff6e6555);
const _good = Color(0xff9bd14a);
const _bad = Color(0xffff6b6b);

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
      dotColor = _good;
      text = 'Live · adesso'.hc;
      textColor = _ink;
      pulse = true;
      stale = false;
    } else if (seconds < 60) {
      final val = (seconds / 5).toInt();

      dotColor = _good;
      text = 'Aggiornato ${val * 5}s fa'.hc;
      textColor = _inkDim;
      pulse = true;
      stale = false;
    } else {
      dotColor = _bad;
      text = 'Aggiornato ${seconds ~/ 60} min fa'.hc;
      textColor = _bad;
      pulse = false;
      stale = true;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: stale ? _bad.withValues(alpha: .09) : _bgInset,
        borderRadius: BorderRadius.circular(100),
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
