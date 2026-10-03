import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';

class SosButton extends StatefulWidget {
  final VoidCallback onTrigger;
  final double size;

  const SosButton({
    super.key,
    required this.onTrigger,
    this.size = RgDimensions.sosButtonSize,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _holdController;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _pulseOpacityAnimation;

  bool _isHolding = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation (gentle continuous breathing rings)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );

    _pulseOpacityAnimation = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );

    // Hold-to-send animation (1.5 seconds)
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        _isHolding = false;
        _holdController.reset();
        widget.onTrigger();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    setState(() => _isHolding = true);
    HapticFeedback.mediumImpact();
    _holdController.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isHolding) {
      setState(() => _isHolding = false);
      _holdController.reverse();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_isHolding) {
      setState(() => _isHolding = false);
      _holdController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: SizedBox(
            width: widget.size * 1.45,
            height: widget.size * 1.45,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Repeating pulse ring 1
                if (!disableAnimations)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseScaleAnimation.value,
                        child: Container(
                          width: widget.size,
                          height: widget.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: RgColors.secondary.withOpacity(
                              _pulseOpacityAnimation.value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Repeating pulse ring 2 (offset)
                if (!disableAnimations)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final phaseOffset = (_pulseController.value + 0.5) % 1.0;
                      final scale = 1.0 + (phaseOffset * 0.3);
                      final opacity = (1.0 - phaseOffset) * 0.3;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: widget.size,
                          height: widget.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: RgColors.secondary.withOpacity(opacity),
                          ),
                        ),
                      );
                    },
                  ),

                // Outer progress ring track
                Container(
                  width: widget.size + 14,
                  height: widget.size + 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: RgColors.secondaryLight.withOpacity(0.5),
                      width: 4,
                    ),
                  ),
                ),

                // Circular Hold Progress Arc
                AnimatedBuilder(
                  animation: _holdController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(widget.size + 14, widget.size + 14),
                      painter: _SosProgressPainter(
                        progress: _holdController.value,
                        color: Colors.white,
                        strokeWidth: 5.0,
                      ),
                    );
                  },
                ),

                // Main red button body
                AnimatedScale(
                  scale: _isHolding ? 0.94 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFFF04438),
                          Color(0xFFD92D20),
                          Color(0xFFB42318),
                        ],
                        stops: [0.0, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: RgColors.secondary.withOpacity(_isHolding ? 0.6 : 0.4),
                          blurRadius: _isHolding ? 32 : 24,
                          spreadRadius: _isHolding ? 6 : 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          PhosphorIconsFill.shieldWarning,
                          size: 46,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SOS',
                          style: RgTypography.displayLarge.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isHolding ? 'HOLDING...' : 'HOLD TO SEND',
                          style: RgTypography.caption.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Hold for 1.5s to broadcast immediate campus alert',
          style: RgTypography.caption.copyWith(
            color: RgColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SosProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _SosProgressPainter({
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
      ..color = RgColors.secondary
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
  bool shouldRepaint(covariant _SosProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
