import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';

class PlayerProfileHeader extends StatelessWidget {
  final String playerName;
  final int totalScore;
  final VoidCallback onSettingsTap;

  const PlayerProfileHeader({
    super.key,
    required this.playerName,
    required this.totalScore,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: GameColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_esports_rounded,
              color: Colors.black,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: GoogleFonts.orbitron(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: GameColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: GameColors.accentAmber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Total Points: $totalScore',
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: GameColors.accentAmber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              AudioService.instance.triggerSelectionHaptic();
              onSettingsTap();
            },
            icon: const Icon(
              Icons.tune_rounded,
              color: GameColors.textSecondary,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}
