import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/utils/formatters.dart';
import '../data/models/timeline_event.dart';

class TimelineView extends StatelessWidget {
  final List<TimelineEvent> events;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const TimelineView({
    super.key,
    required this.events,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No timeline events logged yet.',
            style: RgTypography.bodySmall,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: events.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final event = events[index];
        final isFirst = index == 0;
        final isLast = index == events.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column for icon and vertical connector
              SizedBox(
                width: 44,
                child: Column(
                  children: [
                    // Top line
                    Container(
                      width: 2,
                      height: 12,
                      color: isFirst ? Colors.transparent : RgColors.border,
                    ),
                    // Node icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: event.color.withOpacity(0.12),
                        border: Border.all(
                          color: event.color,
                          width: 1.8,
                        ),
                      ),
                      child: Icon(
                        event.icon,
                        size: 15,
                        color: event.color,
                      ),
                    ),
                    // Bottom line
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isLast ? Colors.transparent : RgColors.border,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Content block
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: RgTypography.subheading.copyWith(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            RgFormatters.timeOnly(event.timestamp),
                            style: RgTypography.caption.copyWith(
                              color: RgColors.textMuted,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        style: RgTypography.bodySmall.copyWith(
                          color: RgColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (event.actorName != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: RgColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: RgColors.border),
                              ),
                              child: Text(
                                '${event.actorName} Â· ${event.actorRole ?? "Staff"}',
                                style: RgTypography.caption.copyWith(
                                  fontSize: 10.5,
                                  color: RgColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
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
        );
      },
    );
  }
}
