import 'package:flutter/material.dart';

/// An [IconButton] that switches between [selectedIcon] and [unselectedIcon]
/// and bounces with an elastic scale effect when pressed or when [selected]
/// changes.
class AnimatedIconButton extends StatefulWidget {
  const AnimatedIconButton({
    required this.selectedIcon,
    required this.unselectedIcon,
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
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final bool selected;
  final bool animate;
  final VoidCallback? onPressed;
  final VisualDensity? visualDensity;
  final ButtonStyle? style;
  final double? iconSize;
  final Color? selectedColor;
  final Color? unselectedColor;

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    value: 1.0,
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 0.5, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
  );

  @override
  void didUpdateWidget(AnimatedIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && widget.selected != oldWidget.selected) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() {
    if (widget.animate) _controller.forward(from: 0);
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: widget.style,
      visualDensity: widget.visualDensity,
      iconSize: widget.iconSize,
      icon: ScaleTransition(
        scale: _scale,
        child: Icon(
          widget.selected ? widget.selectedIcon : widget.unselectedIcon,
          color:
              widget.selected ? widget.selectedColor : widget.unselectedColor,
        ),
      ),
      onPressed: widget.onPressed == null ? null : _handlePressed,
    );
  }
}
