import 'package:flutter/material.dart';
import 'package:torino_mobility/models/toast.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class GttToast extends StatelessWidget {
  final ToastTone tone;
  final String title;
  final String? message;
  final ToastAction? action;
  final VoidCallback? onDismiss;

  const GttToast({
    super.key,
    required this.title,
    this.tone = ToastTone.error,
    this.message,
    this.action,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final style = ToastStyle.of(context, tone);
    final double topInset = MediaQuery.of(context).padding.top + 16;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        border: Border(
          bottom: BorderSide(color: style.accent.withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 14),
            blurRadius: 30,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, topInset, 14, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: style.accent.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(style.icon, size: 16, color: style.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style.eyebrow.toUpperCase(),
                  style: Fonts.subtitle(
                    fontSize: 10,
                    letterSpacing: 1.6,
                    color: style.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: Fonts.title(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: -0.16,
                    color: style.ink,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    message!,
                    style: Fonts.title(
                      fontSize: 13,
                      height: 1.4,
                      color: style.inkDim,
                    ),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: action!.onPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: style.accent,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        action!.label,
                        style: Fonts.title(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                child: Icon(Icons.close_rounded, size: 16, color: style.inkDim),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
