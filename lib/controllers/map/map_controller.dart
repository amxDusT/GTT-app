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
  final double minZoom = 10;
  final double maxZoom = 18;
  final gtt.Route _vehicle = Get.arguments['vehicle'];

  late final Rx<gtt.Pattern> currentPattern;
  late final RxList<gtt.Stop> currentFermate;
  RxList<gtt.Pattern> routePatterns = <gtt.Pattern>[].obs;
  MapController mapController = MapController();
  PopupController popupController = PopupController();
  final List<AnimationController> _activeAnimations = [];

  //live bus
  late MqttController _mqttController;
  final RxMap<int, MqttData> mqttData = <int, MqttData>{}.obs;
  RxMap<int, MqttData> get mqttDirection => RxMap.from(
        {
          for (var element in mqttData.values.where(
            (element) => element.direction == currentPattern.value.directionId,
          ))
            element.vehicleNum: element
        },
      );
  Marker? lastOpenedMarker;
  // User Location
  LatLng? _userLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  final RxList<LatLng> userLocationMarker = <LatLng>[].obs;
  final RxBool isLocationLoading = false.obs;
  final RxBool isPatternInitialized = false.obs;

  @override
  void onInit() async {
    _mqttController = MqttController(_vehicle.shortName);
    super.onInit();
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
    if (_vehicle is gtt.RouteWithDetails) {
      currentPattern = (_vehicle as gtt.RouteWithDetails).pattern.obs;
    } else {
      routePatterns.value = await DatabaseCommands.getPatterns(_vehicle);
      if (routePatterns.isEmpty) {
        //error
        throw 'Unexpected Behaviour';
      }
      currentPattern = routePatterns.first.obs;
    }
    currentFermate =
        (await DatabaseCommands.getStopsFromPattern(currentPattern.value)).obs;
    isPatternInitialized.value = true;
    _listenData();
    _centerBounds();
  }

  void _centerBounds() {
    final constrained = CameraFit.coordinates(
      coordinates: currentPattern.value.polylinePoints,
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
        begin: mqttData[payload.vehicleNum]!.position.latitude,
        end: payload.position.latitude);
    final lngTween = Tween<double>(
        begin: mqttData[payload.vehicleNum]!.position.longitude,
        end: payload.position.longitude);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _activeAnimations.add(controller);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      final newLat = latTween.evaluate(animation);
      final newLng = lngTween.evaluate(animation);

      if (mqttData[payload.vehicleNum]?.position.latitude != newLat ||
          mqttData[payload.vehicleNum]?.position.longitude != newLng) {
        mqttData.update(
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
    /*
    popupController.showPopupsOnlyFor(
        [VehicleMarker(mqttData: mqttData[payload.vehicleNum]!)]);
    
    List<Marker> openedMarkers =
        PopupState.maybeOf(Get.context!)!.selectedMarkers;
    */
    // popup following marker
    VehicleMarker oldMarker =
        VehicleMarker(mqttData: mqttData[payload.vehicleNum]!);

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
      if (mqttData.containsKey(payload.vehicleNum)) {
        _animatedMarkerMove(payload);
      } else {
        mqttData.putIfAbsent(payload.vehicleNum, () => payload);
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
    currentPattern.value = newPattern;
    currentFermate.value =
        await DatabaseCommands.getStopsFromPattern(newPattern);
    popupController.hideAllPopups();
    _centerBounds();
    //mqttData.clear();
  }
}
