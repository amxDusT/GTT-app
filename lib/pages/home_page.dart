import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/controllers/home_controller.dart';
import 'package:torino_mobility/controllers/route_list_controller.dart';
import 'package:torino_mobility/controllers/search/home_search_controller.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/spacing.dart';
import 'package:torino_mobility/widgets/app_header.dart';
import 'package:torino_mobility/widgets/home/favorite_card.dart';
import 'package:torino_mobility/widgets/home/favorite_routes.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/widgets/search/home_search_widget.dart';
import 'package:torino_mobility/resources/config/router.dart' as r;

class HomePage extends GetView<HomeController> {
  HomePage({super.key});
  final _searchController = Get.find<SearchStopsController>();
  final _settingsController = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      key: controller.scaffoldKey,
      body: Obx(
        () {
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AppHeader(
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: t.accent,
                          ),
                          height: 5,
                          width: 5,
                          alignment: Alignment.center,
                        ),
                        Spacing.hGap8,
                        Text(
                          'TORINO'.hc,
                          style: Fonts.subtitle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: .9,
                            color: t.inkMute,
                          ),
                        ),
                      ],
                    ),
                    titleTop: 'le tue'.hc,
                    titleBottom: 'fermate'.hc,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: t.bgRaised,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: Divider.createBorderSide(
                              context,
                            ),
                          ),
                        ),
                        onPressed: () => Get.toNamed(r.Router.settingsRoute),
                        /* onPressed: () => controller.scaffoldKey.currentState
                            ?.openEndDrawer(), */
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: SearchStop(searchController: _searchController),
                ),
                //SliverToBoxAdapter(child: SearchBar()),
                if (_settingsController.isFavoritesRoutesShowing.value)
                  GetBuilder<RouteListController>(
                    builder: (controller) => controller.favorites.isEmpty
                        ? const SliverToBoxAdapter(child: SizedBox.shrink())
                        : FavoriteRoutes(
                            controller: controller,
                          ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 24, bottom: 12),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'LE TUE FERMATE'.hc,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                GetBuilder<HomeController>(
                  builder: (controller) {
                    return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                        sliver: SliverReorderableList(
                          itemBuilder: (context, index) {
                            final fermata = controller.fermate[index];
                            return HomeFavCard(
                              key: ValueKey(fermata.code),
                              fermata: fermata,
                              homeController: controller,
                              favoriteRoutes: controller
                                  .favoriteRoutes[fermata.gtfsId]
                                  ?.map((route) => route.shortName)
                                  .toList(),
                            );
                          },
                          itemCount: controller.fermate.length,
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: t.lineStrong,
                                  width: 1.5,
                                ),
                              ),
                              child: child,
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            final item = controller.fermate.removeAt(oldIndex);
                            controller.fermate.insert(newIndex, item);
                            controller.updateFavorites();
                          },
                        ));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
