import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_controller.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:get/get.dart';

class RouteAppBarInfo extends StatelessWidget {
  final MapPageController mapController;
  final _empty = const SizedBox.shrink();
  const RouteAppBarInfo({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (mapController.routePatterns.isEmpty) return _empty;
      if (mapController.isPatternInitialized.isFalse) return _empty;
      if (mapController.isAppBarExpanded.isFalse) return _empty;

      RouteWithDetails route = mapController.routes.values.first;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route.longName.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text('Direzione:'),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  text: mapController.firstStop[route.pattern.code]!.name,
                  children: [
                    const WidgetSpan(child: SizedBox(width: 10)),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.arrow_right_alt,
                      ),
                    ),
                    const WidgetSpan(child: SizedBox(width: 10)),
                    TextSpan(
                      text: route.pattern.headsign,
                    ),
                  ]),
            ),
            const SizedBox(
              height: 15,
            ),
            DropdownMenu(
              enableSearch: false,
              inputDecorationTheme: const InputDecorationTheme(
                constraints: BoxConstraints(
                  maxHeight: 45,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              width: Get.width * 0.9,
              initialSelection: mapController.isPatternInitialized.isTrue
                  ? mapController.routes.values.first.pattern
                  : null,
              onSelected: (pattern) => pattern == null
                  ? null
                  : mapController.setCurrentPattern(pattern),
              dropdownMenuEntries: mapController.routePatterns
                  .map((pattern) => DropdownMenuEntry(
                        value: pattern,
                        label:
                            '${pattern.directionId}:${pattern.code.split(':').last} - ${pattern.headsign}',
                      ))
                  .toList(),
            ),
            const SizedBox(
              height: 5,
            )
          ],
        ),
      );
    });
  }
}
