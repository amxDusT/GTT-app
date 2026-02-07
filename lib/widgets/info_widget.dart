import 'dart:math';

import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/info_controller.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:torino_mobility/widgets/passage_time.dart';
import 'package:get/get.dart';

class InfoWidget extends StatelessWidget {
  final RouteWithDetails vehicle;
  final Stop stop;
  final InfoController _infoController;
  InfoWidget({
    super.key,
    required this.stop,
    required this.vehicle,
  }) : _infoController = Get.find<InfoController>(tag: stop.code.toString());

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
                  min(vehicle.stoptimes.length, maxHours),
                )
                .map(
                  (stoptime) => PassageTime(stoptime: stoptime),
                )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Obx(
        () => ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onTap: () {
            if (_infoController.isSelecting.isTrue) {
              _infoController.onSelectedClick(vehicle);
              return;
            } else if (!Storage.instance.isRouteWithoutPassagesShowing &&
                vehicle.stoptimes.isEmpty) {
              Utils.showSnackBar(
                'Non ci sono passaggi per questo veicolo',
                closePrevious: true,
              );

              return;
            }
            Get.toNamed('/mapBus', arguments: {
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
          title: Text(
            '${vehicle.shortName} - ${vehicle.longName}',
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: _getHoursRow(),
          trailing: SizedBox(
            width: 30,
            child: GestureDetector(
              onTap: vehicle.alerts.isEmpty ? null : _openAlerts,
              child: Text(
                vehicle.alerts.isEmpty ? 'No alerts' : 'Alerts',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
