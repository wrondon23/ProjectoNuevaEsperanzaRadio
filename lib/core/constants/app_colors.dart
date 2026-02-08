import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Updated for Dark Teal / Gold / Cream look)
  static const Color primary = Color(0xFF003B46); // Deep Teal (Backgrounds)
  static const Color secondary = Color(0xFFC5A065); // Gold / Metallic (Accents)
  static const Color tertiary =
      Color(0xFF66A5AD); // Lighter Teal (Secondary accents)

  // Backgrounds
  static const Color backgroundLight =
      Color(0xFFFFFDE7); // Cream / Pale Yellow (Cards)
  static const Color backgroundDark = Color(0xFF07575B); // Dark Teal (Scaffold)

  // Cards / Surface
  static const Color surfaceLight = Color(0xFFFFFDE7); // Cream
  static const Color surfaceDark = Color(0xFF003B46); // Deep Teal

  // Text
  static const Color textLight =
      Color(0xFF003B46); // Deep Teal for light backgrounds
  static const Color textDark = Color(0xFFFFFDE7); // Cream for dark backgrounds

  // Status
  static const Color online = Color(0xFFC5A065); // Gold
  static const Color offline = Color(0xFF9E9E9E); // Grey
  static const Color buffering = Color(0xFF66A5AD); // Lighter Teal
}
