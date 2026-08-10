import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:torino_mobility/resources/config/app_tokens.dart';
import 'package:torino_mobility/resources/utils/color_utils.dart';

class RouteIcon extends StatelessWidget {
  const RouteIcon({
    super.key,
    required this.routeName,
    this.removeIcon = false,
    this.onRemoved,
    this.onTap,
    this.size = 40,
    this.color,
    this.margin = const EdgeInsets.all(4),
    this.padding = const EdgeInsets.all(4),
  }) : assert(!(removeIcon && onRemoved == null),
            'If removeIcon is true, onRemoved must be provided');

  final String routeName;
  final bool removeIcon;
  final VoidCallback? onRemoved;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final name = routeName.replaceAll(' ', '');
    final fill =
        color ?? t.tint(ColorUtils.indexColor(int.tryParse(name) ?? 0));

    Widget mainWidget = Skeleton.leaf(
      child: Container(
        alignment: Alignment.center,
        margin: margin,
        padding: padding,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
        ),
        child: FittedBox(
          child: Text(
            name,
            maxLines: 1,
            style: TextStyle(
              color: t.onColor(fill),
              fontSize: 20,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      mainWidget = GestureDetector(
        onTap: onTap,
        child: mainWidget,
      );
    }
    return removeIcon
        ? Stack(
            fit: StackFit.loose,
            children: [
              mainWidget,
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: onRemoved,
                  child: Container(
                      alignment: Alignment.center,
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 236, 115, 107),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      )),
                ),
              )
            ],
          )
        : mainWidget;
  }
}
