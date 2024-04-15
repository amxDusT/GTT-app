import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_gtt/controllers/map/map_address.dart';
import 'package:flutter_gtt/controllers/map/map_global_controller.dart';
import 'package:flutter_gtt/controllers/map/map_location.dart';
import 'package:flutter_gtt/controllers/search/search_controller.dart';
import 'package:flutter_gtt/models/custom_datepicker.dart';
import 'package:flutter_gtt/models/map/travel.dart';
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
  final RxBool isUsingCustomTime = false.obs;
  final RxBool isSearching = false.obs;
  final Rx<SimpleAddress> fromAddress =
      SimpleAddress(label: '', position: const LatLng(0.0, 0.0)).obs;
  final Rx<SimpleAddress> toAddress =
      SimpleAddress(label: '', position: const LatLng(0.0, 0.0)).obs;
  final Rx<DateTime> travelDate = DateTime.now().obs;
  final MapAddressController mapAddress = Get.find();
  final MapLocation mapLocation = Get.find<MapLocation>();
  final double appBarHeight = 56.0;
  final RxList<Travel> lastTravels = <Travel>[].obs;
  final Rx<Travel?> lastTravel = Rx<Travel?>(null);
  final Map<String, Travel> lastTravelsMap = <String, Travel>{};
  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();

  set updateIsSearching(bool value) {
    isSearching.value = value;
    if (!value) {
      lastTravels.clear();
      lastTravelsMap.clear();
      lastTravel.value = null;
    }
  }

  @override
  void onClose() {
    super.onClose();
    draggableScrollableController.dispose();
  }

  RxBool get hasTravels => (isSearching.isTrue && lastTravels.isNotEmpty).obs;
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

    lastTravels.clear();
    var travels = await GttApi.getTravels(
        from: fromAddress.value, to: toAddress.value, time: travelDate.value);

    lastTravels.value = travels;

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
          ..._buildTravels(travels),
          //...travels.map((e) => _buildTravel(e)).toSet(),
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

  List<Widget> _buildTravels(List<Travel> travels) {
    String getDurationString(int duration) {
      if (duration < 60) {
        return '${duration.toString()} sec';
      }
      return '${(duration / 60).toStringAsFixed(0)} min';
    }

    Map<String, List<Travel>> groupedTravels = {};
    for (var travel in travels) {
      String key = travel.legs
          .where((element) => element.route != null)
          .map((e) => e.route!.shortName)
          .join(',');
      if (!groupedTravels.containsKey(key)) {
        groupedTravels[key] = [];
      }
      groupedTravels[key]!.add(travel);
    }

    final res = groupedTravels.entries
        .map((e) => ListTile(
              title: Text(e.key.isEmpty ? 'A piedi' : e.key),
              subtitle: Text(getDurationString(e.value.first.duration)),
              onTap: () => lastTravel.value = e.value.first,
            ))
        .toList();

    res.sort((a, b) {
      final aInt = int.parse(a.subtitle.toString().split('"')[1].split(' ')[0]);
      final bInt = int.parse(b.subtitle.toString().split('"')[1].split(' ')[0]);
      return aInt.compareTo(bInt);
    });
    return res;
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

    Set<gtt.Route> routes = travel.legs
        .where((element) => element.route != null)
        .map((e) => e.route!)
        .toSet();
    String routesString = routes.map((e) => e.shortName).join(',');
    return ListTile(
      title: Text(routesString.isEmpty ? 'A piedi' : routesString),
      subtitle: Text(getDurationString(travel.duration)),
      onTap: () => lastTravel.value = travel,
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

  void onOpenDate(BuildContext context) async {
    final now = DateTime.now();
    /*  DatePicker.showDateTimePicker(
      context,
      currentTime: isUsingCustomTime.isTrue ? travelDate.value : now,
      minTime: now.subtract(const Duration(days: 1)),
      maxTime: now.add(const Duration(days: 7)),
      locale: LocaleType.it,
      onConfirm: (date) {
        dateTravel = date;
        _updateControllers();
      },
      onChanged: (time) => print(time),
    ); */
    DatePicker.showPicker(context,
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
    });
  }
}
