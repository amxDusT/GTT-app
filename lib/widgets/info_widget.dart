import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/fermata.dart';
import 'package:flutter_gtt/pages/map/map_page.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InfoWidget extends StatelessWidget {
  final Vehicle bus;
  const InfoWidget({super.key, required this.bus});

  void _openAlerts() {
    if (bus.alerts.isEmpty) {
      return;
    }
    Get.defaultDialog(middleText: bus.alerts[0]);
  }

  Widget _getHoursRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...bus.stoptimes
            .getRange(
                0,
                bus.stoptimes.length < MAX_HOURS
                    ? bus.stoptimes.length
                    : MAX_HOURS)
            .map(
              (e) => Text(
                DateFormat.Hm(Get.locale?.languageCode)
                    .format(e.realtimeDeparture),
                style: TextStyle(color: e.realtime ? Colors.green : null),
              ),
            )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Get.to(() => MapPage(), arguments: {'vehicle': bus});
        },
        title: Text(
          '${bus.shortName} - ${bus.longName}',
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _getHoursRow(),
        trailing: SizedBox(
          width: 30,
          child: GestureDetector(
            onTap: _openAlerts,
            child: Text(
              bus.alerts.isEmpty ? "No alerts" : "Alerts",
              textAlign: TextAlign.center,
              style: Get.textTheme.labelSmall!.copyWith(
                  color: bus.alerts.isEmpty
                      ? null
                      : Colors.blue), // Get.theme.colorScheme.background,
            ),
          ),
        ),
      ),
    );
  }
}
