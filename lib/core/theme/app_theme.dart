import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'circle_theme_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const circleColors = CircleThemeColors(
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      surfaceHigh: AppColors.darkSurfaceHigh,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      textMuted: AppColors.darkTextMuted,
      inputBorder: AppColors.darkInputBorder,
      inputFocusedBorder: AppColors.darkInputFocusedBorder,
      divider: Color(0x1AFFFFFF),
      glassOverlay: Color(0x2E000000),
    );

    return _baseTheme(
      brightness: Brightness.dark,
      circleColors: circleColors,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentOrange,
        secondary: AppColors.accentPink,
        surface: AppColors.darkSurface,
      ),
    );
  }

  static ThemeData get light {
    const circleColors = CircleThemeColors(
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      surfaceHigh: AppColors.lightSurfaceHigh,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      textMuted: AppColors.lightTextMuted,
      inputBorder: AppColors.lightInputBorder,
      inputFocusedBorder: AppColors.lightInputFocusedBorder,
      divider: Color(0x1F111111),
      glassOverlay: Color(0xBFFFFFFF),
    );

    return _baseTheme(
      brightness: Brightness.light,
      circleColors: circleColors,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentOrange,
        secondary: AppColors.accentPink,
        surface: AppColors.lightSurface,
      ),
    );
  }

  static ThemeData _baseTheme({
    required Brightness brightness,
    required CircleThemeColors circleColors,
    required ColorScheme colorScheme,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: circleColors.background,
    );

    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: circleColors.textPrimary,
      displayColor: circleColors.textPrimary,
    );

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[circleColors],
      textTheme: textTheme,
      dividerColor: circleColors.divider,
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: circleColors.textSecondary,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: circleColors.inputBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(
            color: circleColors.inputFocusedBorder,
            width: 0.9,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: circleColors.surfaceHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: circleColors.textPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppSizes.bottomNavHeight,
        backgroundColor: circleColors.surface,
        indicatorColor: AppColors.accentPink.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? circleColors.textPrimary : circleColors.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? circleColors.textPrimary : circleColors.textMuted,
          );
        }),
      ),
    );
  }
}
