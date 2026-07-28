import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color primaryText, Color secondaryText) {
    final base = GoogleFonts.tajawalTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: primaryText, fontWeight: FontWeight.bold),
      headlineLarge: base.headlineLarge?.copyWith(color: primaryText, fontWeight: FontWeight.bold),
      headlineMedium: base.headlineMedium?.copyWith(color: primaryText, fontWeight: FontWeight.bold),
      headlineSmall: base.headlineSmall?.copyWith(color: primaryText, fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(color: primaryText, fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(color: primaryText),
      bodyMedium: base.bodyMedium?.copyWith(color: secondaryText),
      bodySmall: base.bodySmall?.copyWith(color: secondaryText),
      labelLarge: base.labelLarge?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.priorityHigh,
      ),
      textTheme: _textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.lightTextPrimary,
        centerTitle: false,
      ),
      dividerColor: AppColors.lightBorder,
      iconTheme: const IconThemeData(color: AppColors.lightTextSecondary),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightTextTertiary,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primaryLight,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.priorityHigh,
      ),
      textTheme: _textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.darkTextPrimary,
        centerTitle: false,
      ),
      dividerColor: AppColors.darkBorder,
      iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkTextTertiary,
      ),
    );
  }
}
