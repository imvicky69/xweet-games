import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import 'package:xweet_games/features/hub/screens/game_hub_screen.dart';
import 'package:xweet_games/features/hub/widgets/game_card.dart';
import 'package:xweet_games/features/tilt/screens/tilt_lobby_screen.dart';
import 'package:xweet_games/features/tilt/screens/tilt_playground_screen.dart';
import 'package:xweet_games/features/tilt/widgets/tilt_hud_overlay.dart';
import 'package:xweet_games/features/tilt/widgets/tilt_rules_modal.dart';
import 'package:xweet_games/features/wordle/logic/word_repository.dart';
import 'package:xweet_games/features/word_ladder/logic/ladder_dictionary.dart';
import 'package:xweet_games/main.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await WordRepository.instance.init();
    await LadderDictionary.instance.init();
  });

  testWidgets('XweetGamesApp displays TILT. and navigates to TiltLobbyScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const XweetGamesApp());
    await tester.pumpAndSettle();

    expect(find.byType(GameHubScreen), findsOneWidget);
    expect(find.byType(GameCard), findsWidgets);
    expect(find.text('TILT.'), findsWidgets);

    // Scroll until PLAY TILT. is visible
    final playBtn = find.text('PLAY TILT.');
    await tester.scrollUntilVisible(playBtn, 200);
    await tester.pumpAndSettle();

    // Tap PLAY TILT. to navigate to Lobby
    await tester.tap(playBtn);
    await tester.pumpAndSettle();

    expect(find.byType(TiltLobbyScreen), findsOneWidget);
    expect(find.text('FORGE2D PHYSICS ARCADE'), findsOneWidget);
    expect(find.text('START EXPEDITION'), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);

    // Tap How to Play to open blueprint modal
    await tester.tap(find.text('How to Play'));
    await tester.pumpAndSettle();

    expect(find.byType(TiltRulesModal), findsOneWidget);
    expect(find.text('How to Play TILT.'), findsOneWidget);
    expect(find.text('One-Tap Drop Release'), findsOneWidget);

    // Dismiss modal via close button
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(TiltRulesModal), findsNothing);

    // Scroll to START EXPEDITION and launch playground
    final startExpeditionBtn = find.text('START EXPEDITION');
    await tester.scrollUntilVisible(startExpeditionBtn, 200, scrollable: find.byType(Scrollable));
    await tester.pumpAndSettle();

    await tester.tap(startExpeditionBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(TiltPlaygroundScreen), findsOneWidget);
    expect(find.byType(TiltHudOverlay), findsOneWidget);
    expect(find.text('FLOOR 0'), findsOneWidget);

    // Tap pause button on HUD
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('PHYSICS PAUSED'), findsOneWidget);
    expect(find.text('RESUME RUN'), findsOneWidget);

    // Resume run
    await tester.tap(find.text('RESUME RUN'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('PHYSICS PAUSED'), findsNothing);
  });
}
