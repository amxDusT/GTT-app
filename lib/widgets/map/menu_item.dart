import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/spacing.dart';

class MenuItem<T> extends PopupMenuItem<T> {
  MenuItem({
    required String label,
    required IconData leadingIcon,
    required VoidCallback onTap,
    bool dangerous = false,
    super.key,
  }) : super(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: dangerous
                      ? Colors.red.withValues(alpha: 0.1)
                      : const Color(0xffe0e0e0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  leadingIcon,
                  color: dangerous ? Colors.red : null,
                  size: 20,
                ),
              ),
              Spacing.hGap16,
              Text(label,
                  style: Fonts.title(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: dangerous ? Colors.red : null,
                  )),
            ],
          ),
        );
}

class MenuDivider extends PopupMenuEntry {
  const MenuDivider({super.key});
  @override
  double get height => 1;

  @override
  bool represents(void value) => false;

  @override
  State createState() => _MenuDividerState();
}

class _MenuDividerState extends State<MenuDivider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: .2,
      color: Colors.grey[300],
    );
  }
}
