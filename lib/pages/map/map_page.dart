import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:torino_mobility/models/marker.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/spacing.dart';
import 'package:torino_mobility/widgets/home/info_icon_button.dart';
import 'package:torino_mobility/widgets/animated_icon_button.dart';
import 'package:torino_mobility/widgets/map/add_route_modal.dart';
import 'package:torino_mobility/widgets/map/card_map_widget.dart';
import 'package:torino_mobility/widgets/map/circle_button.dart';
import 'package:torino_mobility/widgets/map/direction_arrows_layer.dart';
import 'package:torino_mobility/widgets/map/map_pattern_info.dart';
import 'package:torino_mobility/widgets/map/zoom_pill.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:torino_mobility/widgets/route_icon.dart';

class MapPage extends StatelessWidget {
  final MapPageController _flutterMapController;
  final SettingsController _settingsController = Get.find();
  MapPage({super.key})
      : _flutterMapController = Get.find(
          tag: Get.arguments['vehicles'].map((route) => route.gtfsId).join(),
        );
  void openModalInfoRoute(BuildContext context, RouteWithDetails route) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MapPatternInfo(
        route: route,
        controller: _flutterMapController,
      ),
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xff221d17),
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }

  void openAddRouteModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xff221d17),
        showDragHandle: true,
        builder: (context) => AddRouteModal(controller: _flutterMapController));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: _flutterMapController.mapController,
                  options: MapOptions(
                    maxZoom: MapPageController.maxZoom,
                    minZoom: MapPageController.minZoom,
                    initialZoom: 15,
                    onMapReady: _flutterMapController.onMapReady,
                    onMapEvent: _flutterMapController.onMapEvent,
                    onTap: (tapPosition, point) {
                      _flutterMapController.popupController.hideAllPopups();
                      _flutterMapController.lastOpenedMarker = null;
                    },
                    interactionOptions: const InteractionOptions(
                      flags: ~InteractiveFlag.rotate,
                    ),
                    initialCenter: const LatLng(45.064889, 7.670805),
                    initialCameraFit: CameraFit.bounds(
                      bounds: LatLngBounds(
                        const LatLng(45.17400, 7.88700),
                        const LatLng(
                          44.94300,
                          7.504,
                        ),
                      ),
                    ),
                  ),
                  children: [
                    TileLayer(
                        userAgentPackageName: 'it.amxdust.torino_mobility',
                        maxNativeZoom:
                            _settingsController.showBetaFeatures.isTrue
                                ? 22
                                : 19,
                        urlTemplate: (_settingsController
                                    .showBetaFeatures.isTrue &&
                                mapboxApiKey.isNotEmpty)
                            ? 'https://api.mapbox.com/styles/v1/amxdust/cltc6f9j2002201qp5x08376z/tiles/256/{z}/{x}/{y}?access_token=$mapboxApiKey'
                            : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        tileProvider:
                            const FMTCStore(tileCacheName).getTileProvider(
                          httpClient: IOClient(
                            HttpClient()
                              ..userAgent = null
                              ..connectionTimeout = const Duration(seconds: 5),
                          ),
                        )),

                    /*  TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      //userAgentPackageName: 'com.example.app',
                    ), */
                    Obx(
                      () => PolylineLayer(polylines: [
                        ..._flutterMapController.isPatternInitialized.isTrue
                            ? _flutterMapController.routes.values.indexed
                                .map((value) {
                                var route = value.$2;
                                var index = value.$1;

                                return Polyline(
                                  points: _flutterMapController
                                      .offsetPolylineFor(route, index),
                                  strokeWidth: 4,
                                  color: _flutterMapController
                                      .polylineColorFor(route),
                                );
                              })
                            : [],
                      ]),
                    ),
                    Obx(
                      () => DirectionArrowsLayer(
                        animate: _settingsController
                            .showDirectionArrowsAnimation.value,
                        routes:
                            _flutterMapController.isPatternInitialized.isTrue
                                ? _flutterMapController.routes.values.indexed
                                    .map(
                                    (value) => DirectionArrowRoute(
                                      points: _flutterMapController
                                          .offsetPolylineFor(
                                              value.$2, value.$1),
                                      color: _flutterMapController
                                          .polylineColorFor(value.$2),
                                    ),
                                  )
                                    .toList()
                                : const [],
                      ),
                    ),
                    Obx(
                      () => MarkerLayer(
                        markers: [
                          if (_flutterMapController
                              .userLocation.isLocationAvailable.isTrue)
                            UserLocationMarker(
                              position: _flutterMapController
                                  .userLocation.userPosition.first,
                              heading: _flutterMapController
                                  .userLocation.userHeading.value,
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Obx(
                        () => PopupMarkerLayer(
                          options: PopupMarkerLayerOptions(
                            markerTapBehavior: MarkerTapBehavior.custom(
                              (popupSpec, popupState, popupController) {
                                if (popupState.selectedPopupSpecs
                                    .contains(popupSpec)) {
                                  popupController.hideAllPopups();
                                } else {
                                  popupController
                                      .showPopupsOnlyForSpecs([popupSpec]);
                                  _flutterMapController.centerMarkerBiasedDown(
                                      popupSpec.marker.point);
                                }
                              },
                            ),
                            popupController:
                                _flutterMapController.popupController,
                            markers: [
                              ..._flutterMapController
                                      .isPatternInitialized.isTrue
                                  ? _flutterMapController.allStops
                                  : [],
                              ..._flutterMapController.allVehiclesInDirection,
                            ],
                            popupDisplayOptions: PopupDisplayOptions(
                              snap: PopupSnap.markerTop,
                              builder: (BuildContext context, Marker marker) {
                                _flutterMapController.lastOpenedMarker = marker;

                                return CardMapWidget(
                                    marker: marker,
                                    mapPageController: _flutterMapController);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => Opacity(
                        opacity: _flutterMapController.followVehicle.value > 0
                            ? 0.8
                            : 0,
                        child: Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 15),
                          // show which color each route has
                          child: GestureDetector(
                            onTap: () => _flutterMapController.moveToFollowed(),
                            child: Container(
                                width: 140,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                margin: const EdgeInsets.all(2),
                                alignment: Alignment.topCenter,
                                child: Text.rich(
                                  TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            'Seguito:  ${_flutterMapController.followVehicle.value}',
                                      ),
                                      const WidgetSpan(
                                          child: SizedBox(width: 10)),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: GestureDetector(
                                          onTap: () => _flutterMapController
                                              .stopFollowingVehicle(),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            //size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Obx(
                              () => CircleButton(
                                child: _flutterMapController
                                        .isLocationLoading.isTrue
                                    ? const Padding(
                                        padding: EdgeInsets.all(13),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : Tooltip(
                                        message: 'Location',
                                        child: AnimatedIconButton(
                                          selectedIcon: Icons.location_off,
                                          unselectedIcon: Icons.location_on,
                                          selectedColor: kInk,
                                          unselectedColor: kInk,
                                          selected: _flutterMapController
                                              .userLocation
                                              .isLocationShowing
                                              .isTrue,
                                          onPressed: () {
                                            _flutterMapController.userLocation
                                                .switchLocationShowing();

                                            if (_flutterMapController
                                                .userLocation
                                                .isLocationShowing
                                                .isTrue) {
                                              _flutterMapController
                                                  .centerUser();
                                            }
                                          },
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ZoomPill(
                              onZoomIn: () => _flutterMapController.zoomIn(),
                              onZoomOut: () => _flutterMapController.zoomOut(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 8,
            right: 8,
            child: SafeArea(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0).copyWith(left: 0),
                    child: InfoIconButton(
                      icon: Icons.chevron_left,
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                      backgroundColor:
                          const Color(0xff221d17).withValues(alpha: 0.8),
                      onPressed: () {
                        Get.back(closeOverlays: true);
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xff221d17).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Obx(() {
                        final canAdd = _flutterMapController.routes.length <
                            maxRoutesInMap;
                        return Row(
                          spacing: 8,
                          children: [
                            Text('TRACKING'.hc),
                            Spacing.hGap4,
                            if (_flutterMapController.routes.isNotEmpty)
                              ..._flutterMapController.routes.values.indexed
                                  .map((value) {
                                var route = value.$2;
                                var index = value.$1;
                                return RouteIcon(
                                  routeName: route.shortName,
                                  size: 25,
                                  margin: EdgeInsets.zero,
                                  color: MapPageController.colors[
                                      index % MapPageController.colors.length],
                                  onTap: () =>
                                      openModalInfoRoute(context, route),
                                );
                              }),
                            const Spacer(),
                            if (canAdd)
                              InkWell(
                                onTap: () => openAddRouteModal(context),
                                customBorder: const CircleBorder(),
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff3a322a),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
