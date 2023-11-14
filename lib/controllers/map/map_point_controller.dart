import 'package:flutter_gtt/models/fermata.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/extension_api.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapPointController extends GetxController {
  final Fermata initialFermata = Get.arguments['fermata'];
  final mapController = MapController();
  final popupController = PopupController();

  LatLng get fermataLocation =>
      LatLng(initialFermata.latitude, initialFermata.longitude);

  @override
  void onClose() {
    mapController.dispose();
    popupController.dispose();
    super.onClose();
  }

  void onMapReady() {
    popupController.togglePopup(FermataMarker(fermata: initialFermata));
  }
}
