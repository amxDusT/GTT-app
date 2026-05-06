import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

final class AppTheme {
  static const _seed = Colors.blue;
  static const _darkBackground = Color(0xFF1A1611);
  static const _darkInputFill = Color(0xFF221D17);
  static const _darkText = Color(0xFFF3EDE0);

  static ThemeData get light {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: _applyFont(base.textTheme, color: _darkBackground),
      inputDecorationTheme: _inputDecoration(base.dividerColor),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
        surface: _darkBackground,
      ),
      scaffoldBackgroundColor: _darkBackground,
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: _applyFont(base.textTheme, color: _darkText),
      inputDecorationTheme: _inputDecoration(
        base.dividerColor,
        fillColor: _darkInputFill,
      ),
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
