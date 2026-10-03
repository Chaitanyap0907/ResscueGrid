import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../core/theme/colors.dart';

enum UserRole {
  student,
  responder,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.responder:
        return 'Responder';
      case UserRole.admin:
        return 'Command Center';
    }
  }
}

enum IncidentCategory {
  medical,
  fire,
  securityThreat,
  accident,
  harassment,
  other;

  String get displayName {
    switch (this) {
      case IncidentCategory.medical:
        return 'Medical';
      case IncidentCategory.fire:
        return 'Fire Emergency';
      case IncidentCategory.securityThreat:
        return 'Security Threat';
      case IncidentCategory.accident:
        return 'Accident / Hazard';
      case IncidentCategory.harassment:
        return 'Harassment';
      case IncidentCategory.other:
        return 'Other Emergency';
    }
  }

  IconData get icon {
    switch (this) {
      case IncidentCategory.medical:
        return PhosphorIconsRegular.firstAid;
      case IncidentCategory.fire:
        return PhosphorIconsRegular.flame;
      case IncidentCategory.securityThreat:
        return PhosphorIconsRegular.shieldWarning;
      case IncidentCategory.accident:
        return PhosphorIconsRegular.warningOctagon;
      case IncidentCategory.harassment:
        return PhosphorIconsRegular.handPalm;
      case IncidentCategory.other:
        return PhosphorIconsRegular.bellRinging;
    }
  }

  Color get color {
    switch (this) {
      case IncidentCategory.medical:
        return const Color(0xFFE63946);
      case IncidentCategory.fire:
        return const Color(0xFFF79009);
      case IncidentCategory.securityThreat:
        return const Color(0xFF7A5AF8);
      case IncidentCategory.accident:
        return const Color(0xFFF04438);
      case IncidentCategory.harassment:
        return const Color(0xFFEE46BC);
      case IncidentCategory.other:
        return const Color(0xFF13508F);
    }
  }
}

enum IncidentSeverity {
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case IncidentSeverity.low:
        return 'LOW';
      case IncidentSeverity.medium:
        return 'MEDIUM';
      case IncidentSeverity.high:
        return 'HIGH';
      case IncidentSeverity.critical:
        return 'CRITICAL';
    }
  }

  Color get color {
    switch (this) {
      case IncidentSeverity.low:
        return RgColors.severityLow;
      case IncidentSeverity.medium:
        return RgColors.severityMedium;
      case IncidentSeverity.high:
        return RgColors.severityHigh;
      case IncidentSeverity.critical:
        return RgColors.severityCritical;
    }
  }

  Color get bgColor {
    switch (this) {
      case IncidentSeverity.low:
        return RgColors.severityLowBg;
      case IncidentSeverity.medium:
        return RgColors.severityMediumBg;
      case IncidentSeverity.high:
        return RgColors.severityHighBg;
      case IncidentSeverity.critical:
        return RgColors.severityCriticalBg;
    }
  }

  IconData get icon {
    switch (this) {
      case IncidentSeverity.low:
        return PhosphorIconsRegular.checkCircle;
      case IncidentSeverity.medium:
        return PhosphorIconsRegular.warning;
      case IncidentSeverity.high:
        return PhosphorIconsRegular.warningCircle;
      case IncidentSeverity.critical:
        return PhosphorIconsBold.warningOctagon;
    }
  }
}

enum IncidentStatus {
  reported,
  assigned,
  enRoute,
  arrived,
  resolved,
  escalated;

  String get label {
    switch (this) {
      case IncidentStatus.reported:
        return 'Reported';
      case IncidentStatus.assigned:
        return 'Assigned';
      case IncidentStatus.enRoute:
        return 'En Route';
      case IncidentStatus.arrived:
        return 'Arrived';
      case IncidentStatus.resolved:
        return 'Resolved';
      case IncidentStatus.escalated:
        return 'Escalated';
    }
  }

  int get stepIndex {
    switch (this) {
      case IncidentStatus.reported:
        return 0;
      case IncidentStatus.assigned:
        return 1;
      case IncidentStatus.enRoute:
        return 2;
      case IncidentStatus.arrived:
        return 3;
      case IncidentStatus.resolved:
        return 4;
      case IncidentStatus.escalated:
        return 1;
    }
  }

  Color get color => RgColors.statusColor(label);
  Color get bgColor => RgColors.statusBgColor(label);
}

enum DutyStatus {
  onDuty,
  breakTime,
  offDuty;

  String get label {
    switch (this) {
      case DutyStatus.onDuty:
        return 'On Duty';
      case DutyStatus.breakTime:
        return 'On Break';
      case DutyStatus.offDuty:
        return 'Off Duty';
    }
  }

  Color get color {
    switch (this) {
      case DutyStatus.onDuty:
        return RgColors.success;
      case DutyStatus.breakTime:
        return RgColors.warning;
      case DutyStatus.offDuty:
        return RgColors.textSecondary;
    }
  }
}

enum ResponderType {
  medical,
  security,
  fire;

  String get label {
    switch (this) {
      case ResponderType.medical:
        return 'Campus Medic';
      case ResponderType.security:
        return 'Security Officer';
      case ResponderType.fire:
        return 'Fire Warden';
    }
  }

  String get displayName => label;

  IconData get icon {
    switch (this) {
      case ResponderType.medical:
        return PhosphorIconsRegular.firstAid;
      case ResponderType.security:
        return PhosphorIconsRegular.shieldCheck;
      case ResponderType.fire:
        return PhosphorIconsRegular.flame;
    }
  }
}
