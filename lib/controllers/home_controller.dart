import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<FavStop> fermate = [];
  late final Rx<TextEditingController> descriptionController;
  final key = GlobalKey<FormState>();
  late Offset tapPosition;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  RelativeRect get relRectSize => RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        Get.size.width - tapPosition.dx,
        Get.size.height - tapPosition.dy,
      );

  // ↓ get the tap position Offset
  void getPosition(TapDownDetails detail) {
    tapPosition = detail.globalPosition;
  }

  @override
  void onClose() {
    descriptionController.value.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    Get.put(RouteListController());
    descriptionController = TextEditingController().obs;
    getStops();
  }

  void getStops() async {
    fermate = await DatabaseCommands.getFermate();
    update();
  }

  void moveOnTop(Stop stop) {
    DatabaseCommands.updateStopWithSmallestDate(stop);
    getStops();
  }

  void updateStop(FavStop fermata) {
    DatabaseCommands.updateStop(fermata);
    getStops();
  }

  void deleteStop(FavStop fermata) {
    DatabaseCommands.deleteStop(fermata);
    getStops();
  }
}
