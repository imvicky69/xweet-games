import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import '../models/ladder_game_state.dart';
import 'ladder_input_row.dart';
import 'ladder_word_row.dart';

class LadderVerticalTimeline extends StatelessWidget {
  final LadderGameState state;
  final String currentInput;
  final Animation<double>? shakeAnimation;
  final ScrollController scrollController;

  const LadderVerticalTimeline({
    super.key,
    required this.state,
    required this.currentInput,
    required this.scrollController,
    this.shakeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final puzzle = state.puzzle;
    final steps = state.steps;
    final isCompleted = state.isCompleted;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        // Target Goal Header Strip
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: GameColors.surfaceWhite,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: GameColors.carbon, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: GameColors.carbon.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TARGET GOAL: ',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: GameColors.terrain,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: GameColors.signalLime,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GameColors.carbon, width: 1),
                ),
                child: Text(
                  puzzle.targetWord.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: GameColors.carbon,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${puzzle.optimalMoves} moves optimal)',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: GameColors.terrain,
                ),
              ),
            ],
          ),
        ),

        // Steps progression
        ...List.generate(steps.length, (index) {
          final step = steps[index];
          final isStart = index == 0;
          final isTarget = isCompleted && index == steps.length - 1;

          return LadderWordRow(
            step: step,
            isStart: isStart,
            isTarget: isTarget,
          );
        }),

        // Active Input Row (if game is still active)
        if (!isCompleted)
          LadderInputRow(
            currentInput: currentInput,
            stepNumber: steps.length,
            shakeAnimation: shakeAnimation,
          ),
      ],
    );
  }
}
