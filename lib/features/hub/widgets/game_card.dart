import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/features/wordle/screens/wordle_detail_screen.dart';
import 'package:xweet_games/features/wordle/widgets/how_to_play_modal.dart';
import 'package:xweet_games/models/game_model.dart';

class GameCard extends StatelessWidget {
  final GameModel game;

  const GameCard({
    super.key,
    required this.game,
  });

  void _navigateToWordle(BuildContext context) {
    AudioService.instance.triggerSelectionHaptic();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WordleDetailScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.surfaceWhite,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: GameColors.borderMuted,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.carbon.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => _navigateToWordle(context),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Badges
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
                        '5-ROUND CHALLENGE',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: GameColors.carbon,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'FEATURED',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: GameColors.carbon,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title & Subtitle
                Text(
                  'Wordle',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: GameColors.carbon,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '5-Round Series Lexical Tournament',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: GameColors.terrain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),

                // Visual Wordle Letter Tiles (W O R D L)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildPreviewTile('W', GameColors.signalLime, GameColors.carbon),
                    _buildPreviewTile('O', GameColors.mist, GameColors.carbon),
                    _buildPreviewTile('R', GameColors.carbon, Colors.white),
                    _buildPreviewTile('D', GameColors.terrain, Colors.white),
                    _buildPreviewTile('L', GameColors.signalLime, GameColors.carbon),
                  ],
                ),
                const SizedBox(height: 18),

                // Description
                Text(
                  'Solve 5 secret words in a row. You have 6 attempts per word with live color clues and instant audio feedback. Test your vocabulary and climb the ranks!',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: GameColors.carbon.withValues(alpha: 0.85),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 22),

                // Action Buttons
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => HowToPlayModal.show(context),
                      child: const Text('HOW TO PLAY'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToWordle(context),
                        icon: const Icon(Icons.play_arrow_rounded, size: 22),
                        label: const Text('PLAY WORDLE'),
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
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
