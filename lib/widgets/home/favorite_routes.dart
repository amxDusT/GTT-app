import 'package:flutter/material.dart';
import 'package:torino_mobility/controllers/route_list_controller.dart';
import 'package:torino_mobility/pages/nav_shell.dart';
import 'package:torino_mobility/resources/globals.dart';
import 'package:torino_mobility/resources/utils/extensions.dart';
import 'package:torino_mobility/widgets/route_icon.dart';

class FavoriteRoutes extends StatelessWidget {
  const FavoriteRoutes({required this.controller, super.key});

  final RouteListController controller;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LINEE PREFERITE'.hc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () => NavShell.goTo(NavShell.routeListIndex),
                  child: Text('tutte'.hc),
                )
              ],
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...controller.favorites.map((route) => RouteIcon(
                      route: route,
                    )),
                if (controller.favorites.length <= maxDisplayAddRoutes)
                  GestureDetector(
                    onTap: () => NavShell.goTo(NavShell.routeListIndex),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomPaint(
                        painter: DottedBorderPainter(
                          color: Colors.grey,
                          radius: 8,
                          dashLength: 3,
                          gapLength: 3,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  DottedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    _drawDottedRRect(canvas, rect, paint);
  }

  void _drawDottedRRect(Canvas canvas, RRect rrect, Paint paint) {
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DottedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        dashLength != oldDelegate.dashLength ||
        gapLength != oldDelegate.gapLength;
  }
}
