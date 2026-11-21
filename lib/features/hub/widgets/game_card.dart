import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/models/game_model.dart';

class GameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: GameColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: GameColors.borderMuted,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.carbon.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            AudioService.instance.triggerSelectionHaptic();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag & Category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: GameColors.signalLime,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: GameColors.carbon, width: 1),
                      ),
                      child: Text(
                        game.badgeText,
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: GameColors.carbon,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      game.statusText,
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: GameColors.terrain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title & Subtitle
                Text(
                  game.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: GameColors.carbon,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  game.tagline,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: GameColors.terrain,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Tactile Wordle Tile Preview Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildPreviewTile('X', GameColors.signalLime, GameColors.carbon),
                    _buildPreviewTile('W', GameColors.mist, GameColors.carbon),
                    _buildPreviewTile('E', GameColors.carbon, Colors.white),
                    _buildPreviewTile('E', GameColors.terrain, Colors.white),
                    _buildPreviewTile('T', GameColors.signalLime, GameColors.carbon),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  game.description,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: GameColors.carbon.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Action Pill Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: GameColors.carbon,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: GameColors.carbon, width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'VIEW SPEC & RULES',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: GameColors.paper,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: GameColors.signalLime,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewTile(String letter, Color bg, Color textColor) {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GameColors.carbon.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.spaceMono(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
