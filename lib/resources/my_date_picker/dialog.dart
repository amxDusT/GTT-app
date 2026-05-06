import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/my_date_picker/date_time_picker.dart';

Future<void> showDateTimePickerDialog({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  Function(DateTime selectedDate)? onDateSelected,
  Function(DateTime selectedTime)? onTimeSelected,
  Function(DateTime submittedDate)? onSubmittedDate,
  bool hasRestoreButton = true,
}) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: DustDateTimePicker(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        onTimeSelected: onTimeSelected,
        onDateSelected: onDateSelected,
        onSubmittedDate: onSubmittedDate,
      ),
    ),
  );
}
