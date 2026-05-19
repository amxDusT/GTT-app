import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:torino_mobility/controllers/home_controller.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/controllers/map/map_info_controller.dart';
import 'package:torino_mobility/controllers/search/home_search_controller.dart';
import 'package:torino_mobility/models/marker.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
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
                            color: const Color(0xff6e6555),
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
                IconButton(
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    widget.controller.popupController
                        .hidePopupsOnlyFor([widget.marker]);
                    widget.controller.lastOpenedMarker = null;

                    Get.delete<MapInfoController>(
                      tag: widget.marker.fermata.code.toString(),
                    );
                  },
                )
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Get.find<HomeController>()
                        .switchAddDeleteFermata(widget.marker.fermata);
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: GetBuilder<HomeController>(builder: (controller) {
                    bool isFavorite = controller.fermate
                        .any((f) => f.code == widget.marker.fermata.code);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        IgnorePointer(
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () {},
                            icon: Icon(
                                isFavorite ? Icons.star : Icons.star_border),
                            iconSize: 16,
                            color: isFavorite ? Colors.yellow : Colors.grey,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xff221d17),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                                side: Divider.createBorderSide(
                                  context,
                                  color: isFavorite ? Colors.yellow : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          isFavorite ? 'Salvata'.hc : 'Salva'.hc,
                          style: TextStyle(
                            color: isFavorite ? Colors.yellow : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                TextButton(
                  onPressed: () {
                    widget.controller
                        .setHighlightedStop(widget.marker.fermata.code);
                    _isHighlighted.value = !_isHighlighted.value;
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: ValueListenableBuilder(
                      valueListenable: _isHighlighted,
                      builder: (context, bool isHighlighted, child) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            IgnorePointer(
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () {},
                                icon: Icon(_isHighlighted.value
                                    ? Icons.highlight
                                    : Icons.highlight_outlined),
                                iconSize: 16,
                                color:
                                    isHighlighted ? Colors.yellow : Colors.grey,
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xff221d17),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    side: Divider.createBorderSide(
                                      context,
                                      color:
                                          isHighlighted ? Colors.yellow : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              isHighlighted ? 'Evidenziata'.hc : 'Evidenzia'.hc,
                              style: TextStyle(
                                color:
                                    isHighlighted ? Colors.yellow : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }),
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
                          color: const Color(0xff6e6555),
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
          ],
        ),
      ),
    );
  }
}
