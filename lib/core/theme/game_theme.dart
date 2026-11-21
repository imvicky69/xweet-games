import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/game_colors.dart';

class GameTheme {
  GameTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.spaceGroteskTextTheme(
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
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: GameColors.carbon,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: GameColors.carbon,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: GameColors.carbon,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: GameColors.carbon,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          color: GameColors.carbon,
        ),
        bodyMedium: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          color: GameColors.terrain,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: GameColors.carbon,
        ),
        labelSmall: GoogleFonts.spaceMono(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: GameColors.terrain,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: GameColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.bold,
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
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50), // Fully rounded pill shape
            side: const BorderSide(color: GameColors.carbon, width: 1.2),
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
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: GameColors.surfaceWhite,
        selectedItemColor: GameColors.carbon,
        unselectedItemColor: GameColors.terrain,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: DividerThemeData(
        color: GameColors.borderMuted,
        thickness: 1,
      ),
    );
  }
}
