import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_address.dart';
import 'package:flutter_gtt/controllers/map/map_location.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_gtt/pages/map/map_search.dart';
import 'package:flutter_gtt/widgets/search/disabled_focusnode.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapTravelController extends GetxController {
  static const _textfieldHeight = 56.0;
  static const maxElements = 2;
  RxDouble additionalHeight = 0.0.obs;
  final RxList<Widget> rows = <Widget>[].obs;
  final MapSearchController fromController =
      Get.put(MapSearchController(), tag: 'from');
  final MapSearchController toController =
      Get.put(MapSearchController(), tag: 'to');
  final TextEditingController fromTextController = TextEditingController();
  final TextEditingController toTextController = TextEditingController();
  final RxBool isSearching = false.obs;
  final Rx<SimpleAddress> fromAddress =
      SimpleAddress(label: '', position: const LatLng(0.0, 0.0)).obs;
  final Rx<SimpleAddress> toAddress =
      SimpleAddress(label: '', position: const LatLng(0.0, 0.0)).obs;
  final Rx<DateTime> travelDate = DateTime.now().obs;
  final MapAddressController mapAddress = Get.find();
  final MapLocation mapLocation = Get.find<MapLocation>();
  final double appBarHeight = 56.0;

  @override
  void onClose() {
    fromTextController.dispose();
    toTextController.dispose();

    super.onClose();
  }

  void switchAddresses() {
    final SimpleAddress tmp = fromAddress.value;
    fromAddress.value = toAddress.value;
    toAddress.value = tmp;

    _updateControllers();
  }

  void searchTravel({
    required SimpleAddress from,
    required SimpleAddress to,
    DateTime? date,
  }) async {
    isSearching.value = true;
    fromAddress.value = from;
    toAddress.value = to;
    travelDate.value = date ?? DateTime.now();
    _updateControllers();
  }

  void _updateControllers() {
    fromController.controller.text = fromAddress.value.label;
    toController.controller.text = toAddress.value.label;
    //fromTextController.text = fromAddress.value.label;
    //toTextController.text = toAddress.value.label;
  }

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
              onTap: () =>
                  Get.to(MapSearchPage(searchController: fromController)),
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
              onTap: () =>
                  Get.to(MapSearchPage(searchController: toController)),
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
