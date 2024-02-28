import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_global_controller.dart';
import 'package:flutter_gtt/widgets/map/address_widget.dart';
import 'package:flutter_gtt/widgets/map/search_map_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';

class MapGlobal extends StatelessWidget {
  MapGlobal({super.key});
  final _mapController = Get.put(MapGlobalController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (_mapController.searchController.focusNode?.hasFocus ?? false) {
            _mapController.searchController.focusNode?.unfocus();
          } else if (_mapController
              .searchController.suggestionsController.isOpen) {
            _mapController.searchController.suggestionsController.close();
          } else {
            Future.delayed(Duration.zero, () {
              if (!didPop) Get.back(closeOverlays: true);
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
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
          ),
          body: FlutterMap(
            mapController: _mapController.mapController,
            options: MapOptions(
              initialZoom: 14,
              onMapReady: _mapController.onMapReady,
              onTap: _mapController.onTap,
              onLongPress: _mapController.mapAddress.onMapLongPress,
              interactionOptions: const InteractionOptions(
                flags: ~InteractiveFlag.rotate,
              ),
              initialCenter: MapGlobalController.initialCenter,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                //userAgentPackageName: 'com.example.app',
              ),
              PopupMarkerLayer(
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
            ],
          ),
        ),
      ),
    );
  }
}
