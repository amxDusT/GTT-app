import 'package:flutter/material.dart';
import 'package:flutter_gtt/pages/intro/pages/page_1.dart';
import 'package:flutter_gtt/pages/intro/pages/page_2.dart';
import 'package:flutter_gtt/pages/intro/pages/page_3.dart';
import 'package:get/get.dart';

class IntroController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final PageController pageController = PageController();

  final List<Widget> pages = [
    const Page1(),
    const Page2(),
    const Page3(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
