import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/models/gtt/pattern.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/spacing.dart';
import 'package:torino_mobility/widgets/floating_nav_pill.dart';
import 'package:torino_mobility/widgets/map/stop_timeline_row.dart';
import 'package:torino_mobility/widgets/route_icon.dart';
import 'package:get/get.dart';

const double _kExpandedAppBarHeight = kToolbarHeight + 75;

class MapPatternInfo extends StatefulWidget {
  const MapPatternInfo({
    required this.route,
    required this.controller,
    super.key,
  });

  final RouteWithDetails route;
  final MapPageController controller;

  @override
  State<MapPatternInfo> createState() => _MapPatternInfoState();
}

class _MapPatternInfoState extends State<MapPatternInfo> {
  int? _page;
  @override
  void initState() {
    super.initState();
    widget.controller.loadPatternsFor(widget.route.gtfsId);
    final currentPattern =
        widget.controller.routes[widget.route.gtfsId]?.pattern ??
            widget.route.pattern;
    _page = currentPattern.directionId;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: .9,
      initialChildSize: .9,
      expand: false,
      builder: (context, scrollController) {
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: _kExpandedAppBarHeight,
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0,
              backgroundColor: const Color(0xff221d17),
              leadingWidth: 70,
              leading: Padding(
                  padding: const EdgeInsets.all(4).copyWith(left: 16),
                  child: RouteIcon(routeName: widget.route.shortName)),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
              actions: [
                Obx(() {
                  final canRemove = widget.controller.routes.length > 1;
                  return IconButton(
                    tooltip: 'Rimuovi dalla mappa'.hc,
                    onPressed: canRemove
                        ? () {
                            widget.controller.removeRoute(widget.route.gtfsId);
                            Get.back();
                          }
                        : null,
                    icon: const Icon(Icons.delete_outline),
                    visualDensity: VisualDensity.compact,
                  );
                }),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                )
              ],
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              widget.route.type == 3 ? 'AUTOBUS'.hc : 'TRAM'.hc,
                          style: Fonts.subtitle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff8a8273),
                          ),
                        ),
                        TextSpan(
                          text: '  •  '.hc,
                          style: Fonts.subtitle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff8a8273),
                          ),
                        ),
                        TextSpan(
                          text: 'LINEA ${widget.route.shortName}'.hc,
                          style: Fonts.subtitle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff8a8273),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('Cambia Percorso'.hc, style: Fonts.title()),
                ],
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                  child: FloatingNavPill(
                    showAllLabels: true,
                    expand: true,
                    backgroundColor: Colors.black,
                    currentIndex: _page ?? 0,
                    onChanged: (i) => setState(() => _page = i),
                    items: [
                      NavPillItem(
                          icon: Icons.keyboard_arrow_right,
                          label: 'Direzione 0'.hc),
                      NavPillItem(
                          icon: Icons.keyboard_arrow_left,
                          label: 'Direzione 1'.hc),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(
                () {
                  final patterns =
                      widget.controller.patternsByRoute[widget.route.gtfsId];
                  if (patterns == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (patterns.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Nessun percorso disponibile'.hc,
                          style: Fonts.subtitle(),
                        ),
                      ),
                    );
                  }
                  final patternsWithDirections0 =
                      patterns.where((p) => p.directionId == 0).toList();
                  final patternsWithDirections1 =
                      patterns.where((p) => p.directionId == 1).toList();
                  return IndexedStack(
                    index: _page ?? 0,
                    children: [
                      PatternListPerDirection(
                        patternsToShow: patternsWithDirections0,
                        route: widget.route,
                        mapController: widget.controller,
                      ),
                      PatternListPerDirection(
                        patternsToShow: patternsWithDirections1,
                        mapController: widget.controller,
                        route: widget.route,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class PatternListPerDirection extends StatelessWidget {
  const PatternListPerDirection({
    super.key,
    required this.patternsToShow,
    required this.mapController,
    required this.route,
  });
  final RouteWithDetails route;
  final List<Pattern> patternsToShow;
  final MapPageController mapController;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => Spacing.vGap8,
      itemCount: patternsToShow.length + 1,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == patternsToShow.length) {
          return const SizedBox(height: 16);
        }
        final pattern = patternsToShow[index];

        return ExpansionTile(
          leading: Obx(() {
            final currentPattern =
                mapController.routes[route.gtfsId]?.pattern ?? route.pattern;
            return Checkbox(
              shape: const CircleBorder(),
              value: pattern.code == currentPattern.code,
              onChanged: (v) {
                if (v == true) {
                  mapController.setCurrentPattern(route.gtfsId, pattern);
                  Get.back();
                }
              },
            );
          }),
          subtitle: Obx(() {
            final stops =
                mapController.stopsByPattern[pattern.code] ?? const [];
            return Skeletonizer(
              enabled: stops.isEmpty,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: pattern.code.split(':').last,
                      style: Fonts.subtitle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff8a8273),
                      ),
                    ),
                    TextSpan(
                      text: '  •  '.hc,
                      style: Fonts.subtitle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff8a8273),
                      ),
                    ),
                    TextSpan(
                      text: '${stops.length} FERMATE'.hc,
                      style: Fonts.subtitle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff8a8273),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Color(0xff8a8273),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Color(0xff8a8273),
            ),
          ),
          collapsedBackgroundColor: const Color(0xff1a1611),
          backgroundColor: const Color(0xff1a1611),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            children: [
              const Icon(
                Icons.arrow_right_alt,
              ),
              Expanded(
                child: Text(
                  pattern.headsign,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: Fonts.title(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Obx(() {
              final stops =
                  mapController.stopsByPattern[pattern.code] ?? const [];
              if (stops.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < stops.length; i++)
                      StopTimelineRow(
                        name: stops[i].name,
                        isFirst: i == 0,
                        isLast: i == stops.length - 1,
                      ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
