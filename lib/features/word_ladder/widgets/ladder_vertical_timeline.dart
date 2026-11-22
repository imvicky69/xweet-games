import 'package:flutter/material.dart';
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
    final steps = state.steps;
    final isCompleted = state.isCompleted;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
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
