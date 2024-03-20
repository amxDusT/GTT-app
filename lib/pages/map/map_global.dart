import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_global_controller.dart';
import 'package:flutter_gtt/ignored.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/resources/utils/maps.dart';
import 'package:flutter_gtt/widgets/map/address_widget.dart';
import 'package:flutter_gtt/widgets/map/bottom_buttons.dart';
import 'package:flutter_gtt/widgets/map/circle_button.dart';
import 'package:flutter_gtt/widgets/map/travel_appbar.dart';
import 'package:flutter_gtt/widgets/search/map_search_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';

class MapGlobal extends StatelessWidget {
  MapGlobal({super.key});
  final _mapController = Get.find<MapGlobalController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (_mapController.travelController.isSearching.isTrue) {
          _mapController.travelController.isSearching.value = false;
        } else if (_mapController.searchController.focusNode.hasFocus) {
          _mapController.searchController.focusNode.unfocus();
          //print('unfocus');
        } else {
          //print('back');
          Future.delayed(Duration.zero, () {
            if (!didPop) Get.back(closeOverlays: true);
          });
        }
      },
      child: Obx(
        () => Scaffold(
          appBar: _mapController.travelController.isSearching.isTrue
              ? TravelAppBar(
                  controller: _mapController.travelController,
                )
              : null,
          body: FlutterMap(
            mapController: _mapController.mapController,
            options: MapOptions(
              initialZoom: 14,
              onMapReady: _mapController.onMapReady,
              onTap: _mapController.onTap,
              onLongPress: _mapController.onMapLongPress,
              interactionOptions: const InteractionOptions(
                flags: ~InteractiveFlag.rotate,
              ),
              initialCenter: MapGlobalController.initialCenter,
            ),
            children: [
              TileLayer(
                maxNativeZoom: 22,
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/amxdust/cltc6f9j2002201qp5x08376z/tiles/256/{z}/{x}/{y}?access_token=$apiKey',
              ),
              /* TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              //userAgentPackageName: 'com.example.app',
            ), */
              if (!_mapController.travelController.isSearching.isTrue)
                SearchAddress(
                    searchController: _mapController.searchController),
              Obx(
                () => MarkerLayer(
                  markers: [
                    if (_mapController.mapLocation.isLocationAvailable.isTrue)
                      UserLocationMarker(
                        position: _mapController.mapLocation.userPosition.first,
                        heading: _mapController.mapLocation.userHeading.value,
                        beta: true,
                      ),
                  ],
                ),
              ),
              Obx(
                () => MarkerLayer(
                  markers: [
                    if (_mapController.travelController.isSearching.isTrue)
                      Marker(
                        point: _mapController
                            .travelController.fromAddress.value.position,
                        child: const Icon(Icons.circle),
                      ),
                    if (_mapController.travelController.isSearching.isTrue)
                      Marker(
                        point: _mapController
                            .travelController.toAddress.value.position,
                        child: const Icon(
                          Icons.circle,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
              PolylineLayer(polylines: [
                if (_mapController.travelController.isSearching.isTrue &&
                    _mapController.travelController.lastTravel.isNotEmpty)
                  ..._mapController.travelController.lastTravel.first.legs.map(
                    (leg) => Polyline(
                      points: MapUtils.decodeGooglePolyline(leg.points),
                      isDotted: leg.mode == 'WALK',
                      color: leg.mode == 'WALK'
                          ? Colors.blue
                          : leg.mode == 'BUS'
                              ? Colors.green
                              : Colors.red,
                      strokeWidth: 4,
                    ),
                  ),
              ]),
              GestureDetector(
                // block flutter_map from handling taps on markers
                onTap: () {},
                onLongPress: () {},
                child: PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    markers: [],
                    markerCenterAnimation: const MarkerCenterAnimation(),
                    popupController: _mapController.mapAddress.popupController,
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) {
                        return AddressWidget(
                          marker: marker,
                          controller: _mapController,
                        );
                      },
                    ),
                  ),
                ),
              ),
              BottomButtons(children: [
                /* CircleButton(
                  tooltip: 'Location',
                  icon: const Icon(Icons.location_on),
                  onPressed: () => _mapController.,
                ), */
                CircleButton(
                  tooltip: 'Zoom out',
                  icon: const Icon(Icons.remove),
                  onPressed: () => _mapController.zoomOut,
                ),
                CircleButton(
                  tooltip: 'Zoom in',
                  icon: const Icon(Icons.add),
                  onPressed: () => _mapController.zoomIn,
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }

  /* AppBar oldAppBar() => AppBar(
        actions: [
          IconButton(
            tooltip: 'Inverti indirizzi',
            onPressed: () => _mapController.travelController.switchAddresses(),
            icon: const Icon(Icons.swap_vert),
          ),
        ],
        leadingWidth: 40,
        title: TextField(
          controller: _mapController.travelController.fromTextController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 8.0),
            hintText: 'Da..',
            hintStyle: const TextStyle(color: Colors.grey),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _mapController.travelController.fromTextController.clear();
              },
            ),
          ),
        ),
        bottom: AppBar(
            actions: [
              IconButton(
                tooltip: 'Aggiungi intermedio',
                onPressed: () {},
                icon: const Icon(Icons.add),
              ),
            ],
            toolbarHeight: 70,
            leadingWidth: 40,
            leading: const SizedBox(),
            automaticallyImplyLeading: false,
            title: Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: TextField(
                controller: _mapController.travelController.toTextController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 8.0),
                  hintText: 'A..',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _mapController.travelController.toTextController.clear();
                    },
                  ),
                ),
              ),
            )),
      ); */
}
