import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import '../models/ladder_step.dart';

class LadderWordRow extends StatelessWidget {
  final LadderStep step;
  final bool isStart;
  final bool isTarget;

  const LadderWordRow({
    super.key,
    required this.step,
    this.isStart = false,
    this.isTarget = false,
  });

  @override
  Widget build(BuildContext context) {
    final word = step.word.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step Number Badge
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: isStart
                  ? GameColors.carbon
                  : isTarget
                      ? GameColors.signalLime
                      : GameColors.paper,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isStart || isTarget ? GameColors.carbon : GameColors.borderMuted,
                width: 1,
              ),
            ),
            child: Text(
              isStart
                  ? 'START'
                  : isTarget
                      ? 'GOAL'
                      : '0${step.stepNumber}',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: isStart ? GameColors.paper : GameColors.carbon,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 4 Letter Tiles
          ...List.generate(4, (i) {
            final letter = i < word.length ? word[i] : '';
            final isChanged = step.changedIndex == i;

            Color bgColor = GameColors.surfaceWhite;
            Color textColor = GameColors.carbon;
            Border border = Border.all(color: GameColors.borderMuted, width: 1.2);

            if (isTarget) {
              bgColor = GameColors.signalLime;
              border = Border.all(color: GameColors.carbon, width: 1.4);
            } else if (isStart) {
              bgColor = GameColors.paper;
              border = Border.all(color: GameColors.carbon, width: 1.2);
            } else if (isChanged) {
              bgColor = GameColors.mist;
              border = Border.all(color: GameColors.carbon, width: 1.3);
            }

            return Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: border,
                boxShadow: [
                  BoxShadow(
                    color: GameColors.carbon.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  letter,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
