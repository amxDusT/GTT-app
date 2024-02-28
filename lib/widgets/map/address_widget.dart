import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_address.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

class AddressWidget extends StatelessWidget {
  final Marker marker;
  final MapAddressController controller;
  const AddressWidget(
      {super.key, required this.marker, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Address'),
              controller.isLoadingAddress.isTrue
                  ? const CircularProgressIndicator()
                  : Text(controller.lastAddress.first
                      .toDetailedString(showHouseNumber: true)),
            ],
          ),
        ),
      ),
    );
  }
}
