import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class NavPillItem {
  final IconData icon;
  final String label;

  const NavPillItem({required this.icon, required this.label});
}

class PillPalette {
  final Color background;
  final Color selectedFill;
  final Color selectedForeground;
  final Color unselectedForeground;

  const PillPalette({
    required this.background,
    required this.selectedFill,
    required this.selectedForeground,
    required this.unselectedForeground,
  });

  /// Dark keeps the inverted look (cream pill on the dark bar); light fills
  /// the selected tab with the accent. Both come from [AppTokens].
  factory PillPalette.of(BuildContext context, Color? accent) {
    final t = context.tokens;
    return PillPalette(
      background: t.bgRaised,
      selectedFill: t.isDark ? t.ink : (accent ?? t.accent),
      selectedForeground: t.isDark ? t.bg : t.onAccent,
      unselectedForeground: t.inkDim,
    );
  }
}

class FloatingNavPill extends StatelessWidget {
  final List<NavPillItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final Color? accentColor;
  final Color? backgroundColor;
  final bool showAllLabels;
  final bool expand;
  const FloatingNavPill({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.accentColor,
    this.backgroundColor,
    this.showAllLabels = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = PillPalette.of(context, accentColor);
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(40),
      color: backgroundColor ?? palette.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;
            final button = NavPillButton(
              item: items[i],
              selected: selected,
              palette: palette,
              alwaysShowLabel: showAllLabels,
              expand: expand,
              onTap: () => onChanged(i),
            );
            return expand ? Expanded(child: button) : button;
          }),
        ),
      ),
    );
  }
}

class NavPillButton extends StatefulWidget {
  final NavPillItem item;
  final bool selected;
  final PillPalette palette;
  final VoidCallback onTap;
  final bool alwaysShowLabel;
  final bool expand;

  const NavPillButton({
    super.key,
    required this.item,
    required this.selected,
    required this.palette,
    required this.onTap,
    this.alwaysShowLabel = false,
    this.expand = false,
  });

  @override
  State<NavPillButton> createState() => _NavPillButtonState();
}

class _NavPillButtonState extends State<NavPillButton>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 150);

  bool get _showLabel => widget.selected || widget.alwaysShowLabel;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
    value: _showLabel ? 1.0 : 0.0,
  );

  late final Animation<double> _widthAnim = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    reverseCurve: const Interval(0.45, 1.0, curve: Curves.easeInCubic),
  );

  late final Animation<double> _textOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    reverseCurve: const Interval(0.0, 0.45, curve: Curves.easeIn),
  );

  @override
  void didUpdateWidget(NavPillButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasShown = oldWidget.selected || oldWidget.alwaysShowLabel;
    if (_showLabel != wasShown) {
      _showLabel ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: widget.selected ? palette.selectedFill : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: widget.expand
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(
              widget.item.icon,
              size: 20,
              color: widget.selected
                  ? palette.selectedForeground
                  : palette.unselectedForeground,
            ),
            SizeTransition(
              axis: Axis.horizontal,
              sizeFactor: _widthAnim,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    widget.item.label,
                    style: Fonts.title(
                      color: widget.selected
                          ? palette.selectedForeground
                          : palette.unselectedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
