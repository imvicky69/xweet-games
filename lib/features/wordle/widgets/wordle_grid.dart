import 'package:flutter/material.dart';
import '../models/guess_evaluation.dart';
import '../models/tile_state.dart';
import 'wordle_tile.dart';

class WordleGrid extends StatelessWidget {
  final List<String> guesses;
  final List<GuessEvaluation> evaluations;
  final String currentInput;
  final int maxAttempts;
  final Animation<double>? shakeAnimation;

  const WordleGrid({
    super.key,
    required this.guesses,
    required this.evaluations,
    required this.currentInput,
    this.maxAttempts = 6,
    this.shakeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final currentAttemptIndex = guesses.length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: AspectRatio(
          aspectRatio: 5 / 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(maxAttempts, (rowIndex) {
              final isCurrentRow = rowIndex == currentAttemptIndex;
              final isSubmittedRow = rowIndex < currentAttemptIndex;

              Widget rowContent = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (colIndex) {
                  String letter = '';
                  TileState state = TileState.empty;
                  bool animateFlip = false;

                  if (isSubmittedRow) {
                    final guess = guesses[rowIndex];
                    letter = (colIndex < guess.length) ? guess[colIndex] : '';
                    if (rowIndex < evaluations.length) {
                      state = evaluations[rowIndex].tileStates[colIndex];
                    }
                    // Only animate flip for the very last submitted guess
                    animateFlip = rowIndex == currentAttemptIndex - 1;
                  } else if (isCurrentRow) {
                    if (colIndex < currentInput.length) {
                      letter = currentInput[colIndex];
                      state = TileState.tbd;
                    }
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(3.5),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: WordleTile(
                          letter: letter,
                          state: state,
                          index: colIndex,
                          animateFlip: animateFlip,
                        ),
                      ),
                    ),
                  );
                }),
              );

              // Apply shake animation to active row when an error/invalid word occurs
              if (isCurrentRow && shakeAnimation != null) {
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
            }),
          ),
        ),
      ),
    );
  }
}
