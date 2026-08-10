import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

final class AppTheme {
  static ThemeData get light {
    // Seeded from the app accent (not a stock blue) so Material-derived
    // colours land in the same warm family as AppTokens.
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTokens.light.accent,
        surface: AppTokens.light.bg,
      ),
      scaffoldBackgroundColor: AppTokens.light.bg,
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: _applyFont(base.textTheme, color: AppTokens.light.ink),
      inputDecorationTheme: _inputDecoration(
        base.dividerColor,
        fillColor: AppTokens.light.bgInset,
      ),
      extensions: const [AppTokens.light],
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTokens.dark.accent,
        brightness: Brightness.dark,
        surface: AppTokens.dark.bg,
      ),
      scaffoldBackgroundColor: AppTokens.dark.bg,
      useMaterial3: true,
      scrollbarTheme: ScrollbarThemeData(
        crossAxisMargin: 0,
        radius: const Radius.circular(100),
        thumbColor: WidgetStatePropertyAll(
          AppTokens.dark.ink.withValues(alpha: 0.4),
        ),
      ),
    );
    return base.copyWith(
      textTheme: _applyFont(base.textTheme, color: AppTokens.dark.ink),
      inputDecorationTheme: _inputDecoration(
        base.dividerColor,
        fillColor: AppTokens.dark.bgRaised,
      ),
      extensions: const [AppTokens.dark],
    );
  }

  static InputDecorationTheme _inputDecoration(
    Color borderColor, {
    Color? fillColor,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(100),
      borderSide: BorderSide(color: borderColor),
    );
    return InputDecorationTheme(
      border: border,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      filled: fillColor != null,
      fillColor: fillColor,
    );
  }

  static TextTheme _applyFont(TextTheme base, {Color? color}) {
    final subtitle = Fonts.subtitle();
    return base.apply(
      fontFamily: subtitle.fontFamily,
      fontFamilyFallback: subtitle.fontFamilyFallback,
      bodyColor: color,
      displayColor: color,
    );
  }
}
