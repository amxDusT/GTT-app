import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_info_controller.dart';
import 'package:flutter_gtt/models/gtt/route.dart';
import 'package:flutter_gtt/models/gtt/stop.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:flutter_gtt/widgets/passage_time.dart';
import 'package:get/get.dart';

class MapInfoWidget extends StatefulWidget {
  final Stop stop;
  const MapInfoWidget({super.key, required this.stop});

  @override
  State<MapInfoWidget> createState() => _MapInfoWidgetState();
}

class _MapInfoWidgetState extends State<MapInfoWidget> {
  final _mapInfoController = Get.find<MapInfoController>();
  @override
  void initState() {
    super.initState();
    updateWidget();
  }

  void updateWidget() async {
    print('test');
    await _mapInfoController.getFermata(widget.stop.code);
    //HACKY: force rebuild
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        // Parent widget has Obx already so we don't need to wrap this in Obx

        _mapInfoController.isLoading.isTrue
            ? const CircularProgressIndicator()
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _mapInfoController.fermata.value.vehicles.length + 1,
                itemBuilder: (context, index) {
                  if (index ==
                      _mapInfoController.fermata.value.vehicles.length) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        Text('(${_mapInfoController.routes.join(', ')})'),
                      ],
                    );
                  }
                  RouteWithDetails route =
                      _mapInfoController.fermata.value.vehicles.elementAt(index)
                          as RouteWithDetails;
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
                                    color:
                                        stoptime.realtime ? Colors.green : null,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 14,
                                  )),
                            ),
                          )
                    ],
                  );
                },
              ),
      ],
    );
  }
}
