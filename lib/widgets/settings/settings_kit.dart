import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class SettingsTokens {
  final Color bg;
  final Color bgRaised;
  final Color bgInset;
  final Color ink;
  final Color inkDim;
  final Color inkMute;
  final Color line;
  final Color lineStrong;
  final Color accent;
  final Color good;
  final Color bad;

  const SettingsTokens({
    required this.bg,
    required this.bgRaised,
    required this.bgInset,
    required this.ink,
    required this.inkDim,
    required this.inkMute,
    required this.line,
    required this.lineStrong,
    required this.accent,
    required this.good,
    required this.bad,
  });

  factory SettingsTokens.of(bool dark) => dark
      ? const SettingsTokens(
          bg: Color(0xff1a1611),
          bgRaised: Color(0xff221d17),
          bgInset: Color(0xff13100c),
          ink: Color(0xfff3ede0),
          inkDim: Color(0xffa89e89),
          inkMute: Color(0xff6e6555),
          line: Color(0xff332c22),
          lineStrong: Color(0xff473e30),
          accent: Color(0xffff7a3f),
          good: Color(0xff9bd14a),
          bad: Color(0xffff6b6b),
        )
      : const SettingsTokens(
          bg: Color(0xfff5f1e8),
          bgRaised: Color(0xfffbf8f0),
          bgInset: Color(0xffece6d8),
          ink: Color(0xff1a1611),
          inkDim: Color(0xff5a5447),
          inkMute: Color(0xff8a8273),
          line: Color(0xffe2dccb),
          lineStrong: Color(0xffc8bfa8),
          accent: Color(0xffff5a1f),
          good: Color(0xff3a8c2c),
          bad: Color(0xffc42b1c),
        );
}

class SettingsHeader extends StatelessWidget {
  final SettingsTokens tokens;
  final String eyebrow;
  final String title;
  final VoidCallback? onBack;

  const SettingsHeader({
    super.key,
    required this.tokens,
    required this.eyebrow,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          if (onBack != null) ...[
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.bgRaised,
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.line),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: tokens.ink),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: Fonts.subtitle(
                    fontSize: 10,
                    letterSpacing: 1.6,
                    color: tokens.inkMute,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: Fonts.title(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.1,
                    color: tokens.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsSectionLabel extends StatelessWidget {
  final SettingsTokens tokens;
  final String label;

  const SettingsSectionLabel({
    super.key,
    required this.tokens,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 6),
      child: Text(
        label.toUpperCase(),
        style: Fonts.subtitle(
          fontSize: 10,
          letterSpacing: 1.8,
          color: tokens.inkMute,
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final SettingsTokens tokens;
  final List<Widget> children;

  const SettingsCard({
    super.key,
    required this.tokens,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: tokens.bgRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.line),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  final SettingsTokens tokens;

  const SettingsDivider({super.key, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: tokens.line);
  }
}

class SettingsIconChip extends StatelessWidget {
  final SettingsTokens tokens;
  final IconData icon;
  final bool danger;

  const SettingsIconChip({
    super.key,
    required this.tokens,
    required this.icon,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tokens.bgInset,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: danger ? tokens.bad : tokens.inkDim),
    );
  }
}

class SettingsRow extends StatelessWidget {
  final SettingsTokens tokens;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  const SettingsRow({
    super.key,
    required this.tokens,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = danger ? tokens.bad : tokens.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            SettingsIconChip(tokens: tokens, icon: icon, danger: danger),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Fonts.title(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Fonts.title(fontSize: 12, color: tokens.inkMute),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsSwitch extends StatelessWidget {
  final SettingsTokens tokens;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    super.key,
    required this.tokens,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? tokens.accent : tokens.lineStrong,
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
