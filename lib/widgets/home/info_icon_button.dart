import 'package:flutter/material.dart';

class InfoIconButton extends StatelessWidget {
  const InfoIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.iconSize = 20,
    this.color,
    super.key,
  });

  final IconData icon;
  final Function() onPressed;
  final String tooltip;
  final double iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xff524446).withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      onPressed: onPressed,
      tooltip: tooltip,
      iconSize: iconSize,
      icon: Icon(
        icon,
        size: iconSize,
        color: color,
      ),
    );
  }
}
