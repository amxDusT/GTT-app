import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/intro/intro_controller.dart';
import 'package:torino_mobility/widgets/intro/back_forward_button.dart';
import 'package:get/get.dart';

class IntroPage extends GetView<IntroController> {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 60),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.changePage,
                children: controller.pages,
              ),
            ),
            const SizedBox(height: 40),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BackForwardButton(
                    visible: controller.currentIndex.value != 0,
                    onPressed: () {
                      controller.pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutQuad,
                      );
                    },
                    direction: ButtonDirection.back,
                  ),
                  IntroDots(
                    count: controller.pages.length,
                    currentIndex: controller.currentIndex.value,
                  ),
                  BackForwardButton(
                    visible: controller.currentIndex.value !=
                        controller.pages.length - 1,
                    onPressed: () {
                      controller.pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutQuad,
                      );
                    },
                    direction: ButtonDirection.forward,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  Get.offNamed('/home');
                },
                child: Obx(
                  () => Text(
                    controller.currentIndex.value == controller.pages.length - 1
                        ? 'Comincia'
                        : 'Salta',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
