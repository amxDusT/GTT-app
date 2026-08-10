import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';

class InfoIconButton extends StatelessWidget {
  const InfoIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.iconSize = 20,
    this.color,
    this.backgroundColor,
    this.borderSide,
    super.key,
  });

  final IconData icon;
  final Function() onPressed;
  final String tooltip;
  final double iconSize;
  final Color? color;

  /// Defaults to a faint scrim of [AppTokens.ink], which reads on both a dark
  /// and a pale surface (a fixed dark scrim only worked in dark mode).
  final Color? backgroundColor;

  /// Set when the button floats over the map, so it doesn't blend into it.
  final BorderSide? borderSide;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor ?? t.ink.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: borderSide ?? BorderSide.none,
        ),
      ),
      onPressed: onPressed,
      tooltip: tooltip,
      iconSize: iconSize,
      icon: Icon(
        icon,
        size: iconSize,
        color: color ?? t.ink,
      ),
    );
  }
}
