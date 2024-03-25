import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_point_controller.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/resources/utils/map_utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';

class MapPointPage extends StatelessWidget {
  MapPointPage({super.key});
  final MapPointController _mapController = Get.put(MapPointController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Fermata ${_mapController.initialFermata.name}'),
        ),
        body: FlutterMap(
          mapController: _mapController.mapController,
          options: MapOptions(
            initialZoom: 16,
            onMapReady: _mapController.onMapReady,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom,
            ),
            initialCenter: _mapController.fermataLocation,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              //userAgentPackageName: 'com.example.app',
            ),
            PopupMarkerLayer(
              options: PopupMarkerLayerOptions(
                markers: [
                  _buildPin(_mapController.initialFermata),
                ],
                markerCenterAnimation: const MarkerCenterAnimation(),
                popupController: _mapController.popupController,
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (BuildContext context, Marker marker) {
                    return Card(
                      color: Colors.yellow.withOpacity(0.9),
                      child: SizedBox(
                        //height: 70,
                        width: 150,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.all(5.0),
                                child: InkWell(
                                  child: const Icon(
                                    Icons.clear,
                                    size: 20,
                                  ),
                                  onTap: () {
                                    _mapController.popupController
                                        .hideAllPopups();
                                  },
                                )),
                            if (marker is FermataMarker)
                              Text('Fermata ${marker.fermata.name}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 0.7,
                child: Container(
                  //color: Get.theme.colorScheme.primaryContainer,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Apri in Google Maps'),
                    onPressed: () => MapUtils.openMap(
                        _mapController.fermataLocation.latitude,
                        _mapController.fermataLocation.longitude),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Marker _buildPin(Stop fermata) => FermataMarker(fermata: fermata);
}
