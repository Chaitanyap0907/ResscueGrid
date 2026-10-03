import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class RadarSweep extends StatefulWidget {
  final double size;
  final Color color;
  final Widget? centerChild;

  const RadarSweep({
    super.key,
    this.size = 140,
    this.color = RgColors.primaryAccent,
    this.centerChild,
  });

  @override
  State<RadarSweep> createState() => _RadarSweepState();
}

class _RadarSweepState extends State<RadarSweep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Concentric circles
          for (double factor in [0.35, 0.65, 1.0])
            Container(
              width: widget.size * factor,
              height: widget.size * factor,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withOpacity(0.18),
                  width: 1.2,
                ),
              ),
            ),

          // Crosshairs
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RadarCrosshairPainter(color: widget.color.withOpacity(0.14)),
          ),

          // Rotating radar sweep
          if (!disableAnimations)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _RadarSweepPainter(color: widget.color),
                  ),
                );
              },
            ),

          // Center icon/pulse dot
          if (widget.centerChild != null)
            widget.centerChild!
          else
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RadarCrosshairPainter extends CustomPainter {
  final Color color;
  _RadarCrosshairPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RadarSweepPainter extends CustomPainter {
  final Color color;
  _RadarSweepPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.35),
        ],
        stops: const [0.75, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
