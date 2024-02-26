import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_controller.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

class AddressWidget extends StatelessWidget {
  final Marker marker;
  final MapPageController controller;
  const AddressWidget(
      {super.key, required this.marker, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Address'),
            /* Obx(
              () => Text(controller.lastAddress.value),
            ), */
          ],
        ),
      ),
    );
  }
}
