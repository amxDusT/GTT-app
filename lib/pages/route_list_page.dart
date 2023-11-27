import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/pages/map/map_page.dart';
import 'package:get/get.dart';

class RouteListPage extends StatelessWidget {
  RouteListPage({super.key});
  final _routeListController = Get.find<RouteListController>();

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
    _routeListController.getRoutes();
    return Hero(
      tag: 'RouteListPage',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bus List'),
        ),
        body: GetBuilder<RouteListController>(
          builder: (controller) => ListView(
            shrinkWrap: true,
            children: [
              ...controller.agencies.map(
                (agency) => ExpansionTile(
                  initiallyExpanded: agency.gtfsId == 'gtt:U',
                  title: Text(agency.name),
                  children: [
                    SizedBox(
                      height:
                          (controller.routesMap[agency.gtfsId]?.length ?? 0) > 5
                              ? Get.size.height * 0.5
                              : Get.size.height * 0.2,
                      child: ListView.builder(
                        itemCount:
                            controller.routesMap[agency.gtfsId]?.length ?? 0,
                        itemBuilder: (context, index) {
                          final route =
                              controller.routesMap[agency.gtfsId]![index];

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
                            onTap: () {
                              Get.to(() => MapPage(), arguments: {
                                'vehicles': [route]
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
