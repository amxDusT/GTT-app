import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/controllers/search/list_search_controller.dart';
import 'package:flutter_gtt/pages/search/list_search_page.dart';
import 'package:flutter_gtt/widgets/route_list_favorite_widget.dart';
import 'package:flutter_gtt/widgets/route_list_tile_widget.dart';
import 'package:get/get.dart';

class RouteListPage extends StatelessWidget {
  RouteListPage({super.key});
  final _routeListController = Get.find<RouteListController>();
  final _searchController = Get.put(ListSearchController());
  @override
  Widget build(BuildContext context) {
    _routeListController.getRoutes();
    _routeListController.getFavorites();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (_searchController.focusNode?.hasFocus ?? false) {
          _searchController.focusNode?.unfocus();
        } else {
          Future.delayed(Duration.zero, () {
            if (!didPop) Get.back(closeOverlays: true);
          });
        }
      },
      child: Hero(
        tag: 'RouteListPage',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Bus List'),
          ),
          body: GetBuilder<RouteListController>(
            builder: (controller) => ListView(
              shrinkWrap: true,
              children: [
                ListSearchPage(
                  controller: _routeListController,
                  searchController: _searchController,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ...controller.favorites.map((route) => RouteListFavorite(
                          route: route, controller: controller)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                ...controller.agencies.map(
                  (agency) => ExpansionTile(
                    initiallyExpanded: agency.gtfsId == 'gtt:U',
                    title: Text(agency.name),
                    children: [
                      SizedBox(
                        height:
                            (controller.routesMap[agency.gtfsId]?.length ?? 0) >
                                    5
                                ? Get.size.height * 0.5
                                : Get.size.height * 0.2,
                        child: ListView.builder(
                          itemCount:
                              controller.routesMap[agency.gtfsId]?.length ?? 0,
                          itemBuilder: (context, index) {
                            final route =
                                controller.routesMap[agency.gtfsId]![index];

                            return RouteListTile(
                                route: route, controller: controller);
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
      ),
    );
  }
}
