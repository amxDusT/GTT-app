import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/home_controller.dart';
import 'package:torino_mobility/controllers/settings_controller.dart';
import 'package:torino_mobility/models/gtt/favorite_stop.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/utils/color_utils.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:torino_mobility/resources/config/router.dart' as r;
import 'package:get/get.dart';

class HomeFavCard extends GetView<SettingsController> {
  const HomeFavCard({
    super.key,
    required this.fermata,
    required this.homeController,
    this.favoriteRoutes,
  });
  final List<String>? favoriteRoutes;
  final FavStop fermata;
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    final GlobalKey iconKey = GlobalObjectKey('fav_icon_${fermata.code}');
    return ReorderableDragStartListener(
      enabled: false,
      index: homeController.fermate.indexOf(fermata),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: (controller.isDarkMode.isTrue
                  ? Utils.darken(fermata.color, 30)
                  : Utils.lighten(fermata.color))
              .withValues(alpha: 0.9),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        //padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'HeroTagFermata${fermata.code}',
              flightShuttleBuilder: ((flightContext, animation, flightDirection,
                      fromHeroContext, toHeroContext) =>
                  Material(
                    color: (controller.isDarkMode.isTrue
                            ? Utils.darken(fermata.color, 30)
                            : Utils.lighten(fermata.color))
                        .withValues(alpha: 0.9),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                    child: toHeroContext.widget,
                  )),
              child: InkWell(
                splashColor: Colors.red,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                onTap: () => Get.toNamed(r.Router.infoRoute,
                    arguments: {'fermata': fermata}),
                onLongPress: () =>
                    homeController.showContextMenu(fermata, iconKey),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                              color: Colors.white,
                            ),
                            child: Text(
                              '#${fermata.code}',
                              overflow: TextOverflow.ellipsis,
                              style: Fonts.subtitle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fermata.name.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Fonts.title(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4, bottom: 6),
                                  child: Text(
                                    fermata.descrizione ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Fonts.subtitle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            key: iconKey,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => homeController.showContextMenu(
                                fermata, iconKey),
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (favoriteRoutes != null &&
                              favoriteRoutes!.isNotEmpty)
                            Expanded(
                              child: SizedBox(
                                height: 30,
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    final route = favoriteRoutes![index];

                                    return Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(
                                          right: 6, top: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(4),
                                        ),
                                        color: index < maxFavoriteRoutes
                                            ? ColorUtils.normalize(
                                                ColorUtils.indexColor(
                                                    int.tryParse(route) ?? 0),
                                                dark: controller
                                                    .isDarkMode.isTrue)
                                            : Colors.grey
                                                .withValues(alpha: 0.8),
                                      ),
                                      child: Text(
                                        index < maxFavoriteRoutes
                                            ? route
                                            : '+${favoriteRoutes!.length - maxFavoriteRoutes}',
                                        overflow: TextOverflow.ellipsis,
                                        style: Fonts.subtitle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                  //shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      favoriteRoutes!.length > maxFavoriteRoutes
                                          ? maxFavoriteRoutes + 1
                                          : favoriteRoutes!.length,
                                ),
                              ),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
