import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_address.dart';
import 'package:flutter_gtt/controllers/map/map_global_controller.dart';
import 'package:flutter_gtt/controllers/map/map_location.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:flutter_gtt/models/gtt/travel.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_gtt/pages/map/map_search_page.dart';
import 'package:flutter_gtt/resources/api/gtt_api.dart';
import 'package:flutter_gtt/widgets/search/disabled_focusnode.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gtt/models/gtt/route.dart' as gtt;

class MapTravelController extends GetxController {
  static const _textfieldHeight = 56.0;
  static const maxElements = 2;
  RxDouble additionalHeight = 0.0.obs;
  final RxList<Widget> rows = <Widget>[].obs;
  final MapSearchController fromController =
      Get.put(MapSearchController(), tag: 'from');
  final MapSearchController toController =
      Get.put(MapSearchController(), tag: 'to');

  final RxBool isSearching = false.obs;
  final Rx<SimpleAddress> fromAddress =
      SimpleAddress(label: '', position: const LatLng(0.0, 0.0)).obs;
  final Rx<SimpleAddress> toAddress =
      SimpleAddress(label: '', position: const LatLng(0.0, 0.0)).obs;
  final Rx<DateTime> travelDate = DateTime.now().obs;
  final MapAddressController mapAddress = Get.find();
  final MapLocation mapLocation = Get.find<MapLocation>();
  final double appBarHeight = 56.0;
  final RxList<Travel> lastTravel = <Travel>[].obs;

  void switchAddresses() {
    final SimpleAddress tmp = fromAddress.value;
    fromAddress.value = toAddress.value;
    toAddress.value = tmp;

    _updateControllers();
  }

  void searchTravel({
    SimpleAddress? from,
    SimpleAddress? to,
    DateTime? date,
  }) {
    isSearching.value = true;

    if (from != null) {
      fromAddress.value = from;
    } else if (fromAddress.value.label.isEmpty) {
      fromAddress.value = SimpleAddress.fromCurrentPosition(
        mapLocation.isLocationShowing.isTrue
            ? LatLng(mapLocation.userPosition.first.latitude,
                mapLocation.userPosition.first.longitude)
            : MapGlobalController.initialCenter,
      );
    }
    if (to != null) {
      toAddress.value = to;
    }
    travelDate.value = date ?? DateTime.now();
    _updateControllers();
  }

  Future<void> _updateControllers() async {
    fromController.controller.text = fromAddress.value.label;
    toController.controller.text = toAddress.value.label;

    var travels = await GttApi.getTravels(
        from: fromAddress.value, to: toAddress.value, time: travelDate.value);
    print(travels);
    showFlexibleBottomSheet(
      minHeight: 0,
      initHeight: 0.5,
      maxHeight: 1,
      context: Get.context!,
      builder: ((context, scrollController, bottomSheetOffset) {
        return _buildBottomSheet(
            travels, context, scrollController, bottomSheetOffset);
      }),
      anchors: [0, 0.5, 1],
      isSafeArea: false,
    );
  }

  //-- test---

  Widget _buildBottomSheet(
    List<Travel> travels,
    BuildContext context,
    ScrollController scrollController,
    double bottomSheetOffset,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(
            child: Icon(
              Icons.horizontal_rule_rounded,
              size: 40,
            ),
          ),
          ...travels.map((e) => _buildTravel(e)),
          /*Flexible(
            child: Text(
              travels.toString(),
              maxLines: 50,
              overflow: TextOverflow.ellipsis,
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildTravel(Travel travel) {
    /* String getDistanceString(double distance) {
      if (distance < 1000) {
        return '${distance.toStringAsFixed(0)} m';
      }
      return '${(distance / 1000.0).toStringAsFixed(1)} km';
    } */

    String getDurationString(int duration) {
      if (duration < 60) {
        return '${duration.toString()} sec';
      }
      return '${(duration / 60).toStringAsFixed(0)} min';
    }

    List<gtt.Route> routes = travel.legs
        .where((element) => element.route != null)
        .map((e) => e.route!)
        .toList();
    String routesString = routes.map((e) => e.shortName).join(',');
    return ListTile(
      title: Text(routesString.isEmpty ? 'A piedi' : routesString),
      subtitle: Text(getDurationString(travel.duration)),
      onTap: () => lastTravel.value = [travel],
    );
  }
  // --end test--

  int get addedElements => (additionalHeight.value / _textfieldHeight).round();
  List<Widget> get intermediateWithSpaces {
    return rows
        .expand((element) => [element, const SizedBox(height: 8.0)])
        .toList();
  }

  @override
  void onInit() {
    rows.add(
      Row(
        children: [
          Expanded(
            child: TextField(
              onTap: () => Get.to(() => MapSearchPage(
                    searchController: fromController,
                    isTravel: true,
                    isFrom: true,
                  )),
              readOnly: true,
              focusNode: AlwaysDisabledFocusNode(),
              controller: fromController.controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 8.0),
                hintText: 'Da..',
                hintStyle: const TextStyle(color: Colors.grey),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    fromController.clearText();
                  },
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.swap_vert),
            onPressed: () {
              switchAddresses();
            },
          ),
        ],
      ),
    );
    rows.add(
      Row(
        children: [
          Expanded(
            child: TextField(
              readOnly: true,
              focusNode: AlwaysDisabledFocusNode(),
              onTap: () => Get.to(() => MapSearchPage(
                    searchController: toController,
                    isFrom: false,
                    isTravel: true,
                  )),
              controller: toController.controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 8.0),
                hintText: 'A..',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    toController.clearText();
                  },
                ),
              ),
            ),
          ),
          Opacity(
            opacity: addedElements < maxElements ? 1.0 : 0.0,
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                addHeight();
              },
            ),
          ),
        ],
      ),
    );
    super.onInit();
  }

  void addHeight() {
    if (addedElements >= maxElements) return;
    additionalHeight.value += _textfieldHeight;
    addRow();
  }

  void addRow() {
    final key = UniqueKey();
    Widget row = Row(
      key: key,
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 8.0),
              hintText: 'Intermedio',
              hintStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {},
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.0,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.timer_outlined),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            removeHeight();
            rows.removeWhere((element) => element.key == key);
          },
        ),
      ],
    );
    rows.insert(rows.length - 1, row);
    //rows.add(row);
  }

  void removeHeight() {
    if (additionalHeight.value > 0) {
      additionalHeight.value -= _textfieldHeight;
    }
  }

  void resetHeight() {
    additionalHeight.value = 0.0;

    rows.removeRange(1, rows.length - 1);
  }
}
