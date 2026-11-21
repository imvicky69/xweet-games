import 'ladder_puzzle.dart';
import 'ladder_step.dart';

class LadderGameState {
  final LadderPuzzle puzzle;
  final List<LadderStep> steps;
  final bool isCompleted;

  const LadderGameState({
    required this.puzzle,
    required this.steps,
    required this.isCompleted,
  });

  String get currentWord => steps.isNotEmpty ? steps.last.word : puzzle.startWord;
  int get moveCount => steps.length > 1 ? steps.length - 1 : 0;
  int get optimalMoves => puzzle.optimalMoves;

  LadderGameState copyWith({
    List<LadderStep>? steps,
    bool? isCompleted,
  }) {
    return LadderGameState(
      puzzle: puzzle,
      steps: steps ?? this.steps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
