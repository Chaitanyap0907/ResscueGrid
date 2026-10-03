import 'package:flutter/material.dart';

/// RescueGrid Design System Color Tokens
/// Design Direction: "Calm authority"
/// Dark navy base conveys trust and institutional control;
/// Alert red is reserved strictly for SOS, critical severity, and emergency actions.
class RgColors {
  RgColors._();

  // Core Brand
  static const Color primary = Color(0xFF0B2545); // Deep Navy
  static const Color primaryAccent = Color(0xFF13508F); // Links, active nav, selected
  static const Color primaryLight = Color(0xFFE8EEF5); // Very light navy tint
  static const Color secondary = Color(0xFFE63946); // Alert Red (SOS / Critical)
  static const Color secondaryDark = Color(0xFFB42318); // Dark Red (Critical badge)
  static const Color secondaryLight = Color(0xFFFEE4E2); // Alert red tint

  // Background & Surfaces
  static const Color background = Color(0xFFF4F6FA); // Soft cool screen background
  static const Color surface = Color(0xFFFFFFFF); // Card, sheet, dialog surface
  static const Color surfaceMuted = Color(0xFFF9FAFB); // Input backgrounds, inactive
  static const Color surfaceDark = Color(0xFF0F172A); // Dark slate for command overlays

  // Typography & Content
  static const Color textPrimary = Color(0xFF101828); // Primary headings and body
  static const Color textSecondary = Color(0xFF667085); // Captions, subtitles, hints
  static const Color textMuted = Color(0xFF98A2B3); // Disabled or placeholder text
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFE4E7EC); // Standard card & divider border
  static const Color borderStrong = Color(0xFFD0D5DD); // Focused or elevated borders
  static const Color divider = Color(0xFFF2F4F7);

  // Semantic Status Colors
  static const Color success = Color(0xFF12B76A); // Resolved, on duty, low severity
  static const Color statusSuccess = success; // Backward-compatible alias
  static const Color successLight = Color(0xFFECFDF3);
  static const Color warning = Color(0xFFF79009); // Escalated, backup, medium severity
  static const Color warningLight = Color(0xFFFEF0C7);
  static const Color error = Color(0xFFD92D20); // Failures, errors, high severity
  static const Color errorLight = Color(0xFFFEE4E2);
  static const Color info = Color(0xFF2E90FA); // Assigned, informative
  static const Color infoLight = Color(0xFFEFF8FF);

  // Severity Scale
  static const Color severityLow = Color(0xFF12B76A);
  static const Color severityLowBg = Color(0xFFECFDF3);

  static const Color severityMedium = Color(0xFFF79009);
  static const Color severityMediumBg = Color(0xFFFEF0C7);

  static const Color severityHigh = Color(0xFFF04438);
  static const Color severityHighBg = Color(0xFFFEE4E2);

  static const Color severityCritical = Color(0xFFB42318);
  static const Color severityCriticalBg = Color(0xFFFEE4E2);

  // Helper getters for incident status
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
        return warning;
      case 'assigned':
        return info;
      case 'en route':
      case 'enroute':
        return primaryAccent;
      case 'arrived':
        return const Color(0xFF7A5AF8); // Purple accent for on-scene
      case 'resolved':
        return success;
      case 'escalated':
        return error;
      default:
        return textSecondary;
    }
  }

  static Color statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
        return warningLight;
      case 'assigned':
        return infoLight;
      case 'en route':
      case 'enroute':
        return primaryLight;
      case 'arrived':
        return const Color(0xFFF4F3FF);
      case 'resolved':
        return successLight;
      case 'escalated':
        return errorLight;
      default:
        return surfaceMuted;
    }
  }
}
