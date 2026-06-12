import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torino_mobility/controllers/home_controller.dart';
import 'package:torino_mobility/controllers/info_controller.dart';
import 'package:torino_mobility/l10n/localization_service.dart';
import 'package:torino_mobility/models/gtt/favorite_stop.dart';
import 'package:torino_mobility/resources/extensions/date_time.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/spacing.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:torino_mobility/widgets/home/info_icon_button.dart';
import 'package:torino_mobility/widgets/star_icon_button.dart';

const double _kExpandedAppBarHeight = 200;

class StopSliverAppBar extends StatelessWidget {
  final InfoController controller;
  final int stopCode;

  const StopSliverAppBar({
    super.key,
    required this.controller,
    required this.stopCode,
  });

  int _selectedTotal() {
    final vehicleCount = controller.fermata.value.vehicles.length;
    return maxRoutesInMap > vehicleCount ? vehicleCount : maxRoutesInMap;
  }

  FavStop? _favStop() {
    if (controller.isSaved.isFalse) return null;
    if (!Get.isRegistered<HomeController>()) return null;
    return Get.find<HomeController>()
        .fermate
        .where((f) => f.code == stopCode)
        .firstOrNull;
  }

  TextStyle _titleStyle(double fontSize, Color color) => Fonts.title(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: -0.5,
        height: 1.1,
      );

  /// Largest font size at which the stop name fits in 2 lines within
  /// [maxHeight], starting from the size the design prefers for this length.
  double _titleFontSize(
    String name, {
    required Color color,
    required double maxWidth,
    required double maxHeight,
    required TextScaler textScaler,
  }) {
    final preferred =
        (30 + (48 - 30) * (1 - name.length / 25)).clamp(30, 48).toDouble();
    for (var size = preferred; size > 20; size -= 2) {
      final painter = TextPainter(
        text: TextSpan(text: name, style: _titleStyle(size, color)),
        maxLines: 2,
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout(maxWidth: maxWidth);
      if (!painter.didExceedMaxLines && painter.height <= maxHeight) {
        return size;
      }
    }
    return 20;
  }

  void _showFullDescription(
      BuildContext context, String name, String description) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FERMATA #$stopCode'.hc,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                    fontSize: 12,
                  ),
                ),
                Spacing.vGap4,
                Text(
                  name,
                  style: Fonts.title(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Spacing.vGap16,
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _bgColor(BuildContext context, {FavStop? fav}) {
    final theme = Theme.of(context);
    if (fav == null) return theme.colorScheme.inversePrimary;
    final tinted = theme.brightness == Brightness.dark
        ? Utils.darken(fav.color, 30)
        : Utils.lighten(fav.color);
    return tinted.withValues(alpha: 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBg = theme.colorScheme.onSurface;

    return SliverAppBar(
      pinned: true,
      expandedHeight: _kExpandedAppBarHeight,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      automaticallyImplyActions: false,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: InfoIconButton(
            icon: Icons.chevron_left,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              if (controller.isSelecting.isTrue) {
                controller.switchSelecting();
              } else {
                Get.back(closeOverlays: true);
              }
            },
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Obx(
            () {
              final isFavorite = controller.isSaved.isTrue;
              return StarIconButton(
                onPressed: controller.switchAddDeleteFermata,
                selected: isFavorite,
                selectedColor: const Color(0xffff5a1f),
                unselectedColor: onBg,
                style: IconButton.styleFrom(
                  backgroundColor: const Color.fromARGB(77, 82, 68, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final topPadding = MediaQuery.paddingOf(context).top;
          final minH = kToolbarHeight + topPadding;
          const maxH = _kExpandedAppBarHeight;
          final height = constraints.biggest.height;
          final transparency =
              ((height - minH) / (maxH - minH)).clamp(0.0, 1.0);

          return Obx(() {
            final fav = _favStop();
            final bg = _bgColor(context, fav: fav);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: bg.withValues(alpha: 1),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16 * transparency),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Collapsed title (visible when scrolled)
                  Positioned(
                    top: topPadding,
                    left: 64,
                    right: 104,
                    height: kToolbarHeight,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 1 - transparency,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            controller.isSelecting.isTrue
                                ? l10n.selectedRoutesCount(
                                    controller.selectedRoutes.length,
                                    _selectedTotal(),
                                  )
                                : '#$stopCode ${controller.fermata.value.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Fonts.title(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: onBg,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Expanded content
                  Positioned(
                    left: 20,
                    right: 56,
                    top: topPadding + 20,
                    child: IgnorePointer(
                      ignoring: transparency < 0.5,
                      child: Opacity(
                        opacity: transparency,
                        child: Obx(() {
                          final stop = controller.fermata.value;
                          final desc = (fav?.descrizione?.isNotEmpty ?? false)
                              ? fav!.descrizione
                              : null;
                          final isLoading = controller.isLoading.isTrue;

                          final textScaler = MediaQuery.textScalerOf(context);
                          final contentWidth =
                              constraints.biggest.width - 20 - 56;

                          final descStyle =
                              theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: onBg.withValues(alpha: 0.75),
                          );
                          var descHeight = 0.0;
                          var descOverflows = false;
                          if (desc != null) {
                            final painter = TextPainter(
                              text: TextSpan(text: desc, style: descStyle),
                              maxLines: 2,
                              textDirection: TextDirection.ltr,
                              textScaler: textScaler,
                            )..layout(maxWidth: contentWidth);
                            descHeight = painter.height;
                            descOverflows = painter.didExceedMaxLines;
                          }

                          final titleGap = descHeight > 30 ? 12.0 : 24.0;
                          final titleMaxHeight = (_kExpandedAppBarHeight -
                                  20 - // offset below the status bar
                                  17 - // 'FERMATA #' label
                                  titleGap -
                                  (desc == null ? 0 : 4 + descHeight) -
                                  16 - // gap above the update chip
                                  34) // update chip
                              .clamp(24.0, double.infinity);

                          final fontSize = _titleFontSize(
                            stop.name,
                            color: onBg,
                            maxWidth: contentWidth,
                            maxHeight: titleMaxHeight,
                            textScaler: textScaler,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 44.0),
                                child: Text(
                                  'FERMATA #$stopCode'.hc,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: onBg.withValues(alpha: 0.7),
                                    letterSpacing: 0.5,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(height: titleGap),
                              Text(
                                stop.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: _titleStyle(fontSize, onBg),
                              ),
                              if (desc != null) ...[
                                Spacing.vGap4,
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: descOverflows
                                      ? () => _showFullDescription(
                                          context, stop.name, desc)
                                      : null,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    spacing: 12,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          desc,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: descStyle,
                                        ),
                                      ),
                                      if (descOverflows)
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 18,
                                          color: onBg.withValues(alpha: 0.75),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                              Spacing.vGap16,
                              Container(
                                decoration: BoxDecoration(
                                  color: onBg.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      height: 10,
                                      width: 10,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: switch ((
                                            controller.lastUpdate.value
                                                .add(const Duration(minutes: 1))
                                                .isAfter(DateTime.now()),
                                            isLoading
                                          )) {
                                            (true, false) =>
                                              const Color(0xff9bd14a),
                                            (false, false) =>
                                              const Color.fromARGB(
                                                  211, 220, 131, 48),
                                            (_, true) => Colors.grey
                                          }),
                                    ),
                                    AnimatedSize(
                                      duration:
                                          const Duration(milliseconds: 350),
                                      curve: Curves.easeOutCubic,
                                      alignment: Alignment.centerLeft,
                                      child: isLoading
                                          ? const SizedBox.shrink()
                                          : ClipRect(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Spacing.hGap8,
                                                  Text(
                                                    controller.lastUpdate.value
                                                        .toTimeString(Storage
                                                            .instance
                                                            .showSecondsInUpdates),
                                                  ),
                                                  Spacing.hGap8,
                                                  Text('•'.hc),
                                                  Spacing.hGap8,
                                                  Icon(
                                                    Icons.directions_bus,
                                                    size: 16,
                                                    color: onBg.withValues(
                                                        alpha: 0.8),
                                                  ),
                                                  Spacing.hGap8,
                                                  Text(
                                                    '${stop.vehicles.length} LINEE'
                                                        .hc,
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      color: onBg.withValues(
                                                          alpha: 0.85),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}
