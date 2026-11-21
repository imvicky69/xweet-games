import 'package:flutter/material.dart';

enum GameCategory {
  all('All Games'),
  arcade('Arcade'),
  reflex('Reflex & Speed'),
  puzzle('Puzzle'),
  action('Action');

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
  final Widget Function(BuildContext) builder;
  final bool isPlayable;

  const GameModel({
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    required this.category,
    required this.icon,
    required this.accentColor,
    required this.builder,
    this.isPlayable = true,
  });
}
