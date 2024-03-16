import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/models/gtt/favorite_stop.dart';
import 'package:flutter_gtt/pages/map/map_point_page.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:get/get.dart';

class HomeFavCard extends StatelessWidget {
  final FavStop fermata;
  final HomeController controller;
  const HomeFavCard(
      {super.key, required this.fermata, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'HeroTagFermata${fermata.code}',
          //placeholderBuilder: (context, size, widget) => widget,

          flightShuttleBuilder: ((flightContext, animation, flightDirection,
                  fromHeroContext, toHeroContext) =>
              Material(
                type: MaterialType.transparency,
                child: toHeroContext.widget,
              )),
          child: InkWell(
            onTapDown: controller.getPosition,
            onLongPress: () => controller.showContextMenu(fermata),
            onTap: () => Get.toNamed('/info', arguments: {'fermata': fermata}),
            /* onTap: () => Get.to(
              () => InfoPage(
                  //stopCode: fermata.code,
                  ),
              arguments: {'fermata': fermata},
            ), */
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: Utils.lighten(fermata.color),
              ),
              height: 115,
              padding: const EdgeInsets.all(8),
              //color: Utils.lighten(e.color),
              child: Column(
                children: [
                  Text(fermata.toString()),
                  const Divider(),
                  Text(fermata.descrizione ?? ''),
                ],
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
          child: Ink(
            width: double.maxFinite,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              color: Utils.lighten(fermata.color, 70),
            ),
            child: const Center(child: Text('Posizione')),
          ),
        ),
      ],
    );
  }
}
