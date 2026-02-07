import 'package:torino_mobility/controllers/map/map_address.dart';
import 'package:torino_mobility/controllers/map/map_animation.dart';
import 'package:torino_mobility/controllers/map/map_location.dart';
import 'package:torino_mobility/controllers/map/map_travel_controller.dart';
import 'package:torino_mobility/controllers/search/search_controller.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapGlobalController extends GetxController
    with GetTickerProviderStateMixin {
  static const LatLng initialCenter = LatLng(45.063609, 7.679618);
  final mapController = MapController();

  late final MapAnimation _mapAnimation;
  late final MapAddressController mapAddress = Get.find();
  late final MapSearchController searchController = Get.find();
  late final MapTravelController travelController = Get.find();
  final MapLocation mapLocation = Get.find<MapLocation>();

  @override
  void onInit() {
    super.onInit();
    _mapAnimation = Get.find(tag: 'globalAnimation');
    mapLocation.locationShowing = true;
  }

  void onMapLongPress(TapPosition tapPosition, LatLng location) {
    _mapAnimation.animate(location);
    mapAddress.onMapLongPress(tapPosition, location);
  }

  void animateCamera(MapCamera camera) {
    _mapAnimation.animate(camera.center, zoom: camera.zoom);
  }

  void onTap(TapPosition tapPosition, LatLng position) {
    mapAddress.popupController.hideAllPopups();
    mapAddress.addressReset();
    searchController.focusNode.unfocus();
    //searchController.isSearching.value = false;
  }

  void onMapReady() {
    _mapAnimation.animateZoom(
        zoom: 15, duration: const Duration(milliseconds: 1000));
  }

  @override
  void onClose() {
    super.onClose();
    searchController.dispose();
    _mapAnimation.dispose();
    mapController.dispose();
    mapLocation.onMapDispose();
  }

  void get zoomIn => _mapAnimation.animateZoom(isZoomIn: true);
  void get zoomOut => _mapAnimation.animateZoom(isZoomIn: false);
}
