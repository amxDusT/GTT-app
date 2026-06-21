import 'package:flutter/material.dart';
import 'package:torino_mobility/widgets/animated_icon_button.dart';

class CircleButton extends StatelessWidget {
  final String? tooltip;
  final Widget? child;
  final void Function()? onPressed;
  final Widget? icon;
  final double size;
  const CircleButton({
    super.key,
    this.child,
    this.onPressed,
    this.icon,
    this.tooltip,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    assert(icon != null || child != null, 'icon or child must be not null');
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: kBgInset.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(color: kLineBorder),
      ),
      child: child ??
          IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            color: kInk,
            icon: icon!,
          ),
    );
  }
}
