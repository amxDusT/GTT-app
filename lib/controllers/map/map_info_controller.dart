import 'package:flutter_gtt/models/gtt_models.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/resources/api.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MapInfoController extends GetxController {
  late Rx<StopWithDetails> fermata;
  final RxBool isLoading = false.obs;

  // show stoptimes for each route
  Map<String, List<String>> get stoptimes {
    Map<String, List<String>> result = {};
    for (RouteWithDetails route
        in fermata.value.vehicles as List<RouteWithDetails>) {
      if (route.stoptimes.isNotEmpty) {
        result[route.shortName] = route.stoptimes
            .map(
              (stoptime) => DateFormat.Hm(Get.locale?.languageCode)
                  .format(stoptime.realtimeDeparture),
            )
            .toList();
      }
    }
    return result;
  }

  @override
  void onInit() async {
    if (Get.arguments['fermata'] != null) {
      getFermata((Get.arguments['fermata'] as Stop).code);
    }

    super.onInit();
  }

  void getFermata(int fermataNum) async {
    isLoading.value = true;
    fermata = (await Api.getStop(fermataNum)).obs;
    isLoading.value = false;
  }
}
