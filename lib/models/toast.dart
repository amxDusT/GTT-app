import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';

enum ToastTone { error, warn, good, info }

class ToastAction {
  final String label;
  final VoidCallback onPressed;

  const ToastAction({
    required this.label,
    required this.onPressed,
  });
}

class ToastStyle {
  final Color background;
  final Color ink;
  final Color inkDim;
  final Color accent;
  final String eyebrow;
  final IconData icon;

  const ToastStyle({
    required this.background,
    required this.ink,
    required this.inkDim,
    required this.accent,
    required this.eyebrow,
    required this.icon,
  });

  factory ToastStyle.of(BuildContext context, ToastTone tone) {
    final dark = context.tokens.isDark;
    switch (tone) {
      case ToastTone.error:
        return ToastStyle(
          background: dark ? const Color(0xff3a1a16) : const Color(0xfffdecea),
          ink: dark ? const Color(0xffffd0c8) : const Color(0xff7a1a10),
          inkDim: dark ? const Color(0xffc89a92) : const Color(0xffa14638),
          accent: dark ? const Color(0xffff6b6b) : const Color(0xffc42b1c),
          eyebrow: 'Errore'.hc,
          icon: Icons.close_rounded,
        );
      case ToastTone.warn:
        return ToastStyle(
          background: dark ? const Color(0xff3a2c12) : const Color(0xfffcf2dd),
          ink: dark ? const Color(0xffffe2a8) : const Color(0xff6b4400),
          inkDim: dark ? const Color(0xffc8b079) : const Color(0xff9a7414),
          accent: dark ? const Color(0xffffb547) : const Color(0xffc87a00),
          eyebrow: 'Avviso'.hc,
          icon: Icons.warning_amber_rounded,
        );
      case ToastTone.good:
        return ToastStyle(
          background: dark ? const Color(0xff1d2e16) : const Color(0xffe9f4dd),
          ink: dark ? const Color(0xffcee9a0) : const Color(0xff2a5e1c),
          inkDim: dark ? const Color(0xff9ab37a) : const Color(0xff4a7a3c),
          accent: dark ? const Color(0xff9bd14a) : const Color(0xff3a8c2c),
          eyebrow: 'Fatto'.hc,
          icon: Icons.check_rounded,
        );
      case ToastTone.info:
        return ToastStyle(
          background: dark ? const Color(0xff16263a) : const Color(0xffeaf1fb),
          ink: dark ? const Color(0xffcbdcf7) : const Color(0xff14375f),
          inkDim: dark ? const Color(0xff92a6c8) : const Color(0xff46658c),
          accent: dark ? const Color(0xff6b9bd1) : const Color(0xff2f6fb0),
          eyebrow: 'Info'.hc,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}
