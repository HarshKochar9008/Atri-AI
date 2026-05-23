import 'package:flutter/material.dart';

/// Central color palette for the app.
/// Use these or Theme.of(context).colorScheme / theme extensions for consistency.
abstract class AppColors {
  AppColors._();

  // Core violet palette (existing names kept for back-compat).
  static const Color headerViolet = Color.fromARGB(255, 55, 16, 128);
  static const Color accentViolet = Color(0xFFB39DFF);
  static const Color surfaceBlack = Color(0xFF0A0612);
  static const Color cardDark = Color(0xFF181229);

  // Borders.
  static const Color borderDark = Color(0xFF2A2245);
  static const Color inputBorderDark = Color(0xFF37346E);

  // Secondary / unselected text.
  static const Color unselectedDark = Color(0xFF8A85C2);

  // Chart paper.
  static const Color chartBackground = Color(0xFFF5F0E6);

  // Cosmic palette additions.
  /// Deep space — used at the bottom of cosmic gradients.
  static const Color deepSpace = Color(0xFF050211);

  /// Midnight indigo — gradient midpoint.
  static const Color midnightIndigo = Color(0xFF1A0E3F);

  /// Nebula pink — accent for highlight halos.
  static const Color nebulaPink = Color(0xFFE89BFF);

  /// Starlight — for star dots and subtle accents.
  static const Color starlight = Color(0xFFF6F1FF);

  /// Twilight — used for subtle glass card overlays.
  static const Color twilight = Color(0xFF24193F);

  /// Cosmic gradient for full-screen backgrounds (top → bottom).
  static const List<Color> cosmicGradient = [
    Color(0xFF1A0E3F), // midnight indigo
    Color(0xFF0F0824), // deep violet
    Color(0xFF050211), // deep space
  ];

  /// Cosmic gradient for the light theme background.
  static const List<Color> cosmicGradientLight = [
    Color(0xFFF5F0FF),
    Color(0xFFEDE6FF),
    Color(0xFFF8F4FF),
  ];
}
