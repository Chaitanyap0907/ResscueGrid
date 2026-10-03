import 'package:flutter/material.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';
import '../data/models/enums.dart';

class SeverityBadge extends StatelessWidget {
  final IncidentSeverity severity;
  final bool isFilled;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = severity == IncidentSeverity.critical || isFilled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCritical ? severity.color : severity.bgColor,
        borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
        border: Border.all(
          color: severity.color.withOpacity(isCritical ? 1.0 : 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            severity.icon,
            size: 13,
            color: isCritical ? Colors.white : severity.color,
          ),
          const SizedBox(width: 5),
          Text(
            severity.label,
            style: RgTypography.badgeLabel.copyWith(
              color: isCritical ? Colors.white : severity.color,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
