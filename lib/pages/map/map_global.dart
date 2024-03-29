import 'package:bottom_sheet/bottom_sheet.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_global_controller.dart';
import 'package:flutter_gtt/ignored.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/resources/utils/map_utils.dart';
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
          _mapController.travelController.updateIsSearching = false;
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
                  searchController: _mapController.searchController,
                ),
              MarkerLayer(
                markers: [
                  if (_mapController.mapLocation.isLocationAvailable.isTrue)
                    UserLocationMarker(
                      position: _mapController.mapLocation.userPosition.first,
                      heading: _mapController.mapLocation.userHeading.value,
                    ),
                ],
              ),
              MarkerLayer(
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
              PolylineLayer(polylines: [
                if (_mapController.travelController.isSearching.isTrue &&
                    _mapController.travelController.lastTravel.value != null)
                  ..._mapController.travelController.lastTravel.value!.legs.map(
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
              ]),
              FlexibleBottomSheet(
                minHeight: _mapController.travelController.isSearching.isTrue
                    ? 0.14
                    : 0,
                initHeight: _mapController.travelController.isSearching.isTrue
                    ? 0.14
                    : 0,
                isCollapsible: false,
                builder: (context, scrollController, bottomSheetOffset) =>
                    DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    //physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      //mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 6),
                            width: 70,
                            height: 5,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            )),
                        _mapController.travelController.lastTravels.isEmpty
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                primary: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _mapController
                                        .travelController.lastTravels.length +
                                    1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Strade possibili',
                                        style:
                                            Get.textTheme.titleLarge!.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  final travel = _mapController
                                      .travelController.lastTravels[index - 1];
                                  final legs = travel.legs
                                      .where((element) =>
                                          element.transitLeg == true)
                                      .map((e) => e.route!.shortName);
                                  return ListTile(
                                    title: Text(
                                        legs.isEmpty ? 'WALK' : legs.first),
                                    subtitle: Text(
                                        '${(travel.duration / 60).toStringAsFixed(0)} min'),
                                    onTap: () {
                                      _mapController.travelController.lastTravel
                                          .value = travel;
                                    },
                                  );
                                },
                                separatorBuilder: (context, index) => index != 0
                                    ? const Divider()
                                    : const Divider() /* const SizedBox() */,
                              ),
                      ],
                    ),
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
