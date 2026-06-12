import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/models/marker.dart';
import 'package:torino_mobility/resources/extensions/date_time.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/map_utils.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/resources/utils/spacing.dart';
import 'package:torino_mobility/widgets/map/close_popup_icon_button.dart';
import 'package:torino_mobility/widgets/route_icon.dart';

class RouteWidget extends StatelessWidget {
  final VehicleMarker marker;
  final MapPageController controller;
  const RouteWidget(
      {super.key, required this.marker, required this.controller});

  @override
  Widget build(BuildContext context) {
    final route = controller.routes[marker.mqttData.gtfsId];
    final patternStops =
        controller.stopsByPattern[route?.pattern.code] ?? const [];

    final nextIndex =
        patternStops.indexWhere((s) => s.code == marker.mqttData.nextStop);
    final nextStop = nextIndex != -1 ? patternStops[nextIndex] : null;
    final currentStop = nextIndex > 0 ? patternStops[nextIndex - 1] : null;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RouteIcon(
                routeName: route?.shortName ?? '-',
                margin: const EdgeInsets.only(right: 8),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey, width: .2),
                          ),
                          child: Row(
                            spacing: 2,
                            children: [
                              Icon(
                                MapUtils.isTram(marker.mqttData.vehicleNum)
                                    ? Icons.tram
                                    : Icons.directions_bus,
                                size: 12,
                              ),
                              Text(
                                  MapUtils.isTram(marker.mqttData.vehicleNum)
                                      ? 'TRAM'
                                      : 'BUS',
                                  style: Fonts.subtitle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Text('#${marker.mqttData.vehicleNum}',
                            style: Fonts.subtitle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    Spacing.vGap4,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(
                            Icons.arrow_right_alt,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            route?.pattern.headsign ?? '-',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ClosePopupIconButton(controller: controller, marker: marker),
            ],
          ),
          const Divider(),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RouteInfoRow(
                  stopName: currentStop?.name ?? '-'.hc, isFirst: true),
              RouteInfoRow(stopName: nextStop?.name ?? '-'.hc, isFirst: false),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                  child: Row(
                children: [
                  Text(marker.mqttData.lastUpdate.lastUpdateRelativeTime(),
                      style: Fonts.title(fontSize: 14)),
                ],
              )),
              SizedBox(
                //color: Colors.blue,
                width: 120,
                height: 30,
                child: TextButton(
                  onPressed: () => controller.followVehicle.value ==
                          marker.mqttData.vehicleNum
                      ? controller.stopFollowingVehicle()
                      : controller.followVehicleMarker(marker.mqttData),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  child: Obx(
                    () => Text(
                      controller.followVehicle.value ==
                              marker.mqttData.vehicleNum
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
          ),

          /* Text(
              'next stop: ${controller.stopsMap[marker.mqttData.nextStop]?.name ?? 'UNKOWN'}'), */
        ],
      ),
    );
  }
}

class RouteInfoRow extends StatelessWidget {
  const RouteInfoRow({
    required this.stopName,
    this.isFirst = true,
    super.key,
  });
  final String stopName;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SizedBox(
            width: 15,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // line on the half that connects to the adjacent stop:
                // down for the first stop, up for the next one.
                Align(
                  alignment:
                      isFirst ? Alignment.bottomCenter : Alignment.topCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.5,
                    child: Padding(
                      // start the line at the circle's edge so it doesn't
                      // show through the transparent (first) dot.
                      padding: EdgeInsets.only(
                        top: isFirst ? 7.5 : 0,
                        bottom: isFirst ? 0 : 7.5,
                      ),
                      child: Container(
                        width: 2,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),

                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: isFirst ? Colors.transparent : Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFirst
                          ? Colors.red
                          : const Color(0xff3A241C), // TODO: sistemare colore
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              /// hacky: cosi hanno la stessa lunghezza
              Visibility(
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Text(isFirst ? 'PROSSIMA'.hc : 'ULTIMA'.hc,
                    style:
                        Fonts.subtitle(fontSize: 9, color: Colors.grey[600])),
              ),
              Text(
                isFirst ? 'ULTIMA'.hc : 'PROSSIMA'.hc,
                style: Fonts.subtitle(
                  fontSize: 9,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Spacing.hGap4,
          Expanded(
              child: Text(stopName.capitalizeWords,
                  style: Fonts.title(
                    fontSize: 14,
                    color: isFirst ? Colors.grey[500] : null,
                    fontWeight: isFirst ? FontWeight.w400 : FontWeight.w600,
                  ))),
        ],
      ),
    );
  }
}
