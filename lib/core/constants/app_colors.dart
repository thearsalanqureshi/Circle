import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const transparent = Color(0x00000000);

  static const darkBackground = Color(0xFF090909);
  static const darkSurface = Color(0xFF111111);
  static const darkSurfaceHigh = Color(0xFF151515);
  static const darkTextPrimary = Color(0xE6FFFFFF);
  static const darkTextSecondary = Color(0xB3FFFFFF);
  static const darkTextMuted = Color(0x80FFFFFF);
  static const darkInputBorder = Color(0x7AFFFFFF);
  static const darkInputFocusedBorder = Color(0xC7FFFFFF);

  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceHigh = Color(0xFFF4F2F7);
  static const lightTextPrimary = Color(0xFF111111);
  static const lightTextSecondary = Color(0xFF555555);
  static const lightTextMuted = Color(0xFF888888);
  static const lightInputBorder = Color(0xFFD4D0DA);
  static const lightInputFocusedBorder = Color(0xFF8C7AA4);

  static const accentOrange = Color(0xFFFF6320);
  static const accentPink = Color(0xFFB63B7A);
  static const accentPurple = Color(0xFF8E25C7);
  static const accentPurpleSoft = Color(0xFFE27CFF);
  static const accentWarm = Color(0xFFFFA236);
  static const accentDeepOrange = Color(0xFFFF6416);

  static const primaryGradient = LinearGradient(
    colors: [accentOrange, accentPink],
  );

  static const purpleGlowGradient = RadialGradient(
    center: Alignment(-0.2, -0.25),
    radius: 0.78,
    colors: [accentPurpleSoft, accentPurple, darkSurfaceHigh],
  );

  static const orangeGlowGradient = RadialGradient(
    center: Alignment(-0.2, -0.25),
    radius: 0.78,
    colors: [accentWarm, accentDeepOrange, darkSurfaceHigh],
  );
}
