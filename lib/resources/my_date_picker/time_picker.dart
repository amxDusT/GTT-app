import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:torino_mobility/resources/my_date_picker/cupertino_picker.dart';

class DustTimePicker extends StatelessWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime selectedTime)? onTimeSelected;
  final double itemHeight;
  const DustTimePicker({
    super.key,
    required this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onTimeSelected,
    this.itemHeight = 60,
  });

  final int _maxHours = 24;
  final int _maxMinutes = 60;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // hour
        DustCupertinoPicker(
          itemHeight: itemHeight,
          selectedItem: initialDate.hour,
          items: List.generate(_maxHours, (index) => index),
          onSelectedItemChanged: (index) {
            if (onTimeSelected != null) {
              onTimeSelected!(DateTime(initialDate.year, initialDate.month,
                  initialDate.day, index, initialDate.minute));
            }
          },
        ),
        const SizedBox(width: 10),
        const Text(':'),
        const SizedBox(width: 10),
        DustCupertinoPicker(
          itemHeight: itemHeight,
          selectedItem: initialDate.minute,
          items: List.generate(_maxMinutes, (index) => index),
          onSelectedItemChanged: (index) {
            if (onTimeSelected != null) {
              onTimeSelected!(DateTime(
                initialDate.year,
                initialDate.month,
                initialDate.day,
                initialDate.hour,
                index,
              ));
            }
          },
        )
      ],
    );
  }
}
