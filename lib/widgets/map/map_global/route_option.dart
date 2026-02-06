import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/map/map_global_controller.dart';
import 'package:flutter_map/flutter_map.dart';

class RouteOption extends StatelessWidget {
  final MapGlobalController controller;
  final String vehicleName;
  const RouteOption(
      {super.key, required this.controller, required this.vehicleName});

  @override
  Widget build(BuildContext context) {
    final travelController = controller.travelController;
    return ListTile(
      title: Text(vehicleName),
      subtitle: Text(
        '${(travelController.lastTravelsMap[vehicleName]!.duration / 60).toStringAsFixed(0)} min',
      ),
      onTap: () {
        travelController.panelController.close();
        travelController.lastTravel.value =
            travelController.lastTravelsMap[vehicleName];
        //controller.mapController.camera.
        controller.animateCamera(CameraFit.coordinates(
          coordinates: [
            travelController.lastTravel.value!.legs.first.from.position,
            travelController.lastTravel.value!.legs.last.to.position,
          ],
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 100.0,
            top: travelController.appBarHeight + 50,
          ),
        ).fit(controller.mapController.camera));
      },
    );
  }
}
