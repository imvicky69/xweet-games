import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import 'package:xweet_games/models/game_model.dart';
import 'package:xweet_games/features/games/game_template/screens/game_template_screen.dart';
import 'package:xweet_games/features/games/reaction_tap/screens/reaction_tap_screen.dart';
import 'package:xweet_games/features/settings/screens/settings_screen.dart';
import 'package:xweet_games/features/hub/widgets/game_card.dart';
import 'package:xweet_games/features/hub/widgets/player_profile_header.dart';

class GameHubScreen extends StatefulWidget {
  const GameHubScreen({super.key});

  @override
  State<GameHubScreen> createState() => _GameHubScreenState();
}

class _GameHubScreenState extends State<GameHubScreen> {
  GameCategory _selectedCategory = GameCategory.all;

  late final List<GameModel> _games = [
    GameModel(
      id: 'reaction_tap',
      title: 'Cyber Reflex',
      tagline: 'High-speed target reflex challenge',
      description: 'Tap appearing targets before they disappear to build combos.',
      category: GameCategory.reflex,
      icon: Icons.flash_on_rounded,
      accentColor: GameColors.primaryNeon,
      builder: (context) => const ReactionTapScreen(),
    ),
    GameModel(
      id: 'neon_runner',
      title: 'Neon Dash',
      tagline: 'Arcade endless obstacle course',
      description: 'Dodge obstacles and collect energy orbs in this arcade runner.',
      category: GameCategory.arcade,
      icon: Icons.directions_run_rounded,
      accentColor: GameColors.secondaryNeon,
      builder: (context) => const GameTemplateScreen(
        gameTitle: 'Neon Dash',
        gameId: 'neon_runner',
      ),
    ),
    GameModel(
      id: 'quantum_puzzle',
      title: 'Quantum Grid',
      tagline: 'Pattern matching puzzle brain teaser',
      description: 'Solve grid puzzles and link quantum energy nodes.',
      category: GameCategory.puzzle,
      icon: Icons.grid_view_rounded,
      accentColor: GameColors.accentAmber,
      builder: (context) => const GameTemplateScreen(
        gameTitle: 'Quantum Grid',
        gameId: 'quantum_puzzle',
      ),
    ),
    GameModel(
      id: 'space_vortex',
      title: 'Space Vortex',
      tagline: 'Galactic action space shooter',
      description: 'Command your starship through enemy vortex waves.',
      category: GameCategory.action,
      icon: Icons.rocket_launch_rounded,
      accentColor: GameColors.accentRose,
      builder: (context) => const GameTemplateScreen(
        gameTitle: 'Space Vortex',
        gameId: 'space_vortex',
      ),
    ),
  ];

  void _openGame(GameModel game) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: game.builder),
    ).then((_) {
      // Refresh high scores when returning
      setState(() {});
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    ).then((_) {
      setState(() {});
    });
  }

  int _calculateTotalScore() {
    int total = 0;
    for (final game in _games) {
      total += StorageService.instance.getHighScore(game.id);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final filteredGames = _selectedCategory == GameCategory.all
        ? _games
        : _games.where((g) => g.category == _selectedCategory).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlayerProfileHeader(
                      playerName: StorageService.instance.playerName,
                      totalScore: _calculateTotalScore(),
                      onSettingsTap: _openSettings,
                    ),
                    const SizedBox(height: 24),
                    // Hero Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: GameColors.cardGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GameColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: GameColors.primaryNeon.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'FEATURED GAME',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: GameColors.primaryNeon,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Cyber Reflex',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: GameColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Test your speed and reaction limits now!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: GameColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _openGame(_games.first),
                                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                                  label: const Text('PLAY NOW'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: GameColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: GameColors.primaryNeon.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              size: 44,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Categories horizontal chips
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: GameCategory.values.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = GameCategory.values[index];
                          final isSelected = cat == _selectedCategory;
                          return ChoiceChip(
                            label: Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : GameColors.textSecondary,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: GameColors.primaryNeon,
                            backgroundColor: GameColors.surface,
                            side: BorderSide(
                              color: isSelected ? GameColors.primaryNeon : GameColors.surfaceBorder,
                            ),
                            showCheckmark: false,
                            onSelected: (val) {
                              if (val) {
                                AudioService.instance.triggerSelectionHaptic();
                                setState(() => _selectedCategory = cat);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Game Cards List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = filteredGames[index];
                    final highScore = StorageService.instance.getHighScore(game.id);
                    return GameCard(
                      game: game,
                      highScore: highScore,
                      onPlay: () => _openGame(game),
                    );
                  },
                  childCount: filteredGames.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
