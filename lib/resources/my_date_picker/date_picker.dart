import 'package:flutter/material.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:intl/intl.dart';

class DustDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime selectedDate)? onDateSelected;
  const DustDatePicker({
    super.key,
    required this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
  });

  @override
  State<DustDatePicker> createState() => _DustDatePickerState();
}

class _DustDatePickerState extends State<DustDatePicker> {
  late DateTime _date;
  bool rightDirection = false;
  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  void _onDateForward() {
    if (Utils.isSameDay(widget.initialDate, widget.lastDate)) {
      return;
    }
    setState(() {
      rightDirection = true;
      _date = _date.add(const Duration(days: 1));
    });
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(widget.initialDate.add(const Duration(days: 1)));
    }
  }

  void _onDateBackward() {
    if (Utils.isSameDay(widget.initialDate, widget.firstDate)) {
      return;
    }
    setState(() {
      rightDirection = false;
      _date = _date.subtract(const Duration(days: 1));
    });
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(
          widget.initialDate.subtract(const Duration(days: 1)));
    }
  }

  String _getFormattedDate(DateTime date) {
    if (Utils.isSameDay(widget.initialDate, DateTime.now())) {
      return 'Oggi';
    } else if (Utils.isSameDay(
        widget.initialDate, DateTime.now().add(const Duration(days: 1)))) {
      return 'Domani';
    } else if (Utils.isSameDay(
        widget.initialDate, DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Ieri';
    }

    return DateFormat('EEE dd MMM yy', 'it').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: _onDateBackward,
          icon: const Icon(Icons.arrow_back),
        ),
        SizedBox(
          width: 100,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(rightDirection ? 1 : -1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            layoutBuilder:
                (Widget? currentChild, List<Widget> previousChildren) {
              return Center(
                child: currentChild!,
              );
            },
            child: Text(
              _getFormattedDate(_date),
              key: ValueKey<DateTime>(_date),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        IconButton(
          onPressed: _onDateForward,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}
