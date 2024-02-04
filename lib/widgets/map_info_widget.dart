import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_info_controller.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:get/get.dart';

class MapInfoWidget extends StatelessWidget {
  final _mapInfoController = Get.find<MapInfoController>();
  final Stop stop;
  MapInfoWidget({super.key, required this.stop});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        // Parent widget has Obx already so we don't need to wrap this in Obx
        Builder(builder: (context) {
          if (_mapInfoController.isLoading.isTrue) {
            return const CircularProgressIndicator();
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: _mapInfoController.stoptimes.entries.length + 1,
            itemBuilder: (context, index) {
              if (index == _mapInfoController.stoptimes.entries.length) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Text('(${_mapInfoController.routes.join(', ')})'),
                  ],
                );
              }
              var entry = _mapInfoController.stoptimes.entries.elementAt(index);
              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ...entry.value
                      .getRange(
                          0,
                          maxHoursMap >= entry.value.length
                              ? entry.value.length
                              : maxHoursMap)
                      .map(
                        (e) => Expanded(
                          child: Text(
                            e,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                ],
              );
            },
          );
        }),
      ],
    );
  }
}
