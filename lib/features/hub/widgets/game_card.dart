import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/features/wordle/screens/wordle_detail_screen.dart';
import 'package:xweet_games/features/wordle/widgets/how_to_play_modal.dart';
import 'package:xweet_games/features/word_ladder/screens/ladder_lobby_screen.dart';
import 'package:xweet_games/features/word_ladder/widgets/ladder_rules_modal.dart';
import 'package:xweet_games/features/tilt/screens/tilt_lobby_screen.dart';
import 'package:xweet_games/features/tilt/widgets/tilt_rules_modal.dart';
import 'package:xweet_games/features/tilt/widgets/tilt_preview_widget.dart';
import 'package:xweet_games/features/tilt/models/tilt_block_style.dart';
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
    } else if (game.id == 'tilt') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TiltLobbyScreen()),
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
    } else if (game.id == 'tilt') {
      TiltRulesModal.show(context);
    } else {
      HowToPlayModal.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLadder = game.id == 'ladder';
    final isTilt = game.id == 'tilt';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _onPlayGame(context),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isTilt
                            ? GameColors.signalLime
                            : (isLadder ? GameColors.mist : GameColors.signalLime),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: GameColors.carbon, width: 1),
                      ),
                      child: Text(
                        isTilt
                            ? 'FORGE2D PHYSICS'
                            : (isLadder ? 'ONE-LETTER SHIFT' : 'DAILY & SURVIVAL'),
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: GameColors.carbon,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          isTilt
                              ? Icons.apartment_rounded
                              : (isLadder ? Icons.swap_vert_rounded : Icons.local_fire_department_rounded),
                          size: 15,
                          color: isTilt
                              ? TiltBlockStyle.mutedForest
                              : (isLadder ? const Color(0xFF6B4EE6) : Colors.deepOrange),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isTilt
                              ? 'PHYSICS ARCADE'
                              : (isLadder ? 'DAILY PUZZLE' : 'FEATURED'),
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
                const SizedBox(height: 12),

                // Title & Subtitle
                Text(
                  game.title,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: GameColors.carbon,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  game.tagline,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: GameColors.terrain,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),

                // Compact, Sleek Visual Preview
                if (isTilt)
                  const TiltPreviewWidget(height: 72)
                else if (isLadder)
                  _buildLadderPreview()
                else
                  _buildWordlePreview(),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _onHowToPlay(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        textStyle: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      child: const Text('HOW TO PLAY'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _onPlayGame(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(
                          isTilt
                              ? Icons.apartment_rounded
                              : (isLadder ? Icons.swap_vert_rounded : Icons.play_arrow_rounded),
                          size: 20,
                        ),
                        label: Text(
                          isTilt
                              ? 'PLAY TILT.'
                              : (isLadder ? 'PLAY WORD LADDER' : 'PLAY WORDLE'),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
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

  // Wordle 5-Letter Preview Tiles
  Widget _buildWordlePreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildMiniTile('W', GameColors.signalLime, GameColors.carbon),
        _buildMiniTile('O', GameColors.mist, GameColors.carbon),
        _buildMiniTile('R', GameColors.carbon, Colors.white),
        _buildMiniTile('D', GameColors.terrain, Colors.white),
        _buildMiniTile('L', GameColors.signalLime, GameColors.carbon),
      ],
    );
  }

  Widget _buildMiniTile(String letter, Color bg, Color textColor) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: GameColors.carbon.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // Word Ladder 3-Step Compact Transformation Chips
  Widget _buildLadderPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GameColors.borderMuted),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLadderChip('COLD', changedIdx: -1),
          const Icon(Icons.arrow_forward_rounded, size: 14, color: GameColors.terrain),
          _buildLadderChip('CORD', changedIdx: 2),
          const Icon(Icons.arrow_forward_rounded, size: 14, color: GameColors.terrain),
          _buildLadderChip('WARM', changedIdx: -1, isTarget: true),
        ],
      ),
    );
  }

  Widget _buildLadderChip(String word, {required int changedIdx, bool isTarget = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isTarget ? GameColors.signalLime : GameColors.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTarget ? GameColors.carbon : GameColors.borderMuted,
          width: isTarget ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (i) {
          final isChanged = i == changedIdx;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Text(
              word[i],
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isChanged
                    ? const Color(0xFF6B4EE6)
                    : GameColors.carbon,
              ),
            ),
          );
        }),
      ),
    );
  }
}
