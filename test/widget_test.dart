import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import 'package:xweet_games/features/hub/screens/game_hub_screen.dart';
import 'package:xweet_games/features/hub/widgets/game_card.dart';
import 'package:xweet_games/features/wordle/screens/wordle_detail_screen.dart';
import 'package:xweet_games/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  testWidgets('XweetGamesApp launches GameHub and navigates to WordleDetailScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const XweetGamesApp());
    await tester.pumpAndSettle();

    // Verify GameHub is rendered with Wordle card
    expect(find.byType(GameHubScreen), findsOneWidget);
    expect(find.byType(GameCard), findsOneWidget);
    expect(find.text('Wordle'), findsWidgets);
    expect(find.text('PLAY WORDLE'), findsOneWidget);

    // Tap PLAY WORDLE
    await tester.tap(find.text('PLAY WORDLE'));
    await tester.pumpAndSettle();

    // Verify navigation to WordleDetailScreen
    expect(find.byType(WordleDetailScreen), findsOneWidget);
    expect(find.text('Wordle Expedition'), findsOneWidget);
    expect(find.text('LAST SERIES AUDIT LOG'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
  });
}
