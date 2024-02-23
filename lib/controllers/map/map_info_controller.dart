import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/resources/api/gtt_api.dart';
import 'package:get/get.dart';

class MapInfoController extends GetxController {
  late Rx<StopWithDetails> fermata;
  final RxBool isLoading = false.obs;

  List<String> get routes {
    return fermata.value.vehicles.map((route) => route.shortName).toList();
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
    fermata = (await GttApi.getStop(fermataNum)).obs;
    isLoading.value = false;
  }
}
