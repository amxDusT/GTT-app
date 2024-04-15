import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_global_controller.dart';
import 'package:flutter_gtt/widgets/map/distance_icon.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

class AddressWidget extends StatelessWidget {
  final Marker marker;
  final MapGlobalController controller;
  const AddressWidget(
      {super.key, required this.marker, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      //margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Stack(
        children: [
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              constraints: BoxConstraints(
                maxWidth: context.width * 0.75,
                minWidth: context.width * 0.5,
              ),
              //width: context.width * 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 24.0,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    child: controller.mapAddress.isLoadingAddress.isTrue
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              Text(
                                controller.mapAddress.lastAddress.first
                                    .toDetailedString(
                                  showHouseNumber: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Text(
                                      controller.mapAddress.lastAddress.first
                                          .toDetailedString(
                                        showStreet: false,
                                        showPostalCode: true,
                                        showCity: true,
                                        showProvince: true,
                                      ),
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    alignment: Alignment.center,
                                    width: 10.0,
                                    child: const Text("\u2022"),
                                  ),
                                  DistanceWidget(
                                    width: 50,
                                    address:
                                        controller.mapAddress.lastAddress.first,
                                    showIcon: false,
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () async {
                          controller.travelController.searchTravel(
                            from: null,
                            to: controller.mapAddress.lastAddress.first,
                          );
                        },
                        style: TextButton.styleFrom(
                          fixedSize: const Size(110, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                        child: const Text('Indicazioni'),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          fixedSize: const Size(110, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                        child: const Text('Fermate vicine'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => controller.mapAddress.addressReset(),
              child: const Padding(
                padding: EdgeInsets.only(top: 2.0, right: 1.0),
                child: Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
