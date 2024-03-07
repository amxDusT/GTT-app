import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_address.dart';
import 'package:flutter_gtt/controllers/map/map_location.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class MapSearchController {
  TextEditingController controller = TextEditingController();
  FocusNode? focusNode;
  final RxBool isSearching = false.obs;
  final MapAddressController mapAddress;
  final SuggestionsController<AddressWithDetails> suggestionsController =
      SuggestionsController();
  final MapLocation mapLocation = Get.find();
  MapSearchController({required this.mapAddress});

  void onSearchIconClicked() {
    isSearching.toggle();
  }

  void clearText() {
    controller.clear();
  }

  void listenFocus(FocusNode node) {
    focusNode = node;
    node.addListener(() {
      if (node.hasFocus) {
        isSearching.value = true;
      } else {
        isSearching.value = false;
      }
    });
  }

  void addToText(AddressWithDetails address) {
    controller.text = address.toDetailedString(showHouseNumber: true);
  }

  void dispose() {
    isSearching.close();
  }
}
