import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/models/game_model.dart';
import 'package:xweet_games/features/hub/widgets/game_card.dart';
import 'package:xweet_games/features/hub/widgets/xweet_app_header.dart';
import 'package:xweet_games/features/settings/screens/settings_screen.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  final List<GameModel> _games = const [
    GameModel(
      id: 'wordle',
      title: 'Wordle',
      tagline: '5-Round Series Lexical Tournament',
      description:
          'Solve 5 secret words in a row. You have 6 attempts per word with live color clues and instant audio feedback. Test your vocabulary and climb the ranks!',
      category: GameCategory.lexical,
      icon: Icons.grid_view_rounded,
      accentColor: GameColors.signalLime,
      badgeText: '5-ROUND SERIES',
      statusText: 'EXPEDITION READY',
      isPlayable: true,
    ),
  ];

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            // Editorial Header with Xweet Logo & Settings
            XweetAppHeader(onSettingsTap: () => _openSettings(context)),

            // Main Content Area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  // Friendly Welcome Message
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GameColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: GameColors.borderMuted),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: GameColors.signalLime,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'GAMES AVAILABLE',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: GameColors.carbon,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Choose Your Game',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a game below to configure difficulty and start playing.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: GameColors.terrain,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Games List - Focused on Wordle
                  ..._games.map((game) {
                    return GameCard(game: game);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
