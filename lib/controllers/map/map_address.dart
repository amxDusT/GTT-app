import 'dart:async';

import 'package:flutter_gtt/controllers/map/map_animation.dart';
import 'package:flutter_gtt/controllers/map/map_location.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_gtt/resources/api/geocoder_api.dart';
import 'package:flutter_gtt/resources/utils/maps.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../resources/utils/utils.dart';

class MapAddressController {
  final RxList<Marker> markerSelected = <Marker>[].obs;
  RxList<Address> lastAddress = <Address>[].obs;
  RxBool isLoadingAddress = false.obs;
  final PopupController popupController;
  final mapLocation = Get.put(MapLocation(), permanent: true);
  final MapAnimation mapAnimation;
  MapAddressController({
    required this.popupController,
    required this.mapAnimation,
  });

  void onMapLongPress(TapPosition tapPosition, LatLng location) {
    getAddress(location);
    setMarker(location);
    print(location);
  }

  void setAddress(Address address) {
    if (!address.isValid) {
      Utils.showSnackBar('Indirizzo non valido');

      return;
    }
    setMarker(address.position);
    lastAddress.value = [address];
  }

  void setMarker(LatLng position) {
    //print(position);
    markerSelected.value = [
      MapUtils.addressMarker(position),
    ];
    popupController.showPopupsOnlyFor(markerSelected);
  }

  void addressReset() {
    popupController.hideAllPopups();
    markerSelected.clear();
    lastAddress.clear();
  }

  Future<void> getAddress(LatLng position) async {
    isLoadingAddress.value = true;
    var jsonResult = await GeocoderApi.getAddressFromPosition(
        position.latitude, position.longitude);

    print(jsonResult);
    Address address = Address.empty();
    if (jsonResult['features'] != null && jsonResult['features'].isNotEmpty) {
      address = Address.fromJson(jsonResult['features'][0]);
    }

    if (address.isValid) {
      if (mapLocation.isLocationAvailable.isTrue) {
        address.distanceInKm = Geolocator.distanceBetween(
              mapLocation.userLocationMarker.value.latitude,
              mapLocation.userLocationMarker.value.longitude,
              address.position.latitude,
              address.position.longitude,
            ) /
            1000;
      }
      lastAddress.value = [address];
    } else {
      if (markerSelected.isNotEmpty && markerSelected.first.point == position) {
        addressReset();
      }
      lastAddress.value = [Address.empty()];
      Utils.showSnackBar('Indirizzo non valido');
    }
    //print(jsonResult['features'][0]);

    isLoadingAddress.value = false;
  }

  FutureOr<List<Address>?> getSuggestions(String value) async {
    if (value.isEmpty) {
      return null;
    }
    double? lat, lon;

    if (mapLocation.isLocationAvailable.isTrue) {
      lat = mapLocation.userLocationMarker.value.latitude;
      lon = mapLocation.userLocationMarker.value.longitude;
    }
    var jsonResult =
        await GeocoderApi.getAddressFromString(value, lat: lat, lon: lon);
    Set<Address> suggestions = {};
    Address address;
    for (var json in jsonResult['features']) {
      address = Address.fromJson(json);
      if (address.isValid) suggestions.add(address);
    }

    return suggestions.toList();
  }

  void onSearch(String value) async {
    List<Address>? suggestions = await getSuggestions(value);
    if (suggestions != null && suggestions.isNotEmpty) {
      Address address = suggestions.first;

      onSelected(address);
      print(address);
    } else {
      Utils.showSnackBar(
        'Nessun indirizzo trovato',
        snackPosition: SnackPosition.BOTTOM,
        closePrevious: true,
      );
    }
  }

  void onSelected(Address address) {
    setAddress(address);
    mapAnimation.animate(address.position, zoom: 15);
  }

  void dispose() {
    markerSelected.close();
    lastAddress.close();
    isLoadingAddress.close();
  }
}
