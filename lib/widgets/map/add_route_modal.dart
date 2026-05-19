import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/controllers/route_list_controller.dart';
import 'package:torino_mobility/models/gtt/route.dart' as gtt;
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/resources/utils/utils.dart';
import 'package:torino_mobility/widgets/route_icon.dart';
import 'package:get/get.dart';

class AddRouteModal extends StatefulWidget {
  const AddRouteModal({required this.controller, super.key});

  final MapPageController controller;

  @override
  State<AddRouteModal> createState() => _AddRouteModalState();
}

class _AddRouteModalState extends State<AddRouteModal> {
  final _routeListController = Get.find<RouteListController>();
  String _query = '';
  bool _adding = false;

  List<gtt.Route> get _candidates {
    final onMap = widget.controller.routes.keys.toSet();
    final all = _routeListController.routesMap.values
        .expand((r) => r)
        .where((r) => !onMap.contains(r.gtfsId))
        .toList();
    Utils.sort(all);
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where((r) =>
            r.shortName.toLowerCase().contains(q) ||
            r.longName.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _onTap(gtt.Route route) async {
    if (_adding) return;
    setState(() => _adding = true);
    await widget.controller.addRoute(route);
    if (!mounted) return;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: .85,
      initialChildSize: .7,
      minChildSize: .4,
      expand: false,
      builder: (context, scrollController) {
        final candidates = _candidates;
        final atLimit = widget.controller.routes.length >= maxRoutesInMap;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aggiungi linea'.hc, style: Fonts.title(fontSize: 20)),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Cerca linea'.hc,
                      hintStyle: Fonts.subtitle(
                        fontSize: 13,
                        color: const Color(0xff8a8273),
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (atLimit)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Hai raggiunto il numero massimo di linee'.hc,
                  style: Fonts.subtitle(color: const Color(0xff8a8273)),
                ),
              )
            else
              Expanded(
                child: candidates.isEmpty
                    ? Center(
                        child: Text(
                          'Nessuna linea da aggiungere'.hc,
                          style: Fonts.subtitle(color: const Color(0xff8a8273)),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: candidates.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 12, endIndent: 12),
                        itemBuilder: (context, index) {
                          final route = candidates[index];
                          return ListTile(
                            leading: RouteIcon(routeName: route.shortName),
                            title: Text(
                              route.longName,
                              overflow: TextOverflow.ellipsis,
                              style: Fonts.title(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            subtitle: Text(
                              '${route.type == 3 ? 'AUTOBUS'.hc : 'TRAM'.hc}  •  LINEA ${route.shortName}'
                                  .hc,
                              style: Fonts.subtitle(
                                fontSize: 10,
                                color: const Color(0xff8a8273),
                              ),
                            ),
                            trailing: const Icon(Icons.add),
                            onTap: () => _onTap(route),
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
