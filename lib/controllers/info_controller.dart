import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/resources/api.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:get/get.dart';

class InfoController extends GetxController {
  late final Rx<DateTime> lastUpdate;
  final RxBool isLoading = false.obs;
  late Rx<StopWithDetails> fermata;
  late RxString fermataName;
  final HomeController _homeController = Get.find<HomeController>();
  final RxBool isSaved = false.obs;
  @override
  void onInit() async {
    super.onInit();
    Stop stop = Get.arguments['fermata'];
    print(stop);
    fermataName = stop.name.obs;
    lastUpdate = DateTime.now().obs;
    fermata = StopWithDetails.fromStop(stop: stop).obs;

    getFermata();
    isSaved.value = (await DatabaseCommands.hasStop(fermata.value));
  }

  void switchAddDeleteFermata() async {
    if (isSaved.isTrue) {
      DatabaseCommands.deleteStop(fermata.value);
    } else {
      DatabaseCommands.insertStop(fermata.value);
    }
    _homeController.getStops();
    isSaved.value = !isSaved.value;
  }

  Future<void> getFermata() async {
    isLoading.value = true;
    try {
      final StopWithDetails newFermata = await Api.getStop(fermata.value.code);
      lastUpdate.value = DateTime.now();
      fermata = newFermata.obs;
      fermataName.value = fermata.value.name;
    } on ApiException catch (e) {
      Get.snackbar("Errore ${e.statusCode}", e.message);
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
