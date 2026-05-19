import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/models/marker.dart';
import 'package:torino_mobility/models/triangle_clipper.dart';
import 'package:torino_mobility/widgets/map/route_widget.dart';
import 'package:torino_mobility/widgets/map/stop_widget.dart';
import 'package:flutter_map/flutter_map.dart';

class CardMapWidget extends StatelessWidget {
  final MapPageController mapPageController;
  final Marker marker;
  static const Color backgroundColor = Color.fromARGB(229, 255, 235, 59);
  const CardMapWidget(
      {super.key, required this.marker, required this.mapPageController});

  @override
  Widget build(BuildContext context) {
    //print('CardMapWidget build');
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          bottom: 1,
          child: ClipPath(
            clipper: TriangleClipper(),
            child: const SizedBox(
              height: 10,
              width: 20,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xff221d17),
                ),
              ),
            ),
          ),
        ),
        Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          color: const Color(0xff221d17),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (marker is FermataMarker)
                StopWidget(
                  marker: marker as FermataMarker,
                  controller: mapPageController,
                ),
              if (marker is VehicleMarker)
                RouteWidget(
                  marker: marker as VehicleMarker,
                  controller: mapPageController,
                ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
