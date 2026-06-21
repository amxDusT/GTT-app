import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:torino_mobility/widgets/settings/settings_kit.dart';

class ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final SettingsTokens tokens;
  final VoidCallback onTap;
  const ColorSwatch({
    super.key,
    required this.color,
    required this.selected,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? tokens.ink : tokens.line,
            width: selected ? 2.5 : 1,
          ),
        ),
      ),
    );
  }
}
