import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CircleButton extends StatelessWidget {
  final String? tooltip;
  final Widget? child;
  final void Function()? onPressed;
  final Widget? icon;
  const CircleButton({
    super.key,
    this.child,
    this.onPressed,
    this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    assert(icon != null || child != null, 'icon or child must be not null');
    return CircleAvatar(
      radius: 25,
      backgroundColor: Get.theme.colorScheme.primaryContainer.withOpacity(0.8),
      child: child ??
          IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: icon!,
          ),
    );
  }
}
