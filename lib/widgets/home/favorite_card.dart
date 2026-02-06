import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/home_controller.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:torino_mobility/models/gtt/favorite_stop.dart';
import 'package:torino_mobility/pages/map/map_point_page.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:get/get.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

class HomeFavCard extends GetView<SettingsController> {
  final FavStop fermata;
  final HomeController homeController;
  const HomeFavCard(
      {super.key, required this.fermata, required this.homeController});

  @override
  Widget build(BuildContext context) {
    return ReorderableGridDelayedDragStartListener(
      index: homeController.fermate.indexOf(fermata),
      child: Column(
        children: [
          Expanded(
            child: Hero(
              tag: 'HeroTagFermata${fermata.code}',
              flightShuttleBuilder: ((flightContext, animation, flightDirection,
                      fromHeroContext, toHeroContext) =>
                  Material(
                    //color: Utils.lighten(fermata.color),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                    //type: MaterialType.transparency,
                    child: toHeroContext.widget,
                  )),
              child: InkWell(
                splashColor: Colors.red,
                onTapDown: homeController.getPosition,
                onLongPress: () => homeController.showContextMenu(fermata),
                onTap: () =>
                    Get.toNamed('/info', arguments: {'fermata': fermata}),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: (controller.isDarkMode.isTrue
                              ? Utils.darken(fermata.color, 30)
                              : Utils.lighten(fermata.color))
                          .withOpacity(0.9),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    //height: 115,
                    padding: const EdgeInsets.all(8),
                    //color: Utils.lighten(e.color),
                    child: Column(
                      children: [
                        Text(
                          fermata.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(),
                        Text(fermata.descrizione ?? ''),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () =>
                Get.to(() => MapPointPage(), arguments: {'fermata': fermata}),

            //MapUtils.openMap(e.latitude, e.longitude),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: Obx(
              () => Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  color: controller.isDarkMode.isTrue
                      ? Utils.darken(fermata.color, 50)
                      : Utils.lighten(fermata.color, 70),
                ),
                child: Row(
                  children: [
                    const Expanded(child: Text('Posizione')),
                    ReorderableGridDragStartListener(
                      index: homeController.fermate.indexOf(fermata),
                      child: const Icon(Icons.reorder_sharp),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
