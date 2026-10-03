import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';

class CountdownRing extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onExpired;
  final Widget? child;
  final double size;
  final Color activeColor;

  const CountdownRing({
    super.key,
    this.durationSeconds = 30,
    required this.onExpired,
    this.child,
    this.size = 90,
    this.activeColor = RgColors.secondary,
  });

  @override
  State<CountdownRing> createState() => _CountdownRingState();
}

class _CountdownRingState extends State<CountdownRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onExpired();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final remainingSeconds = (widget.durationSeconds * (1.0 - _controller.value)).ceil();
        final isUrgent = remainingSeconds <= 10;
        final currentColor = isUrgent ? RgColors.secondary : widget.activeColor;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CountdownPainter(
                  progress: 1.0,
                  color: Colors.white.withOpacity(0.15),
                  strokeWidth: 4.5,
                ),
              ),

              // Animated countdown arc
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CountdownPainter(
                  progress: 1.0 - _controller.value,
                  color: currentColor,
                  strokeWidth: 4.5,
                ),
              ),

              if (widget.child != null)
                widget.child!
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$remainingSeconds',
                      style: RgTypography.displayMedium.copyWith(
                        color: Colors.white,
                        fontSize: widget.size * 0.32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'SEC',
                      style: RgTypography.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CountdownPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CountdownPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
