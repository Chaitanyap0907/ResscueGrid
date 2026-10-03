import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';

class StatCard extends StatefulWidget {
  final String label;
  final num value;
  final String? suffix;
  final String? prefix;
  final IconData icon;
  final Color? iconColor;
  final String? trendText;
  final bool isTrendPositive;
  final bool isWarning;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.suffix,
    this.prefix,
    required this.icon,
    this.iconColor,
    this.trendText,
    this.isTrendPositive = true,
    this.isWarning = false,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.value.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant StatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final effectiveIconColor = widget.iconColor ?? (widget.isWarning ? RgColors.warning : RgColors.primaryAccent);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        border: Border.all(
          color: widget.isWarning ? RgColors.warning.withOpacity(0.5) : RgColors.border,
          width: 1,
        ),
        boxShadow: RgDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(RgDimensions.radiusSmall),
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: effectiveIconColor,
                ),
              ),
              if (widget.trendText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.isTrendPositive ? RgColors.successLight : RgColors.errorLight,
                    borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isTrendPositive ? 'â–² ' : 'â–¼ ',
                        style: TextStyle(
                          fontSize: 9,
                          color: widget.isTrendPositive ? RgColors.success : RgColors.error,
                        ),
                      ),
                      Text(
                        widget.trendText!,
                        style: RgTypography.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.isTrendPositive ? RgColors.success : RgColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final displayedValue = disableAnimations
                  ? widget.value
                  : (widget.value is int
                      ? _animation.value.round()
                      : double.parse(_animation.value.toStringAsFixed(1)));

              return Text(
                '${widget.prefix ?? ''}$displayedValue${widget.suffix ?? ''}',
                style: RgTypography.kpiNumber.copyWith(
                  color: widget.isWarning ? RgColors.warning : RgColors.textPrimary,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            widget.label,
            style: RgTypography.caption.copyWith(
              color: RgColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
