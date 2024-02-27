import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_gtt/controllers/map/map_info_controller.dart';
import 'package:flutter_gtt/controllers/map/map_location.dart';
import 'package:flutter_gtt/models/gtt/pattern.dart' as gtt;
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/models/mqtt_data.dart';
import 'package:flutter_gtt/models/gtt/route.dart' as gtt;
import 'package:flutter_gtt/resources/api/geocoder_api.dart';
import 'package:flutter_gtt/resources/api/mqtt_controller.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:flutter_gtt/resources/utils/maps.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapPageController extends GetxController
    with GetTickerProviderStateMixin {
  static const double minZoom = 12;
  static const double maxZoom = 18;
  static const List colors = [
    Colors.blue,
    Colors.green,
    Colors.pinkAccent,
    Colors.brown,
    Colors.deepPurple,
    Colors.tealAccent,
    Colors.deepOrange,
  ];
  late MapInfoController mapInfoController;
  MapController mapController = MapController();
  PopupController popupController = PopupController();
  // used for deleting animations that are not finished yet when closing the page
  final List<AnimationController> _activeAnimations = [];

  late RxList<FermataMarker> allStops;
  final RxMap<int, VehicleMarker> allVehicles = <int, VehicleMarker>{}.obs;
  final RxMap<String, gtt.RouteWithDetails> routes =
      <String, gtt.RouteWithDetails>{}.obs;
  final Map<String, int> routeIndex = {};
  final RxList<gtt.Pattern> routePatterns = <gtt.Pattern>[].obs;

  //live bus
  late final MqttController _mqttController;

  final RxMap<String, RxMap<int, MqttVehicle>> mqttInformation =
      <String, RxMap<int, MqttVehicle>>{}.obs;

  Marker? lastOpenedMarker;

  final MapLocation userLocation = Get.put(MapLocation(), permanent: true);
  final RxBool isLocationLoading = false.obs;

  final RxBool isPatternInitialized = false.obs;

  // for single route, for showing the direction
  final Map<String, Stop> firstStop = {};

  // save last view
  late MapCamera lastView;

  // map event related
  double lastZoom = 0.0;

  // follow vehicle
  final RxInt followVehicle = 0.obs; // <= 0 = not following

  RxList<VehicleMarker> get allVehiclesInDirection => allVehicles.values
      .where(
        (vehicle) =>
            vehicle.mqttData.direction ==
            routes[vehicle.mqttData.shortName]?.pattern.directionId,
      )
      .toList()
      .obs;

  double get offsetVal {
    int len = routes.length;
    switch (len) {
      case 1:
        return 0.0;
      case 2:
        return 0.0002;
      case 3:
        return 0.0001;
      default:
        return 0.00005;
    }
  }

  @override
  void onClose() async {
    for (var element in _activeAnimations) {
      element.dispose();
    }
    await _mqttController.dispose();
    mapController.dispose();
    popupController.dispose();
    mapInfoController.dispose();
    userLocation.onMapDispose();

    super.onClose();
  }

  void _removeOldVehicles() {
    allVehicles.removeWhere((key, vehicle) {
      if (vehicle.mqttData.lastUpdate
          .isBefore(DateTime.now().subtract(const Duration(minutes: 2)))) {
        if (followVehicle.value != 0 &&
            vehicle.mqttData.vehicleNum == followVehicle.value) {
          stopFollowingVehicle();
          Utils.showSnackBar('Il veicolo che stavi seguendo è stato rimosso');
        }
        if (lastOpenedMarker != null &&
            lastOpenedMarker is VehicleMarker &&
            (lastOpenedMarker as VehicleMarker).mqttData.vehicleNum ==
                vehicle.mqttData.vehicleNum) {
          popupController.hideAllPopups();
        }
        return true;
      }
      return false;
    });
  }

  void onMapEvent(MapEvent mapEvent) {
    if (lastZoom != mapEvent.camera.zoom && isPatternInitialized.isTrue) {
      lastZoom = mapEvent.camera.zoom;

      List<FermataMarker> list = allStops
          .map((marker) => marker.copyWith(zoom: mapEvent.camera.zoom))
          .toList();
      allStops.clear();
      allStops.addAll(list);
    }
  }

  void onMapReady() async {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _removeOldVehicles();
    });
    _mqttController = MqttController();
    List<gtt.Route> routeValues = Get.arguments['vehicles'];
    final Stop? initialStop = Get.arguments['fermata'];
    mapInfoController = Get.put(MapInfoController());
    final bool showMultiplePatterns =
        Get.arguments['multiple-patterns'] ?? false;

    if (initialStop != null && Storage.isFermataShowing) {
      popupController.togglePopup(FermataMarker(fermata: initialStop));
    }
    // if opened from bus list
    if (!showMultiplePatterns && routeValues.first is! gtt.RouteWithDetails) {
      routePatterns
          .addAll(await DatabaseCommands.getPatterns(routeValues.first));

      for (var pattern in routePatterns) {
        Stop firstStopValue =
            (await DatabaseCommands.getStopsFromPattern(pattern)).first;
        firstStop.putIfAbsent(pattern.code, () => firstStopValue);
      }
      routeValues = [
        gtt.RouteWithDetails.fromData(
            route: routeValues.first,
            stoptimes: [],
            pattern: routePatterns.first)
      ];
    }
    int routeCount = 0; // limit to 'maxRoutesInMap' routes
    Set<Stop> stops = {};
    for (gtt.Route route in routeValues) {
      if (showMultiplePatterns &&
          !Storage.isRouteWithoutPassagesShowing &&
          (route as gtt.RouteWithDetails).stoptimes.isEmpty) continue;

      _mqttController
          .addSubscription((route as gtt.RouteWithDetails).shortName);
      stops.addAll(await DatabaseCommands.getStopsFromPattern(route.pattern));

      /*for (var stop in stops) {
        List<gtt.Route> routeValues =
            await DatabaseCommands.getRouteFromStop(stop);
        uniqueStops
            .add(StopWithDetails.fromStop(stop: stop, vehicles: routeValues));
      }*/

      // stopsTemp.addAll(await DatabaseCommands.getStopsFromPattern(route.pattern));

      routes.putIfAbsent(route.shortName.replaceAll(' ', ''), () => route);
      routeIndex.putIfAbsent(
          route.shortName.replaceAll(' ', ''), () => routeIndex.length);

      if (++routeCount >= maxRoutesInMap) break;
    }
    allStops = stops.map((stop) => FermataMarker(fermata: stop)).toList().obs;
    /*allStops =
        uniqueStops.map((stop) => FermataMarker(fermata: stop)).toList().obs;
    */
    _mqttController.connect();

    isPatternInitialized.value = true;
    _listenData();
    lastView = _getCenterBounds();
    centerBounds();
  }

  void centerBounds() {
    final constrained = _getCenterBounds();

    if (nearEqual(constrained.zoom, mapController.camera.zoom, 0.0001) &&
        nearEqual(constrained.center.latitude,
            mapController.camera.center.latitude, 0.0001) &&
        nearEqual(constrained.center.longitude,
            mapController.camera.center.longitude, 0.0001)) {
      _animatedMapMove(lastView.center, lastView.zoom);
    } else {
      lastView = mapController.camera;
      _animatedMapMove(constrained.center, constrained.zoom);
    }
  }

  MapCamera _getCenterBounds() {
    return CameraFit.coordinates(
      coordinates: (routes.values.first).pattern.polylinePoints,
      padding: const EdgeInsets.all(20.0),
    ).fit(mapController.camera);
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _activeAnimations.add(controller);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _activeAnimations.remove(controller);
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _animatedMarkerMove(MqttVehicle payload) {
    final latTween = Tween<double>(
        begin: allVehicles[payload.vehicleNum]!.mqttData.position.latitude,
        end: payload.position.latitude);
    final lngTween = Tween<double>(
        begin: allVehicles[payload.vehicleNum]!.mqttData.position.longitude,
        end: payload.position.longitude);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _activeAnimations.add(controller);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      final newLat = latTween.evaluate(animation);
      final newLng = lngTween.evaluate(animation);

      if (allVehicles[payload.vehicleNum]!.mqttData.position.latitude !=
              newLat ||
          allVehicles[payload.vehicleNum]!.mqttData.position.longitude !=
              newLng) {
        allVehicles.update(
          payload.vehicleNum,
          (value) => allVehicles[payload.vehicleNum]!.copyWith(
            mqttData: allVehicles[payload.vehicleNum]!.mqttData.copyWith(
                  position: LatLng(newLat, newLng),
                  rotation: payload.rotation,
                  speed: payload.speed,
                  tripId: payload.tripId,
                  direction: payload.direction,
                  isFull: payload.isFull,
                  nextStop: payload.nextStop,
                  lastUpdate: payload.lastUpdate,
                ),
          ),
        );
      }
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _activeAnimations.remove(controller);
        controller.dispose();
      }
    });

    // popup following marker
    VehicleMarker oldMarker = allVehicles[payload.vehicleNum]!;
    if (lastOpenedMarker != null &&
        lastOpenedMarker is VehicleMarker &&
        (lastOpenedMarker as VehicleMarker).point == oldMarker.point) {
      popupController.showPopupsOnlyFor([VehicleMarker(mqttData: payload)]);
      lastOpenedMarker = VehicleMarker(mqttData: payload);
    }
    if (followVehicle.value == payload.vehicleNum) {
      _animatedMapMove(payload.position, mapController.camera.zoom);
    }
    controller.forward();
  }

  void _listenData() async {
    _mqttController.payloadStream.listen((MqttVehicle payload) {
      if (allVehicles.containsKey(payload.vehicleNum)) {
        _animatedMarkerMove(payload);
      } else {
        allVehicles.putIfAbsent(
          payload.vehicleNum,
          () => VehicleMarker(
            mqttData: payload,
            color: routes.length == 1
                ? null
                : Utils.darken(
                    colors[
                        (routeIndex[payload.shortName] ?? 0) % colors.length],
                    30),
            internalColor: routes[payload.shortName]?.type == 0 &&
                    !MapUtils.isTram(payload.vehicleNum)
                ? Colors.white
                : null,
          ),
        );
      }
      //}
    });
  }

  void zoomIn() => _zoomAnimation(true);

  void zoomOut() => _zoomAnimation(false);

  Future<void> _zoomAnimation(bool isZoomIn) async {
    final animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _activeAnimations.add(animController);
    final currentZoom = mapController.camera.zoom;
    double destZoom =
        clampDouble(currentZoom + (isZoomIn ? 1 : (-1)), minZoom, maxZoom);
    final zoomTween = Tween<double>(begin: currentZoom, end: destZoom);
    final Animation<double> animation =
        CurvedAnimation(parent: animController, curve: Curves.fastOutSlowIn);
    animController.addListener(() {
      mapController.move(
        mapController.camera.center,
        zoomTween.evaluate(animation),
      );
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _activeAnimations.remove(animController);
        animController.dispose();
      }
    });
    animController.forward();
  }

  void setCurrentPattern(gtt.Pattern newPattern) async {
    allStops.clear();
    List<Stop> stopTemp =
        await DatabaseCommands.getStopsFromPattern(newPattern);

    allStops.addAll(stopTemp.map((stop) => FermataMarker(fermata: stop)));
    routes.update(routes.keys.first,
        (value) => routes.values.first.copyWith(pattern: newPattern));
    popupController.hideAllPopups();
    centerBounds();
    //mqttData.clear();
  }

  void goToUserLocation() async {
    isLocationLoading.value = true;
    try {
      if (userLocation.isLocationInitialized.isTrue) {
        _animatedMapMove(userLocation.userLocationMarker.value, 16);
      } else {
        _animatedMapMove(await userLocation.userLocation, 16);
      }
    } catch (e) {
      Utils.showSnackBar(e.toString(), title: "Error");
    }

    isLocationLoading.value = false;
  }

  void stopFollowingVehicle() {
    followVehicle.value = 0;
  }

  void followVehicleMarker(MqttVehicle vehicle) {
    followVehicle.value = vehicle.vehicleNum;
    _animatedMapMove(vehicle.position, mapController.camera.zoom);
  }

  void moveToFollowed() {
    if (followVehicle.value != 0) {
      _animatedMapMove(allVehicles[followVehicle.value]!.mqttData.position,
          mapController.camera.zoom);
    }
  }

  RxList<Marker> markerSelected = <Marker>[].obs;
  RxString lastAddress = ''.obs;
  RxBool isLoadingAddress = false.obs;
  void onMapLongPress(TapPosition tapPosition, LatLng location) {
    if (kDebugMode) {
      markerSelected.value = [
        MapUtils.addressMarker(location),
      ];
      getAddress(markerSelected.first);
      popupController.showPopupsOnlyFor(markerSelected);
    }
  }

  void addressReset() {
    markerSelected.clear();
  }

  void getAddress(Marker marker) async {
    if (kDebugMode) {
      isLoadingAddress.value = true;
      var jsonResult = await GeocoderApi.getAddress(
          marker.point.latitude, marker.point.longitude);
      lastAddress.value =
          '${jsonResult['features'][0]['properties']?['name'] ?? 'Indirizzo non trovato'},${jsonResult['features'][0]['properties']?['postalcode'] ?? ''}';
      print(jsonResult['features'][0]);

      isLoadingAddress.value = false;
    }
  }
}
