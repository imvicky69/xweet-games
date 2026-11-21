import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/game_colors.dart';

class GameTheme {
  GameTheme._();

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.rajdhaniTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GameColors.background,
      colorScheme: const ColorScheme.dark(
        primary: GameColors.primaryNeon,
        secondary: GameColors.secondaryNeon,
        surface: GameColors.surface,
        error: GameColors.accentRose,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: GameColors.textPrimary,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: GameColors.textPrimary,
          letterSpacing: 1.5,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: GameColors.textPrimary,
          letterSpacing: 1.2,
        ),
        titleLarge: GoogleFonts.rajdhani(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: GameColors.textPrimary,
        ),
        titleMedium: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: GameColors.textSecondary,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 16,
          color: GameColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 14,
          color: GameColors.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: GameColors.textPrimary,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: GameColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: GameColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: GameColors.surfaceBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GameColors.primaryNeon,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
