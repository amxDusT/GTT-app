import 'package:flutter/material.dart';

enum ButtonDirection {
  back,
  forward,
}

class BackForwardButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;
  final double iconSize;
  final ButtonDirection direction;
  const BackForwardButton({
    super.key,
    this.visible = true,
    required this.onPressed,
    this.iconSize = 36,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    return visible
        ? SizedBox(
            width: iconSize + 16,
            height: iconSize + 16,
            child: IconButton.filled(
              iconSize: iconSize,
              onPressed: onPressed,
              icon: Icon(direction == ButtonDirection.back
                  ? Icons.keyboard_arrow_left
                  : Icons.keyboard_arrow_right),
            ),
          )
        : SizedBox(width: iconSize + 16);
  }
}
