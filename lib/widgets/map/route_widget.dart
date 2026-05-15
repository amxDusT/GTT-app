import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/models/marker.dart';
import 'package:torino_mobility/resources/extensions/date_time.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/map_utils.dart';
import 'package:get/get.dart';

class RouteWidget extends StatelessWidget {
  final VehicleMarker marker;
  final MapPageController controller;
  const RouteWidget(
      {super.key, required this.marker, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${MapUtils.isTram(marker.mqttData.vehicleNum) ? 'Tram' : 'Bus'} ${controller.routes[marker.mqttData.gtfsId]?.shortName ?? 'UNKOWN'} - ${marker.mqttData.vehicleNum}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          marker.mqttData.lastUpdate
              .toTimeString(Storage.instance.showSecondsInUpdates),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        /* Text(
            'next stop: ${controller.stopsMap[marker.mqttData.nextStop]?.name ?? 'UNKOWN'}'), */
        SizedBox(
          //color: Colors.blue,
          width: 120,
          height: 30,
          child: TextButton(
            onPressed: () =>
                controller.followVehicle.value == marker.mqttData.vehicleNum
                    ? controller.stopFollowingVehicle()
                    : controller.followVehicleMarker(marker.mqttData),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            ),
            child: Obx(
              () => Text(
                controller.followVehicle.value == marker.mqttData.vehicleNum
                    ? 'Smetti di seguire'
                    : 'Segui',
                style: TextStyle(
                  color: controller.followVehicle.value ==
                          marker.mqttData.vehicleNum
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
