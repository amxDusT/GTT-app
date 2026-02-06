import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/models/marker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/extension_api.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapPointController extends GetxController {
  final Stop initialFermata = Get.arguments['fermata'];
  final mapController = MapController();
  final popupController = PopupController();

  LatLng get fermataLocation => LatLng(initialFermata.lat, initialFermata.lon);

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
