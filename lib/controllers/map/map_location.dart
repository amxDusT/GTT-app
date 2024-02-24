import 'dart:async';

import 'package:flutter_gtt/controllers/map/map_location_exception.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapLocation extends GetxController {
  late LatLng _userLocation;
  StreamSubscription<Position>? _geolocatorSubscription;
  late final Rx<LatLng> userLocationMarker;
  final RxBool isLocationInitialized = false.obs;
  final RxBool isLocationShowing = false.obs;

  RxBool get isLocationAvailable =>
      (isLocationInitialized.isTrue && isLocationShowing.isTrue).obs;
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
    isLocationShowing.value = !isLocationShowing.value;
    isLocationShowing.isTrue ? userLocation : stopLocationListen();
  }

  FutureOr<LatLng> get userLocation async {
    if (_geolocatorSubscription == null) {
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
      Position position = await Geolocator.getCurrentPosition();
      _userLocation = LatLng(position.latitude, position.longitude);
      _listenGeoLocator();
      return _userLocation;
    }
    return _userLocation;
  }

  Future<void> _listenGeoLocator() async {
    if (_geolocatorSubscription != null) return;
    _geolocatorSubscription = Geolocator.getPositionStream().listen((position) {
      _userLocation = LatLng(position.latitude, position.longitude);
      if (isLocationInitialized.isFalse) {
        userLocationMarker = _userLocation.obs;
        isLocationInitialized.value = true;
      } else {
        userLocationMarker.value = _userLocation;
      }
    });
  }

  Future<void> stopLocationListen() async {
    await _geolocatorSubscription?.cancel();
    _geolocatorSubscription = null;
  }
}
