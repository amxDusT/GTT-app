import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/models/toast.dart';
import 'package:torino_mobility/widgets/gtt_toast.dart';

class Toasts {
  static void show(
    String title, {
    String? message,
    ToastTone tone = ToastTone.error,
    ToastAction? action,
    Duration? duration,
    bool? closePrevious,
  }) async {
    if (closePrevious ?? false) {
      await Get.closeCurrentSnackbar();
    }

    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.GROUNDED,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        borderRadius: 0,
        duration: duration ?? const Duration(seconds: 3),
        animationDuration: const Duration(milliseconds: 320),
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        messageText: GttToast(
          tone: tone,
          title: title,
          message: message,
          action: action,
          onDismiss: () => Get.closeCurrentSnackbar(),
        ),
      ),
    );
  }
}
