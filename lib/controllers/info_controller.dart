import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/models/fermata.dart';
import 'package:flutter_gtt/resources/api.dart';
import 'package:flutter_gtt/resources/database.dart';
import 'package:get/get.dart';

class InfoController extends GetxController {
  late final Rx<DateTime> lastUpdate;
  final RxBool isLoading = false.obs;
  Fermata fermata = Get.arguments['fermata'];
  late RxString fermataName;
  final HomeController _homeController = Get.find<HomeController>();
  final RxBool isSaved = false.obs;
  @override
  void onInit() async {
    super.onInit();
    fermataName = fermata.toString().obs;
    lastUpdate = DateTime.now().obs;
    isSaved.value = (await DatabaseCommands.hasStop(fermata));
    getFermata();
  }
  // void addStop() {
  //   int stopNum = int.parse(searchController.value.text);

  //   searchController.value.clear();
  //   focusNode.value.unfocus();
  //   Fermata fermataEmpty = Fermata.empty(stopNum);
  //   DatabaseCommands.insertStop(fermataEmpty);
  //   getStops();
  //   Get.to(() => InfoPage(), arguments: {'fermata': fermataEmpty});
  // }
  void switchAddDeleteFermata() async {
    if (isSaved.isTrue) {
      DatabaseCommands.deleteStop(fermata);
    } else {
      DatabaseCommands.insertStop(fermata);
    }
    _homeController.getStops();
    isSaved.value = !isSaved.value;
  }

  void getFermata() async {
    isLoading.value = true;
    try {
      final newFermata = await Api.getStop(fermata.stopNum);
      lastUpdate.value = DateTime.now();
      if (fermata.nome.isEmpty && isSaved.isTrue) {
        _homeController.updateStop(newFermata);
      }
      fermata = newFermata;
      fermataName.value = fermata.toString();
    } on ApiException catch (e) {
      Get.snackbar("Errore ${e.statusCode}", e.message);
      if (fermata.nome.isEmpty && isSaved.isTrue) {
        _homeController.deleteStop(fermata);
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
