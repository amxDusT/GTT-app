import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/gtt_models.dart' as gtt;
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/models/mqtt_data.dart';
import 'package:flutter_gtt/resources/api.dart';
import 'package:flutter_gtt/resources/database.dart';
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
    //Colors.red,
    Colors.green,
    //Colors.yellow,
    Colors.brown,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
  ];

  late final Map<String, gtt.Route> _newVehicles = {};
  final RxMap<String, gtt.Pattern> patterns = <String, gtt.Pattern>{}.obs;
  final RxMap<String, List<gtt.Stop>> stops = <String, List<gtt.Stop>>{}.obs;
  RxList<gtt.Pattern> routePatterns = <gtt.Pattern>[].obs;
  MapController mapController = MapController();
  PopupController popupController = PopupController();
  final List<AnimationController> _activeAnimations = [];

  //live bus
  late MqttController _mqttController;

  final RxMap<String, RxMap<int, MqttData>> newMqttData =
      <String, RxMap<int, MqttData>>{}.obs;

  List<gtt.Stop> get allStops {
    List<gtt.Stop> all = [];

    for (var s in stops.values) {
      all.addAll(s);
    }

    return all;
  }

  RxList<MqttData> get allVehiclesInDirection {
    RxList<MqttData> list = <MqttData>[].obs;
    for (var mapEntry in newMqttData.entries) {
      list.addAll(mapEntry.value.values.where(
        (el) => el.direction == patterns[mapEntry.key]!.directionId,
      ));
    }
    return list;
  }

  // RxMap<int, MqttData> get mqttDirection => RxMap.from(
  //       {
  //         for (var element in mqttData.values.where(
  //           (element) => element.direction == currentPattern.value.directionId,
  //         ))
  //           element.vehicleNum: element
  //       },
  //     );
  Marker? lastOpenedMarker;
  // User Location
  LatLng? _userLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  final RxList<LatLng> userLocationMarker = <LatLng>[].obs;
  final RxBool isLocationLoading = false.obs;
  final RxBool isPatternInitialized = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _mqttController = MqttController();

    for (gtt.Route route in Get.arguments['vehicles']) {
      _newVehicles.putIfAbsent(route.shortName, () => route);
      _mqttController.addSubscription(route.shortName);
    }

    _mqttController.connect();
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

  void onMapReady() async {
    final gtt.Stop? initialFermata = Get.arguments['fermata'];
    if (initialFermata != null) {
      //print("fermata exists");
      popupController.togglePopup(FermataMarker(fermata: initialFermata));
    }

    for (gtt.Route route in _newVehicles.values) {
      patterns.putIfAbsent(
          route.shortName, () => (route as gtt.RouteWithDetails).pattern);

      List<gtt.Stop> stopsForPattern =
          await DatabaseCommands.getStopsFromPattern(
              patterns[route.shortName]!);
      stops.putIfAbsent(route.shortName, () => stopsForPattern);
      newMqttData.putIfAbsent(route.shortName, () => <int, MqttData>{}.obs);
    }

    isPatternInitialized.value = true;
    _listenData();
    _centerBounds();
  }

  void _centerBounds() {
    final constrained = CameraFit.coordinates(
      coordinates: patterns.values.first.polylinePoints,
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

  void _animatedMarkerMove(MqttData payload) {
    final latTween = Tween<double>(
        begin: newMqttData[payload.shortName]![payload.vehicleNum]!
            .position
            .latitude,
        end: payload.position.latitude);
    final lngTween = Tween<double>(
        begin: newMqttData[payload.shortName]![payload.vehicleNum]!
            .position
            .longitude,
        end: payload.position.longitude);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _activeAnimations.add(controller);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      final newLat = latTween.evaluate(animation);
      final newLng = lngTween.evaluate(animation);

      if (newMqttData[payload.shortName]![payload.vehicleNum]
                  ?.position
                  .latitude !=
              newLat ||
          newMqttData[payload.shortName]![payload.vehicleNum]
                  ?.position
                  .longitude !=
              newLng) {
        newMqttData[payload.shortName]!.update(
          payload.vehicleNum,
          (value) => payload.copyWith(position: LatLng(newLat, newLng)),
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
    VehicleMarker oldMarker = VehicleMarker(
        mqttData: newMqttData[payload.shortName]![payload.vehicleNum]!);

    if (lastOpenedMarker != null &&
        lastOpenedMarker is VehicleMarker &&
        (lastOpenedMarker as VehicleMarker).point == oldMarker.point) {
      //print("position updated?");
      popupController.showPopupsOnlyFor([VehicleMarker(mqttData: payload)]);
      lastOpenedMarker = VehicleMarker(mqttData: payload);
    }
    controller.forward();
  }

  void _listenData() async {
    _mqttController.payloadStream.listen((MqttData payload) {
      //if (currentPattern.value.directionId == payload.direction) {
      print(payload.shortName);
      if (newMqttData[payload.shortName]!.containsKey(payload.vehicleNum)) {
        _animatedMarkerMove(payload);
      } else {
        newMqttData[payload.shortName]!
            .putIfAbsent(payload.vehicleNum, () => payload);
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
}
