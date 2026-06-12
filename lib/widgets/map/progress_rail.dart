import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/widgets/map/pulsing_dot.dart';

const _surface = Color(0xff221d17);
const _ink = Color(0xfff3ede0);
const _inkDim = Color(0xffa89e89);
const _inkMute = Color(0xff6e6555);

/// Vertical rail: hollow dot (last stop) → pulsing dot (vehicle) → solid
/// dot (next stop), connected by a faint line in the route color.
class ProgressRail extends StatelessWidget {
  const ProgressRail({
    super.key,
    required this.lineColor,
    required this.lastStopName,
    required this.nextStopName,
  });
  final Color lineColor;
  final String lastStopName;
  final String nextStopName;

  @override
  Widget build(BuildContext context) {
    // The text column drives the height; the rail overlays it via
    // Positioned.fill (IntrinsicHeight would break the LayoutBuilder
    // inside AutoShrinkText).
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 14,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 6,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: lineColor.withValues(alpha: .27),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // last stop — passed, hollow
              Positioned(
                left: 2,
                top: 4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _surface,
                    border: Border.all(
                      color: lineColor.withValues(alpha: .53),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // vehicle — en route, pulsing
              Positioned.fill(
                child: Align(
                  alignment: const Alignment(0, 0.15),
                  child: PulsingDot(size: 8, color: lineColor, glow: true),
                ),
              ),
              // next stop — destination, solid
              Positioned(
                left: 2,
                bottom: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lineColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              RailStop(
                label: 'ULTIMA FERMATA'.hc,
                name: lastStopName,
                isNext: false,
              ),
              RailStop(
                label: 'PROSSIMA FERMATA'.hc,
                name: nextStopName,
                isNext: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RailStop extends StatelessWidget {
  const RailStop({
    super.key,
    required this.label,
    required this.name,
    required this.isNext,
  });
  final String label;
  final String name;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          label,
          style: Fonts.subtitle(
            fontSize: 10,
            letterSpacing: 1.4,
            color: _inkMute,
          ),
        ),
        Text(
          name.capitalizeWords,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Fonts.title(
            fontSize: isNext ? 16 : 14,
            fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
            color: isNext ? _ink : _inkDim,
          ),
        ),
      ],
    );
  }
}
