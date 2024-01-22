import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/gtt_models.dart' as gtt;
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/models/mqtt_data.dart';
import 'package:flutter_gtt/resources/api.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/storage.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapPageController extends GetxController
    with GetTickerProviderStateMixin {
  static const double minZoom = 10;
  static const double maxZoom = 18;
  static const List colors = [
    Colors.green,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.brown,
    Colors.pinkAccent,
    Colors.tealAccent,
  ];

  MapController mapController = MapController();
  PopupController popupController = PopupController();
  final List<AnimationController> _activeAnimations = [];

  late final RxList<FermataMarker> allStops;
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
  // User Location
  LatLng? _userLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  final RxList<LatLng> userLocationMarker = <LatLng>[].obs;
  final RxBool isLocationLoading = false.obs;
  final RxBool isPatternInitialized = false.obs;

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
    if (len == 1) return 0.0;
    if (len == 2) return 0.0002;
    if (len == 3) return 0.0001;
    return 0.00005;
  }

  @override
  void onClose() async {
    for (var element in _activeAnimations) {
      element.dispose();
    }
    await _mqttController.dispose();
    mapController.dispose();
    popupController.dispose();
    _stopLocationListen();
    super.onClose();
  }

  void _removeOldVehicles() {
    allVehicles.removeWhere((key, vehicle) => vehicle.mqttData.lastUpdate
        .isBefore(DateTime.now().subtract(const Duration(minutes: 2))));
  }

  void onMapReady() async {
    Timer.periodic(const Duration(minutes: 2), (timer) {
      _removeOldVehicles();
    });
    _mqttController = MqttController();
    //bool isSingleRoute = Get.arguments['vehicles'].length == 1;
    Set<Stop> stopsTemp = {};
    List<gtt.Route> routeValues = Get.arguments['vehicles'];
    final Stop? initialFermata = Get.arguments['fermata'];
    final bool showMultiplePatterns =
        Get.arguments['multiple-patterns'] ?? false;

    if (initialFermata != null && Storage.isFermataShowing) {
      popupController.togglePopup(FermataMarker(fermata: initialFermata));
    }

    if (!showMultiplePatterns && routeValues.first is! gtt.RouteWithDetails) {
      routePatterns
          .addAll(await DatabaseCommands.getPatterns(routeValues.first));
      routeValues = [
        gtt.RouteWithDetails.fromData(
            route: routeValues.first,
            stoptimes: [],
            pattern: routePatterns.first)
      ];
    }

    for (gtt.Route route in routeValues) {
      _mqttController
          .addSubscription((route as gtt.RouteWithDetails).shortName);
      List<Stop> stops =
          await DatabaseCommands.getStopsFromPattern(route.pattern);

      for (var stop in stops) {
        List<gtt.Route> routeValues =
            await DatabaseCommands.getRouteFromStop(stop);
        stopsTemp
            .add(StopWithDetails.fromStop(stop: stop, vehicles: routeValues));
      }

      // stopsTemp.addAll(await DatabaseCommands.getStopsFromPattern(route.pattern));

      routes.putIfAbsent(route.shortName.replaceAll(' ', ''), () => route);
      routeIndex.putIfAbsent(
          route.shortName.replaceAll(' ', ''), () => routeIndex.length);
    }
    allStops =
        stopsTemp.map((stop) => FermataMarker(fermata: stop)).toList().obs;
    _mqttController.connect();

    isPatternInitialized.value = true;
    _listenData();
    _centerBounds();
  }

  void _centerBounds() {
    final constrained = CameraFit.coordinates(
      coordinates: (routes.values.first).pattern.polylinePoints,
      padding: const EdgeInsets.all(20.0),
    ).fit(mapController.camera);
    _animatedMapMove(constrained.center, constrained.zoom);
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
                        colors[(routeIndex[payload.shortName] ?? 0) %
                            colors.length],
                        30)));
      }
      //}
    });
  }

  void zoomIn() => _zoomAnimation(true);

  void zoomOut() => _zoomAnimation(false);

  FutureOr<LatLng> get userLocation async {
    if (_locationSubscription == null) {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw 'Service not enabled';
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw 'Permission denied';
        }
      }
      LocationData locationData = await location.getLocation();
      _listenLocation(location);
      return LatLng(locationData.latitude!, locationData.longitude!);
    } else if (_userLocation == null) {
      LocationData locationData = await Location().getLocation();
      return LatLng(locationData.latitude!, locationData.longitude!);
    }

    return _userLocation!;
  }

  void goToUserLocation() async {
    isLocationLoading.value = true;
    try {
      _animatedMapMove(await userLocation, 17);
    } catch (e) {
      Get
        ..closeAllSnackbars()
        ..snackbar("Errore", "Could not retrieve position");
    }

    isLocationLoading.value = false;
  }

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

  Future<void> _listenLocation(Location location) async {
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
      _stopLocationListen();
    }).listen((currentLocation) {
      _userLocation =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);
      userLocationMarker.clear();
      userLocationMarker.add(_userLocation!);
    });
  }

  Future<void> _stopLocationListen() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  void setCurrentPattern(gtt.Pattern newPattern) async {
    allStops.clear();
    List<Stop> stopTemp =
        await DatabaseCommands.getStopsFromPattern(newPattern);

    allStops.addAll(stopTemp.map((stop) => FermataMarker(fermata: stop)));
    routes.update(routes.keys.first,
        (value) => routes.values.first.copyWith(pattern: newPattern));
    popupController.hideAllPopups();
    _centerBounds();
    //mqttData.clear();
  }
}
