import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/features/wordle/screens/wordle_detail_screen.dart';
import 'package:xweet_games/features/wordle/widgets/how_to_play_modal.dart';
import 'package:xweet_games/features/word_ladder/screens/ladder_lobby_screen.dart';
import 'package:xweet_games/features/word_ladder/widgets/ladder_rules_modal.dart';
import 'package:xweet_games/models/game_model.dart';

class GameCard extends StatelessWidget {
  final GameModel game;

  const GameCard({
    super.key,
    required this.game,
  });

  void _onPlayGame(BuildContext context) {
    AudioService.instance.triggerSelectionHaptic();
    if (game.id == 'ladder') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LadderLobbyScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const WordleDetailScreen()),
      );
    }
  }

  void _onHowToPlay(BuildContext context) {
    AudioService.instance.triggerSelectionHaptic();
    if (game.id == 'ladder') {
      LadderRulesModal.show(context);
    } else {
      HowToPlayModal.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLadder = game.id == 'ladder';

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
          onTap: () => _onPlayGame(context),
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
                        color: game.accentColor,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: GameColors.carbon, width: 1),
                      ),
                      child: Text(
                        game.badgeText,
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
                        Icon(
                          isLadder ? Icons.auto_awesome_rounded : Icons.local_fire_department_rounded,
                          size: 16,
                          color: isLadder ? const Color(0xFF6B4EE6) : Colors.deepOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLadder ? 'NEW PUZZLE' : 'FEATURED',
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
                  game.title,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: GameColors.carbon,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  game.tagline,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: GameColors.terrain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),

                // Visual Letter Tiles Preview
                if (isLadder)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildPreviewTile('S', GameColors.mist, GameColors.carbon),
                      _buildPreviewTile('H', GameColors.signalLime, GameColors.carbon),
                      _buildPreviewTile('I', GameColors.carbon, Colors.white),
                      _buildPreviewTile('F', GameColors.terrain, Colors.white),
                      _buildPreviewTile('T', GameColors.mist, GameColors.carbon),
                    ],
                  )
                else
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
                  game.description,
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
                      onPressed: () => _onHowToPlay(context),
                      child: const Text('HOW TO PLAY'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _onPlayGame(context),
                        icon: const Icon(Icons.play_arrow_rounded, size: 22),
                        label: Text(isLadder ? 'PLAY WORD LADDER' : 'PLAY WORDLE'),
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
