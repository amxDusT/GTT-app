import 'package:flutter_gtt/controllers/map/map_address.dart';
import 'package:flutter_gtt/controllers/map/map_animation.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapGlobalController extends GetxController
    with GetTickerProviderStateMixin {
  static const LatLng initialCenter = LatLng(45.063609, 7.679618);
  final mapController = MapController();
  final popupController = PopupController();
  late final MapAddressController mapAddress;
  late final MapAnimation _mapAnimation;
  late final MapSearchController searchController;
  @override
  void onInit() {
    super.onInit();
    _mapAnimation = MapAnimation(controller: mapController, vsync: this);
    mapAddress = MapAddressController(popupController: popupController);
    searchController = MapSearchController(
        mapAddress: mapAddress, mapAnimation: _mapAnimation);
  }

  void onTap(TapPosition tapPosition, LatLng position) {
    popupController.hideAllPopups();
    mapAddress.addressReset();
    searchController.focusNode?.unfocus();
  }

  void onMapReady() {
    _mapAnimation.animateZoom(
        zoom: 15, duration: const Duration(milliseconds: 1000));
  }

  @override
  void onClose() {
    super.onClose();
    mapAddress.dispose();
    searchController.dispose();
    _mapAnimation.dispose();
    mapController.dispose();
    popupController.dispose();
  }
}
