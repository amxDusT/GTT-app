import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/spacing.dart';

class AppHeader extends StatelessWidget {
  final Widget subtitle;
  final String titleTop;
  final String titleBottom;
  final Color? accentColor;
  final List<Widget> actions;

  const AppHeader({
    super.key,
    required this.subtitle,
    required this.titleTop,
    required this.titleBottom,
    this.accentColor,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                subtitle,
                Spacing.vGap8,
                Text(
                  titleTop,
                  style: Fonts.title(
                    fontSize: 52,
                    fontWeight: FontWeight.w600,
                    height: .9,
                  ),
                ),
                Text(
                  titleBottom,
                  style: Fonts.title(
                    fontSize: 52,
                    fontWeight: FontWeight.w600,
                    height: .9,
                    color: accentColor ?? context.tokens.accent,
                  ),
                ),
              ],
            ),
          ),
          if (actions.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
        ],
      ),
    );
  }
}
