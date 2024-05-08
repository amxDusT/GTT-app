import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_info_controller.dart';
import 'package:flutter_gtt/fake/fake_data.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/widgets/passage_time.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MapInfoWidget extends StatefulWidget {
  final Stop stop;
  final MapInfoController _mapInfoController;
  MapInfoWidget({super.key, required this.stop})
      : _mapInfoController = Get.put<MapInfoController>(MapInfoController(),
            tag: stop.code.toString());

  @override
  State<MapInfoWidget> createState() => _MapInfoWidgetState();
}

class _MapInfoWidgetState extends State<MapInfoWidget> {
  @override
  void initState() {
    super.initState();
    updateWidget();
  }

  void updateWidget() async {
    await widget._mapInfoController.getFermata(widget.stop.code);

    //HACKY: force rebuild
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final routes = widget._mapInfoController.isLoading.isTrue
        ? List.filled(3, FakeData().fakeRouteWithDetails)
        : widget._mapInfoController.fermata.value.vehicles;
    final routeNames = widget._mapInfoController.isLoading.isTrue
        ? '(${FakeData().fakeText(20)})'
        : '(${widget._mapInfoController.routesNames.join(', ')})';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        // Parent widget has Obx already so we don't need to wrap this in Obx

        Skeletonizer(
          enabled: widget._mapInfoController.isLoading.isTrue,
          effect: ShimmerEffect(
            baseColor: Colors.grey[500]!,
            highlightColor: Colors.grey[400]!,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: routes.length + 1,
            itemBuilder: (context, index) {
              if (index == routes.length) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      routeNames,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }
              RouteWithDetails route = routes[index] as RouteWithDetails;
              // don't show empty routes
              if (route.stoptimes.isEmpty) return const SizedBox();

              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        route.shortName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  ...route.stoptimes
                      .getRange(
                        0,
                        min(maxHoursMap, route.stoptimes.length),
                      )
                      .map(
                        (stoptime) => Expanded(
                          child: PassageTime(
                              stoptime: stoptime,
                              style: TextStyle(
                                color: stoptime.realtime
                                    ? Colors.green
                                    : Colors.grey[700],
                                overflow: TextOverflow.ellipsis,
                                fontSize: 14,
                              )),
                        ),
                      )
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
