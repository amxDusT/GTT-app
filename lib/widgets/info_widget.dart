import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/info_controller.dart';
import 'package:flutter_gtt/models/gtt_models.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/pages/map/map_page.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InfoWidget extends StatelessWidget {
  final RouteWithDetails vehicle;
  final Stop stop;
  final InfoController _infoController;
  InfoWidget(
      {super.key,
      required this.stop,
      required this.vehicle,
      String? infoControllerKey})
      : _infoController = Get.find<InfoController>(tag: infoControllerKey);

  void _openAlerts() {
    if (vehicle.alerts.isEmpty) {
      return;
    }
    Get.defaultDialog(middleText: vehicle.alerts[0]);
  }

  Widget _getHoursRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...vehicle.stoptimes.isEmpty
            ? [
                Text(
                  'Non ci sono passaggi',
                  style:
                      Get.textTheme.labelMedium!.copyWith(letterSpacing: 1.5),
                ),
              ]
            : vehicle.stoptimes
                .getRange(
                    0,
                    vehicle.stoptimes.length < maxHours
                        ? vehicle.stoptimes.length
                        : maxHours)
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
      child: Obx(
        () => ListTile(
          onTap: () {
            if (_infoController.isSelecting.isTrue) {
              _infoController.onSelectedClick(vehicle);
              return;
            }

            Get.to(
                () => MapPage(
                      key: UniqueKey(),
                    ),
                arguments: {
                  'vehicles': [vehicle],
                  'fermata': stop
                });
          },
          onLongPress: () {
            _infoController.onLongPress(vehicle);
            //print('long press');
          },
          tileColor: _infoController.selectedRoutes.contains(vehicle)
              ? Get.theme.colorScheme.primary.withOpacity(0.2)
              : null,
          // leading: _infoController.isSelecting.isTrue
          //     ? Checkbox(
          //         value: _infoController.selectedRoutes.contains(vehicle),
          //         onChanged: (value) {
          //           _infoController.onSelectedClick(vehicle);
          //         },
          //       )
          //     : null,
          title: Text(
            '${vehicle.shortName} - ${vehicle.longName}',
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: _getHoursRow(),
          trailing: SizedBox(
            width: 30,
            child: GestureDetector(
              onTap: _openAlerts,
              child: Text(
                vehicle.alerts.isEmpty ? "No alerts" : "Alerts",
                textAlign: TextAlign.center,
                style: Get.textTheme.labelSmall!.copyWith(
                    color: vehicle.alerts.isEmpty
                        ? null
                        : Colors.blue), // Get.theme.colorScheme.background,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
