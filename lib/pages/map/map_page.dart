import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_controller.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/resources/utils/maps.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_gtt/widgets/map/address_widget.dart';
import 'package:flutter_gtt/widgets/map/card_map_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  final MapPageController _flutterMapController;
  final String? infoKey;
  MapPage({super.key, this.infoKey})
      : _flutterMapController =
            Get.put(MapPageController(), tag: key?.toString());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          GetBuilder<RouteListController>(
              builder: (controller) => Obx(() => IconButton(
                    icon: _flutterMapController.isPatternInitialized.isTrue &&
                            controller.favorites.contains(
                                _flutterMapController.routes.values.first)
                        ? const Icon(Icons.star)
                        : const Icon(Icons.star_border),
                    onPressed: () => controller.toggleFavorite(
                        _flutterMapController.routes.values.first),
                  ))),
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
                onLongPress: _flutterMapController.onMapLongPress,
                onMapReady: _flutterMapController.onMapReady,
                onMapEvent: _flutterMapController.onMapEvent,
                onTap: (tapPosition, point) {
                  _flutterMapController.popupController.hideAllPopups();
                  //_flutterMapController.addressReset();
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
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  //userAgentPackageName: 'com.example.app',
                ),
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
                        //..._flutterMapController.markerSelected,
                      ],
                      popupDisplayOptions: PopupDisplayOptions(
                        builder: (BuildContext context, Marker marker) {
                          //_flutterMapController.lastOpenedMarker = marker;
                          if (marker is! VehicleMarker &&
                              marker is! FermataMarker) {
                            return AddressWidget(
                                marker: marker,
                                controller: _flutterMapController);
                          }
                          return CardMapWidget(
                              marker: marker,
                              controller: _flutterMapController);
                        },
                      ),
                    ),
                  ),
                ),
                /* Obx(
                  () => PopupMarkerLayer(
                      options: PopupMarkerLayerOptions(
                    markers: _flutterMapController
                        .geolocatorController.markerSelected,
                    popupController: _flutterMapController
                        .geolocatorController.popupController,
                    popupDisplayOptions:
                        PopupDisplayOptions(builder: (context, marker) {
                      return AddressWidget(
                        marker: marker,
                      );
                    }),
                  )),
                ), */
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Get
                                .theme.colorScheme.primaryContainer
                                .withOpacity(0.8),
                            child: IconButton(
                              tooltip: 'Center Bounds',
                              onPressed: () =>
                                  _flutterMapController.centerBounds(),
                              icon: const Icon(Icons.center_focus_strong),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Obx(
                            () => CircleAvatar(
                              radius: 25,
                              backgroundColor: Get
                                  .theme.colorScheme.primaryContainer
                                  .withOpacity(0.8),
                              child:
                                  _flutterMapController.isLocationLoading.isTrue
                                      ? const CircularProgressIndicator()
                                      : IconButton(
                                          tooltip: 'Location',
                                          onPressed: () {
                                            _flutterMapController.userLocation
                                                .switchLocationShowing();
                                            if (_flutterMapController
                                                .userLocation
                                                .isLocationShowing
                                                .isTrue) {
                                              _flutterMapController
                                                  .goToUserLocation();
                                            }
                                          },
                                          icon: _flutterMapController
                                                  .userLocation
                                                  .isLocationShowing
                                                  .isFalse
                                              ? const Icon(Icons.location_on)
                                              : const Icon(Icons.location_off),
                                        ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
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
                              onPressed: () => _flutterMapController.zoomOut(),
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
                              onPressed: () => _flutterMapController.zoomIn(),
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => MarkerLayer(
                    markers: [
                      if (_flutterMapController
                          .userLocation.isLocationAvailable.isTrue)
                        Marker(
                          point: _flutterMapController
                              .userLocation.userLocationMarker.value,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                    ],
                  ),
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
