// ============================================================
// app_colors.dart - Centralized Color Palette
// Place this file at: lib/utils/app_colors.dart
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  // Primary brand color - deep indigo blue
  static const Color primary = Color(0xFF1A3C6E);

  // Accent color - vibrant orange for CTAs
  static const Color accent = Color(0xFFE8602C);

  // Light background
  static const Color background = Color(0xFFF4F6FA);

  // Card background
  static const Color cardBg = Colors.white;

  // Text colors
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMedium = Color(0xFF5A5A7A);
  static const Color textLight = Color(0xFF9A9AB0);

  // Border color
  static const Color border = Color(0xFFE0E4EF);

  // Department badge colors
  static const Color deptCS = Color(0xFF3B82F6);
  static const Color deptECE = Color(0xFF8B5CF6);
  static const Color deptMech = Color(0xFFEF4444);
  static const Color deptCivil = Color(0xFF10B981);
  static const Color deptMBA = Color(0xFFF59E0B);

  // Success, warning, error
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Gradient for cards and banners
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3C6E), Color(0xFF2563EB)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8602C), Color(0xFFFF8C42)],
  );
}
