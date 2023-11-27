import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_controller.dart';
import 'package:flutter_gtt/models/gtt_models.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/models/mqtt_data.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  MapPage({super.key});
  final MapPageController _flutterMapController = Get.put(MapPageController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Visibility(
              visible: _flutterMapController.routePatterns.isNotEmpty,
              child: SizedBox(
                height: Get.size.height * 0.07,
                child: DropdownMenu(
                  initialSelection:
                      _flutterMapController.isPatternInitialized.isTrue
                          ? _flutterMapController.patterns.values.first
                          : null,
                  onSelected: (pattern) =>
                      pattern == null ? null : null, //TODO: setNewPatter
                  dropdownMenuEntries: (_flutterMapController.routePatterns
                      .map((pattern) => DropdownMenuEntry(
                            value: pattern,
                            label: pattern.code,
                          ))
                      .toList()),
                ),

                // child: PopupMenuButton(
                //   itemBuilder: (context) {
                //     return (_flutterMapController.routePatterns
                //         .map((pattern) => PopupMenuItem(
                //               child: Text(pattern.code),
                //               onTap: () =>
                //                   _flutterMapController.changePattern(pattern),
                //             ))
                //         .toList());
                //   },
                // ),
              ),
            ),
          ),
          Flexible(
            //flex: 3,
            child: FlutterMap(
              mapController: _flutterMapController.mapController,
              options: MapOptions(
                initialZoom: 15,
                onMapReady: _flutterMapController.onMapReady,
                interactionOptions: const InteractionOptions(
                  flags: ~InteractiveFlag.rotate,
                ),
                initialCenter: const LatLng(45.064889, 7.670805),
                initialCameraFit: CameraFit.bounds(
                  bounds: LatLngBounds(
                    const LatLng(45.17400, 7.88700),
                    const LatLng(
                      44.94300,
                      7.504,
                    ),
                  ),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  //userAgentPackageName: 'com.example.app',
                ),
                Obx(
                  () => PolylineLayer(polylines: [
                    ..._flutterMapController.isPatternInitialized.isTrue
                        ? _flutterMapController.patterns.values.indexed
                            .map((value) => Polyline(
                                  points: value.$2.polylinePoints,
                                  strokeWidth: 2,
                                  color: MapPageController.colors[value.$1 %
                                      MapPageController.colors.length],
                                  borderColor: Colors.red,
                                ))
                        : <Polyline>[],
                  ]),
                ),
                Obx(
                  () => MarkerLayer(
                    markers: _flutterMapController.userLocationMarker
                        .map(
                          (element) => Marker(
                            point: element,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Obx(
                  () => PopupMarkerLayer(
                    options: PopupMarkerLayerOptions(
                      markerCenterAnimation: const MarkerCenterAnimation(),
                      popupController: _flutterMapController.popupController,
                      markers: [
                        ..._flutterMapController.isPatternInitialized.isTrue
                            ? _flutterMapController.allStops.map(_buildFermata)
                            : [],
                        ..._flutterMapController.allVehiclesInDirection.map(
                          (data) => _buildVehicle(data),
                        )
                      ],
                      popupDisplayOptions: PopupDisplayOptions(
                        builder: (BuildContext context, Marker marker) {
                          _flutterMapController.lastOpenedMarker = marker;
                          return Card(
                            color: Colors.yellow.withOpacity(0.9),
                            child: SizedBox(
                              //height: 70,
                              width: 150,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        _flutterMapController.popupController
                                            .hidePopupsOnlyFor([marker]);
                                        _flutterMapController.lastOpenedMarker =
                                            null;
                                      },
                                    ),
                                  ),
                                  if (marker is FermataMarker)
                                    _containerFermata(marker),
                                  if (marker is VehicleMarker)
                                    _containerVehicle(marker),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 15,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Obx(
                          () => CircleAvatar(
                            radius: 25,
                            backgroundColor: Get
                                .theme.colorScheme.primaryContainer
                                .withOpacity(0.8),
                            child:
                                _flutterMapController.isLocationLoading.isTrue
                                    ? const CircularProgressIndicator()
                                    : IconButton(
                                        tooltip: 'Location',
                                        onPressed: () => _flutterMapController
                                            .goToUserLocation(),
                                        icon: const Icon(Icons.location_on),
                                      ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Get
                                .theme.colorScheme.primaryContainer
                                .withOpacity(0.8),
                            child: IconButton(
                              tooltip: 'Zoom out',
                              onPressed: () => _flutterMapController.zoomOut(),
                              icon: const Icon(Icons.remove),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Get
                                .theme.colorScheme.primaryContainer
                                .withOpacity(0.8),
                            child: IconButton(
                              tooltip: 'Zoom in',
                              onPressed: () => _flutterMapController.zoomIn(),
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _containerFermata(FermataMarker marker) {
    return Text('${marker.fermata.code} - ${marker.fermata.name}');
  }

  Widget _containerVehicle(VehicleMarker marker) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bus ${marker.mqttData.shortName} n${marker.mqttData.vehicleNum}',
        ),
        Text(
          'last update: ${Utils.dateToHourString(marker.mqttData.lastUpdate)}',
          style: Get.textTheme.bodySmall,
        ),
      ],
    );
  }

  Marker _buildFermata(Stop fermata) => FermataMarker(fermata: fermata);
  Marker _buildVehicle(MqttData data) => VehicleMarker(mqttData: data);
}
