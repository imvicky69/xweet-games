import 'package:flutter/material.dart';

class GameColors {
  GameColors._();

  // Dark gaming background shades
  static const Color background = Color(0xFF0A0C14);
  static const Color surface = Color(0xFF131722);
  static const Color surfaceLight = Color(0xFF1D2333);
  static const Color surfaceBorder = Color(0xFF2B3347);

  // Vibrant neon game accents
  static const Color primaryNeon = Color(0xFF00F0FF); // Cyber Cyan
  static const Color secondaryNeon = Color(0xFFB026FF); // Electric Violet
  static const Color accentAmber = Color(0xFFFFB800); // Radiant Gold
  static const Color accentEmerald = Color(0xFF00FFA3); // Neon Green
  static const Color accentRose = Color(0xFFFF2A6D); // Cyber Magenta

  // Text colors
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFFB026FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF171B29), Color(0xFF10131E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF8A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
