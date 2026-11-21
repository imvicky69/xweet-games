import 'package:flutter/material.dart';

enum GameCategory {
  all('All Expeditions'),
  lexical('Lexical & Word'),
  puzzle('Puzzle & Logic'),
  arcade('Tactile Arcade');

  final String label;
  const GameCategory(this.label);
}

class GameModel {
  final String id;
  final String title;
  final String tagline;
  final String description;
  final GameCategory category;
  final IconData icon;
  final Color accentColor;
  final String badgeText;
  final String statusText;
  final WidgetBuilder? builder;
  final bool isPlayable;

  const GameModel({
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    required this.category,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
    required this.statusText,
    this.builder,
    this.isPlayable = false,
  });
}
