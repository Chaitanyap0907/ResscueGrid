import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../core/theme/colors.dart';
import 'enums.dart';

class TimelineEvent {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final IncidentStatus status;
  final String? actorName;
  final String? actorRole;

  const TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
    this.actorName,
    this.actorRole,
  });

  IconData get icon {
    switch (status) {
      case IncidentStatus.reported:
        return PhosphorIconsRegular.paperPlaneTilt;
      case IncidentStatus.assigned:
        return PhosphorIconsRegular.userCheck;
      case IncidentStatus.enRoute:
        return PhosphorIconsRegular.navigationArrow;
      case IncidentStatus.arrived:
        return PhosphorIconsRegular.mapPin;
      case IncidentStatus.resolved:
        return PhosphorIconsRegular.checkCircle;
      case IncidentStatus.escalated:
        return PhosphorIconsRegular.warning;
    }
  }

  Color get color {
    switch (status) {
      case IncidentStatus.reported:
        return RgColors.warning;
      case IncidentStatus.assigned:
        return RgColors.info;
      case IncidentStatus.enRoute:
        return RgColors.primaryAccent;
      case IncidentStatus.arrived:
        return const Color(0xFF7A5AF8);
      case IncidentStatus.resolved:
        return RgColors.success;
      case IncidentStatus.escalated:
        return RgColors.error;
    }
  }
}
