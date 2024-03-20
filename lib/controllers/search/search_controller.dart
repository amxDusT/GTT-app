import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_address.dart';
import 'package:flutter_gtt/controllers/map/map_location.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_gtt/resources/api/geocoder_api.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapSearchController extends GetxController {
  TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final MapAddressController mapAddress = Get.find();
  final MapLocation mapLocation = Get.find();
  final RxList<AddressWithDetails> suggestions = <AddressWithDetails>[].obs;
  final Rx<SimpleAddress> lastAddress = SimpleAddress(
    label: '',
    position: const LatLng(0.0, 0.0),
  ).obs;

  @override
  void onClose() {
    super.onClose();
    controller.dispose();
    focusNode.dispose();
  }

  void clearText() {
    controller.clear();
  }

  void addToText(AddressWithDetails address) {
    controller.text = address.toDetailedString(showHouseNumber: true);
    getSuggestions();
  }

  void onSearch(String value) async {
    await getSuggestions(value);
    if (suggestions.isNotEmpty) {
      AddressWithDetails address = suggestions.first;
      lastAddress.value = address;
      mapAddress.onSelected(address);
    } else {
      Utils.showSnackBar(
        'Nessun indirizzo trovato',
        snackPosition: SnackPosition.BOTTOM,
        closePrevious: true,
      );
    }
  }

  Future<void> getSuggestions([String? value]) async {
    if (value == null || value.isEmpty) {
      if (controller.text.isEmpty) {
        value = 'Torino';
      } else {
        value = controller.text;
      }
    }
    double? lat, lon;

    if (mapLocation.isLocationAvailable.isTrue) {
      lat = mapLocation.userPosition.first.latitude;
      lon = mapLocation.userPosition.first.longitude;
    }
    var jsonResult =
        await GeocoderApi.getAddressFromString(value, lat: lat, lon: lon);
    Set<AddressWithDetails> suggestionsLocal = {};
    AddressWithDetails address;
    for (var json in jsonResult['features']) {
      address = AddressWithDetails.fromJson(json);
      if (address.isValid) suggestionsLocal.add(address);
    }
    suggestions.value = suggestionsLocal.toList();
  }
}
