import 'package:flutter/material.dart';

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
    const fillColor = Color(0xFFFF8A3D);
    final borderColor =
        selected ? const Color(0xff1a1611) : Theme.of(context).dividerColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50,
        alignment: const AlignmentGeometry.directional(0, -.5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? fillColor : Colors.transparent,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: selected
              ? const Icon(Icons.check, color: Color(0xff1a1611), size: 24)
              : null,
        ),
      ),
    );
  }
}
