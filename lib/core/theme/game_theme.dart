import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/game_colors.dart';

class GameTheme {
  GameTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: GameColors.paper,
      colorScheme: const ColorScheme.light(
        primary: GameColors.carbon,
        secondary: GameColors.signalLime,
        tertiary: GameColors.mist,
        surface: GameColors.paper,
        error: GameColors.error,
        onPrimary: GameColors.paper,
        onSecondary: GameColors.carbon,
        onSurface: GameColors.carbon,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: GameColors.carbon,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: GameColors.carbon,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: GameColors.carbon,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: GameColors.carbon,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: GameColors.carbon,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: GameColors.terrain,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: GameColors.carbon,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: GameColors.terrain,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: GameColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: GameColors.carbon,
        ),
        iconTheme: const IconThemeData(color: GameColors.carbon),
      ),
      cardTheme: CardThemeData(
        color: GameColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: GameColors.borderMuted, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GameColors.signalLime,
          foregroundColor: GameColors.carbon,
          elevation: 0,
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: GameColors.carbon, width: 1.4),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GameColors.carbon,
          side: const BorderSide(color: GameColors.carbon, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: GameColors.borderMuted,
        thickness: 1,
      ),
    );
  }
}
