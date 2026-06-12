import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class PopupButton extends StatelessWidget {
  const PopupButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
  });
  final Widget icon;
  final VoidCallback onPressed;
  final Widget label;
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
            .copyWith(left: 8),
        splashFactory: NoSplash.splashFactory,
        visualDensity: VisualDensity.compact,
        backgroundColor: Colors.black,
        textStyle: Fonts.title(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [icon, label],
      ),
    );
  }
}
