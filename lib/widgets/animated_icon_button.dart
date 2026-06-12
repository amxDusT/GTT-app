import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

const _bgInset = Color(0xff13100c);
const _ink = Color(0xfff3ede0);
const _lineBorder = Color(0xff332c22);
const _accent = Color(0xffff7a3f);

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
    this.selectedLabel,
    this.unselectedLabel,
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
  final String? selectedLabel;
  final String? unselectedLabel;

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
    final label = widget.selected
        ? (widget.selectedLabel ?? widget.unselectedLabel)
        : (widget.unselectedLabel ?? widget.selectedLabel);
    if (label != null) return _buildPill(label);

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

  Widget _buildPill(String label) {
    final selectedColor = widget.selectedColor ?? _accent;
    return TextButton(
      onPressed: widget.onPressed == null ? null : _handlePressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(0, 40),
        visualDensity: widget.visualDensity,
        backgroundColor:
            widget.selected ? selectedColor.withValues(alpha: .11) : _bgInset,
        foregroundColor:
            widget.selected ? selectedColor : widget.unselectedColor ?? _ink,
        shape: StadiumBorder(
          side: BorderSide(
            color: widget.selected ? selectedColor : _lineBorder,
          ),
        ),
      ).merge(widget.style),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Icon(
              widget.selected ? widget.selectedIcon : widget.unselectedIcon,
              size: widget.iconSize ?? 16,
            ),
          ),
          Text(
            label,
            style: Fonts.title(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
