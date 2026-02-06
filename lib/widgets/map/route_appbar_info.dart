import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/map/map_controller.dart';
import 'package:torino_mobility/models/gtt/route.dart';
import 'package:get/get.dart';

class RouteAppBarInfo extends StatefulWidget {
  final MapPageController mapController;

  const RouteAppBarInfo({super.key, required this.mapController});

  @override
  State<RouteAppBarInfo> createState() => _RouteAppBarInfoState();
}

class _RouteAppBarInfoState extends State<RouteAppBarInfo>
    with SingleTickerProviderStateMixin {
  final _empty = const SizedBox.shrink();
  bool previousState = false;
  late final AnimationController _animationController;
  late final CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleContainer() {
    if (_curvedAnimation.status != AnimationStatus.completed) {
      previousState = true;
      _animationController.forward();
    } else {
      previousState = false;
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool canShow = widget.mapController.routePatterns.isNotEmpty &&
          widget.mapController.isPatternInitialized.isTrue &&
          widget.mapController.isAppBarExpanded.isTrue;
      if (widget.mapController.routePatterns.isEmpty) return _empty;
      if (widget.mapController.isPatternInitialized.isFalse) return _empty;

      if (canShow != previousState) {
        _toggleContainer();
      }
      RouteWithDetails route = widget.mapController.routes.values.first;

      return SizeTransition(
        sizeFactor: _curvedAnimation,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.longName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text('Direzione:'),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                      text: widget
                          .mapController.firstStop[route.pattern.code]!.name,
                      children: [
                        const WidgetSpan(child: SizedBox(width: 10)),
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.arrow_right_alt,
                          ),
                        ),
                        const WidgetSpan(child: SizedBox(width: 10)),
                        TextSpan(
                          text: route.pattern.headsign,
                        ),
                      ]),
                ),
                const SizedBox(
                  height: 15,
                ),
                DropdownMenu(
                  enableSearch: false,
                  inputDecorationTheme: const InputDecorationTheme(
                    constraints: BoxConstraints(
                      maxHeight: 45,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  width: Get.width * 0.9,
                  initialSelection:
                      widget.mapController.isPatternInitialized.isTrue
                          ? widget.mapController.routes.values.first.pattern
                          : null,
                  onSelected: (pattern) => pattern == null
                      ? null
                      : widget.mapController.setCurrentPattern(pattern),
                  dropdownMenuEntries: widget.mapController.routePatterns
                      .map((pattern) => DropdownMenuEntry(
                            value: pattern,
                            label:
                                '${pattern.directionId}:${pattern.code.split(':').last} - ${pattern.headsign}',
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                route.pattern == pattern
                                    ? Theme.of(context).focusColor
                                    : null,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
