import 'package:flutter_gtt/models/gtt/stop.dart';
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

  Future<void> getFermata(int fermataNum) async {
    isLoading.value = true;
    //if (kDebugMode) await Future.delayed(const Duration(seconds: 10));
    fermata = (await GttApi.getStop(fermataNum)).obs;
    //print('test3');
    isLoading.value = false;
  }
}
