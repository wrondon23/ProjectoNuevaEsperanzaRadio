import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.textPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.cardBackground,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20)), // Rounded corners as per request
      margin: EdgeInsets.zero,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
        .copyWith(
          displayLarge: const TextStyle(fontWeight: FontWeight.bold),
          displayMedium: const TextStyle(fontWeight: FontWeight.bold),
          headlineMedium: const TextStyle(fontWeight: FontWeight.w700),
          titleLarge: const TextStyle(
              fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          bodyMedium: const TextStyle(color: AppColors.textPrimary),
          bodySmall: const TextStyle(color: AppColors.textSecondary),
        )
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.drawerBackground,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.drawerBackground,
      scrimColor: Colors.black54,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.drawerBackground,
      selectedItemColor: AppColors.primary, // Electric Blue
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  );

  // We are forcing Dark Theme now, so Light Theme maps to Dark or is removed.
  // For safety, we make lightTheme point to darkTheme or a light variation if strictly needed.
  // Given the request "change the look", we'll just align both to the new design system or keep standard light.
  // User asked for specific look (Dark), so we'll standardize on Dark for now or updated Light.
  // Let's update Light to match new brand colors if they toggle it, but preferably app should be Dark.
  static final ThemeData lightTheme = darkTheme;
}
