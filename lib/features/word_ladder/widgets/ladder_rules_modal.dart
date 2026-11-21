import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';

class LadderRulesModal extends StatelessWidget {
  const LadderRulesModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const LadderRulesModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.76,
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
                    decoration: const BoxDecoration(
                      color: GameColors.signalLime,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      size: 20,
                      color: GameColors.carbon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'How to Play Word Ladder',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                'Transform the starting 4-letter word into the target word by changing exactly ONE letter on each move.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: GameColors.carbon,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Example Progression
              Text(
                'EXAMPLE TRANSFORMATION',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: GameColors.terrain,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              _buildExampleStep('START', 'C', 'O', 'L', 'D', -1),
              _buildExampleStep('MOVE 1', 'C', 'O', 'R', 'D', 2),
              _buildExampleStep('MOVE 2', 'C', 'A', 'R', 'D', 1),
              _buildExampleStep('MOVE 3', 'W', 'A', 'R', 'D', 0),
              _buildExampleStep('TARGET', 'W', 'A', 'R', 'M', 3, isTarget: true),

              const SizedBox(height: 22),

              // Key Rules Box
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
                    Text(
                      'Core Rules & Tips',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: GameColors.carbon,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRuleItem('1. Exactly One Letter', 'Every new step must change exactly 1 letter from the current word.'),
                    const SizedBox(height: 6),
                    _buildRuleItem('2. Real Dictionary Words', 'Every word you enter must be a valid 4-letter English word.'),
                    const SizedBox(height: 6),
                    _buildRuleItem('3. Unlimited Moves & Undo', 'Take as many moves as you need. Tap Undo anytime or restart if you hit a dead end.'),
                    const SizedBox(height: 6),
                    _buildRuleItem('4. Optimal Path Challenge', 'Can you reach the goal in the minimum possible moves?'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('GOT IT, LET’S SHIFT!'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExampleStep(String label, String l1, String l2, String l3, String l4, int changedIndex, {bool isTarget = false}) {
    final letters = [l1, l2, l3, l4];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isTarget ? GameColors.carbon : GameColors.terrain,
              ),
            ),
          ),
          ...List.generate(4, (i) {
            final isChanged = changedIndex == i;
            return Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: isTarget
                    ? GameColors.signalLime
                    : isChanged
                        ? GameColors.mist
                        : GameColors.surfaceWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isTarget || isChanged ? GameColors.carbon : GameColors.borderMuted,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  letters[i],
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: GameColors.carbon,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: GameColors.carbon,
          ),
        ),
        Text(
          desc,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: GameColors.terrain,
          ),
        ),
      ],
    );
  }
}
