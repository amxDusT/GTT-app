import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/controllers/settings_controller.dart';
import 'package:flutter_gtt/models/gtt/route.dart' as gtt;
import 'package:get/get.dart';

class RouteListFavorite extends GetView<SettingsController> {
  final gtt.Route route;
  final RouteListController routeListController;
  final bool hasRemoveIcon;
  const RouteListFavorite({
    super.key,
    required this.route,
    required this.routeListController,
    this.hasRemoveIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        GestureDetector(
          onTap: () => Get.toNamed('/mapBus', arguments: {
            'vehicles': [route]
          }),
          child: Obx(
            () => Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(
                  vertical: 8, horizontal: hasRemoveIcon ? 8 : 4),
              padding: const EdgeInsets.all(5),
              width: 40 +
                  (route.shortName.length > 2 ? route.shortName.length * 5 : 0),
              height: 40,
              decoration: BoxDecoration(
                color: controller.isDarkMode.isTrue
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.primary,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                route.shortName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        if (hasRemoveIcon)
          Positioned(
              right: 2,
              top: 2,
              child: GestureDetector(
                onTap: () => routeListController.toggleFavorite(route),
                child: Container(
                    alignment: Alignment.center,
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 236, 115, 107),
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    )),
              )),
      ],
    );
  }
}
