import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/route_list_controller.dart';
import 'package:torino_mobility/models/gtt/route.dart' as gtt;
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:get/get.dart';

class ListSearchController extends GetxController {
  late final List<gtt.Route> routes;
  TextEditingController? _searchController;
  FocusNode? focusNode;
  @override
  void onInit() async {
    routes = Get.find<RouteListController>()
        .routesMap
        .values
        .expand((element) => element)
        .toList();
    super.onInit();
  }

  void setSearchController(TextEditingController searchController) {
    _searchController = searchController;
  }

  void clearText() {
    _searchController?.clear();
  }

  void listenUnfocus(FocusNode node) {
    focusNode = node;
    node.addListener(() {
      if (!node.hasFocus) {
        clearText();
      }
    });
  }

  void onSearch(String value) async {
    List<gtt.Route>? suggestions = await getSuggestions(value);
    clearText();
    if (suggestions != null && suggestions.isNotEmpty) {
      Get.toNamed('/mapBus', arguments: {
        'vehicles': [suggestions.first]
      });
    } else {
      Utils.showSnackBar(
        'Nessun veicolo trovato',
        snackPosition: SnackPosition.TOP,
        closePrevious: true,
      );
    }
  }

  FutureOr<List<gtt.Route>?> getSuggestions(String value) async {
    if (value.isEmpty) {
      return null;
    }
    List<gtt.Route> suggestions = routes
        .where((route) => route.shortName.isCaseInsensitiveContains(value))
        .toList();
    Utils.sort(suggestions);
    return suggestions;
  }
}
