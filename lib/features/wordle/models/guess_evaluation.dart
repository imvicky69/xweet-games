import 'tile_state.dart';

class GuessEvaluation {
  final List<TileState> tileStates;
  final int correctCount;
  final int presentCount;
  final int totalMatched;
  final bool allMissing;
  final bool isClose;
  final bool isWinning;

  const GuessEvaluation({
    required this.tileStates,
    required this.correctCount,
    required this.presentCount,
    required this.totalMatched,
    required this.allMissing,
    required this.isClose,
    required this.isWinning,
  });
}
