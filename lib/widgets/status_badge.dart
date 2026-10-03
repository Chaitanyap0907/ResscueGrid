import 'package:flutter/material.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';
import '../data/models/enums.dart';

class StatusBadge extends StatelessWidget {
  final IncidentStatus status;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
        border: Border.all(
          color: status.color.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status.color,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status.label,
            style: RgTypography.badgeLabel.copyWith(
              color: status.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
