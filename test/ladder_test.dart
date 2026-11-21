import 'package:flutter_test/flutter_test.dart';
import 'package:xweet_games/features/word_ladder/logic/ladder_dictionary.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LadderDictionary.instance.init();
  });

  group('LadderDictionary Move Validation', () {
    test('accepts single letter change with valid dictionary word', () {
      final res = LadderDictionary.instance.validateMove(
        currentWord: 'COLD',
        newWord: 'CORD',
        existingLadder: ['COLD'],
      );
      expect(res, equals(LadderMoveError.none));
    });

    test('rejects same word', () {
      final res = LadderDictionary.instance.validateMove(
        currentWord: 'COLD',
        newWord: 'COLD',
        existingLadder: ['COLD'],
      );
      expect(res, equals(LadderMoveError.sameWord));
    });

    test('rejects word already in ladder', () {
      final res = LadderDictionary.instance.validateMove(
        currentWord: 'CORD',
        newWord: 'COLD',
        existingLadder: ['COLD', 'CORD'],
      );
      expect(res, equals(LadderMoveError.alreadyInLadder));
    });

    test('rejects words with multiple letter changes', () {
      final res = LadderDictionary.instance.validateMove(
        currentWord: 'COLD',
        newWord: 'WARM',
        existingLadder: ['COLD'],
      );
      expect(res, equals(LadderMoveError.multipleChanges));
    });

    test('rejects words not in dictionary', () {
      final res = LadderDictionary.instance.validateMove(
        currentWord: 'COLD',
        newWord: 'ZZZZ',
        existingLadder: ['COLD'],
      );
      expect(res, equals(LadderMoveError.notInDictionary));
    });

    test('rejects words of invalid length', () {
      final res = LadderDictionary.instance.validateMove(
        currentWord: 'COLD',
        newWord: 'CAT',
        existingLadder: ['COLD'],
      );
      expect(res, equals(LadderMoveError.invalidLength));
    });
  });

  group('LadderDictionary BFS Solver', () {
    test('finds valid shortest path between COLD and WARM', () {
      final path = LadderDictionary.instance.findShortestPath('cold', 'warm');
      expect(path, isNotNull);
      expect(path!.first.toLowerCase(), equals('cold'));
      expect(path.last.toLowerCase(), equals('warm'));
      expect(path.length, inInclusiveRange(4, 6)); // Usually 4 to 5 steps

      // Verify each consecutive pair changes exactly 1 letter
      for (int i = 0; i < path.length - 1; i++) {
        final a = path[i];
        final b = path[i + 1];
        int diff = 0;
        for (int j = 0; j < 4; j++) {
          if (a[j] != b[j]) diff++;
        }
        expect(diff, equals(1), reason: '$a -> $b must differ by exactly 1 letter');
      }
    });

    test('daily puzzle is deterministic for given date', () async {
      final puzzle1 = await LadderDictionary.instance.generateDailyPuzzle(DateTime(2026, 11, 21));
      final puzzle2 = await LadderDictionary.instance.generateDailyPuzzle(DateTime(2026, 11, 21));

      expect(puzzle1.startWord, equals(puzzle2.startWord));
      expect(puzzle1.targetWord, equals(puzzle2.targetWord));
      expect(puzzle1.optimalMoves, equals(puzzle2.optimalMoves));
      expect(puzzle1.isDaily, isTrue);
    });

    test('generates valid random puzzle within requested move bounds', () async {
      final puzzle = await LadderDictionary.instance.generateRandomPuzzle(minMoves: 3, maxMoves: 5);
      expect(puzzle.startWord.length, equals(4));
      expect(puzzle.targetWord.length, equals(4));
      expect(puzzle.optimalMoves, inInclusiveRange(3, 5));
      expect(puzzle.optimalPath.length, equals(puzzle.optimalMoves + 1));
      expect(puzzle.optimalPath.first, equals(puzzle.startWord));
      expect(puzzle.optimalPath.last, equals(puzzle.targetWord));
    });
  });
}
