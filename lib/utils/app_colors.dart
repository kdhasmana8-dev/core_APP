import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryOrange = Color(0xFFFF8C1A);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Background & Surface
  static const Color background = Color(0xFF050505);
  static const Color cardSurface = Color(0xFF111111);

  // UI Elements
  static const Color borderStroke = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure White
  static const Color textSecondary = Color(0xFFA1A1A1);

  // Cinematic Gradient (As specified in section 02)
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment(-0.7, -0.7), // Approximation of 135deg
    end: Alignment(0.7, 0.7),
    colors: [
      Color(0xFF1A1A1A),
      Color(0x33FF8C1A), // #FF8C1A at 20% opacity
    ],
  );
}