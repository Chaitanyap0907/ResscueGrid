import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import '../constants/dimensions.dart';

/// Complete Material 3 ThemeData definition for RescueGrid
class RgTheme {
  RgTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: RgColors.primary,
      onPrimary: Colors.white,
      primaryContainer: RgColors.primaryLight,
      onPrimaryContainer: RgColors.primary,
      secondary: RgColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: RgColors.secondaryLight,
      onSecondaryContainer: RgColors.secondaryDark,
      surface: RgColors.surface,
      onSurface: RgColors.textPrimary,
      error: RgColors.error,
      onError: Colors.white,
      outline: RgColors.border,
      outlineVariant: RgColors.borderStrong,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: RgColors.background,
      fontFamily: RgTypography.bodyMedium.fontFamily,
      textTheme: RgTypography.textTheme,
      dividerTheme: const DividerThemeData(
        color: RgColors.divider,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: RgColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: RgTypography.headingMedium,
        iconTheme: const IconThemeData(color: RgColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: RgColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
          side: const BorderSide(color: RgColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RgColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(RgDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RgDimensions.radiusButton),
          ),
          textStyle: RgTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RgColors.primary,
          minimumSize: const Size.fromHeight(RgDimensions.buttonHeight),
          side: const BorderSide(color: RgColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RgDimensions.radiusButton),
          ),
          textStyle: RgTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RgColors.primaryAccent,
          textStyle: RgTypography.button.copyWith(fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RgDimensions.radiusSmall),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RgColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: RgTypography.bodyMedium.copyWith(color: RgColors.textMuted),
        labelStyle: RgTypography.bodyMedium.copyWith(color: RgColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
          borderSide: const BorderSide(color: RgColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
          borderSide: const BorderSide(color: RgColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
          borderSide: const BorderSide(color: RgColors.primaryAccent, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
          borderSide: const BorderSide(color: RgColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
          borderSide: const BorderSide(color: RgColors.error, width: 1.8),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RgDimensions.radiusSheet),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: RgColors.borderStrong,
        dragHandleSize: Size(44, 4),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RgDimensions.radiusDialog),
        ),
        titleTextStyle: RgTypography.headingMedium,
        contentTextStyle: RgTypography.bodyMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: RgColors.primaryLight,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return RgTypography.caption.copyWith(
              color: RgColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return RgTypography.caption.copyWith(
            color: RgColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: RgColors.primary, size: 24);
          }
          return const IconThemeData(color: RgColors.textSecondary, size: 24);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: RgColors.primary,
        elevation: 0,
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 24),
        unselectedIconTheme: const IconThemeData(color: Color(0xFF8DA4C4), size: 24),
        selectedLabelTextStyle: RgTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: RgTypography.caption.copyWith(
          color: const Color(0xFF8DA4C4),
        ),
        indicatorColor: RgColors.primaryAccent,
      ),
    );
  }
}
