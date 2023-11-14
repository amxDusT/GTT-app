import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_controller.dart';
import 'package:flutter_gtt/models/fermata.dart';
import 'package:flutter_gtt/models/marker.dart';
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
      body: FlutterMap(
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
              Polyline(
                points: _flutterMapController.patternDetails.value.polyline,
                color: Colors.red,
                strokeWidth: 2,
              ),
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
                popupController: _flutterMapController.stopsPopupController,
                markers: _flutterMapController.patternDetails.value.fermate
                    .map(
                      (e) => _buildPin(e),
                    )
                    .toList(),
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (BuildContext context, Marker marker) {
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
                                    _flutterMapController.stopsPopupController
                                        .hideAllPopups();
                                  },
                                )),
                            if (marker is FermataMarker)
                              Text('Fermata ${marker.fermata.nome}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Obx(
            () => PopupMarkerLayer(
              options: PopupMarkerLayerOptions(
                markerCenterAnimation: const MarkerCenterAnimation(),
                popupController: _flutterMapController.vehiclesPopupController,
                markers: _flutterMapController.mqttData.values
                    .map(
                      (data) => _buildVehicle(data),
                    )
                    .toList(),
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (BuildContext context, Marker marker) {
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
                                    _flutterMapController
                                        .vehiclesPopupController
                                        .hideAllPopups();
                                  },
                                )),
                            if (marker is VehicleMarker)
                              Text(
                                  'Bus ${marker.mqttData.vehicleNum} - ${marker.mqttData.nextStop}\n ${marker.mqttData.direction}'),
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
                      backgroundColor: Get.theme.colorScheme.primaryContainer
                          .withOpacity(0.8),
                      child: _flutterMapController.isLocationLoading.isTrue
                          ? const CircularProgressIndicator()
                          : IconButton(
                              tooltip: 'Location',
                              onPressed: () =>
                                  _flutterMapController.goToUserLocation(),
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
                      backgroundColor: Get.theme.colorScheme.primaryContainer
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
                      backgroundColor: Get.theme.colorScheme.primaryContainer
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
          /*Obx(
            () => MarkerLayer(
              markers: _flutterMapController.patternDetails.value.fermate
                  .map(
                    (e) => _buildPin(e),
                  )
                  .toList(),
            ),
          ),*/
        ],
      ),
    );
  }

  Marker _buildPin(Fermata fermata) => FermataMarker(fermata: fermata);
  Marker _buildVehicle(MqttData data) => VehicleMarker(mqttData: data);
}
