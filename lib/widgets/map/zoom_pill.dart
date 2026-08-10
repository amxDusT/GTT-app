import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/widgets/animated_icon_button.dart';

/// A vertical pill-shaped control with a zoom-in button on top and a
/// zoom-out button on the bottom, sharing the [AnimatedIconButton] look.
class ZoomPill extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  const ZoomPill({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.floating,
        borderRadius: BorderRadius.circular(28),
        border: t.hairline,
        boxShadow: t.floatingShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedIconButton(
            selectedIcon: Icons.add,
            unselectedIcon: Icons.add,
            selectedColor: t.ink,
            unselectedColor: t.ink,
            onPressed: onZoomIn,
          ),
          Container(
            width: 22,
            height: 1,
            color: t.line,
          ),
          AnimatedIconButton(
            selectedIcon: Icons.remove,
            unselectedIcon: Icons.remove,
            selectedColor: t.ink,
            unselectedColor: t.ink,
            onPressed: onZoomOut,
          ),
        ],
      ),
    );
  }
}
