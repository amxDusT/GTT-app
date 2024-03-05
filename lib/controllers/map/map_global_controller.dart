import 'package:flutter_gtt/controllers/map/map_address.dart';
import 'package:flutter_gtt/controllers/map/map_animation.dart';
import 'package:flutter_gtt/controllers/map/map_location.dart';
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
  final MapLocation mapLocation = Get.put(MapLocation(), permanent: true);
  @override
  void onInit() {
    super.onInit();

    mapLocation.switchLocationShowing();
    _mapAnimation = MapAnimation(controller: mapController, vsync: this);
    mapAddress = MapAddressController(
      popupController: popupController,
      mapAnimation: _mapAnimation,
    );
    searchController = MapSearchController(
      mapAddress: mapAddress,
    );
  }

  void onMapLongPress(TapPosition tapPosition, LatLng location) {
    _mapAnimation.animate(location);
    mapAddress.onMapLongPress(tapPosition, location);
  }

  void onTap(TapPosition tapPosition, LatLng position) {
    print('here');
    popupController.hideAllPopups();
    mapAddress.addressReset();
    searchController.focusNode?.unfocus();
    searchController.isSearching.value = false;
    //searchController.isSearching.toggle();
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
    mapLocation.onMapDispose();
  }

  void get zoomIn => _mapAnimation.animateZoom(isZoomIn: true);
  void get zoomOut => _mapAnimation.animateZoom(isZoomIn: false);
}
