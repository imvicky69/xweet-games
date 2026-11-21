import 'package:xweet_games/features/wordle/models/guess_evaluation.dart';
import 'package:xweet_games/features/wordle/models/tile_state.dart';

/// Two-Pass Wordle Tile Evaluation Algorithm
/// Exactly as specified in wordle.md Section 5
class WordleEvaluator {
  WordleEvaluator._();

  static GuessEvaluation evaluateGuess(String guess, String target) {
    assert(guess.length == 5 && target.length == 5);

    final targetChars = target.toUpperCase().split('');
    final guessChars = guess.toUpperCase().split('');
    final states = List<TileState>.filled(5, TileState.absent);
    final remainingTarget = List<String?>.from(targetChars);

    var correctCount = 0;
    var presentCount = 0;

    // PASS 1: Exact matches (CORRECT / Signal Lime)
    for (int i = 0; i < 5; i++) {
      if (guessChars[i] == targetChars[i]) {
        states[i] = TileState.correct;
        correctCount++;
        remainingTarget[i] = null; // Consume this letter
      }
    }

    // PASS 2: Misplaced matches (PRESENT / Mist)
    for (int i = 0; i < 5; i++) {
      if (states[i] != TileState.correct) {
        final matchIndex = remainingTarget.indexOf(guessChars[i]);
        if (matchIndex != -1) {
          states[i] = TileState.present;
          presentCount++;
          remainingTarget[matchIndex] = null; // Consume this letter
        } else {
          states[i] = TileState.absent;
        }
      }
    }

    final totalMatched = correctCount + presentCount;
    final allMissing = totalMatched == 0;
    // "Close": Either 4+ exact letters correct, or 4+ total letters matched
    final isClose = !allMissing && (correctCount >= 4 || totalMatched >= 4) && correctCount < 5;
    final isWinning = correctCount == 5;

    return GuessEvaluation(
      tileStates: states,
      correctCount: correctCount,
      presentCount: presentCount,
      totalMatched: totalMatched,
      allMissing: allMissing,
      isClose: isClose,
      isWinning: isWinning,
    );
  }
}
