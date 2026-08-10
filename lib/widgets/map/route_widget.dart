import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/models/marker.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/map_utils.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/widgets/animated_icon_button.dart';
import 'package:torino_mobility/widgets/auto_shrink_text.dart';
import 'package:torino_mobility/widgets/map/close_popup_icon_button.dart';
import 'package:torino_mobility/widgets/map/occupancy_chip.dart';
import 'package:torino_mobility/widgets/map/progress_rail.dart';
import 'package:torino_mobility/widgets/map/update_pill.dart';
import 'package:torino_mobility/widgets/route_icon.dart';

// Popup tokens (dark editorial palette, same as the card host).

class RouteWidget extends StatelessWidget {
  final VehicleMarker marker;
  final MapPageController controller;
  const RouteWidget(
      {super.key, required this.marker, required this.controller});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final route = controller.routes[marker.mqttData.gtfsId];
    final patternStops =
        controller.stopsByPattern[route?.pattern.code] ?? const [];

    final nextIndex =
        patternStops.indexWhere((s) => s.code == marker.mqttData.nextStop);
    final nextStop = nextIndex != -1 ? patternStops[nextIndex] : null;
    final currentStop = nextIndex > 0 ? patternStops[nextIndex - 1] : null;

    final routeName = route?.shortName ?? '-';
    // Same fallback as the VehicleMarker child, so the popup always
    // matches the color drawn on the map.
    final lineColor = marker.color ?? Colors.blue;
    final isTram = MapUtils.isTram(marker.mqttData.vehicleNum);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header — line badge + identity + close
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RouteIcon(
                routeName: routeName,
                size: 44,
                margin: const EdgeInsets.only(right: 12),
                color: lineColor,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: t.line),
                          ),
                          child: Row(
                            spacing: 4,
                            children: [
                              Icon(
                                isTram ? Icons.tram : Icons.directions_bus,
                                size: 11,
                                color: t.inkDim,
                              ),
                              Text(
                                isTram ? 'TRAM'.hc : 'BUS'.hc,
                                style: Fonts.subtitle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: t.inkDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '#${marker.mqttData.vehicleNum}',
                          style: Fonts.subtitle(
                            fontSize: 10,
                            letterSpacing: 1.6,
                            color: t.inkMute,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        Text(
                          '→',
                          style: Fonts.subtitle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: lineColor,
                          ),
                        ),
                        Expanded(
                          child: AutoShrinkText(
                            route?.pattern.headsign ?? '-',
                            maxLines: 2,
                            minFontSize: 12,
                            style: Fonts.title(
                              fontSize: 16,
                              height: 1.15,
                              fontWeight: FontWeight.w400,
                              color: t.ink,
                            ),
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
          if (marker.mqttData.isFull != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: OccupancyChip(isFull: marker.mqttData.isFull!),
              ),
            ),

          Divider(color: t.line, height: 28),

          ProgressRail(
            lineColor: lineColor,
            lastStopName: currentStop?.name ?? '-'.hc,
            nextStopName: nextStop?.name ?? '-'.hc,
          ),

          Divider(color: t.line, height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 12,
            children: [
              Flexible(
                child: UpdatePill(lastUpdate: marker.mqttData.lastUpdate),
              ),
              Obx(() {
                final following = controller.followVehicle.value ==
                    marker.mqttData.vehicleNum;
                return AnimatedIconButton(
                  selectedIcon: Icons.my_location,
                  unselectedIcon: Icons.location_searching,
                  selected: following,
                  selectedLabel: 'In ascolto'.hc,
                  unselectedLabel: 'Segui'.hc,
                  onPressed: () => following
                      ? controller.stopFollowingVehicle()
                      : controller.followVehicleMarker(marker.mqttData),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
