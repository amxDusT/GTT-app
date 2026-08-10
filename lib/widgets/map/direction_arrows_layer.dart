import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:torino_mobility/widgets/map/arrows_painter.dart';

/// Arrow
class DirectionArrowRoute {
  final List<LatLng> points;
  final Color color;
  const DirectionArrowRoute({required this.points, required this.color});
}

class DirectionArrowsLayer extends StatefulWidget {
  final List<DirectionArrowRoute> routes;

  /// distance between arrows
  final double spacing;

  final double glyphSize;
  final double strokeWidth;

  final double borderWidth;

  final bool animate;

  final Duration period;

  const DirectionArrowsLayer({
    super.key,
    required this.routes,
    this.spacing = 48,
    this.glyphSize = 10,
    this.strokeWidth = 2,
    this.borderWidth = 1,
    this.animate = true,
    this.period = const Duration(milliseconds: 1200),
  });

  @override
  State<DirectionArrowsLayer> createState() => _DirectionArrowsLayerState();
}

class _DirectionArrowsLayerState extends State<DirectionArrowsLayer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) _startController();
  }

  void _startController() {
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant DirectionArrowsLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && _controller == null) {
      _startController();
    } else if (!widget.animate && _controller != null) {
      _controller!
        ..stop()
        ..dispose();
      _controller = null;
    } else if (_controller != null && widget.period != oldWidget.period) {
      _controller!.duration = widget.period;
      _controller!
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    return MobileLayerTransformer(
      child: CustomPaint(
        painter: ArrowsPainter(
          camera: camera,
          routes: widget.routes,
          spacing: widget.spacing,
          glyphSize: widget.glyphSize,
          strokeWidth: widget.strokeWidth,
          borderWidth: widget.borderWidth,
          phase: _controller,
        ),
        size: Size(camera.size.x, camera.size.y),
        isComplex: true,
        willChange: widget.animate,
      ),
    );
  }
}
