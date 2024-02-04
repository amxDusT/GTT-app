import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/info_controller.dart';
import 'package:flutter_gtt/controllers/map/map_info_controller.dart';
import 'package:flutter_gtt/models/gtt_models.dart';
import 'package:flutter_gtt/models/gtt_stop.dart';
import 'package:flutter_gtt/resources/globals.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
        Obx(() {
          if (_mapInfoController.isLoading.isTrue) {
            return const CircularProgressIndicator();
          }
          return Column(
            children: [
              const Text(
                "Veicoli in arrivo:",
                style: TextStyle(fontSize: 16),
              ),
              ..._mapInfoController.stoptimes.entries.map(
                (e) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          e.key,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...e.value.getRange(0, 2).map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                    ],
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }
}
