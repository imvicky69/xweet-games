import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/features/wordle/screens/wordle_detail_screen.dart';
import 'package:xweet_games/features/word_ladder/screens/ladder_lobby_screen.dart';
import 'package:xweet_games/features/tilt/screens/tilt_lobby_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final isLadder = game.id == 'ladder';
    final isTilt = game.id == 'tilt';

    final categoryBadge = isTilt
        ? 'PHYSICS'
        : (isLadder ? 'SHIFT' : 'DAILY');

    final playButtonText = isTilt
        ? 'PLAY TILT.'
        : (isLadder ? 'PLAY WORD LADDER' : 'PLAY WORDLE');

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: GameColors.surfaceWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: GameColors.borderMuted,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.carbon.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _onPlayGame(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isTilt
                            ? GameColors.signalLime.withValues(alpha: 0.35)
                            : (isLadder ? GameColors.mist : GameColors.signalLime.withValues(alpha: 0.35)),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: GameColors.carbon, width: 0.8),
                      ),
                      child: Text(
                        categoryBadge,
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: GameColors.carbon,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    Icon(
                      isTilt
                          ? Icons.apartment_rounded
                          : (isLadder ? Icons.swap_vert_rounded : Icons.local_fire_department_rounded),
                      size: 15,
                      color: isTilt
                          ? TiltBlockStyle.mutedForest
                          : (isLadder ? const Color(0xFF6B4EE6) : Colors.deepOrange),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bespoke Game Visual Icon
                SizedBox(
                  height: 48,
                  child: Center(
                    child: isTilt
                        ? _buildTiltMiniGraphic()
                        : (isLadder ? _buildLadderMiniGraphic() : _buildWordleMiniGraphic()),
                  ),
                ),

                const SizedBox(height: 8),

                // Title
                Text(
                  game.title,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: GameColors.carbon,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Tagline
                Text(
                  game.tagline,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: GameColors.terrain,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Play Button Pill
                GestureDetector(
                  onTap: () => _onPlayGame(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: GameColors.signalLime,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GameColors.carbon, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        playButtonText,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: GameColors.carbon,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Wordle 4-Letter Mini Tiles
  Widget _buildWordleMiniGraphic() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMiniTile('W', GameColors.signalLime, GameColors.carbon),
        _buildMiniTile('O', GameColors.carbon, Colors.white),
        _buildMiniTile('R', GameColors.mist, GameColors.carbon),
        _buildMiniTile('D', GameColors.signalLime, GameColors.carbon),
      ],
    );
  }

  Widget _buildMiniTile(String letter, Color bg, Color textColor) {
    return Container(
      width: 26,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: GameColors.carbon.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // TILT Mini Architectural Floor Graphic
  Widget _buildTiltMiniGraphic() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 1.2,
          height: 10,
          color: GameColors.carbon,
        ),
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: GameColors.carbon,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 68,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFE2DFD6),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: GameColors.carbon, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniWindow(const Color(0xFFD7F36A)),
              _buildMiniWindow(Colors.white),
              _buildMiniWindow(Colors.white),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniWindow(Color fill) {
    return Container(
      width: 12,
      height: 14,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: GameColors.carbon.withValues(alpha: 0.3), width: 0.6),
      ),
    );
  }

  // Word Ladder Mini Transformation
  Widget _buildLadderMiniGraphic() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMiniLadderChip('COLD', false),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.arrow_forward_rounded, size: 12, color: GameColors.terrain),
        ),
        _buildMiniLadderChip('WARM', true),
      ],
    );
  }

  Widget _buildMiniLadderChip(String word, bool isTarget) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isTarget ? GameColors.signalLime : GameColors.surfaceWhite,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isTarget ? GameColors.carbon : GameColors.borderMuted,
          width: 1,
        ),
      ),
      child: Text(
        word,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: GameColors.carbon,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
