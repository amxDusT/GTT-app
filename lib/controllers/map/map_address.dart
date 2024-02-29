import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_gtt/resources/api/geocoder_api.dart';
import 'package:flutter_gtt/resources/utils/maps.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../resources/utils/utils.dart';

class MapAddressController {
  final RxList<Marker> markerSelected = <Marker>[].obs;
  RxList<Address> lastAddress = <Address>[].obs;
  RxBool isLoadingAddress = false.obs;
  final PopupController popupController;
  MapAddressController({required this.popupController});

  void onMapLongPress(TapPosition tapPosition, LatLng location) {
    getAddress(location);
    setMarker(location);
    print(location);
  }

  void setAddress(Address address) {
    if (!address.isValid) {
      Utils.showSnackBar('Indirizzo non valido');

      return;
    }
    setMarker(address.position);
    lastAddress.value = [address];
  }

  void setMarker(LatLng position) {
    //print(position);
    markerSelected.value = [
      MapUtils.addressMarker(position),
    ];
    popupController.showPopupsOnlyFor(markerSelected);
  }

  void addressReset() {
    popupController.hideAllPopups();
    markerSelected.clear();
    lastAddress.clear();
  }

  Future<void> getAddress(LatLng position) async {
    isLoadingAddress.value = true;
    var jsonResult = await GeocoderApi.getAddressFromPosition(
        position.latitude, position.longitude);
    print(jsonResult);
    Address address = Address.empty();
    if (jsonResult['features'] != null && jsonResult['features'].isNotEmpty) {
      address = Address.fromJson(jsonResult['features'][0]);
    }

    if (address.isValid) {
      lastAddress.value = [address];
    } else {
      if (markerSelected.isNotEmpty && markerSelected.first.point == position) {
        addressReset();
      }
      lastAddress.value = [Address.empty()];
      Utils.showSnackBar('Indirizzo non valido');
    }
    //print(jsonResult['features'][0]);

    isLoadingAddress.value = false;
  }

  void dispose() {
    markerSelected.close();
    lastAddress.close();
    isLoadingAddress.close();
  }
}
