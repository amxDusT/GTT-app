import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/search/home_search_controller.dart';
import 'package:flutter_gtt/models/marker.dart';
import 'package:flutter_gtt/widgets/map/map_info_widget.dart';
import 'package:get/get.dart';

class StopWidget extends StatelessWidget {
  final FermataMarker marker;
  const StopWidget({super.key, required this.marker});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Get.find<SearchStopsController>().openInfoPage(marker.fermata);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${marker.fermata.code} - ${marker.fermata.name}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          MapInfoWidget(stop: marker.fermata),
        ],
      ),
    );
  }
}
