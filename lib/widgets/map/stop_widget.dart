import 'package:flutter/material.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:torino_mobility/controllers/home_controller.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/controllers/map/map_info_controller.dart';
import 'package:torino_mobility/controllers/search/home_search_controller.dart';
import 'package:torino_mobility/models/marker.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/widgets/animated_icon_button.dart';
import 'package:torino_mobility/widgets/map/close_popup_icon_button.dart';
import 'package:torino_mobility/widgets/map/map_info_widget.dart';
import 'package:get/get.dart';

class StopWidget extends StatefulWidget {
  final FermataMarker marker;
  final MapPageController controller;
  const StopWidget({super.key, required this.marker, required this.controller});

  @override
  State<StopWidget> createState() => _StopWidgetState();
}

class _StopWidgetState extends State<StopWidget> {
  late final ValueNotifier<bool> _isHighlighted = ValueNotifier(false);
  late final MapInfoController _mapInfoController = Get.put<MapInfoController>(
    MapInfoController(),
    tag: widget.marker.fermata.code.toString(),
  );

  @override
  void dispose() {
    _isHighlighted.dispose();
    Get.delete<MapInfoController>(
      tag: widget.marker.fermata.code.toString(),
    );
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isHighlighted.value = widget.controller.isStopHighlighted(
      stopCode: widget.marker.fermata.code,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: () async {
        Get.find<SearchStopsController>().openInfoPage(widget.marker.fermata);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FERMATA #${widget.marker.fermata.code}'.hc,
                          style: Fonts.subtitle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: t.inkMute,
                          )),
                      Text(
                        widget.marker.fermata.name,
                        style: Fonts.title(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                ClosePopupIconButton(
                  controller: widget.controller,
                  marker: widget.marker,
                  onPressed: () => Get.delete<MapInfoController>(
                    tag: widget.marker.fermata.code.toString(),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Obx(() => Skeletonizer(
                      enabled: _mapInfoController.isLoading.isTrue,
                      child: Text(
                        '${_mapInfoController.isLoading.isTrue ? 0 : _mapInfoController.fermata.value.vehicles.length} ${'LINEE'.hc}',
                        style: Fonts.subtitle(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: t.inkMute,
                        ),
                      ),
                    )),
              ),
            ),
            const Divider(),
            MapInfoWidget(
              stop: widget.marker.fermata,
              mapPageController: widget.controller,
              mapInfoController: _mapInfoController,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                Expanded(
                  child: GetBuilder<HomeController>(
                    builder: (controller) {
                      bool isFavorite = controller.fermate
                          .any((f) => f.code == widget.marker.fermata.code);
                      return AnimatedIconButton(
                        selectedIcon: Icons.star,
                        unselectedIcon: Icons.star_outline,
                        selected: isFavorite,
                        selectedColor: t.warn,
                        selectedLabel: 'Salvato'.hc,
                        unselectedLabel: 'Salva'.hc,
                        onPressed: () {
                          controller.switchAddDeleteFermata(
                            widget.marker.fermata,
                          );
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _isHighlighted,
                    builder: (context, bool isHighlighted, child) {
                      return AnimatedIconButton(
                        selectedIcon: Icons.flashlight_on,
                        unselectedIcon: Icons.flashlight_on_outlined,
                        selected: isHighlighted,
                        selectedColor: t.warn,
                        selectedLabel: 'Evidenziato'.hc,
                        unselectedLabel: 'Evidenzia'.hc,
                        onPressed: () {
                          widget.controller
                              .setHighlightedStop(widget.marker.fermata.code);
                          _isHighlighted.value = !_isHighlighted.value;
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
