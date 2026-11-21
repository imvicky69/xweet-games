import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/models/game_model.dart';

class GameCard extends StatelessWidget {
  final GameModel game;
  final int highScore;
  final VoidCallback onPlay;

  const GameCard({
    super.key,
    required this.game,
    required this.highScore,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: game.accentColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: game.accentColor.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            AudioService.instance.triggerSelectionHaptic();
            onPlay();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Avatar
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: game.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: game.accentColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    game.icon,
                    size: 30,
                    color: game.accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                // Game Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              game.title,
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: GameColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: game.accentColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              game.category.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: game.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.tagline,
                        style: const TextStyle(
                          fontSize: 13,
                          color: GameColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            size: 14,
                            color: GameColors.accentAmber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'High Score: $highScore',
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: GameColors.accentAmber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Play Button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        game.accentColor,
                        game.accentColor.withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: game.accentColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
