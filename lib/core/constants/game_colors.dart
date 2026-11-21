import 'package:flutter/material.dart';

/// Editorial Design Tokens matching Xweet Wordle Specification
/// Strict Tactile Editorial Light Mode (artisanal cartography & telemetry)
class GameColors {
  GameColors._();

  // Core Palette Tokens
  static const Color carbon = Color(0xFF171815); // Primary typography, dark buttons, high-contrast borders
  static const Color paper = Color(0xFFF0EFE6); // Default canvas background, card surfaces, modal background
  static const Color signalLime = Color(0xFFD7F36A); // Primary CTA buttons, correct letter tiles, active indicators
  static const Color terrain = Color(0xFF858779); // Secondary labels, borders, coordinate grids, absent keys
  static const Color mist = Color(0xFFB7A7D9); // Present letter tiles (Misplaced), soft badges, subtle clues

  // Clean White Surface (for bottom bar and crisp cards)
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // Derived Semantic Surface & Alpha Accents
  static Color get borderMuted => terrain.withValues(alpha: 0.25);
  static Color get borderActive => carbon.withValues(alpha: 0.60);
  static Color get keyDefaultBg => const Color(0xFFFFFFFF).withValues(alpha: 0.90);
  static Color get keyAbsentBg => terrain.withValues(alpha: 0.25);
  static Color get keyAbsentText => terrain.withValues(alpha: 0.60);
  static Color get surfaceGlass => paper.withValues(alpha: 0.92);

  // Text Colors
  static const Color textPrimary = carbon;
  static const Color textSecondary = terrain;
  static const Color textMuted = Color(0xFFA1A396);

  // Status & Utility Colors
  static const Color success = signalLime;
  static const Color warning = Color(0xFFE5A93C);
  static const Color error = Color(0xFFE25555);
}
