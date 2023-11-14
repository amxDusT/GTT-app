import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_point_controller.dart';
import 'package:flutter_gtt/models/fermata.dart';
import 'package:flutter_gtt/models/marker.dart';
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
          title: Text('Fermata ${_mapController.initialFermata.nome}'),
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
                          children: [
                            Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _mapController.popupController
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
          ],
        ));
  }

  Marker _buildPin(Fermata fermata) => FermataMarker(fermata: fermata);
}
