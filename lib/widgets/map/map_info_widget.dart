import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/controllers/map/map_info_controller.dart';
import 'package:torino_mobility/fake/fake_data.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/spacing.dart';
import 'package:torino_mobility/widgets/map/map_passage_time.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:torino_mobility/widgets/route_icon.dart';

class MapInfoWidget extends StatefulWidget {
  final Stop stop;
  final MapPageController mapPageController;
  final MapInfoController _mapInfoController;
  const MapInfoWidget({
    super.key,
    required this.stop,
    required this.mapPageController,
    required MapInfoController mapInfoController,
  }) : _mapInfoController = mapInfoController;

  @override
  State<MapInfoWidget> createState() => _MapInfoWidgetState();
}

class _MapInfoWidgetState extends State<MapInfoWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    updateWidget();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void updateWidget() async {
    await widget._mapInfoController.getFermata(widget.stop.code);

    //HACKY: force rebuild
    if (mounted) setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ensurePopupVisible();
    });
  }

  void _ensurePopupVisible() {
    RenderBox? cardBox;
    RenderBox? mapBox;
    context.visitAncestorElements((element) {
      if (cardBox == null && element.widget is Card) {
        cardBox = element.renderObject as RenderBox?;
      }
      if (element.widget is FlutterMap) {
        mapBox = element.renderObject as RenderBox?;
        return false;
      }
      return true;
    });
    if (cardBox == null || mapBox == null) return;
    if (!cardBox!.hasSize || !mapBox!.hasSize) return;

    final cardSize = cardBox!.size;

    final camera = widget.mapPageController.mapController.camera;
    final markerScreen = camera.latLngToScreenPoint(
      LatLng(widget.stop.lat, widget.stop.lon),
    );

    final desiredTop = markerScreen.y - cardSize.height;

    const padding = 16.0;
    if (desiredTop < padding) {
      widget.mapPageController.panMapByPixels(0, padding - desiredTop);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allRoutes = widget._mapInfoController.isLoading.isTrue
        ? List.filled(3, FakeData().fakeRouteWithDetails)
        : widget._mapInfoController.fermata.value.vehicles;
    final routes = allRoutes
        .map((r) => r as RouteWithDetails)
        .where((r) => r.stoptimes.isNotEmpty)
        .toList();
    final routeNames = widget._mapInfoController.isLoading.isTrue
        ? '(${FakeData().fakeText(20)})'
        : '(${widget._mapInfoController.routesNames.join(', ')})';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Parent widget has Obx already so we don't need to wrap this in Obx
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 160),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Skeletonizer(
                enabled: widget._mapInfoController.isLoading.isTrue,
                child: Table(
                  columnWidths: {
                    0: const IntrinsicColumnWidth(),
                    1: const FlexColumnWidth(),
                    for (int i = 0; i < maxHoursMap; i++)
                      i + 2: const IntrinsicColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    for (final route in routes)
                      TableRow(
                        children: [
                          RouteIcon(routeName: route.shortName, size: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.arrow_right_alt,
                                size: 16,
                              ),
                              Expanded(
                                child: Text(
                                  route.pattern.headsign.capitalizeFirst ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Fonts.title(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          for (int i = 0; i < maxHoursMap; i++)
                            if (i < route.stoptimes.length)
                              Padding(
                                padding: i == 0
                                    ? const EdgeInsets.only(right: 8)
                                    : const EdgeInsets.symmetric(horizontal: 0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: MapPassageTime(
                                    stoptime: route.stoptimes[i],
                                    style: TextStyle(
                                      color: route.stoptimes[i].realtime
                                          ? Colors.green
                                          : Colors.grey[700],
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Skeletonizer(
          enabled: widget._mapInfoController.isLoading.isTrue,
          child: Text(
            routeNames,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Spacing.vGap8,
      ],
    );
  }
}
