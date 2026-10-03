import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final bool isDestructive;
  final double? width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.isDestructive = false,
    this.width,
    this.height = RgDimensions.buttonHeight,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;

    if (widget.isDestructive) {
      bgColor = RgColors.secondary;
      fgColor = Colors.white;
    } else if (widget.isSecondary) {
      bgColor = RgColors.primaryLight;
      fgColor = RgColors.primary;
    } else {
      bgColor = RgColors.primary;
      fgColor = Colors.white;
    }

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: ElevatedButton(
          onPressed: isEnabled
              ? () {
                  _pressController.forward().then((_) {
                    _pressController.reverse();
                  });
                  widget.onPressed!();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            disabledBackgroundColor: bgColor.withOpacity(0.4),
            disabledForegroundColor: fgColor.withOpacity(0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RgDimensions.radiusButton),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: widget.isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20, color: fgColor),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        style: RgTypography.button.copyWith(color: fgColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
