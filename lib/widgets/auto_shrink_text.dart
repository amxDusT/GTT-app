import 'package:flutter/material.dart';

/// Wraps up to [maxLines], shrinking the font until the whole text fits;
/// ellipsizes only if it still overflows at [minFontSize].
class AutoShrinkText extends StatelessWidget {
  const AutoShrinkText(
    this.text, {
    super.key,
    required this.style,
    required this.maxLines,
    required this.minFontSize,
  });
  final String text;
  final TextStyle style;
  final int maxLines;
  final double minFontSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final textScaler = MediaQuery.textScalerOf(context);
      var fontSize = style.fontSize ?? 14;
      while (fontSize > minFontSize) {
        final painter = TextPainter(
          text: TextSpan(
            text: text,
            style: style.copyWith(fontSize: fontSize),
          ),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout(maxWidth: constraints.maxWidth);
        if (!painter.didExceedMaxLines) break;
        fontSize -= 0.5;
      }
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style.copyWith(fontSize: fontSize),
      );
    });
  }
}
