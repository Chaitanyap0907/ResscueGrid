import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';
import '../core/utils/formatters.dart';
import '../data/models/incident.dart';
import 'severity_badge.dart';
import 'status_badge.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;
  final bool showAssignedResponder;
  final bool compact;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
    this.showAssignedResponder = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
            border: Border.all(
              color: incident.isEscalated ? RgColors.warning : RgColors.border,
              width: incident.isEscalated ? 1.5 : 1.0,
            ),
            boxShadow: RgDimensions.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Severity colored left edge strip (4px)
                  Container(
                    width: 5,
                    color: incident.severity.color,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(compact ? 12 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: ID, Badges
                          Row(
                            children: [
                              Text(
                                incident.id,
                                style: RgTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: RgColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              SeverityBadge(severity: incident.severity),
                              const SizedBox(width: 6),
                              StatusBadge(status: incident.status),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Title with Category Icon
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: incident.category.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  incident.category.icon,
                                  size: 16,
                                  color: incident.category.color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  incident.title,
                                  style: RgTypography.subheading.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: compact ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Location and Time
                          Row(
                            children: [
                              const Icon(
                                PhosphorIconsRegular.mapPin,
                                size: 14,
                                color: RgColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  incident.locationName,
                                  style: RgTypography.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                RgFormatters.timeAgo(incident.createdAt),
                                style: RgTypography.caption.copyWith(
                                  color: RgColors.textMuted,
                                ),
                              ),
                            ],
                          ),

                          // Assigned responder info (if active)
                          if (showAssignedResponder &&
                              incident.assignedResponderName != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: RgColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    PhosphorIconsRegular.userCheck,
                                    size: 14,
                                    color: RgColors.primaryAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      incident.assignedResponderName!,
                                      style: RgTypography.caption.copyWith(
                                        color: RgColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (incident.responderEtaMinutes > 0) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: RgColors.infoLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'ETA ${incident.responderEtaMinutes}m',
                                        style: RgTypography.caption.copyWith(
                                          color: RgColors.info,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          if (incident.isEscalated) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  PhosphorIconsRegular.warning,
                                  size: 13,
                                  color: RgColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Unaccepted > 30s. Escalated for override.',
                                  style: RgTypography.caption.copyWith(
                                    color: RgColors.warning,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
