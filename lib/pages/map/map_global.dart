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
            print('unfocus');
          } else if (_mapController
                  .searchController.suggestionsController.isOpen &&
              (_mapController.searchController.suggestionsController.suggestions
                      ?.isNotEmpty ??
                  false)) {
            _mapController.searchController.suggestionsController.close();
            print('close');
          } else {
            print('back');
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
              onLongPress: _mapController.onMapLongPress,
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
              Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                            onPressed: () => _mapController.zoomOut,
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
                            onPressed: () => _mapController.zoomIn,
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
      ),
    );
  }
}
