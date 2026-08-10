import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/utils/color_utils.dart';

/// The app's colour palette, resolved from the ambient [Theme].
///
/// Registered on both [ThemeData]s in `AppTheme`, so widgets read it with
/// `context.tokens` and never branch on brightness themselves. Because it goes
/// through `Theme.of`, every reader rebuilds automatically when the theme
/// changes, and [lerp] cross-fades the palette during the switch.
class AppTokens extends ThemeExtension<AppTokens> {
  final Brightness brightness;
  final Color bg;
  final Color bgRaised;
  final Color bgInset;
  final Color ink;
  final Color inkDim;
  final Color inkMute;
  final Color line;
  final Color lineStrong;
  final Color accent;

  /// Text and icons drawn *on top of* an [accent] fill.
  final Color onAccent;
  final Color good;

  /// Amber, for "saved" / "highlighted" states. Same family as the warn toast.
  final Color warn;
  final Color bad;

  const AppTokens({
    required this.brightness,
    required this.bg,
    required this.bgRaised,
    required this.bgInset,
    required this.ink,
    required this.inkDim,
    required this.inkMute,
    required this.line,
    required this.lineStrong,
    required this.accent,
    required this.onAccent,
    required this.good,
    required this.warn,
    required this.bad,
  });

  bool get isDark => brightness == Brightness.dark;

  /// Picks between two brightness-dependent values.
  ///
  /// The escape hatch for the rare case that isn't a colour — prefer a named
  /// token or one of the helpers below when one fits.
  T pick<T>({required T light, required T dark}) => isDark ? dark : light;

  /// Adapts an arbitrary runtime colour (a stop's colour, a line's colour) so
  /// it sits correctly on the current background.
  Color tint(Color color) =>
      isDark ? ColorUtils.darken(color, 30) : ColorUtils.lighten(color);

  /// A translucent wash of [color], for filled status chips and cards.
  Color soft(Color color, {double light = 0.11, double dark = 0.13}) =>
      color.withValues(alpha: pick(light: light, dark: dark));

  /// A readable foreground for a surface produced by [tint].
  ///
  /// [tint] darkens in dark mode but *lightens* in light mode, and the input is
  /// an arbitrary user-chosen colour, so neither [ink] nor white works for all
  /// of them — a tinted yellow stop is pale in both modes. Picks whichever of
  /// the two palette inks actually contrasts with the result.
  Color onTint(Color color) => onColor(tint(color));

  /// A readable foreground for any opaque surface whose colour isn't known at
  /// build time — a raw route colour, a tinted stop colour.
  Color onColor(Color surface) =>
      _contrast(light.ink, surface) >= _contrast(dark.ink, surface)
          ? light.ink
          : dark.ink;

  /// WCAG relative-contrast ratio between two opaque colours.
  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Surface for chrome floating over the map (buttons, pills, the top bar).
  /// Slightly translucent so the map stays legible underneath.
  Color get floating => bgInset.withValues(alpha: 0.85);

  /// Edge that keeps floating chrome from blending into the map beneath it.
  ///
  /// Tinted from [ink] rather than [line]: a border has to read against the
  /// chip it outlines, and the divider weights are near-invisible there
  /// (`line` on `bgRaised` is only 1.2:1). Pair with [floatingShadow] — no
  /// single border colour can contrast with both the chip and an arbitrary
  /// map image, so the shadow does the separating.
  Border get hairline => Border.all(color: ink.withValues(alpha: 0.28));

  /// Soft drop shadow that lifts floating chrome off the map.
  List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color:
              const Color(0xff000000).withValues(alpha: isDark ? 0.45 : 0.20),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  // Contrast ratios in the comments are WCAG, measured against [bg].
  static const AppTokens light = AppTokens(
    brightness: Brightness.light,
    bg: Color(0xfff5f1e8),
    bgRaised: Color(0xfffbf8f0),
    bgInset: Color(0xffece6d8),
    ink: Color(0xff1a1611), // 15.97
    inkDim: Color(0xff5a5447), // 6.67
    inkMute: Color(0xff6e6555), // 5.10, 4.62 on bgInset
    line: Color(0xffe2dccb),
    lineStrong: Color(0xffc8bfa8),
    accent: Color(0xffc2410c), // 4.59 as text, 5.18 under white
    onAccent: Color(0xffffffff),
    good: Color(0xff2f7523), // 5.05
    warn: Color(0xff96590a), // 5.30 on bgRaised, 4.52 on bgInset
    bad: Color(0xffc42b1c), // 5.02
  );

  static const AppTokens dark = AppTokens(
    brightness: Brightness.dark,
    bg: Color(0xff1a1611),
    bgRaised: Color(0xff221d17),
    bgInset: Color(0xff13100c),
    ink: Color(0xfff3ede0), // 15.43
    inkDim: Color(0xffa89e89), // 6.79
    inkMute: Color(0xff8f8778), // 5.06, 4.70 on bgRaised
    line: Color(0xff332c22),
    lineStrong: Color(0xff473e30),
    accent: Color(0xffff7a3f), // 6.95
    onAccent: Color(0xff1a1611),
    good: Color(0xff9bd14a), // 9.95
    warn: Color(0xffffb547), // 9.52 on bgRaised
    bad: Color(0xffff6b6b), // 6.49
  );

  @override
  AppTokens copyWith({
    Brightness? brightness,
    Color? bg,
    Color? bgRaised,
    Color? bgInset,
    Color? ink,
    Color? inkDim,
    Color? inkMute,
    Color? line,
    Color? lineStrong,
    Color? accent,
    Color? onAccent,
    Color? good,
    Color? warn,
    Color? bad,
  }) {
    return AppTokens(
      brightness: brightness ?? this.brightness,
      bg: bg ?? this.bg,
      bgRaised: bgRaised ?? this.bgRaised,
      bgInset: bgInset ?? this.bgInset,
      ink: ink ?? this.ink,
      inkDim: inkDim ?? this.inkDim,
      inkMute: inkMute ?? this.inkMute,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      good: good ?? this.good,
      warn: warn ?? this.warn,
      bad: bad ?? this.bad,
    );
  }

  @override
  AppTokens lerp(covariant ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      // Derived values can't be interpolated: flip at the halfway point.
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: Color.lerp(bg, other.bg, t)!,
      bgRaised: Color.lerp(bgRaised, other.bgRaised, t)!,
      bgInset: Color.lerp(bgInset, other.bgInset, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkDim: Color.lerp(inkDim, other.inkDim, t)!,
      inkMute: Color.lerp(inkMute, other.inkMute, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      good: Color.lerp(good, other.good, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      bad: Color.lerp(bad, other.bad, t)!,
    );
  }
}

extension AppTokensContext on BuildContext {
  /// The app palette for the current theme. See [AppTokens].
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppTokens.dark
          : AppTokens.light);
}
