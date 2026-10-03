import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// RescueGrid Typography System using Inter
class RgTypography {
  RgTypography._();

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: RgColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.25,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: RgColors.textPrimary,
        letterSpacing: -0.4,
        height: 1.3,
      );

  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: RgColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.35,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: RgColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.4,
      );

  static TextStyle get subheading => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: RgColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: RgColors.textPrimary,
        height: 1.45,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: RgColors.textPrimary,
        height: 1.45,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: RgColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: RgColors.textSecondary,
        height: 1.35,
      );

  static TextStyle get badgeLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        height: 1.2,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.2,
      );

  static TextStyle get kpiNumber => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: RgColors.textPrimary,
        letterSpacing: -0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get kpiNumberSmall => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: RgColors.textPrimary,
        letterSpacing: -0.3,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        titleLarge: headingMedium,
        titleMedium: subheading,
        titleSmall: subheading.copyWith(fontSize: 14),
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: button,
        labelMedium: caption,
        labelSmall: badgeLabel,
      );
}
