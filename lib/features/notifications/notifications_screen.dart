import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/enums.dart';
import '../../data/models/notification_item.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final notifications = state.notifications;
    final unreadCount = state.unreadNotificationCount;

    return Scaffold(
      backgroundColor: RgColors.background,
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                state.markAllNotificationsRead();
              },
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? const EmptyState(
                icon: PhosphorIconsRegular.bellSlash,
                title: 'No Notifications',
                message: 'You have caught up with all campus alerts and dispatch notices.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return _buildNotificationCard(context, state, item);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    RescueGridState state,
    NotificationItem item,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          state.markNotificationRead(item.id);
          if (item.incidentId != null) {
            if (state.currentRole == UserRole.student) {
              context.push('/student/tracking/${item.incidentId}');
            } else if (state.currentRole == UserRole.responder) {
              context.push('/responder/active/${item.incidentId}');
            } else {
              context.go('/admin');
            }
          }
        },
        borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
            border: Border.all(
              color: item.isRead ? RgColors.border : RgColors.primaryAccent.withOpacity(0.3),
            ),
            boxShadow: RgDimensions.cardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.type.color.withOpacity(0.12),
                ),
                child: Icon(
                  item.type.icon,
                  size: 18,
                  color: item.type.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: RgTypography.subheading.copyWith(
                              fontSize: 14,
                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: RgColors.primaryAccent,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: RgTypography.bodySmall.copyWith(
                        color: item.isRead ? RgColors.textSecondary : RgColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      RgFormatters.timeAgo(item.timestamp),
                      style: RgTypography.caption.copyWith(
                        color: RgColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
