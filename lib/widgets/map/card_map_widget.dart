import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_controller.dart';
import 'package:flutter_gtt/controllers/map/map_info_controller.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/models/triangle_clipper.dart';
import 'package:flutter_gtt/widgets/map/route_widget.dart';
import 'package:flutter_gtt/widgets/map/stop_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

class CardMapWidget extends StatelessWidget {
  final MapPageController controller;
  final Marker marker;
  const CardMapWidget(
      {super.key, required this.marker, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          bottom: 1,
          child: ClipPath(
            clipper: TriangleClipper(),
            child: Container(
              color: Colors.yellow.withOpacity(0.9),
              //color: Colors.red,
              height: 10,
              width: 20,
            ),
          ),
        ),
        Card(
          elevation: 0,
          margin: const EdgeInsets.all(10),
          color: Colors.yellow.withOpacity(0.9),
          child: SizedBox(
            //height: 70,
            width: 150,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 40,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.popupController.togglePopup(marker);
                      controller.lastOpenedMarker = null;
                      if (marker is FermataMarker) {
                        Get.delete<MapInfoController>(
                          tag:
                              (marker as FermataMarker).fermata.code.toString(),
                        );
                      }
                    },
                  ),
                ),
                if (marker is FermataMarker)
                  StopWidget(marker: marker as FermataMarker),
                if (marker is VehicleMarker)
                  RouteWidget(
                    marker: marker as VehicleMarker,
                    controller: controller,
                  ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
