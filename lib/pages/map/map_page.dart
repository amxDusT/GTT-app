import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_controller.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/controllers/settings_controller.dart';
import 'package:flutter_gtt/ignored.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/resources/utils/maps.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_gtt/widgets/map/bottom_buttons.dart';
import 'package:flutter_gtt/widgets/map/card_map_widget.dart';
import 'package:flutter_gtt/widgets/map/circle_button.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  final MapPageController _flutterMapController;
  final SettingsController _settingsController = Get.find();
  MapPage({super.key})
      : _flutterMapController = Get.find(
          tag: Get.arguments['vehicles'].map((route) => route.gtfsId).join(),
        );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
            'Map${_flutterMapController.routes.length == 1 ? ' - ${_flutterMapController.routes.values.first.shortName}' : ''}')),
        actions: [
          GetBuilder<RouteListController>(
            builder: (controller) => Obx(
              () => _flutterMapController.routes.length == 1
                  ? IconButton(
                      icon: _flutterMapController.isPatternInitialized.isTrue &&
                              controller.favorites.contains(
                                  _flutterMapController.routes.values.first)
                          ? const Icon(Icons.star)
                          : const Icon(Icons.star_border),
                      onPressed: () => controller.toggleFavorite(
                          _flutterMapController.routes.values.first),
                    )
                  : Container(),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Visibility(
              visible: _flutterMapController.routePatterns.isNotEmpty,
              child: _flutterMapController.routePatterns.isEmpty
                  ? Container()
                  : _buildPatternMenu(),
            ),
          ),
          Flexible(
            //flex: 3,
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
                  maxNativeZoom:
                      _settingsController.showBetaFeatures.isTrue ? 22 : 19,
                  urlTemplate: _settingsController.showBetaFeatures.isTrue
                      ? 'https://api.mapbox.com/styles/v1/amxdust/cltc6f9j2002201qp5x08376z/tiles/256/{z}/{x}/{y}?access_token=$apiKey'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),

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

                            double offset =
                                index * _flutterMapController.offsetVal;
                            return Polyline(
                              points: MapUtils.polylineOffset(
                                  route.pattern.polylinePoints, offset),
                              //points: route.pattern.polylinePoints,
                              strokeWidth: 4,
                              color: _flutterMapController.routes.length == 1
                                  ? Colors.red
                                  : Utils.lighten(
                                      MapPageController.colors[
                                          (_flutterMapController.routeIndex[
                                                      route.shortName] ??
                                                  0) %
                                              MapPageController.colors.length],
                                      20,
                                    ),
                            );
                          })
                        : <Polyline>[],
                  ]),
                ),
                Obx(
                  () => MarkerLayer(
                    markers: [
                      if (_flutterMapController
                          .userLocation.isLocationAvailable.isTrue)
                        UserLocationMarker(
                          position: _flutterMapController
                              .userLocation.userPosition.first,
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Obx(
                    () => PopupMarkerLayer(
                      options: PopupMarkerLayerOptions(
                        markerTapBehavior:
                            MarkerTapBehavior.togglePopupAndHideRest(),
                        markerCenterAnimation: const MarkerCenterAnimation(),
                        popupController: _flutterMapController.popupController,
                        markers: [
                          ..._flutterMapController.isPatternInitialized.isTrue
                              ? _flutterMapController.allStops
                              : [],
                          ..._flutterMapController.allVehiclesInDirection,
                        ],
                        popupDisplayOptions: PopupDisplayOptions(
                          builder: (BuildContext context, Marker marker) {
                            //_flutterMapController.lastOpenedMarker = marker;

                            return CardMapWidget(
                                marker: marker,
                                controller: _flutterMapController);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Opacity(
                    opacity: _flutterMapController.routes.length > 1 ? 0.8 : 0,
                    child: Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      // show which color each route has
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ..._flutterMapController.routes.values.indexed.map(
                            (value) => Container(
                              width: 50,
                              height: 20,
                              color: Utils.lighten(
                                MapPageController.colors[
                                    value.$1 % MapPageController.colors.length],
                                20,
                              ),
                              margin: const EdgeInsets.all(2),
                              alignment: Alignment.center,
                              child: Text(
                                value.$2.shortName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Opacity(
                    opacity:
                        _flutterMapController.followVehicle.value > 0 ? 0.8 : 0,
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
                                  const WidgetSpan(child: SizedBox(width: 10)),
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
                BottomButtons(
                  lines: 2,
                  children: [
                    CircleButton(
                      tooltip: 'Center Bounds',
                      onPressed: () => _flutterMapController.centerBounds(),
                      icon: const Icon(Icons.center_focus_strong),
                    ),
                    Obx(
                      () => CircleButton(
                        tooltip: 'Location',
                        onPressed: () {
                          _flutterMapController.userLocation
                              .switchLocationShowing();

                          if (_flutterMapController
                              .userLocation.isLocationShowing.isTrue) {
                            _flutterMapController.centerUser();
                          }
                        },
                        icon: _flutterMapController
                                .userLocation.isLocationShowing.isFalse
                            ? const Icon(Icons.location_on)
                            : const Icon(Icons.location_off),
                        child: _flutterMapController.isLocationLoading.isTrue
                            ? const CircularProgressIndicator()
                            : null,
                      ),
                    ),
                    CircleButton(
                      tooltip: 'Zoom out',
                      onPressed: () => _flutterMapController.zoomOut(),
                      icon: const Icon(Icons.remove),
                    ),
                    CircleButton(
                      tooltip: 'Zoom in',
                      onPressed: () => _flutterMapController.zoomIn(),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternMenu() {
    if (_flutterMapController.isPatternInitialized.isFalse) {
      return Container();
    }
    RouteWithDetails route = _flutterMapController.routes.values.first;
    return Column(
      mainAxisSize: MainAxisSize.min,
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Linea ${route.shortName}'),
        Text(route.longName),
        Text(
            '${_flutterMapController.firstStop[route.pattern.code]!.name} --> ${route.pattern.headsign}'),
        DropdownMenu(
          width: Get.width * 0.9,
          initialSelection: _flutterMapController.isPatternInitialized.isTrue
              ? _flutterMapController.routes.values.first.pattern
              : null,
          onSelected: (pattern) => pattern == null
              ? null
              : _flutterMapController.setCurrentPattern(pattern),
          dropdownMenuEntries: (_flutterMapController.routePatterns
              .map((pattern) => DropdownMenuEntry(
                    value: pattern,
                    label:
                        '${pattern.directionId}:${pattern.code.split(':').last} - ${pattern.headsign}',
                  ))
              .toList()),
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }
}
