import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:get/get.dart';

class SearchStopsController extends GetxController {
  TextEditingController? _searchController;
  FocusNode? _focusNode;
  Future<List<Stop>> getStopsFromValue(String value) async {
    if (value.isEmpty) {
      return [];
    }
    if (int.tryParse(value) != null) {
      return await DatabaseCommands.instance.getStopsFromCode(int.parse(value));
    } else {
      return await DatabaseCommands.instance.getStopsFromName(value);
    }
  }

  void setTextController(TextEditingController controller) {
    _searchController = controller;
  }

  void setFocusNode(FocusNode node) {
    _focusNode = node;
    node.addListener(() {
      if (!node.hasFocus) {
        _searchController?.clear();
      }
    });
  }

  void onSubmitted([String? value]) async {
    value ??= _searchController?.text ?? '';
    _searchController?.clear();
    _focusNode?.unfocus();
    if (value.isEmpty) return;
    List<Stop> stops = await getStopsFromValue(value);

    if (stops.isEmpty) {
      Utils.showSnackBar('La fermata non esiste',
          title: 'Errore', snackPosition: SnackPosition.TOP);
      //Get.snackbar('Errore', 'La fermata non esiste');
    } else {
      openInfoPage(stops.first);
    }
  }

  void openInfoPage(Stop stop) {
    Get.toNamed('/info', arguments: {'fermata': stop});
  }

  void searchButton() {
    _focusNode?.hasFocus ?? false ? onSubmitted() : _focusNode?.requestFocus();
  }
}
