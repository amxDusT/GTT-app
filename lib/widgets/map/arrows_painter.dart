import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:torino_mobility/widgets/map/direction_arrows_layer.dart';

class ArrowsPainter extends CustomPainter {
  final MapCamera camera;
  final List<DirectionArrowRoute> routes;
  final double spacing;
  final double glyphSize;
  final double strokeWidth;
  final double borderWidth;
  final Animation<double>? phase;

  static const double _minSeg = 1.0;

  ArrowsPainter({
    required this.camera,
    required this.routes,
    required this.spacing,
    required this.glyphSize,
    required this.strokeWidth,
    required this.borderWidth,
    required this.phase,
  }) : super(repaint: phase);

  void _drawGlyph(Canvas canvas, Paint border, Paint fill) {
    final h = glyphSize / 2;
    final path = Path()
      ..moveTo(-h, -h)
      ..lineTo(h, 0)
      ..lineTo(-h, h);
    canvas.drawPath(path, border);
    canvas.drawPath(path, fill);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final phasePx = ((phase?.value ?? 0.0) * spacing) % spacing;

    final margin = glyphSize;
    final clip = Rect.fromLTWH(
      -margin,
      -margin,
      size.width + 2 * margin,
      size.height + 2 * margin,
    );

    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2 * borderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    for (final route in routes) {
      final pts = route.points;
      if (pts.length < 2) continue;
      borderPaint.color = route.color;

      final offsets = List<Offset>.generate(
        pts.length,
        (i) => camera.getOffsetFromOrigin(pts[i]),
        growable: false,
      );

      double distToNext = phasePx;

      for (var i = 0; i < offsets.length - 1; i++) {
        final a = offsets[i];
        final b = offsets[i + 1];
        final dx = b.dx - a.dx;
        final dy = b.dy - a.dy;
        final segLen = math.sqrt(dx * dx + dy * dy);
        if (segLen < _minSeg) continue;
        final ux = dx / segLen;
        final uy = dy / segLen;
        final angle = math.atan2(dy, dx);

        double along = distToNext;
        while (along <= segLen) {
          final p = Offset(a.dx + ux * along, a.dy + uy * along);
          if (clip.contains(p)) {
            canvas.save();
            canvas.translate(p.dx, p.dy);
            canvas.rotate(angle);
            _drawGlyph(canvas, borderPaint, fillPaint);
            canvas.restore();
          }
          along += spacing;
        }
        distToNext = along - segLen;
      }
    }
  }

  @override
  bool shouldRepaint(ArrowsPainter old) {
    return old.camera != camera ||
        old.routes != routes ||
        old.spacing != spacing ||
        old.glyphSize != glyphSize ||
        old.strokeWidth != strokeWidth ||
        old.borderWidth != borderWidth ||
        old.phase != phase;
  }
}
