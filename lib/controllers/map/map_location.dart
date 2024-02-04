import 'dart:async';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapLocation extends GetxController {
  LatLng? _userLocation;
  StreamSubscription<LocationData>? _locationSubscription;
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

  Future<void> _listenLocation(Location location) async {
    if (_locationSubscription != null) return;
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
      stopLocationListen();
    }).listen((currentLocation) {
      _userLocation =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);
      if (isLocationInitialized.isFalse) {
        userLocationMarker = _userLocation!.obs;
        isLocationInitialized.value = true;
      } else {
        userLocationMarker.value = _userLocation!;
      }
    });
  }

  Future<void> stopLocationListen() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }
}
