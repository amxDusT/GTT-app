import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/route_list_controller.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:torino_mobility/models/gtt/route.dart' as gtt;
import 'package:torino_mobility/resources/config/router.dart' as r;
import 'package:get/get.dart';
import 'package:torino_mobility/resources/utils/color_utils.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';

class RouteListTile extends StatelessWidget {
  final gtt.Route route;
  final RouteListController controller;
  const RouteListTile(
      {super.key, required this.route, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _RouteIcon(route: route),
      title: Text(
        route.longName,
        overflow: TextOverflow.ellipsis,
        style: Fonts.title(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      subtitle: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: route.type == 3 ? 'AUTOBUS'.hc : 'TRAM'.hc,
              style: Fonts.subtitle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xff8a8273),
              ),
            ),
            TextSpan(
              text: '  •  '.hc,
              style: Fonts.subtitle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xff8a8273),
              ),
            ),
            TextSpan(
              text: 'LINEA ${route.shortName}'.hc,
              style: Fonts.subtitle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xff8a8273),
              ),
            ),
          ],
        ),
      ),
      trailing: IconButton(
        icon: Icon(controller.favorites.contains(route)
            ? Icons.star
            : Icons.star_outline),
        onPressed: () {
          //print(controller.favorites.contains(route));
          controller.toggleFavorite(route);
        },
      ),
      onTap: () {
        Get.toNamed(r.Router.mapBusRoute, arguments: {
          'vehicles': [route]
        });
      },
    );
  }
}

class _RouteIcon extends StatelessWidget {
  const _RouteIcon({required this.route});

  final gtt.Route route;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(5),
      width: 40 + (route.shortName.length > 2 ? route.shortName.length * 5 : 0),
      height: 40,
      decoration: BoxDecoration(
        color: ColorUtils.normalize(
          ColorUtils.indexColor(int.tryParse(route.shortName) ?? 0),
          dark: Get.find<SettingsController>().isDarkMode.isTrue,
        ),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        route.shortName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }
}
