import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/controllers/search/list_search_controller.dart';
import 'package:flutter_gtt/widgets/search/route_search_widget.dart';
import 'package:flutter_gtt/widgets/route_list_favorite_widget.dart';
import 'package:flutter_gtt/widgets/route_list_tile_widget.dart';
import 'package:get/get.dart';

class RouteListPage extends GetView<RouteListController> {
  RouteListPage({super.key});
  final _searchController = Get.put(ListSearchController());
  @override
  Widget build(BuildContext context) {
    //controller.getRoutes();
    controller.getFavorites();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (_searchController.focusNode?.hasFocus ?? false) {
          _searchController.focusNode?.unfocus();
        } else {
          Future.delayed(Duration.zero, () {
            if (!didPop) {
              //controller.onPageClose();
              Get.back(closeOverlays: true);
            }
          });
        }
      },
      child: Hero(
        tag: 'RouteListPage',
        child: Scaffold(
          body: GetBuilder<RouteListController>(
            builder: (controller) => CustomScrollView(
              slivers: [
                const SliverAppBar(
                  title: Text('Lista Veicoli'),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SearchRoute(
                        controller: controller,
                        searchController: _searchController,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...controller.favorites.map((route) =>
                                RouteListFavorite(
                                    route: route, controller: controller)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList.builder(
                  itemCount: controller.agencies.length,
                  itemBuilder: (context, index) {
                    final agency = controller.agencies[index];
                    return ExpansionTile(
                      initiallyExpanded: agency.gtfsId == 'gtt:U',
                      title: Text(agency.name),
                      children: [
                        SizedBox(
                          height:
                              (controller.routesMap[agency.gtfsId]?.length ??
                                          0) >
                                      5
                                  ? Get.size.height * 0.5
                                  : Get.size.height * 0.2,
                          child: CustomScrollView(
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final route = controller
                                        .routesMap[agency.gtfsId]![index];
                                    return RouteListTile(
                                        route: route, controller: controller);
                                  },
                                  childCount: controller
                                          .routesMap[agency.gtfsId]?.length ??
                                      0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
/* 
class RouteListPageOld extends StatelessWidget {
  RouteListPageOld({super.key});
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
            if (!didPop) {
              Get.back(closeOverlays: true);
            }
          });
        }
      },
      child: Hero(
        tag: 'RouteListPage',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Lista Veicoli'),
          ),
          body: GetBuilder<RouteListController>(
            builder: (controller) => ListView(
              shrinkWrap: true,
              children: [
                SearchRoute(
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
 */