import 'package:flutter/material.dart';
import 'package:flutter_gtt/resources/my_date_picker/date_picker.dart';
import 'package:flutter_gtt/resources/my_date_picker/time_picker.dart';

class DustDateTimePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime selectedDate)? onDateSelected;
  final Function(DateTime selectedTime)? onTimeSelected;
  final Function(DateTime submittedDate)? onSubmittedDate;
  final bool hasRestoreButton;
  DustDateTimePicker({
    super.key,
    DateTime? initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.onTimeSelected,
    this.onSubmittedDate,
    this.hasRestoreButton = true,
  }) : initialDate = initialDate ?? DateTime.now() {
    assert(
      firstDate == null || lastDate == null || firstDate!.isBefore(lastDate!),
    );
    assert(firstDate == null || firstDate!.isBefore(this.initialDate));

    assert(
      lastDate == null || firstDate == null || lastDate!.isAfter(firstDate!),
    );
    assert(lastDate == null || lastDate!.isAfter(this.initialDate));
  }

  @override
  State<DustDateTimePicker> createState() => _DustDateTimePickerState();
}

class _DustDateTimePickerState extends State<DustDateTimePicker> {
  late Size size;
  late ValueNotifier<DateTime> selectedDateNotifier;
  @override
  void dispose() {
    selectedDateNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedDateNotifier = ValueNotifier<DateTime>(widget.initialDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
  }

  @override
  void didUpdateWidget(covariant DustDateTimePicker oldWidget) {
    size = MediaQuery.of(context).size;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width * 0.8,
      height: size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Scegli la data e l\'ora',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(child: Container()),
          ValueListenableBuilder(
              valueListenable: selectedDateNotifier,
              builder: (context, value, child) {
                return DustDatePicker(
                  initialDate: value,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateSelected: (selectedDate) {
                    setState(() {
                      selectedDateNotifier.value = selectedDate;
                    });
                    if (widget.onDateSelected != null) {
                      widget.onDateSelected!(selectedDate);
                    }
                  },
                );
              }),
          Flexible(child: Container()),
          DustTimePicker(
            initialDate: selectedDateNotifier.value,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            onTimeSelected: (selectedTime) {
              selectedDateNotifier.value = selectedTime;

              if (widget.onTimeSelected != null) {
                widget.onTimeSelected!(selectedTime);
              }
            },
          ),
          Flexible(flex: 2, child: Container()),
          if (widget.hasRestoreButton)
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDateNotifier.value = DateTime.now();
                });
                if (widget.onSubmittedDate != null) {
                  widget.onSubmittedDate!(widget.initialDate);
                }
              },
              child: const Text('Reimposta ora attuale'),
            ),
          Flexible(flex: 2, child: Container()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Annulla'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (widget.onSubmittedDate != null) {
                    widget.onSubmittedDate!(selectedDateNotifier.value);
                  }
                },
                child: const Text('Imposta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
