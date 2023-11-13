import 'package:flutter/material.dart';
import 'package:flutter_gtt/models/fermata.dart';
import 'package:flutter_gtt/pages/info_page.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<Fermata> fermate = [];
  late final Rx<TextEditingController> searchController;
  late final Rx<FocusNode> focusNode;
  late final Rx<TextEditingController> descriptionController;
  final key = GlobalKey<FormState>();
  late Offset tapXY;

  // ↓ hold screen size, using first line in build() method

  RelativeRect get relRectSize => RelativeRect.fromLTRB(
        tapXY.dx,
        tapXY.dy,
        Get.size.width - tapXY.dx,
        Get.size.height - tapXY.dy,
      );

  // ↓ get the tap position Offset
  void getPosition(TapDownDetails detail) {
    tapXY = detail.globalPosition;
  }

  @override
  void onClose() {
    searchController.value.dispose();
    focusNode.value.dispose();
    descriptionController.value.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController().obs;
    descriptionController = TextEditingController().obs;
    focusNode = FocusNode().obs;
    focusNode.value.addListener(
      () {
        searchController.value.clear();
        if (!focusNode.value.hasFocus) {
          key.currentState!.reset();
        }
      },
    );
    getStops();
  }

  void getStops() async {
    fermate = await DatabaseCommands.getFermate();
    update();
  }

  void updateStop(Fermata fermata) {
    DatabaseCommands.updateStop(fermata);
    getStops();
  }

  void addStop() {
    int stopNum = int.parse(searchController.value.text);

    searchController.value.clear();
    focusNode.value.unfocus();
    Fermata fermataEmpty = Fermata.empty(stopNum);
    DatabaseCommands.insertStop(fermataEmpty);
    getStops();
    Get.to(() => InfoPage(), arguments: {'fermata': fermataEmpty});
  }

  void deleteStop(Fermata fermata) {
    DatabaseCommands.deleteStop(fermata);
    getStops();
  }
}
