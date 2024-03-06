import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/models/gtt/route.dart' as gtt;
import 'package:get/get.dart';

class RouteListTile extends StatelessWidget {
  final gtt.Route route;
  final RouteListController controller;
  const RouteListTile(
      {super.key, required this.route, required this.controller});
  Icon _setIcon(int type) {
    IconData iconData;
    switch (type) {
      case 0:
        iconData = Icons.tram;
        break;
      case 1:
        iconData = Icons.subway;
        break;
      case 2:
        iconData = Icons.train;
        break;
      case 4:
        iconData = Icons.directions_ferry;
        break;
      default:
        iconData = Icons.directions_bus;
    }
    return Icon(iconData);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _setIcon(route.type),
      title: Text(
        route.shortName,
        //overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        route.longName,
        overflow: TextOverflow.ellipsis,
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
        Get.toNamed('/mapBus', arguments: {
          'vehicles': [route]
        });
      },
    );
  }
}
