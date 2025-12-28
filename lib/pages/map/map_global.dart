import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_global_controller.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/widgets/map/map_global/panel_dragger.dart';
import 'package:flutter_gtt/resources/utils/map_utils.dart';
import 'package:flutter_gtt/widgets/map/map_global/address_widget.dart';
import 'package:flutter_gtt/widgets/map/bottom_buttons.dart';
import 'package:flutter_gtt/widgets/map/circle_button.dart';
import 'package:flutter_gtt/widgets/map/map_global/route_option.dart';
import 'package:flutter_gtt/widgets/map/travel_appbar.dart';
import 'package:flutter_gtt/widgets/search/map_search_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapGlobal extends StatelessWidget {
  MapGlobal({super.key});
  final controller = Get.find<MapGlobalController>();

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
      child: Obx(
        () => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: controller.travelController.isSearching.isTrue
              ? TravelAppBar(
                  controller: controller.travelController,
                )
              : null,
          body: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: SlidingUpPanel(
              color: Theme.of(context).scaffoldBackgroundColor,
              controller: controller.travelController.panelController,
              renderPanelSheet: controller.travelController.isSearching.isTrue,
              minHeight: 80,
              maxHeight:
                  Get.height - controller.travelController.appBarHeight - 34,
              panelBuilder: (scrollController) => controller
                      .travelController.isSearching.isFalse
                  ? const SizedBox()
                  : Column(
                      children: [
                        if (controller
                                .travelController.panelController.isAttached &&
                            controller
                                .travelController.panelController.isPanelOpen)
                          const Divider(
                            height: 1,
                          ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            controller: scrollController,
                            child: Column(
                              children: [
                                const PanelDragger(),
                                controller.travelController.lastTravels.isEmpty
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : ListView.separated(
                                        //controller: scrollController,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: controller.travelController
                                                .lastTravelsMap.length +
                                            1,
                                        itemBuilder: (context, index) {
                                          if (index == 0) {
                                            return Container(
                                              padding: const EdgeInsets.all(20),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Strade possibili',
                                                style: Get.textTheme.titleLarge!
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          }

                                          final vehicle = controller
                                              .travelController
                                              .lastTravelsMap
                                              .keys
                                              .elementAt(index - 1);

                                          return RouteOption(
                                              vehicleName: vehicle,
                                              controller: controller);
                                        },
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                      ),
                                //const SizedBox(height: 150),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
              borderRadius: controller
                          .travelController.panelController.isAttached &&
                      controller.travelController.panelController.isPanelOpen
                  ? const BorderRadius.vertical(top: Radius.circular(0))
                  : const BorderRadius.vertical(top: Radius.circular(20)),
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
                    urlTemplate: kDebugMode || mapboxApiKey.isEmpty
                        ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                        : 'https://api.mapbox.com/styles/v1/amxdust/cltc6f9j2002201qp5x08376z/tiles/256/{z}/{x}/{y}?access_token=$mapboxApiKey',
                  ),
                  /* TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  //userAgentPackageName: 'com.example.app',
                ), */
                  MarkerLayer(
                    markers: [
                      if (controller.mapLocation.isLocationAvailable.isTrue)
                        UserLocationMarker(
                          position: controller.mapLocation.userPosition.first,
                          heading: controller.mapLocation.userHeading.value,
                        ),
                    ],
                  ),
                  if (controller.travelController.isSearching.isFalse)
                    SearchAddress(
                      searchController: controller.searchController,
                    ),
                  MarkerLayer(
                    markers: [
                      if (controller.travelController.isSearching.isTrue)
                        Marker(
                          point: controller
                              .travelController.fromAddress.value.position,
                          child: const Icon(Icons.circle),
                        ),
                      if (controller.travelController.isSearching.isTrue)
                        Marker(
                          point: controller
                              .travelController.toAddress.value.position,
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
                  BottomButtons(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 20)
                            .copyWith(
                      bottom: controller.travelController.isSearching.isTrue
                          ? 100
                          : null,
                    ),
                    children: [
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
