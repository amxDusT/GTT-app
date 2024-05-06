import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_address.dart';
import 'package:flutter_gtt/controllers/map/map_global_controller.dart';
import 'package:flutter_gtt/controllers/map/map_location.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:flutter_gtt/models/map/travel.dart';
import 'package:flutter_gtt/models/map/address.dart';
import 'package:flutter_gtt/pages/map/map_search_page.dart';
import 'package:flutter_gtt/resources/api/gtt_api.dart';
import 'package:flutter_gtt/resources/my_date_picker/dialog.dart';
import 'package:flutter_gtt/widgets/search/disabled_focusnode.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapTravelController extends GetxController {
  static const _textfieldHeight = 56.0;
  static const maxElements = 2;
  RxDouble additionalHeight = 0.0.obs;
  final RxList<Widget> rows = <Widget>[].obs;
  final MapSearchController fromController =
      Get.put(MapSearchController(), tag: 'from');
  final MapSearchController toController =
      Get.put(MapSearchController(), tag: 'to');
  final RxBool isUsingCustomTime = false.obs;
  final RxBool isSearching = false.obs;
  final Rx<SimpleAddress> fromAddress =
      SimpleAddress(label: '', position: const LatLng(0.0, 0.0)).obs;
  final Rx<SimpleAddress> toAddress =
      SimpleAddress(label: '', position: const LatLng(0.0, 0.0)).obs;
  final Rx<DateTime> travelDate = DateTime.now().obs;
  final MapAddressController mapAddress = Get.find();
  final MapLocation mapLocation = Get.find<MapLocation>();
  final RxList<Travel> lastTravels = <Travel>[].obs;
  final Rx<Travel?> lastTravel = Rx<Travel?>(null);
  final Map<String, Travel> lastTravelsMap = <String, Travel>{};

  PanelController panelController = PanelController();

  /// show the big app bar and bottom sheet with travels
  set updateIsSearching(bool value) {
    isSearching.value = value;
    if (!value) {
      _clearTravels();
    }
  }

  double get appBarHeight => 180 + additionalHeight.value;
  RxBool get hasTravels => (isSearching.isTrue && lastTravels.isNotEmpty).obs;
  void switchAddresses() {
    final SimpleAddress tmp = fromAddress.value;
    fromAddress.value = toAddress.value;
    toAddress.value = tmp;

    _updateControllers();
  }

  void _clearTravels() {
    lastTravels.clear();
    lastTravelsMap.clear();
    lastTravel.value = null;
  }

  void searchTravel({
    SimpleAddress? from,
    SimpleAddress? to,
    DateTime? date,
  }) {
    updateIsSearching = true;

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
    isUsingCustomTime.value = date != null;
    travelDate.value = date ?? DateTime.now();
    _updateControllers();
  }

  bool _isAtSameTime(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day &&
        date1.hour == date2.hour &&
        date1.minute == date2.minute;
  }

  set dateTravel(DateTime date) {
    travelDate.value = date;
    isUsingCustomTime.value = !_isAtSameTime(date, DateTime.now());
  }

  Future<void> _updateControllers() async {
    fromController.controller.text = fromAddress.value.label;
    toController.controller.text = toAddress.value.label;

    _clearTravels();
    var travels = await GttApi.getTravels(
        from: fromAddress.value, to: toAddress.value, time: travelDate.value);

    lastTravels.value = travels;
    panelController.open();
    for (Travel travel in travels) {
      final transitLegs =
          travel.legs.where((element) => element.transitLeg == true);
      if (transitLegs.isEmpty) {
        lastTravelsMap.putIfAbsent('A piedi', () => travel);
      } else {
        final key = transitLegs
            .map((e) => e.route!.shortName)
            .toList()
            .join(',')
            .replaceAll(' ', '');
        lastTravelsMap.putIfAbsent(key, () => travel);
      }
    }
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

  void onOpenDate(BuildContext context) async {
    final now = DateTime.now();

    showDateTimePickerDialog(
        context: context,
        initialDate: isUsingCustomTime.isTrue ? travelDate.value : now,
        lastDate: now.add(const Duration(days: 7)),
        onSubmittedDate: (date) {
          dateTravel = date;
          _updateControllers();
        });
    /*  DatePicker.showPicker(context,
        showTitleActions: true,
        pickerModel: CustomPicker(
          currentTime: isUsingCustomTime.isTrue ? travelDate.value : now,
          maxTime: now.add(const Duration(days: 7)),
          minTime: DateTime.utc(now.year, now.month, now.day),
          locale: LocaleType.it,
        ),
        //onChanged: (time) => print(time),
        onConfirm: (date) {
      dateTravel = date;
      _updateControllers();
    }); */
  }
}
