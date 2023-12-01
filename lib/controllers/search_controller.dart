import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/pages/info_page.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:get/get.dart';

class SearchStopsController extends GetxController {
  TextEditingController? _searchController;
  FocusNode? _focusNode;
  Future<List<Stop>> getStopsFromValue(String value) async {
    if (value.isEmpty) {
      return [];
    }
    if (int.tryParse(value) != null) {
      return await DatabaseCommands.getStopsFromCode(int.parse(value));
    } else {
      return await DatabaseCommands.getStopsFromName(value);
    }
  }

  void setTextController(TextEditingController controller) {
    _searchController ??= controller;
  }

  void setFocusNode(FocusNode node) {
    _focusNode ??= node;
  }

  void onSubmitted([String? value]) async {
    value ??= _searchController?.text ?? '';
    List<Stop> stops = await getStopsFromValue(value);
    _searchController?.clear();
    _focusNode?.unfocus();
    if (stops.isEmpty) {
      Get.snackbar('Errore', 'La fermata non esiste');
    } else {
      _openInfoPage(stops.first);
    }
  }

  void _openInfoPage(Stop stop) {
    Get.to(() => InfoPage(), arguments: {'fermata': stop});
  }

  void searchButton() {
    _focusNode?.hasFocus ?? false ? onSubmitted() : _focusNode?.requestFocus();
  }
}
