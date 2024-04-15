import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/map/map_travel_controller.dart';
import 'package:flutter_gtt/resources/utils/map_utils.dart';
import 'package:get/get.dart';

class TravelAppBar extends StatelessWidget implements PreferredSizeWidget {
  final MapTravelController controller;
  const TravelAppBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: 8.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.resetHeight();
            controller.isSearching.value = false;
          },
        ),
      ),
      leadingWidth: 50,
      toolbarHeight: 180 + controller.additionalHeight.value,
      title: Column(
        children: [
          ...controller.intermediateWithSpaces,
          Row(
            //mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  //fixedSize: const Size(100, 40),
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  //backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
                onPressed: () {
                  controller.onOpenDate(context);
                },
                icon: const Icon(
                  Icons.calendar_month,
                  size: 18,
                ),
                label: Obx(() {
                  if (controller.isUsingCustomTime.isTrue) {
                    return Text(
                      MapUtils.dateToString(controller.travelDate.value),
                    );
                  }
                  return const Text(
                    'Oggi',
                  );
                }),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                ),
                label: const Text(
                  'Opzioni',
                ),
              ),
              Opacity(
                opacity: 0.0,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(180 + controller.additionalHeight.value);
}
