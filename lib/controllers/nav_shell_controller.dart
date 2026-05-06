import 'package:get/get.dart';

class NavShellController extends GetxController {
  final currentIndex = 0.obs;

  void changeIndex(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }
}
