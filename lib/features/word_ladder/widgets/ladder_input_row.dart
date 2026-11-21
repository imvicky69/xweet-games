import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';

class LadderInputRow extends StatelessWidget {
  final String currentInput;
  final int stepNumber;
  final Animation<double>? shakeAnimation;

  const LadderInputRow({
    super.key,
    required this.currentInput,
    required this.stepNumber,
    this.shakeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final input = currentInput.toUpperCase();

    Widget rowContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step indicator badge
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: GameColors.signalLime.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: GameColors.carbon, width: 1),
            ),
            child: Text(
              '0$stepNumber',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: GameColors.carbon,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 4 Input Letter Slots
          ...List.generate(4, (i) {
            final hasLetter = i < input.length;
            final letter = hasLetter ? input[i] : '';
            final isNextSlot = i == input.length;

            return Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              decoration: BoxDecoration(
                color: hasLetter ? GameColors.surfaceWhite : GameColors.surfaceWhite.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasLetter || isNextSlot ? GameColors.borderActive : GameColors.borderMuted,
                  width: hasLetter || isNextSlot ? 2.0 : 1.2,
                ),
                boxShadow: isNextSlot
                    ? [
                        BoxShadow(
                          color: GameColors.signalLime.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
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

    if (shakeAnimation != null) {
      return AnimatedBuilder(
        animation: shakeAnimation!,
        builder: (context, child) {
          final offset = shakeAnimation!.value * 12.0;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: rowContent,
      );
    }

    return rowContent;
  }
}
