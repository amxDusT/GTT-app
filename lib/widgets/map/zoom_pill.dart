import 'package:flutter/material.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: kBgInset.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kLineBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedIconButton(
            selectedIcon: Icons.add,
            unselectedIcon: Icons.add,
            selectedColor: kInk,
            unselectedColor: kInk,
            onPressed: onZoomIn,
          ),
          Container(
            width: 22,
            height: 1,
            color: kLineBorder,
          ),
          AnimatedIconButton(
            selectedIcon: Icons.remove,
            unselectedIcon: Icons.remove,
            selectedColor: kInk,
            unselectedColor: kInk,
            onPressed: onZoomOut,
          ),
        ],
      ),
    );
  }
}
