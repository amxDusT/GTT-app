import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_global_controller.dart';
import 'package:flutter_gtt/ignored.dart';
import 'package:flutter_gtt/widgets/map/address_widget.dart';
import 'package:flutter_gtt/widgets/map/bottom_buttons.dart';
import 'package:flutter_gtt/widgets/map/circle_button.dart';
import 'package:flutter_gtt/widgets/search/map_search_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';

class MapGlobal extends StatelessWidget {
  MapGlobal({super.key});
  final _mapController = Get.put(MapGlobalController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (_mapController.searchController.focusNode?.hasFocus ?? false) {
          _mapController.searchController.focusNode?.unfocus();
          //print('unfocus');
        } else if (_mapController
                .searchController.suggestionsController.isOpen &&
            (_mapController.searchController.suggestionsController.suggestions
                    ?.isNotEmpty ??
                false)) {
          _mapController.searchController.suggestionsController.close();
          //print('close');
        } else {
          //print('back');
          Future.delayed(Duration.zero, () {
            if (!didPop) Get.back(closeOverlays: true);
          });
        }
      },
      child: Scaffold(
        /* appBar: AppBar(
            title: const Text('Mappa'),
            actions: [
              IconButton(
                onPressed: _mapController.searchController.onSearchIconClicked,
                icon: const Icon(Icons.search),
              ),
            ],
            bottom: _mapController.searchController.isSearching.isTrue
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: SearchAddress(
                      searchController: _mapController.searchController,
                    ),
                  )
                : null,
          ), */
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
            SearchAddress(searchController: _mapController.searchController),
            GestureDetector(
              // block flutter_map from handling taps on markers
              onTap: () {},
              onLongPress: () {},
              child: PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  markers: [],
                  markerCenterAnimation: const MarkerCenterAnimation(),
                  popupController: _mapController.popupController,
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (BuildContext context, Marker marker) {
                      return AddressWidget(
                        marker: marker,
                        controller: _mapController.mapAddress,
                      );
                    },
                  ),
                ),
              ),
            ),
            BottomButtons(children: [
              CircleButton(
                tooltip: 'Location',
                icon: const Icon(Icons.location_on),
                onPressed: () => _mapController.zoomOut,
              ),
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
    );
  }
}
