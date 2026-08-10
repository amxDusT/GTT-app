import 'package:flutter/material.dart';
import 'dart:math';
import 'package:torino_mobility/controllers/home_controller.dart';
import 'package:torino_mobility/models/gtt/favorite_stop.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/utils/color_utils.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/spacing.dart';
import 'package:torino_mobility/resources/config/router.dart' as r;
import 'package:get/get.dart';

class HomeFavCard extends StatelessWidget {
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
    final tokens = context.tokens;
    final cardColor = tokens.tint(fermata.color).withValues(alpha: 0.9);
    final onCard = tokens.onTint(fermata.color);
    return ReorderableDelayedDragStartListener(
      enabled: true,
      index: homeController.fermate.indexOf(fermata),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(22)),
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
                    color: cardColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(22),
                    ),
                    child: toHeroContext.widget,
                  )),
              child: InkWell(
                splashColor: Colors.red,
                borderRadius: const BorderRadius.all(Radius.circular(22)),
                onTap: () => Get.toNamed(r.Router.infoRoute,
                    arguments: {'fermata': fermata}),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                              color: tokens.bg,
                            ),
                            child: Text(
                              '#${fermata.code}',
                              overflow: TextOverflow.ellipsis,
                              style: Fonts.subtitle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tokens.ink,
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
                                    fontWeight: FontWeight.w600,
                                    color: onCard,
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
                                      color: onCard.withValues(alpha: 0.75),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => homeController.showContextMenu(
                                fermata, iconKey),
                            child: IconButton(
                              key: iconKey,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              onPressed: () => {},
                              icon: Icon(
                                Icons.more_horiz,
                                color: onCard,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (favoriteRoutes != null &&
                              favoriteRoutes!.isNotEmpty)
                            SizedBox(
                              height: 24,
                              child: ListView.separated(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                separatorBuilder: (context, index) =>
                                    Spacing.hGap4,
                                itemBuilder: (context, index) {
                                  final route = favoriteRoutes![index]
                                      .replaceAll(' ', '');
                                  final chipFill = index < maxFavoriteRoutes
                                      ? tokens.tint(ColorUtils.indexColor(
                                          int.tryParse(route) ?? 0))
                                      : tokens.inkMute.withValues(alpha: 0.8);

                                  return Container(
                                    alignment: Alignment.center,
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                      border: Border.all(
                                        color: tokens.line,
                                        width: .2,
                                      ),
                                      color: chipFill,
                                    ),
                                    child: FittedBox(
                                      child: Text(
                                        index < maxFavoriteRoutes
                                            ? route
                                            : '+${favoriteRoutes!.length - maxFavoriteRoutes}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Fonts.subtitle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: tokens.onColor(chipFill),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                //shrinkWrap: true,
                                itemCount: min(
                                  favoriteRoutes!.length,
                                  maxFavoriteRoutes + 1,
                                ),
                              ),
                            ),
                          const Spacer(),
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
