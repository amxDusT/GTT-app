import 'package:flutter/material.dart';
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/resources/database.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:get/get.dart';

class SearchStopsController extends GetxController {
  TextEditingController? _searchController;
  FocusNode? _focusNode;
  final RxBool showLeadingIcon = false.obs;

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

  FocusNode? get focusNode => _focusNode;
  void setFocusNode(FocusNode node) {
    _focusNode = node;
    node.addListener(() {
      if (!node.hasFocus) {
        _searchController?.clear();
      }
      showLeadingIcon.value = node.hasFocus;
    });
  }

  void onSubmitted([String? value]) async {
    value ??= _searchController?.text ?? '';
    _searchController?.clear();
    focusNode?.unfocus();
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
    focusNode?.hasFocus ?? false ? onSubmitted() : focusNode?.requestFocus();
  }
}
