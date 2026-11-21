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
    if (game.id == 'ladder') {
      return _buildWordLadderCard(context);
    }
    return _buildWordleCard(context);
  }

  // ==========================================
  // Bespoke Wordle Card (5-Letter Guess Grid)
  // ==========================================
  Widget _buildWordleCard(BuildContext context) {
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
                        color: GameColors.signalLime,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: GameColors.carbon, width: 1),
                      ),
                      child: Text(
                        '5-ROUND SERIES',
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
                const SizedBox(height: 16),

                // Feature pills
                Row(
                  children: [
                    _buildFeaturePill('🎯 5 LETTERS'),
                    const SizedBox(width: 8),
                    _buildFeaturePill('⚡ 6 ATTEMPTS'),
                    const SizedBox(width: 8),
                    _buildFeaturePill('🎨 COLOR HINTS'),
                  ],
                ),
                const SizedBox(height: 16),

                // Visual Wordle Letter Tiles (W O R D L)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildWordleTile('W', GameColors.signalLime, GameColors.carbon),
                    _buildWordleTile('O', GameColors.mist, GameColors.carbon),
                    _buildWordleTile('R', GameColors.carbon, Colors.white),
                    _buildWordleTile('D', GameColors.terrain, Colors.white),
                    _buildWordleTile('L', GameColors.signalLime, GameColors.carbon),
                  ],
                ),
                const SizedBox(height: 16),

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
                      onPressed: () => _onHowToPlay(context),
                      child: const Text('HOW TO PLAY'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _onPlayGame(context),
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

  // ==========================================
  // Bespoke Word Ladder Card (Vertical Word Shift)
  // ==========================================
  Widget _buildWordLadderCard(BuildContext context) {
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
            color: const Color(0xFF6B4EE6).withValues(alpha: 0.06),
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
                        color: GameColors.mist,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: GameColors.carbon, width: 1),
                      ),
                      child: Text(
                        'ONE-LETTER SHIFT',
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
                          Icons.swap_vert_rounded,
                          size: 18,
                          color: Color(0xFF6B4EE6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'DAILY PUZZLE',
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
                  'Word Ladder',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: GameColors.carbon,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '4-Letter Word Transformation Puzzle',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: GameColors.terrain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Feature pills
                Row(
                  children: [
                    _buildFeaturePill('🪜 STEP BY STEP'),
                    const SizedBox(width: 8),
                    _buildFeaturePill('🔤 4-LETTER POOL'),
                    const SizedBox(width: 8),
                    _buildFeaturePill('⚡ OPTIMAL BFS'),
                  ],
                ),
                const SizedBox(height: 16),

                // Distinctive Tactile Mini-Ladder Preview (Start -> Shift -> Target)
                _buildLadderPreview(),

                const SizedBox(height: 16),

                // Description
                Text(
                  'Transform the starting 4-letter word into the target word changing exactly one letter per step. Every word must be valid!',
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
                        icon: const Icon(Icons.swap_vert_rounded, size: 22),
                        label: const Text('PLAY WORD LADDER'),
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

  // ==========================================
  // Helper Widgets
  // ==========================================

  Widget _buildFeaturePill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: GameColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GameColors.borderMuted, width: 0.8),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: GameColors.terrain,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildWordleTile(String letter, Color bg, Color textColor) {
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

  Widget _buildLadderPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: GameColors.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GameColors.borderMuted),
      ),
      child: Column(
        children: [
          // Start Rung
          _buildLadderRung(
            label: 'START',
            letters: ['C', 'O', 'L', 'D'],
            changedIndex: -1,
            isStart: true,
          ),
          // Connector 1
          _buildRungConnector('change 1 letter (L ➔ R)'),
          // Shift Rung
          _buildLadderRung(
            label: 'SHIFT',
            letters: ['C', 'O', 'R', 'D'],
            changedIndex: 2, // 'R' is shifted
          ),
          // Connector 2
          _buildRungConnector('shortest path to goal'),
          // Goal Rung
          _buildLadderRung(
            label: 'GOAL ★',
            letters: ['W', 'A', 'R', 'M'],
            changedIndex: -1,
            isTarget: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLadderRung({
    required String label,
    required List<String> letters,
    required int changedIndex,
    bool isStart = false,
    bool isTarget = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rung step badge
        Container(
          width: 58,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isTarget
                ? GameColors.signalLime
                : (isStart ? GameColors.surfaceWhite : GameColors.paper),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isTarget ? GameColors.carbon : GameColors.borderMuted,
              width: isTarget ? 1.2 : 0.8,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: GameColors.carbon,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 4 Tactile Letter Tiles
        ...List.generate(4, (i) {
          final letter = letters[i];
          final isChanged = i == changedIndex;

          Color bg = GameColors.surfaceWhite;
          Color textC = GameColors.carbon;
          Color borderC = GameColors.carbon.withValues(alpha: 0.2);
          double borderWidth = 1.0;

          if (isTarget) {
            bg = GameColors.signalLime;
            borderC = GameColors.carbon;
            borderWidth = 1.2;
          } else if (isChanged) {
            bg = GameColors.mist;
            borderC = const Color(0xFF6B4EE6);
            borderWidth = 1.4;
          }

          return Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderC, width: borderWidth),
              boxShadow: isChanged
                  ? [
                      BoxShadow(
                        color: GameColors.mist.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                letter,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textC,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRungConnector(String shiftInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 58), // Align with badge width
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: GameColors.surfaceWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GameColors.borderMuted, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_downward_rounded,
                  size: 11,
                  color: GameColors.terrain,
                ),
                const SizedBox(width: 4),
                Text(
                  shiftInfo,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: GameColors.terrain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
