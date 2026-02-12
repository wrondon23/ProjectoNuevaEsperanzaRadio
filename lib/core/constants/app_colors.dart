import 'package:flutter/material.dart';

class AppColors {
  // New Modern Dark Theme Colors

  // Backgrounds
  static const Color background =
      Color(0xFF101922); // Main Background (from HTML)
  static const Color error = Color(0xFFFF3B30); // Red
  static const Color cardBackground =
      Color(0xFF16202a); // Card Background (Derived)
  static const Color drawerBackground =
      Color(0xFF101922); // Match Main Background

  // Accents & Borders
  static const Color primary = Color(0xFF2B8CEE); // Electric Blue (from HTML)
  static const Color secondary = Color(
      0xFFD4AF37); // Gold (Keeping for "En Vivo" contrast if needed, or replace)
  static const Color tertiary =
      Color(0xFF66A5AD); // Keeping for legacy reference if needed

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFA0A8B8); // Grey/Blue

  // Status
  static const Color online = Color(0xFFFF3B30); // Red for "LIVE" badge
  static const Color offline = Color(0xFF9E9E9E);
  static const Color buffering = Color(0xFF3399FF);
}
