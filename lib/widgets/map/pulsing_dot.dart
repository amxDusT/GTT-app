import 'package:flutter/material.dart';

class PulsingDot extends StatefulWidget {
  const PulsingDot(
      {super.key, required this.size, required this.color, this.glow = false});
  final double size;
  final Color color;
  final bool glow;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.45)
          .chain(CurveTween(curve: Curves.easeInOut))
          .animate(_controller),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: widget.glow
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: .15),
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
