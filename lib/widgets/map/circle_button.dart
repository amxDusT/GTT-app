import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';

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
    final t = context.tokens;
    assert(icon != null || child != null, 'icon or child must be not null');
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.floating,
        shape: BoxShape.circle,
        border: t.hairline,
        boxShadow: t.floatingShadow,
      ),
      child: child ??
          IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            color: t.ink,
            icon: icon!,
          ),
    );
  }
}
