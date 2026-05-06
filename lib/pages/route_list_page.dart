import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/route_list_controller.dart';
import 'package:torino_mobility/controllers/search/list_search_controller.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/spacing.dart';
import 'package:torino_mobility/widgets/app_header.dart';
import 'package:torino_mobility/widgets/search/route_search_widget.dart';
import 'package:torino_mobility/widgets/route_list_tile_widget.dart';
import 'package:get/get.dart';

class RouteListPage extends GetView<RouteListController> {
  RouteListPage({super.key});
  final _searchController = Get.put(ListSearchController());

  static final Map<RouteFilter, String> _filterLabels = {
    RouteFilter.all: 'Tutte'.hc,
    RouteFilter.favorites: 'Preferite'.hc,
    RouteFilter.tram: 'Tram'.hc,
    RouteFilter.bus: 'Bus'.hc,
  };

  @override
  Widget build(BuildContext context) {
    controller.getFavorites();
    return SafeArea(
      child: Scaffold(
        body: GetBuilder<RouteListController>(
          builder: (controller) {
            final routes = controller.filteredRoutes;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AppHeader(
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${routes.length} LINEE'.hc,
                          style: Fonts.subtitle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: .9,
                            color: const Color(0xff6e6555),
                          ),
                        ),
                        Spacing.hGap8,
                        Text(
                          '•'.hc,
                          style: Fonts.subtitle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: .9,
                            color: const Color(0xff6e6555),
                          ),
                        ),
                        Spacing.hGap8,
                        Text(
                          '${controller.favorites.length} PREFERITE'.hc,
                          style: Fonts.subtitle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: .9,
                            color: const Color(0xff6e6555),
                          ),
                        ),
                      ],
                    ),
                    titleTop: 'Tutte le'.hc,
                    titleBottom: 'linee'.hc,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    SearchRoute(
                      controller: controller,
                      searchController: _searchController,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final filter in RouteFilter.values)
                            ChoiceChip(
                              label: Text(_filterLabels[filter]!),
                              selected: controller.activeFilter == filter,
                              showCheckmark: false,
                              onSelected: (_) => controller.setFilter(filter),
                            ),
                        ],
                      ),
                    ),
                  ]),
                ),
                SliverList.builder(
                  itemCount: routes.length,
                  itemBuilder: (context, index) => RouteListTile(
                    route: routes[index],
                    controller: controller,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }
}
