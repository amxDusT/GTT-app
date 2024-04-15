import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/foundation.dart';

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

class MapGlobal extends GetView<MapGlobalController> {
  MapGlobal({super.key});
  //final controller = Get.find<MapGlobalController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (controller.travelController.isSearching.isTrue) {
          controller.travelController.updateIsSearching = false;
        } else if (controller.searchController.focusNode.hasFocus) {
          controller.searchController.focusNode.unfocus();
          //print('unfocus');
        } else {
          //print('back');
          Future.delayed(Duration.zero, () {
            if (!didPop) Get.back(closeOverlays: true);
          });
        }
      },
      child: Scaffold(
        appBar: controller.travelController.isSearching.isTrue
            ? TravelAppBar(
                controller: controller.travelController,
              )
            : null,
        body: FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            initialZoom: 14,
            onMapReady: controller.onMapReady,
            onTap: controller.onTap,
            onLongPress: controller.onMapLongPress,
            interactionOptions: const InteractionOptions(
              flags: ~InteractiveFlag.rotate,
            ),
            initialCenter: MapGlobalController.initialCenter,
          ),
          children: [
            TileLayer(
              maxNativeZoom: 22,
              urlTemplate: kDebugMode
                  ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                  : 'https://api.mapbox.com/styles/v1/amxdust/cltc6f9j2002201qp5x08376z/tiles/256/{z}/{x}/{y}?access_token=$apiKey',
            ),
            /* TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              //userAgentPackageName: 'com.example.app',
            ), */
            if (!controller.travelController.isSearching.isTrue)
              SearchAddress(
                searchController: controller.searchController,
              ),
            MarkerLayer(
              markers: [
                if (controller.mapLocation.isLocationAvailable.isTrue)
                  UserLocationMarker(
                    position: controller.mapLocation.userPosition.first,
                    heading: controller.mapLocation.userHeading.value,
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                if (controller.travelController.isSearching.isTrue)
                  Marker(
                    point:
                        controller.travelController.fromAddress.value.position,
                    child: const Icon(Icons.circle),
                  ),
                if (controller.travelController.isSearching.isTrue)
                  Marker(
                    point: controller.travelController.toAddress.value.position,
                    child: const Icon(
                      Icons.circle,
                      size: 24,
                    ),
                  ),
              ],
            ),
            PolylineLayer(polylines: [
              if (controller.travelController.isSearching.isTrue &&
                  controller.travelController.lastTravel.value != null)
                ...controller.travelController.lastTravel.value!.legs.map(
                  (leg) => Polyline(
                    points: MapUtils.decodeGooglePolyline(leg.points),
                    isDotted: leg.mode == 'WALK',
                    color: leg.mode == 'WALK' || leg.mode == 'BUS'
                        ? Colors.blue
                        : leg.mode == 'SUBWAY'
                            ? Colors.red
                            : Colors.green,
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
                  popupController: controller.mapAddress.popupController,
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (BuildContext context, Marker marker) {
                      return AddressWidget(
                        marker: marker,
                        controller: controller,
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
                  onPressed: () => controller.,
                ), */
              CircleButton(
                tooltip: 'Zoom out',
                icon: const Icon(Icons.remove),
                onPressed: () => controller.zoomOut,
              ),
              CircleButton(
                tooltip: 'Zoom in',
                icon: const Icon(Icons.add),
                onPressed: () => controller.zoomIn,
              ),
            ]),
            FlexibleBottomSheet(
              key: const ValueKey('bottom_sheet'),
              draggableScrollableController:
                  controller.travelController.draggableScrollableController,
              /* minHeight: controller.travelController.isSearching.isTrue
                    ? 0.14
                    : 0,
                initHeight: controller.travelController.isSearching.isTrue
                    ? 0.14
                    : 0, */
              initHeight: 0.14,
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
                      controller.travelController.lastTravels.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              primary: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: controller
                                      .travelController.lastTravelsMap.length +
                                  1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Strade possibili',
                                      style: Get.textTheme.titleLarge!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }

                                final vehicle = controller
                                    .travelController.lastTravelsMap.keys
                                    .elementAt(index - 1);

                                return ListTile(
                                  title: Text(vehicle),
                                  subtitle: Text(
                                    '${(controller.travelController.lastTravelsMap[vehicle]!.duration / 60).toStringAsFixed(0)} min',
                                  ),
                                  onTap: () {
                                    controller
                                            .travelController.lastTravel.value =
                                        controller.travelController
                                            .lastTravelsMap[vehicle];
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
    );
  }
}
