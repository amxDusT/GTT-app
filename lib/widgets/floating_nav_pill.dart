import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';

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

  factory PillPalette.of(Color accent) {
    final isDark = Get.find<SettingsController>().isDarkMode.value;
    if (isDark) {
      return const PillPalette(
        background: Color(0xff1f1b16),
        selectedFill: Color(0xfff5efe0),
        selectedForeground: Color(0xff1f1b16),
        unselectedForeground: Color(0xffc9c0b0),
      );
    }
    return PillPalette(
      background: Colors.white,
      selectedFill: accent,
      selectedForeground: Colors.white,
      unselectedForeground: Colors.black87,
    );
  }
}

class FloatingNavPill extends StatelessWidget {
  final List<NavPillItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final Color accentColor;

  const FloatingNavPill({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.accentColor = const Color(0xffff7a3f),
  });

  @override
  Widget build(BuildContext context) {
    final palette = PillPalette.of(accentColor);
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(40),
      color: palette.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;
            return NavPillButton(
              item: items[i],
              selected: selected,
              palette: palette,
              onTap: () => onChanged(i),
            );
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

  const NavPillButton({
    super.key,
    required this.item,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  @override
  State<NavPillButton> createState() => _NavPillButtonState();
}

class _NavPillButtonState extends State<NavPillButton>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 150);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
    value: widget.selected ? 1.0 : 0.0,
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
    if (widget.selected != oldWidget.selected) {
      widget.selected ? _controller.forward() : _controller.reverse();
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
          mainAxisSize: MainAxisSize.min,
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
                    style: TextStyle(
                      color: palette.selectedForeground,
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
