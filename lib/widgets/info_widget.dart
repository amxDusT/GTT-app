import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/info_controller.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:torino_mobility/models/gtt/stop.dart';
import 'package:torino_mobility/resources/storage.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:torino_mobility/widgets/display_hours.dart';
import 'package:torino_mobility/widgets/map_selection_checkbox.dart';
import 'package:torino_mobility/resources/config/router.dart' as r;
import 'package:get/get.dart';
import 'package:torino_mobility/widgets/route_icon.dart';

class InfoWidget extends StatelessWidget {
  final RouteWithDetails vehicle;
  final Stop stop;
  final InfoController _infoController;
  InfoWidget({
    super.key,
    required this.stop,
    required this.vehicle,
  }) : _infoController = Get.find<InfoController>(tag: stop.code.toString());

  void _onTap() {
    if (_infoController.isSelecting.isTrue) {
      _infoController.onSelectedClick(vehicle);
      return;
    } else if (!Storage.instance.isRouteWithoutPassagesShowing &&
        vehicle.stoptimes.isEmpty) {
      Utils.showSnackBar(
        'Non ci sono passaggi per questo veicolo',
        closePrevious: true,
      );
      return;
    }
    Get.toNamed(r.Router.mapBusRoute, arguments: {
      'vehicles': [vehicle],
      'fermata': stop,
    });
  }

  @override
  Widget build(BuildContext context) {
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    return Obx(() {
      final isSelected = _infoController.selectedRoutes.contains(vehicle);
      return Card(
        clipBehavior: Clip.antiAlias,
        shape: shape,
        color: isSelected ? const Color(0xfff3ede0) : null,
        child: InkWell(
          onTap: _onTap,
          onLongPress: () => _infoController.onLongPress(vehicle),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 8),
                          visualDensity: VisualDensity.compact,
                          leading: RouteIcon(routeName: vehicle.shortName),
                          title: Row(
                            children: [
                              Icon(
                                Icons.arrow_right_alt,
                                color:
                                    isSelected ? const Color(0xff1a1611) : null,
                              ),
                              Expanded(
                                child: Text(
                                  vehicle.pattern.headsign,
                                  overflow: TextOverflow.ellipsis,
                                  style: Fonts.title(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xff1a1611)
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'LINEA ${vehicle.shortName}',
                            style: Fonts.subtitle(
                              color: const Color(0xff8a8273),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: DisplayHours(
                            vehicle: vehicle, isSelected: isSelected),
                      ),
                    ],
                  ),
                ),
                MapSelectionCheckbox(
                  selected: isSelected,
                  onTap: () => _infoController.onSelectedClick(vehicle),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
