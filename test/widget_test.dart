import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import 'package:xweet_games/features/hub/screens/game_hub_screen.dart';
import 'package:xweet_games/features/hub/widgets/game_card.dart';
import 'package:xweet_games/features/wordle/logic/word_repository.dart';
import 'package:xweet_games/features/wordle/screens/wordle_detail_screen.dart';
import 'package:xweet_games/features/wordle/screens/wordle_playground_screen.dart';
import 'package:xweet_games/features/wordle/widgets/wordle_grid.dart';
import 'package:xweet_games/features/wordle/widgets/wordle_keyboard.dart';
import 'package:xweet_games/features/word_ladder/logic/ladder_dictionary.dart';
import 'package:xweet_games/features/word_ladder/screens/ladder_lobby_screen.dart';
import 'package:xweet_games/features/word_ladder/screens/ladder_playground_screen.dart';
import 'package:xweet_games/main.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await WordRepository.instance.init();
    await LadderDictionary.instance.init();
  });

  testWidgets('XweetGamesApp launches GameHub and navigates to WordlePlayground', (WidgetTester tester) async {
    await tester.pumpWidget(const XweetGamesApp());
    await tester.pumpAndSettle();

    // Verify GameHub is rendered with both GameCards
    expect(find.byType(GameHubScreen), findsOneWidget);
    expect(find.byType(GameCard), findsNWidgets(2));
    expect(find.text('Wordle'), findsWidgets);
    expect(find.text('PLAY WORDLE'), findsOneWidget);
    expect(find.text('Word Ladder'), findsWidgets);

    // Tap PLAY WORDLE to navigate to WordleDetailScreen
    await tester.tap(find.text('PLAY WORDLE'));
    await tester.pumpAndSettle();

    expect(find.byType(WordleDetailScreen), findsOneWidget);
    expect(find.text('Wordle Tournament'), findsOneWidget);
    expect(find.text('Choose Difficulty'), findsOneWidget);

    // Tap START 5-ROUND GAME to launch playground
    await tester.tap(find.text('START 5-ROUND GAME'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify WordlePlaygroundScreen is active with Grid and Keyboard
    expect(find.byType(WordlePlaygroundScreen), findsOneWidget);
    expect(find.byType(WordleGrid), findsOneWidget);
    expect(find.byType(WordleKeyboard), findsOneWidget);
    expect(find.text('ROUND 01 / 05'), findsOneWidget);

    // Tap keyboard keys 'P', 'L', 'A', 'N', 'T'
    await tester.tap(find.text('P'));
    await tester.pump();
    await tester.tap(find.text('L'));
    await tester.pump();
    await tester.tap(find.text('A'));
    await tester.pump();

    // Letters typed should appear in active row
    expect(find.text('P'), findsWidgets);
    expect(find.text('L'), findsWidgets);
    expect(find.text('A'), findsWidgets);
  });

  testWidgets('XweetGamesApp navigates to Word Ladder Lobby and launches game', (WidgetTester tester) async {
    await tester.pumpWidget(const XweetGamesApp());
    await tester.pumpAndSettle();

    // Scroll until PLAY WORD LADDER is visible
    final playLadderBtn = find.text('PLAY WORD LADDER');
    await tester.scrollUntilVisible(playLadderBtn, 300);
    await tester.pumpAndSettle();

    // Tap PLAY WORD LADDER
    await tester.tap(playLadderBtn);
    await tester.pumpAndSettle();

    // Verify LadderLobbyScreen
    expect(find.byType(LadderLobbyScreen), findsOneWidget);
    expect(find.text('Daily Word Shift'), findsOneWidget);

    final playDailyBtn = find.text('PLAY DAILY PUZZLE');
    await tester.scrollUntilVisible(playDailyBtn, 200);
    await tester.pumpAndSettle();

    // Tap PLAY DAILY PUZZLE
    await tester.tap(playDailyBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify LadderPlaygroundScreen is active
    expect(find.byType(LadderPlaygroundScreen), findsOneWidget);
    expect(find.text('DAILY LADDER'), findsOneWidget);
  });
}
