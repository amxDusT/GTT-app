import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_gtt/controllers/map/map_location_exception.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapLocation extends GetxController {
  StreamSubscription<Position>? _geolocatorSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;
  final RxList<Position> userPosition = <Position>[].obs;
  final RxDouble userHeading = 0.0.obs;
  final RxBool isLocationShowing = false.obs;

  RxBool get isLocationInitialized => userPosition.isNotEmpty.obs;

  RxBool get isLocationAvailable =>
      (isLocationInitialized.isTrue && isLocationShowing.isTrue).obs;
  late LocationSettings locationSettings;

  bool get isLocationListening => _geolocatorSubscription != null;
  @override
  void onInit() {
    super.onInit();
    setLocationSettings();
  }

  @override
  onClose() {
    stopLocationListen();
    super.onClose();
  }

  onMapDispose() {
    stopLocationListen();
    isLocationShowing.value = false;
  }

  void switchLocationShowing() {
    locationShowing = !isLocationShowing.value;
    //isLocationShowing.value ? listen() : stopLocationListen();
  }

  set locationShowing(bool value) {
    isLocationShowing.value = value;
    isLocationShowing.value ? listen() : stopLocationListen();
  }

  Future<void> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw MapLocationException('Servizio disabilitato');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw MapLocationException('Permesso negato',
            locationPermission: permission);
      } else if (permission == LocationPermission.deniedForever) {
        throw MapLocationException(
            'Permesso negato. Abilita la posizione nelle impostazioni del dispositivo',
            locationPermission: permission);
      }
    }
  }

  void listen() async {
    await checkLocationPermission();
    _listenGeoLocator();
  }

  void setLocationSettings({
    bool? forceLocationManager,
    LocationAccuracy? accuracy,
    Duration? intervalDuration,
  }) {
    locationSettings = AndroidSettings(
      accuracy: accuracy ?? LocationAccuracy.bestForNavigation,
      forceLocationManager: forceLocationManager ?? false,
      intervalDuration: intervalDuration ?? const Duration(seconds: 4),
    );
    if (isLocationListening) {
      stopLocationListen();
      listen();
    }
  }

  FutureOr<Position> get userLocation async {
    if (_geolocatorSubscription == null) {
      await checkLocationPermission();
      userPosition.value = [await Geolocator.getCurrentPosition()];

      _listenGeoLocator();
      return userPosition.first;
    }
    return userPosition.first;
  }

  Future<void> _listenGeoLocator() async {
    if (_geolocatorSubscription != null) return;
    _geolocatorSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((position) {
      //print('${position.heading} - ${position.headingAccuracy}');

      userPosition.value = [position];
    });

    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        userHeading.value = event.heading!;
      }
    });
  }

  Future<void> stopLocationListen() async {
    await _geolocatorSubscription?.cancel();
    _compassSubscription?.cancel();
    _geolocatorSubscription = null;
  }

  static LatLng getLatLngFromPosition(Position position) {
    return LatLng(position.latitude, position.longitude);
  }
}
