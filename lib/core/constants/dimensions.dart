import 'package:flutter/material.dart';

/// 8px Spacing Grid, Radii, and Elevation definitions
class RgDimensions {
  RgDimensions._();

  // Spacing
  static const double p2 = 2.0;
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;
  static const double p64 = 64.0;

  // Radii
  static const double radiusSmall = 8.0;
  static const double radiusInput = 12.0;
  static const double radiusButton = 14.0;
  static const double radiusCard = 16.0;
  static const double radiusDialog = 20.0;
  static const double radiusSheet = 24.0;
  static const double radiusFull = 999.0;

  // Component heights
  static const double buttonHeight = 52.0;
  static const double buttonHeightSmall = 40.0;
  static const double inputHeight = 52.0;
  static const double iconContainerSize = 40.0;
  static const double sosButtonSize = 168.0;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A101828), // 4% opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x05101828), // 2% opacity
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x14101828), // 8% opacity
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A101828),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> sosPulseShadow = [
    BoxShadow(
      color: Color(0x40E63946),
      blurRadius: 24,
      spreadRadius: 4,
    ),
  ];

  // Breakpoints
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
}
