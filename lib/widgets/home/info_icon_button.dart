import 'package:flutter/material.dart';

class InfoIconButton extends StatelessWidget {
  const InfoIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.iconSize = 20,
    this.color,
    this.backgroundColor = const Color.fromARGB(77, 82, 68, 70),
    super.key,
  });

  final IconData icon;
  final Function() onPressed;
  final String tooltip;
  final double iconSize;
  final Color? color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
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
