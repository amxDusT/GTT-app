import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_address.dart';
import 'package:flutter_gtt/controllers/map/map_animation.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_gtt/resources/api/geocoder_api.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class MapSearchController {
  TextEditingController controller = TextEditingController();
  FocusNode? focusNode;
  final RxBool isSearching = false.obs;
  final MapAddressController mapAddress;
  final MapAnimation mapAnimation;
  final SuggestionsController<Address> suggestionsController =
      SuggestionsController();
  MapSearchController({required this.mapAddress, required this.mapAnimation});

  void onSearchIconClicked() {
    isSearching.toggle();
  }

  void clearText() {
    controller.clear();
  }

  void listenUnfocus(FocusNode node) {
    focusNode = node;
  }

  void onSelected(Address address) {
    mapAnimation.animate(address.position, 15);
    mapAddress.setAddress(address);

    print('selected');
  }

  void onSearch(String value) async {
    List<Address>? suggestions = await getSuggestions(value);
    //clearText();
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

  FutureOr<List<Address>?> getSuggestions(String value) async {
    if (value.isEmpty) {
      return null;
    }
    var jsonResult = await GeocoderApi.getAddressFromString(value);
    Set<Address> suggestions = {};
    Address address;
    for (var json in jsonResult['features']) {
      address = Address.fromJson(json);
      if (address.isValid) suggestions.add(address);
    }

    return suggestions.toList(growable: false);
  }

  void dispose() {
    isSearching.close();
  }
}
