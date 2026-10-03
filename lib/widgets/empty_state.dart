import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;

  const EmptyState({
    super.key,
    this.icon = PhosphorIconsRegular.shieldCheck,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onButtonPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? RgColors.primaryAccent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: effectiveIconColor.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: 36,
                color: effectiveIconColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: RgTypography.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: RgTypography.bodyMedium.copyWith(color: RgColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 20),
              PrimaryButton(
                label: buttonLabel!,
                onPressed: onButtonPressed!,
                width: 180,
                height: 44,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingSkeleton extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = RgDimensions.radiusSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE4E7EC),
      highlightColor: const Color(0xFFF9FAFB),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'Unable to complete the operation. Please try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: RgColors.errorLight,
              ),
              child: const Icon(
                PhosphorIconsRegular.warningCircle,
                size: 32,
                color: RgColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: RgTypography.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: RgTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Try Again',
                onPressed: onRetry!,
                width: 140,
                height: 40,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
