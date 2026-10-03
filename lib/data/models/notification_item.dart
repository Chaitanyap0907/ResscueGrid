import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../core/theme/colors.dart';

enum NotificationType {
  assignment,
  escalation,
  statusChange,
  backupRequest,
  alert;

  IconData get icon {
    switch (this) {
      case NotificationType.assignment:
        return PhosphorIconsRegular.userCheck;
      case NotificationType.escalation:
        return PhosphorIconsRegular.warning;
      case NotificationType.statusChange:
        return PhosphorIconsRegular.arrowsClockwise;
      case NotificationType.backupRequest:
        return PhosphorIconsRegular.users;
      case NotificationType.alert:
        return PhosphorIconsRegular.bellRinging;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.assignment:
        return RgColors.info;
      case NotificationType.escalation:
        return RgColors.error;
      case NotificationType.statusChange:
        return RgColors.primaryAccent;
      case NotificationType.backupRequest:
        return RgColors.warning;
      case NotificationType.alert:
        return RgColors.secondary;
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? incidentId;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.incidentId,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      type: type,
      isRead: isRead ?? this.isRead,
      incidentId: incidentId,
    );
  }
}
