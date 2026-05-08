import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/route_list_controller.dart';
import 'package:torino_mobility/models/gtt/route.dart' as gtt;
import 'package:torino_mobility/resources/config/router.dart' as r;
import 'package:get/get.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/widgets/route_icon.dart';

class RouteListTile extends StatelessWidget {
  final gtt.Route route;
  final RouteListController controller;
  const RouteListTile(
      {super.key, required this.route, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isFavorite = controller.favorites.contains(route);
    return ListTile(
      leading: RouteIcon(route: route),
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
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_outline,
          color: isFavorite ? Colors.amber : Colors.grey,
        ),
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
