import 'package:flutter/material.dart';

@immutable
class CircleThemeColors extends ThemeExtension<CircleThemeColors> {
  const CircleThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.inputBorder,
    required this.inputFocusedBorder,
    required this.divider,
    required this.glassOverlay,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color inputBorder;
  final Color inputFocusedBorder;
  final Color divider;
  final Color glassOverlay;

  @override
  CircleThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? inputBorder,
    Color? inputFocusedBorder,
    Color? divider,
    Color? glassOverlay,
  }) {
    return CircleThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFocusedBorder: inputFocusedBorder ?? this.inputFocusedBorder,
      divider: divider ?? this.divider,
      glassOverlay: glassOverlay ?? this.glassOverlay,
    );
  }

  @override
  CircleThemeColors lerp(ThemeExtension<CircleThemeColors>? other, double t) {
    if (other is! CircleThemeColors) {
      return this;
    }

    return CircleThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputFocusedBorder: Color.lerp(
        inputFocusedBorder,
        other.inputFocusedBorder,
        t,
      )!,
      divider: Color.lerp(divider, other.divider, t)!,
      glassOverlay: Color.lerp(glassOverlay, other.glassOverlay, t)!,
    );
  }
}
