import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';

class HowToPlayModal extends StatelessWidget {
  const HowToPlayModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const HowToPlayModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: ListView(
            controller: scrollController,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: GameColors.borderMuted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: GameColors.signalLime,
                      shape: BoxShape.circle,
                      border: Border.all(color: GameColors.carbon, width: 1),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      size: 20,
                      color: GameColors.carbon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'How to Play Wordle',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: GameColors.carbon,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Guess the secret 5-letter word in 6 attempts or fewer. Each guess must be a valid English word.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: GameColors.carbon,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Rule 1: Green Tile
              _buildExampleTile(
                letter: 'W',
                bgColor: GameColors.signalLime,
                textColor: GameColors.carbon,
                title: 'Green — Exact Match',
                explanation: 'The letter is in the secret word and in the exact right position!',
              ),
              const SizedBox(height: 14),

              // Rule 2: Mist / Purple Tile
              _buildExampleTile(
                letter: 'I',
                bgColor: GameColors.mist,
                textColor: GameColors.carbon,
                title: 'Purple — Wrong Spot',
                explanation: 'The letter is in the word, but belongs in a different spot.',
              ),
              const SizedBox(height: 14),

              // Rule 3: Grey / Terrain Tile
              _buildExampleTile(
                letter: 'N',
                bgColor: GameColors.terrain,
                textColor: Colors.white,
                title: 'Grey — Not in Word',
                explanation: 'The letter does not appear anywhere in the secret word.',
              ),
              const SizedBox(height: 24),

              // 5-Round Series Tournament Rule
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GameColors.paper,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GameColors.borderMuted),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events_outlined,
                          size: 20,
                          color: GameColors.carbon,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'The 5-Round Expedition',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: GameColors.carbon,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A complete expedition consists of 5 consecutive rounds. Solve as many rounds as you can to earn honorific ranks:\n\n'
                      '• 5 of 5: Grandmaster Lexicographer\n'
                      '• 4 of 5: Master Cryptic Solver\n'
                      '• 3 of 5: Seasoned Wordsmith\n'
                      '• 1–2 of 5: Apprentice Explorer',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: GameColors.carbon.withValues(alpha: 0.85),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('GOT IT, LET’S PLAY'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExampleTile({
    required String letter,
    required Color bgColor,
    required Color textColor,
    required String title,
    required String explanation,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameColors.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.borderMuted),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GameColors.carbon.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                letter,
                style: GoogleFonts.spaceMono(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: GameColors.carbon,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  explanation,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
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
