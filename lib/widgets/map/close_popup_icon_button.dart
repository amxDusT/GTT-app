import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';

class ClosePopupIconButton extends StatelessWidget {
  const ClosePopupIconButton({
    required this.controller,
    required this.marker,
    this.onPressed,
    super.key,
  });
  final MapPageController controller;
  final Marker marker;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return IconButton(
      icon: const Icon(Icons.close, size: 16),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: t.bgInset,
      ),
      onPressed: () {
        controller.popupController.hidePopupsOnlyFor([marker]);
        controller.lastOpenedMarker = null;
        onPressed?.call();
      },
    );
  }
}
