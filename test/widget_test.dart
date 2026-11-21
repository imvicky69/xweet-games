import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import 'package:xweet_games/features/hub/screens/game_hub_screen.dart';
import 'package:xweet_games/features/hub/widgets/game_card.dart';
import 'package:xweet_games/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  testWidgets('XweetGamesApp launches GameHubScreen with Wordle listing test', (WidgetTester tester) async {
    await tester.pumpWidget(const XweetGamesApp());
    await tester.pumpAndSettle();

    // Verify GameHub is rendered with Wordle expedition
    expect(find.byType(GameHubScreen), findsOneWidget);
    expect(find.byType(GameCard), findsOneWidget);
    expect(find.text('Wordle'), findsWidgets);
  });
}
