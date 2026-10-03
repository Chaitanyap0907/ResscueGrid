import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';

enum BannerType {
  info,
  warning,
  error,
  success;

  Color get bgColor {
    switch (this) {
      case BannerType.info:
        return RgColors.infoLight;
      case BannerType.warning:
        return RgColors.warningLight;
      case BannerType.error:
        return RgColors.errorLight;
      case BannerType.success:
        return RgColors.successLight;
    }
  }

  Color get fgColor {
    switch (this) {
      case BannerType.info:
        return RgColors.info;
      case BannerType.warning:
        return RgColors.warning;
      case BannerType.error:
        return RgColors.error;
      case BannerType.success:
        return RgColors.success;
    }
  }

  IconData get defaultIcon {
    switch (this) {
      case BannerType.info:
        return PhosphorIconsRegular.info;
      case BannerType.warning:
        return PhosphorIconsRegular.warning;
      case BannerType.error:
        return PhosphorIconsRegular.warningCircle;
      case BannerType.success:
        return PhosphorIconsRegular.checkCircle;
    }
  }
}

class InfoBanner extends StatelessWidget {
  final String message;
  final String? title;
  final BannerType type;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onClose;

  const InfoBanner({
    super.key,
    required this.message,
    this.title,
    this.type = BannerType.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? type.defaultIcon;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: type.bgColor,
        borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
        border: Border.all(
          color: type.fgColor.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            effectiveIcon,
            color: type.fgColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: RgTypography.caption.copyWith(
                      color: type.fgColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: RgTypography.bodySmall.copyWith(
                    color: RgColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: type.fgColor,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: RgTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: type.fgColor,
                ),
              ),
            ),
          ],
          if (onClose != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClose,
              child: Icon(
                PhosphorIconsRegular.x,
                size: 16,
                color: type.fgColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
