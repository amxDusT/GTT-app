import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/search_controller.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/widgets/map/map_info_widget.dart';
import 'package:get/get.dart';

class StopWidget extends StatelessWidget {
  final FermataMarker marker;
  const StopWidget({super.key, required this.marker});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Get.find<SearchStopsController>().openInfoPage(marker.fermata);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${marker.fermata.code} - ${marker.fermata.name}',
          ),
          MapInfoWidget(stop: marker.fermata),
        ],
      ),
    );
  }
}
