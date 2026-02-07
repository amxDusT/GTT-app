import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/map/map_point_controller.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/models/marker.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/map_utils.dart';
import 'package:torino_mobility/widgets/map/stop_widget.dart';
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
          title: Text(l10n.stopTitle(_mapController.initialFermata.name)),
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
              userAgentPackageName: 'it.amxdust.torino_mobility',
              maxNativeZoom: 19,
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
                                  child: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Colors.grey[600],
                                  ),
                                  onTap: () {
                                    _mapController.popupController
                                        .hideAllPopups();
                                  },
                                )),
                            if (marker is FermataMarker)
                              StopWidget(marker: marker),
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
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Apri in Google Maps',
                      style: TextStyle(
                        color: Storage.instance.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
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
