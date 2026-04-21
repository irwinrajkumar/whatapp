import 'package:flutter/material.dart';

class AppColors {
  // WhatsApp brand colors
  static const Color darkGreen = Color(0xFF075E54);
  static const Color secondaryGreen = Color(0xFF128C7E);
  static const Color lightGreen = Color(0xFF25D366);
  static const Color blue = Color(0xFF34B7F1);

  // WhatsApp Dark Theme colors
  static const Color bgDark = Color(0xFF0B141B);
  static const Color surfaceDark = Color(0xFF1B272E);
  static const Color textDarkPrimary = Colors.white;
  static const Color textDarkSecondary = Color(0xFF8696A0);

  // WhatsApp Light Theme colors
  static const Color bgLight = Colors.white;
  static const Color surfaceLight = Colors.white;
  static const Color textLightPrimary = Color(0xFF111B21);
  static const Color textLightSecondary = Color(0xFF667781);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    primaryColor: AppColors.secondaryGreen,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textDarkSecondary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.secondaryGreen,
      secondary: AppColors.lightGreen,
      surface: AppColors.surfaceDark,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.lightGreen,
      unselectedLabelColor: AppColors.textDarkSecondary,
      indicatorColor: AppColors.lightGreen,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightGreen,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgLight,
    primaryColor: AppColors.darkGreen,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkGreen,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.darkGreen,
      secondary: AppColors.lightGreen,
      surface: AppColors.surfaceLight,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondaryGreen,
      foregroundColor: Colors.white,
    ),
  );
}
