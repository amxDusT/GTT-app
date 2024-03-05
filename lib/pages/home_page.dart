import 'package:flutter/material.dart';
import 'package:flutter_gtt/controllers/home_controller.dart';
import 'package:flutter_gtt/controllers/route_list_controller.dart';
import 'package:flutter_gtt/controllers/search/home_search_controller.dart';
import 'package:flutter_gtt/controllers/settings_controller.dart';
import 'package:flutter_gtt/widgets/search/home_search_widget.dart';
import 'package:flutter_gtt/widgets/home/drawer/drawer.dart';
import 'package:flutter_gtt/widgets/home/favorite_card.dart';
import 'package:flutter_gtt/widgets/route_list_favorite_widget.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final _homeController = Get.find<HomeController>();
  final _searchController = Get.find<SearchStopsController>();
  final _settingsController = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _homeController.scaffoldKey,
      endDrawer: HomeDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Gtt Fermate"),
      ),
      body: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchStop(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_settingsController.isFavoritesRoutesShowing.value)
                      GetBuilder<RouteListController>(
                          builder: (controller) => controller.favorites.isEmpty
                              ? Container()
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(
                                      indent: 10,
                                      endIndent: 10,
                                    ),
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ...controller.favorites
                                              .map((route) => RouteListFavorite(
                                                    route: route,
                                                    controller: controller,
                                                    hasRemoveIcon: false,
                                                  )),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      indent: 10,
                                      endIndent: 10,
                                    ),
                                  ],
                                )),
                    GetBuilder<HomeController>(
                      builder: (controller) {
                        return GridView.count(
                          physics: const ScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          padding: const EdgeInsets.all(20),
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          primary: true,
                          children: [
                            ...controller.fermate.map((fermata) => HomeFavCard(
                                  fermata: fermata,
                                  controller: controller,
                                ))
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              elevation: 2,
              heroTag: '___Menu',
              child: const Icon(Icons.menu),
              onPressed: () {
                _homeController.scaffoldKey.currentState?.openEndDrawer();
              },
            ),
            const SizedBox(
              height: 5,
            ),
            FloatingActionButton(
              elevation: 2,
              child: const Icon(Icons.search),
              onPressed: () {
                _searchController.searchButton();
              },
            ),
          ],
        ),
      ),
    );
  }
}
