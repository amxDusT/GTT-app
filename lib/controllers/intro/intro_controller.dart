import 'package:flutter/material.dart';
import 'package:torino_mobility/pages/intro/pages/page_1.dart';
import 'package:torino_mobility/pages/intro/pages/page_2.dart';
import 'package:torino_mobility/pages/intro/pages/page_3.dart';
import 'package:torino_mobility/pages/intro/pages/page_5.dart';
import 'package:torino_mobility/pages/intro/pages/page_4.dart';
import 'package:torino_mobility/pages/intro/pages/page_6.dart';
import 'package:get/get.dart';

class IntroController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final PageController pageController = PageController();

  final List<Widget> pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
    const Page5(),
    const Page6(),
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
