import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/gtt/stoptime.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';

class PassageTime extends StatelessWidget {
  final Stoptime stoptime;
  final TextStyle? style;
  const PassageTime({
    super.key,
    required this.stoptime,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      Utils.dateToHourString(stoptime.realtimeDeparture, false),
      style: style ?? TextStyle(color: stoptime.realtime ? Colors.green : null),
    );
  }
}
