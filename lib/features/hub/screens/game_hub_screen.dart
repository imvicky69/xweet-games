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
      tagline: 'Daily Word & Endless Streak Survival',
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
      tagline: 'Architectural Tower Stacking & Physics',
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
      tagline: '4-Letter Word Transformation Puzzle',
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
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
