import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class HomeColorPicker extends StatelessWidget {
  final Color color;
  final bool isCurrentColor;
  final void Function() changeColor;
  const HomeColorPicker(
    this.color,
    this.isCurrentColor,
    this.changeColor, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: color.value == Storage.instance.chosenColor.value
            ? Border.all(
                color: Utils.darken(color, 30),
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside)
            : null,
        borderRadius: BorderRadius.circular(50),
        color: color,
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.8),
              offset: const Offset(1, 2),
              blurRadius: 5)
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeColor,
          borderRadius: BorderRadius.circular(50),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isCurrentColor ? 1 : 0,
            child: Icon(
              Icons.done,
              size: 24,
              color: useWhiteForeground(color) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
