import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/models/game_model.dart';
import 'package:xweet_games/features/hub/widgets/game_card.dart';
import 'package:xweet_games/features/hub/widgets/discover_promo_card.dart';
import 'package:xweet_games/features/hub/widgets/xweet_app_header.dart';
import 'package:xweet_games/features/settings/screens/settings_screen.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  final List<GameModel> _games = const [
    GameModel(
      id: 'wordle',
      title: 'Wordle',
      tagline: 'Daily Word & Streak Survival',
      description:
          'Solve the Game of the Day or survive consecutive rounds from 1 onward until your first miss! Live color clues and instant feedback.',
      category: GameCategory.lexical,
      icon: Icons.grid_view_rounded,
      accentColor: GameColors.signalLime,
      badgeText: 'DAILY & SURVIVAL',
      statusText: 'EXPEDITION READY',
      isPlayable: true,
    ),
    GameModel(
      id: 'tilt',
      title: 'TILT.',
      tagline: 'Architectural Stacking Arcade',
      description:
          'Stack floors from a natural swinging pendulum cable using Forge2D rigid-body dynamics. Align drops, balance center of mass, and build into the clouds!',
      category: GameCategory.arcade,
      icon: Icons.apartment_rounded,
      accentColor: Color(0xFF344D3B),
      badgeText: 'FORGE2D PHYSICS',
      statusText: 'EXPEDITION READY',
      isPlayable: true,
    ),
    GameModel(
      id: 'ladder',
      title: 'Word Ladder',
      tagline: '4-Letter Word Shift Puzzle',
      description:
          'Transform a starting word into a target word by changing one letter per move. Plan your path, discover optimal routes, and take on the Daily Challenge!',
      category: GameCategory.puzzle,
      icon: Icons.swap_vert_rounded,
      accentColor: GameColors.mist,
      badgeText: 'ONE-LETTER SHIFT',
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
    final isOdd = _games.length % 2 != 0;

    // Build items: games + promo card in the final slot if odd count
    final List<Widget> items = [];
    for (final game in _games) {
      items.add(GameCard(game: game));
    }
    if (isOdd) {
      items.add(const DiscoverPromoCard(isHorizontal: false));
    }

    // Pair items into 2-in-a-row rows
    final List<Widget> pairedRows = [];
    for (int i = 0; i < items.length; i += 2) {
      final first = items[i];
      final second = (i + 1 < items.length) ? items[i + 1] : const SizedBox.shrink();
      pairedRows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 12),
              Expanded(child: second),
            ],
          ),
        ),
      );
    }

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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  // Editorial Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'COLLECTION',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: GameColors.carbon,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: GameColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: GameColors.borderMuted),
                        ),
                        child: Text(
                          '${_games.length} GAMES',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: GameColors.terrain,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2 Games in a row pairs
                  ...pairedRows,

                  // When even number of games, show dynamic promo in full-sized horizontal banner below
                  if (!isOdd) ...[
                    const DiscoverPromoCard(isHorizontal: true),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
