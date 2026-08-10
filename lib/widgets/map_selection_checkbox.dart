import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';

class MapSelectionCheckbox extends StatelessWidget {
  const MapSelectionCheckbox({
    super.key,
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final borderColor = selected ? t.ink : Theme.of(context).dividerColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        //color: Colors.red,
        width: 40,
        alignment: const AlignmentGeometry.directional(0, -.5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? t.accent : Colors.transparent,
            border: Border.all(color: borderColor, width: 1),
          ),
          child:
              selected ? Icon(Icons.check, color: t.onAccent, size: 24) : null,
        ),
      ),
    );
  }
}
