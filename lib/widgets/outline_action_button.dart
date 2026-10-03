import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';

class OutlineActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;

  const OutlineActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.width,
    this.height = RgDimensions.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? RgColors.primary;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveColor,
          side: BorderSide(
            color: effectiveColor.withOpacity(0.4),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RgDimensions.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: effectiveColor),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                style: RgTypography.button.copyWith(color: effectiveColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
