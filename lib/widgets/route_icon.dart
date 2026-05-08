import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:torino_mobility/models/gtt/route.dart' as gtt;
import 'package:torino_mobility/resources/utils/color_utils.dart';

class RouteIcon extends StatelessWidget {
  const RouteIcon(
      {super.key,
      required this.route,
      this.removeIcon = false,
      this.onRemoved,
      this.onTap})
      : assert(!(removeIcon && onRemoved == null),
            'If removeIcon is true, onRemoved must be provided');

  final gtt.Route route;
  final bool removeIcon;
  final VoidCallback? onRemoved;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final name = route.shortName.replaceAll(' ', '');
    final fontSize = (20 - ((name.length - 2) * 10 / 2)).clamp(10, 20);
    Widget mainWidget = Obx(() {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(5),
        width: 40 /* + (name.length > 2 ? name.length * 5 : 0) */,
        height: 40,
        decoration: BoxDecoration(
          color: ColorUtils.normalize(
            ColorUtils.indexColor(int.tryParse(name) ?? 0),
            dark: Get.find<SettingsController>().isDarkMode.isTrue,
          ),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          name,
          maxLines: 1,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize.toDouble(),
          ),
        ),
      );
    });
    if (onTap != null) {
      mainWidget = GestureDetector(
        onTap: onTap,
        child: mainWidget,
      );
    }
    return removeIcon
        ? Stack(
            fit: StackFit.loose,
            children: [
              mainWidget,
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: onRemoved,
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
                ),
              )
            ],
          )
        : mainWidget;
  }
}
