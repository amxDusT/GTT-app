import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/route_list_controller.dart';
import 'package:torino_mobility/models/gtt/route.dart' as gtt;
import 'package:torino_mobility/resources/config/router.dart' as r;
import 'package:get/get.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/resources/utils/fonts.dart';
import 'package:torino_mobility/widgets/route_icon.dart';
import 'package:torino_mobility/widgets/star_icon_button.dart';

class RouteListTile extends StatefulWidget {
  final gtt.Route route;
  final RouteListController controller;
  const RouteListTile(
      {super.key, required this.route, required this.controller});

  @override
  State<RouteListTile> createState() => _RouteListTileState();
}

class _RouteListTileState extends State<RouteListTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = widget.controller.favorites.contains(widget.route);
    return Row(
      children: [
        Expanded(
          child: Listener(
            onPointerDown: (_) => _setPressed(true),
            onPointerUp: (_) => _setPressed(false),
            onPointerCancel: (_) => _setPressed(false),
            child: AnimatedScale(
              scale: _pressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              child: Theme(
                data: Theme.of(context).copyWith(
                  highlightColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 16),
                  onTap: () {
                    Get.toNamed(r.Router.mapBusRoute, arguments: {
                      'vehicles': [widget.route]
                    });
                  },
                  leading: RouteIcon(routeName: widget.route.shortName),
                  title: Text(
                    widget.route.longName,
                    overflow: TextOverflow.ellipsis,
                    style:
                        Fonts.title(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  subtitle: RichText(
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
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: StarIconButton(
            selected: isFavorite,
            onPressed: () {
              widget.controller.toggleFavorite(widget.route);
            },
          ),
        ),
      ],
    );
  }
}
