import 'dart:async';

import 'package:flutter_gtt/controllers/map/map_animation.dart';
import 'package:flutter_gtt/controllers/map/map_location.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_gtt/resources/api/geocoder_api.dart';
import 'package:flutter_gtt/resources/utils/map_utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../resources/utils/utils.dart';

class MapAddressController extends GetxController {
  final RxList<Marker> markerSelected = <Marker>[].obs;
  RxList<AddressWithDetails> lastAddress = <AddressWithDetails>[].obs;
  RxBool isLoadingAddress = false.obs;
  final PopupController popupController = PopupController();
  final mapLocation = Get.put(MapLocation(), permanent: true);
  final MapAnimation mapAnimation = Get.find(tag: 'globalAnimation');

  void onMapLongPress(TapPosition tapPosition, LatLng location) {
    getAddress(location);
    setMarker(location);
  }

  void setAddress(AddressWithDetails address) {
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

    AddressWithDetails address = AddressWithDetails.empty();
    if (jsonResult['features'] != null && jsonResult['features'].isNotEmpty) {
      address = AddressWithDetails.fromJson(jsonResult['features'][0]);
    }

    if (address.isValid) {
      if (mapLocation.isLocationAvailable.isTrue) {
        address.distanceInKm = Geolocator.distanceBetween(
              mapLocation.userPosition.first.latitude,
              mapLocation.userPosition.first.longitude,
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
      lastAddress.value = [AddressWithDetails.empty()];
      Utils.showSnackBar('Indirizzo non valido');
    }
    //print(jsonResult['features'][0]);

    isLoadingAddress.value = false;
  }

  FutureOr<List<AddressWithDetails>?> getSuggestions(String value) async {
    if (value.isEmpty) {
      value = 'Torino';
    }
    double? lat, lon;

    if (mapLocation.isLocationAvailable.isTrue) {
      lat = mapLocation.userPosition.first.latitude;
      lon = mapLocation.userPosition.first.longitude;
    }
    var jsonResult =
        await GeocoderApi.getAddressFromString(value, lat: lat, lon: lon);
    Set<AddressWithDetails> suggestions = {};
    AddressWithDetails address;
    for (var json in jsonResult['features']) {
      address = AddressWithDetails.fromJson(json);
      if (address.isValid) suggestions.add(address);
    }

    return suggestions.toList();
  }

  void onSelected(AddressWithDetails address) {
    setAddress(address);
    mapAnimation.animate(address.position, zoom: 15);
  }
}
