import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import 'package:xweet_games/features/wordle/logic/word_repository.dart';
import 'package:xweet_games/features/wordle/screens/wordle_playground_screen.dart';
import 'package:xweet_games/features/wordle/widgets/series_debrief_dialog.dart';
import 'package:xweet_games/features/word_ladder/logic/ladder_dictionary.dart';
import 'package:xweet_games/features/word_ladder/models/ladder_puzzle.dart';
import 'package:xweet_games/features/word_ladder/screens/ladder_playground_screen.dart';
import 'package:xweet_games/features/word_ladder/widgets/ladder_solution_modal.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await WordRepository.instance.init();
    await LadderDictionary.instance.init();
  });

  group('Wordle Give Up & Record Preservation', () {
    testWidgets('Wordle has Give Up button and reveals debrief on confirmation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WordlePlaygroundScreen(
            isDaily: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Give Up flag button
      final giveUpButton = find.byTooltip('Give Up Round');
      expect(giveUpButton, findsOneWidget);

      // Tap Give Up
      await tester.tap(giveUpButton);
      await tester.pumpAndSettle();

      // Confirmation dialog should be visible
      expect(find.text('Give Up Round?'), findsOneWidget);
      expect(find.text('GIVE UP & REVEAL'), findsOneWidget);

      // Confirm give up
      await tester.tap(find.text('GIVE UP & REVEAL'));
      await tester.pumpAndSettle();

      // Series debrief dialog should appear with revealed word
      expect(find.byType(SeriesDebriefDialog), findsOneWidget);
      expect(find.text('Survival Run Over'), findsOneWidget);
      expect(find.text('The secret word was:'), findsOneWidget);
    });
  });

  group('Word Ladder Pinned Target Header & Give Up Solution', () {
    testWidgets('Word Ladder shows pinned target header and opens animated solution modal on give up', (WidgetTester tester) async {
      const puzzle = LadderPuzzle(
        startWord: 'COLD',
        targetWord: 'WARM',
        optimalMoves: 4,
        optimalPath: ['COLD', 'CORD', 'CARD', 'WARD', 'WARM'],
        isDaily: true,
        dateString: '2026-11-23',
        puzzleId: 'daily_20261123',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: LadderPlaygroundScreen(
            initialPuzzle: puzzle,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pinned target header shows TARGET and WARM
      expect(find.text('TARGET: '), findsOneWidget);
      expect(find.text('WARM'), findsOneWidget);
      expect(find.text('4 moves optimal'), findsOneWidget);

      // Find Give Up action button
      final giveUpButton = find.byTooltip('Give Up & Solution');
      expect(giveUpButton, findsOneWidget);

      // Tap Give Up
      await tester.tap(giveUpButton);
      await tester.pumpAndSettle();

      expect(find.text('Give Up Puzzle?'), findsOneWidget);
      expect(find.text('REVEAL SOLUTION'), findsOneWidget);

      // Confirm reveal solution
      await tester.tap(find.text('REVEAL SOLUTION'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Solution modal is displayed
      expect(find.byType(LadderSolutionModal), findsOneWidget);
      expect(find.text('Optimal Solution Flow'), findsOneWidget);
      expect(find.text('COLD ➔ WARM • 4 optimal steps'), findsOneWidget);
    });
  });
}
