import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/models/fermata.dart';
import 'package:flutter_gtt/resources/api.dart';
import 'package:get/get.dart';

class InfoController extends GetxController {
  late final Rx<DateTime> lastUpdate;
  final RxBool isLoading = false.obs;
  Fermata fermata = Get.arguments['fermata'];
  late RxString fermataName;
  final HomeController _homeController = Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    fermataName = fermata.toString().obs;
    getFermata();
    lastUpdate = DateTime.now().obs;
  }

  void getFermata() async {
    isLoading.value = true;
    try {
      final newFermata = await Api.getStop(fermata.stopNum);
      lastUpdate.value = DateTime.now();
      if (fermata.nome.isEmpty) {
        _homeController.updateStop(newFermata);
      }
      fermata = newFermata;
      fermataName.value = fermata.toString();
    } on ApiException catch (e) {
      Get.snackbar("Errore ${e.statusCode}", e.message);
      if (fermata.nome.isEmpty) {
        _homeController.deleteStop(fermata);
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
