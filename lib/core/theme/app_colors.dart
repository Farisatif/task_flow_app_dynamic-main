import 'package:flutter/material.dart';

/// لوحة ألوان التطبيق - مستوحاة من التصميم الأصلي (بنفسجي/أزرق باستيل)
class AppColors {
  AppColors._();

  // ألوان أساسية (Brand)
  static const Color primary = Color(0xFF7B6FF0);
  static const Color primaryLight = Color(0xFFA79BFF);
  static const Color primaryDark = Color(0xFF5A4BD6);
  static const Color secondary = Color(0xFF4FD1C5);
  static const Color accentBlue = Color(0xFF5B9DF9);
  static const Color accentGreen = Color(0xFF4CD787);
  static const Color accentOrange = Color(0xFFFFB258);
  static const Color accentPink = Color(0xFFFF7EB3);
  static const Color accentYellow = Color(0xFFFFD166);

  // أولويات المهام
  static const Color priorityHigh = Color(0xFFFF6B81);
  static const Color priorityMedium = Color(0xFFFFB258);
  static const Color priorityLow = Color(0xFF4CD787);

  // -------- الوضع النهاري --------
  static const Color lightBackground = Color(0xFFF6F5FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFEDEBFB);
  static const Color lightTextPrimary = Color(0xFF231F3D);
  static const Color lightTextSecondary = Color(0xFF8B87A3);
  static const Color lightTextTertiary = Color(0xFFB4B1C8);

  // -------- الوضع الليلي --------
  static const Color darkBackground = Color(0xFF14121F);
  static const Color darkSurface = Color(0xFF1D1A2E);
  static const Color darkCard = Color(0xFF211E36);
  static const Color darkBorder = Color(0xFF322D4C);
  static const Color darkTextPrimary = Color(0xFFF3F2FA);
  static const Color darkTextSecondary = Color(0xFF9C97BC);
  static const Color darkTextTertiary = Color(0xFF6C6790);

  // تدرج الأزرار الرئيسي
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8A7CFF), Color(0xFF6C5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> chartPalette = [
    accentBlue,
    accentGreen,
    accentOrange,
    accentPink,
    primary,
    accentYellow,
  ];
}
