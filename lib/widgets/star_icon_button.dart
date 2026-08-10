import 'package:flutter/material.dart';
import 'package:torino_mobility/widgets/animated_icon_button.dart';

class StarIconButton extends StatelessWidget {
  const StarIconButton({
    this.onPressed,
    this.selected = false,
    this.animate = true,
    this.visualDensity,
    this.style,
    this.iconSize,
    this.selectedColor,
    this.unselectedColor,
    super.key,
  });
  final bool selected;
  final bool animate;
  final VoidCallback? onPressed;
  final VisualDensity? visualDensity;
  final ButtonStyle? style;
  final double? iconSize;
  final Color? selectedColor;
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedIconButton(
      selectedIcon: Icons.star,
      unselectedIcon: Icons.star_outline,
      selected: selected,
      animate: animate,
      onPressed: onPressed,
      visualDensity: visualDensity,
      style: style,
      iconSize: iconSize,
      selectedColor: selectedColor ?? Colors.amber,
      unselectedColor: unselectedColor ?? Colors.grey,
    );
  }
}
