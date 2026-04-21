import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bgDark   = Color(0xFF070D1C);
  static const Color surface  = Color(0xFF0C1629);
  static const Color cardDark = Color(0xFF101E35);
  static const Color card2    = Color(0xFF162540);
  static const Color navBg    = Color(0xFF050A17);

  // Brand
  static const Color gold     = Color(0xFFF4A623);
  static const Color goldDim  = Color(0xFFC4831A);

  // Accents
  static const Color blue     = Color(0xFF2B5CE6);
  static const Color blueDark = Color(0xFF1A3FA8);
  static const Color violet   = Color(0xFF7C3AED);
  static const Color pink     = Color(0xFFEC4899);

  // Semantic
  static const Color success  = Color(0xFF10B981);
  static const Color danger   = Color(0xFFE24B4A);
  static const Color warning  = Color(0xFFF59E0B);

  // Text
  static const Color white         = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color muted         = Color(0xFF7B8FA6);
  static const Color mutedDark     = Color(0xFF4A5568);

  // Borders
  static const Color border  = Color(0x12FFFFFF);
  static const Color border2 = Color(0x1FFFFFFF);

  // Light theme
  static const Color bgLight       = Color(0xFFF8FAFC);
  static const Color surfaceLight  = Color(0xFFFFFFFF);
  static const Color cardLight     = Color(0xFFF1F5F9);
  static const Color textDark      = Color(0xFF0F172A);
  static const Color borderLight   = Color(0xFFE2E8F0);

  // Gradients
  static const LinearGradient verseGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0F2356), Color(0xFF0A1A3F), Color(0xFF081230)],
    stops: [0.0, 0.55, 1.0],
  );
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1D3A7A), Color(0xFF2B5CE6)],
  );
  static const LinearGradient violetGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
  );
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1C0A2E), Color(0xFF2A0E42)],
  );
  static const LinearGradient featuredGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0A1C3E), Color(0xFF162C5C)],
  );
  static const LinearGradient playerGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0E1F46), Color(0xFF0A1530)],
  );
}
