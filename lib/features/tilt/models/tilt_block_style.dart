import 'package:flutter/material.dart';

/// Architectural building floor visual styles matching the Xweet minimalist aesthetic
class TiltBlockStyle {
  final String name;
  final Color baseColor;
  final Color shadowColor;
  final Color windowColor;
  final Color windowFrameColor;
  final Color accentColor;
  final int windowCount;
  final bool hasBalcony;
  final bool isRoof;

  const TiltBlockStyle({
    required this.name,
    required this.baseColor,
    required this.shadowColor,
    required this.windowColor,
    required this.windowFrameColor,
    required this.accentColor,
    required this.windowCount,
    this.hasBalcony = false,
    this.isRoof = false,
  });

  // Architectural Concrete & Masonry Palette
  static const Color ivoryBg = Color(0xFFF5F3ED);
  static const Color mutedForest = Color(0xFF344D3B);
  static const Color carbon = Color(0xFF171815);

  static const TiltBlockStyle foundation = TiltBlockStyle(
    name: 'Foundation Pedestal',
    baseColor: Color(0xFFD3D0C6),
    shadowColor: Color(0xFFBFBCB1),
    windowColor: Color(0xFFE5E3DC),
    windowFrameColor: Color(0xFF858779),
    accentColor: mutedForest,
    windowCount: 0,
  );

  static const List<TiltBlockStyle> floorStyles = [
    TiltBlockStyle(
      name: 'Concrete Module Alpha',
      baseColor: Color(0xFFE8E5DD),
      shadowColor: Color(0xFFD4D0C4),
      windowColor: Color(0xFFF2F6F8),
      windowFrameColor: Color(0xFF858779),
      accentColor: mutedForest,
      windowCount: 4,
    ),
    TiltBlockStyle(
      name: 'Linear Rib Concrete',
      baseColor: Color(0xFFDFDCD3),
      shadowColor: Color(0xFFCAC5B8),
      windowColor: Color(0xFFF7F8F4),
      windowFrameColor: Color(0xFF858779),
      accentColor: mutedForest,
      windowCount: 4,
      hasBalcony: true,
    ),
    TiltBlockStyle(
      name: 'Brutalist Paneled',
      baseColor: Color(0xFFE2DFD6),
      shadowColor: Color(0xFFCEC9BD),
      windowColor: Color(0xFFF5F5EF),
      windowFrameColor: Color(0xFF2A2D25),
      accentColor: mutedForest,
      windowCount: 5,
    ),
    TiltBlockStyle(
      name: 'Forest Accent Studio',
      baseColor: Color(0xFFDEE4DB),
      shadowColor: Color(0xFFCCD4C8),
      windowColor: Color(0xFFF8FAF6),
      windowFrameColor: Color(0xFF344D3B),
      accentColor: mutedForest,
      windowCount: 4,
      hasBalcony: true,
    ),
    TiltBlockStyle(
      name: 'Monolithic Glaze',
      baseColor: Color(0xFFE6E5DE),
      shadowColor: Color(0xFFD2D0C6),
      windowColor: Color(0xFFEEF5FA),
      windowFrameColor: Color(0xFF5A6356),
      accentColor: mutedForest,
      windowCount: 6,
    ),
    TiltBlockStyle(
      name: 'Terracotta Strata Studio',
      baseColor: Color(0xFFE8E2D7),
      shadowColor: Color(0xFFD5CCBE),
      windowColor: Color(0xFFFFF7EA),
      windowFrameColor: Color(0xFF6B5848),
      accentColor: mutedForest,
      windowCount: 4,
      hasBalcony: true,
    ),
  ];

  static TiltBlockStyle forFloor(int floorNumber) {
    if (floorNumber <= 0) return foundation;
    final index = (floorNumber - 1) % floorStyles.length;
    return floorStyles[index];
  }
}
