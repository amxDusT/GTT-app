import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/widgets/passage_time.dart';

class DisplayHours extends StatelessWidget {
  const DisplayHours({
    super.key,
    required this.vehicle,
    required this.isSelected,
  });

  final RouteWithDetails vehicle;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (vehicle.stoptimes.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Non ci sono passaggi',
                style: Get.textTheme.labelMedium!.copyWith(
                    letterSpacing: 1.5,
                    color: isSelected
                        ? const Color(0xff1a1611)
                        : const Color(0xff8a8273)),
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: vehicle.stoptimes
            .getRange(
              0,
              min(vehicle.stoptimes.length, maxHours),
            )
            .map(
              (stoptime) => PassageTime(
                stoptime: stoptime,
                isSelected: isSelected,
              ),
            )
            .toList(),
      ),
    );
  }
}
