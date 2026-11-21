import 'package:flutter_test/flutter_test.dart';
import 'package:xweet_games/features/wordle/logic/wordle_evaluator.dart';
import 'package:xweet_games/features/wordle/models/tile_state.dart';

void main() {
  group('WordleEvaluator 2-pass duplicate letter logic tests (wordle.md Section 5)', () {
    test('Exact match all correct', () {
      final result = WordleEvaluator.evaluateGuess('PLANT', 'PLANT');
      expect(result.isWinning, isTrue);
      expect(result.correctCount, 5);
      expect(result.presentCount, 0);
      expect(result.allMissing, isFalse);
      expect(result.tileStates, [
        TileState.correct,
        TileState.correct,
        TileState.correct,
        TileState.correct,
        TileState.correct,
      ]);
    });

    test('Duplicate letter handling: Target ROBOT, Guess BOOST', () {
      // In BOOST vs ROBOT:
      // B: present (target has B at index 2)
      // O: correct (target has O at index 1)
      // O: absent (target has second O at index 3, but guess has second O at index 2, while target index 3 has O)
      // Let's trace Pass 1:
      // guess[1] ('O') == target[1] ('O') -> CORRECT, remainingTarget[1] = null
      // Pass 2:
      // guess[0] ('B') in remainingTarget? Yes (index 2) -> PRESENT, remainingTarget[2] = null
      // guess[2] ('O') in remainingTarget? Yes (index 3) -> PRESENT, remainingTarget[3] = null
      // guess[3] ('S') in remainingTarget? No -> ABSENT
      // guess[4] ('T') in remainingTarget? Yes (index 4) -> CORRECT was matched in Pass 1!
      final result = WordleEvaluator.evaluateGuess('BOOST', 'ROBOT');
      expect(result.tileStates[0], TileState.present); // B
      expect(result.tileStates[1], TileState.correct); // O
      expect(result.tileStates[2], TileState.present); // O
      expect(result.tileStates[3], TileState.absent);  // S
      expect(result.tileStates[4], TileState.correct); // T
    });

    test('Duplicate letter handling: Target APPLE, Guess PAPER', () {
      // Pass 1: guess[2] ('P') == target[2] ('P') -> CORRECT, remainingTarget[2] = null
      // Pass 2: guess[0] ('P') in remainingTarget? Yes (index 1) -> PRESENT, remainingTarget[1] = null
      // A: index 1 in guess matches target[0] -> PRESENT
      final result = WordleEvaluator.evaluateGuess('PAPER', 'APPLE');
      expect(result.tileStates[0], TileState.present); // P
      expect(result.tileStates[1], TileState.present); // A
      expect(result.tileStates[2], TileState.correct); // P
      expect(result.tileStates[3], TileState.present); // E
      expect(result.tileStates[4], TileState.absent);  // R
    });

    test('All missing trigger (BOOM)', () {
      final result = WordleEvaluator.evaluateGuess('CHAMP', 'GUIDE');
      expect(result.allMissing, isTrue);
      expect(result.totalMatched, 0);
    });

    test('Close call trigger', () {
      final result = WordleEvaluator.evaluateGuess('PLANS', 'PLANT');
      expect(result.isClose, isTrue);
      expect(result.correctCount, 4);
    });
  });
}
