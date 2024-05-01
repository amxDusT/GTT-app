import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/intro/intro_controller.dart';

class IntroPage extends GetView<IntroController> {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.changePage,
              children: controller.pages,
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                controller.currentIndex.value != 0
                    ? IconButton.filled(
                        onPressed: () {
                          controller.pageController.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeIn,
                          );
                        },
                        icon: const Icon(Icons.keyboard_arrow_left),
                      )
                    : const SizedBox(width: 48),
                IntroDots(
                  count: controller.pages.length,
                  currentIndex: controller.currentIndex.value,
                ),
                controller.currentIndex.value != controller.pages.length - 1
                    ? IconButton.filled(
                        onPressed: () {
                          controller.pageController.nextPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeIn,
                          );
                        },
                        icon: const Icon(Icons.keyboard_arrow_right),
                      )
                    : const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {},
              child: const Text(
                'Get Started',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class IntroDots extends StatelessWidget {
  final int count;
  final int currentIndex;
  const IntroDots({super.key, required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => IntroDot(
          key: ValueKey(index),
          isSelected: index == currentIndex,
        ),
      ),
    );
  }
}

class IntroDot extends StatelessWidget {
  final bool isSelected;
  const IntroDot({
    super.key,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
