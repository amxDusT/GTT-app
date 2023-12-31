import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_controller.dart';
import 'package:flutter_gtt/controllers/search_controller.dart';
import 'package:flutter_gtt/models/gtt_models.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/models/marker.dart';
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
              child: _flutterMapController.routePatterns.isEmpty
                  ? Container()
                  : _buildPatternMenu(),
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
                        ? _flutterMapController.routes.values.map((route) =>
                            Polyline(
                              points: route.pattern.polylinePoints,
                              strokeWidth: 4,
                              color: _flutterMapController.routes.length == 1
                                  ? Colors.red
                                  : Utils.lighten(
                                      MapPageController.colors[
                                          (_flutterMapController.routeIndex[
                                                      route.shortName] ??
                                                  0) %
                                              MapPageController.colors.length],
                                      20,
                                    ),
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
                            ? _flutterMapController.allStops
                            : [],
                        // ..._flutterMapController.allVehiclesInDirection.map(
                        //   (data) => _buildVehicle(data)),
                        ..._flutterMapController.allVehiclesInDirection,
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

  Widget _buildPatternMenu() {
    if (_flutterMapController.isPatternInitialized.isFalse) {
      return Container();
    }
    RouteWithDetails route = _flutterMapController.routes.values.first;
    return Column(
      mainAxisSize: MainAxisSize.min,
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Linea ${route.shortName}'),
        Text(route.longName),
        Text(
            'Current Pattern: ${route.pattern.directionId} - ${route.pattern.headsign}'),
        DropdownMenu(
          width: Get.width * 0.9,
          initialSelection: _flutterMapController.isPatternInitialized.isTrue
              ? _flutterMapController.routes.values.first.pattern
              : null,
          onSelected: (pattern) => pattern == null
              ? null
              : _flutterMapController.setCurrentPattern(pattern),
          dropdownMenuEntries: (_flutterMapController.routePatterns
              .map((pattern) => DropdownMenuEntry(
                    value: pattern,
                    label:
                        '${pattern.directionId}:${pattern.code.split(':').last} - ${pattern.headsign}',
                  ))
              .toList()),
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }

  Widget _containerFermata(FermataMarker marker) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            Get.find<SearchStopsController>().openInfoPage(marker.fermata);
            /*Get.until(
                (route) => (route as GetPageRoute).routeName == '/HomePage');
            Get.delete<InfoController>();
            Get.find<SearchStopsController>().openInfoPage(marker.fermata);*/
          },
          child: Text(
            '${marker.fermata.code} - ${marker.fermata.name}',
          ),
        ),
        if (marker.fermata is StopWithDetails)
          Text(
              '${(marker.fermata as StopWithDetails).vehicles.map((e) => e.shortName)}'),
      ],
    );
  }

  Widget _containerVehicle(VehicleMarker marker) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bus ${marker.mqttData.shortName} - ${marker.mqttData.vehicleNum}',
        ),
        Text(
          'last update: ${Utils.dateToHourString(marker.mqttData.lastUpdate)}',
          style: Get.textTheme.bodySmall,
        ),
      ],
    );
  }
}
