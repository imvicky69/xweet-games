import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/models/game_model.dart';
import 'package:xweet_games/features/hub/widgets/game_card.dart';
import 'package:xweet_games/features/hub/widgets/xweet_app_header.dart';
import 'package:xweet_games/features/settings/screens/settings_screen.dart';

class GameHubScreen extends StatefulWidget {
  const GameHubScreen({super.key});

  @override
  State<GameHubScreen> createState() => _GameHubScreenState();
}

class _GameHubScreenState extends State<GameHubScreen> {
  int _currentNavIndex = 0;

  // Single game registered for now as per requirement: Wordle
  final List<GameModel> _games = const [
    GameModel(
      id: 'wordle',
      title: 'Wordle',
      tagline: '5-Round Series Lexical Expedition',
      description:
          'Strict Tactile Editorial Wordle. 5 independent rounds, progressive vocabulary ramp (top 900 to 5,757 words), audio triggers, and precision ratings.',
      category: GameCategory.lexical,
      icon: Icons.grid_view_rounded,
      accentColor: GameColors.signalLime,
      badgeText: '5-ROUND SERIES',
      statusText: 'EXPEDITION READY',
      isPlayable: false,
    ),
  ];

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _showWordleSpecificationSheet(GameModel game) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: ListView(
                controller: scrollController,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: GameColors.borderMuted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Header Badge & Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GameColors.signalLime,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: GameColors.carbon, width: 1),
                        ),
                        child: Text(
                          'SPECIFICATION',
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: GameColors.carbon,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'xweet.in/wordle',
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          color: GameColors.terrain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Xweet Wordle Expedition',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: GameColors.carbon,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Native Android edition adhering to Tactile Editorial Light Mode.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: GameColors.terrain,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Design Tokens Showcase
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GameColors.paper,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: GameColors.borderMuted),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EDITORIAL PALETTE TOKENS',
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GameColors.carbon,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTokenRow('Signal Lime', '#D7F36A', GameColors.signalLime, 'Correct letter tiles & CTAs'),
                        const SizedBox(height: 8),
                        _buildTokenRow('Mist', '#B7A7D9', GameColors.mist, 'Present misplaced letters'),
                        const SizedBox(height: 8),
                        _buildTokenRow('Carbon', '#171815', GameColors.carbon, 'Primary typography & dark buttons', isDark: true),
                        const SizedBox(height: 8),
                        _buildTokenRow('Terrain', '#858779', GameColors.terrain, 'Absent keys & muted telemetry', isDark: true),
                        const SizedBox(height: 8),
                        _buildTokenRow('Paper', '#F0EFE6', GameColors.paper, 'Canvas background & surfaces'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tournament Structure
                  Text(
                    'TOURNAMENT ARCHITECTURE',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: GameColors.carbon,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 5 Independent Rounds per Series\n'
                    '• Progressive Difficulty Ramp (R1: 900 words -> R5: 5,757 words)\n'
                    '• 3 Audio Triggers: correct.mp3, boom.mp3, close.mp3\n'
                    '• Series Debrief Ratings: Grandmaster (5/5), Master (4/5), Wordsmith (3/5)\n'
                    '• Google Definition Lookup on round misses',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: GameColors.carbon,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Close Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('GOT IT'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTokenRow(String name, String hex, Color color, String desc, {bool isDark = false}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GameColors.carbon.withValues(alpha: 0.2)),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: GameColors.carbon,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  hex,
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    color: GameColors.terrain,
                  ),
                ),
              ],
            ),
            Text(
              desc,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: GameColors.terrain,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            // Editorial Header with Xweet Logo
            XweetAppHeader(onSettingsTap: _openSettings),

            // Main Content Area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                children: [
                  // Editorial Hero Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: GameColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: GameColors.borderMuted),
                      boxShadow: [
                        BoxShadow(
                          color: GameColors.carbon.withValues(alpha: 0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: GameColors.mist.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: GameColors.mist, width: 1),
                              ),
                              child: Text(
                                'EDITORIAL LIGHT MODE',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: GameColors.carbon,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Artisanal Cartography & Lexical Telemetry',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: GameColors.carbon,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Crafted with high-contrast tactile elements, etched 1px borders, and physical print styling.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: GameColors.terrain,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Quick Palette Swatches
                        Row(
                          children: [
                            _buildMiniSwatch(GameColors.signalLime, 'LIME'),
                            const SizedBox(width: 8),
                            _buildMiniSwatch(GameColors.mist, 'MIST'),
                            const SizedBox(width: 8),
                            _buildMiniSwatch(GameColors.carbon, 'CARBON', isDark: true),
                            const SizedBox(width: 8),
                            _buildMiniSwatch(GameColors.terrain, 'TERRAIN', isDark: true),
                            const SizedBox(width: 8),
                            _buildMiniSwatch(GameColors.paper, 'PAPER'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FEATURED EXPEDITIONS',
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: GameColors.carbon,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '01 READY',
                        style: GoogleFonts.spaceMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: GameColors.terrain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Games List - Only Wordle for now
                  ..._games.map((game) {
                    return GameCard(
                      game: game,
                      onTap: () => _showWordleSpecificationSheet(game),
                    );
                  }),
                ],
              ),
            ),

            // Bottom Navigation with Clean White Background ("add bottom bg white")
            Container(
              decoration: BoxDecoration(
                color: GameColors.surfaceWhite,
                border: Border(
                  top: BorderSide(color: GameColors.borderMuted, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.carbon.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomNavItem(
                        index: 0,
                        icon: Icons.grid_view_rounded,
                        label: 'GAMES',
                      ),
                      _buildBottomNavItem(
                        index: 1,
                        icon: Icons.history_edu_rounded,
                        label: 'EXPEDITIONS',
                      ),
                      _buildBottomNavItem(
                        index: 2,
                        icon: Icons.analytics_outlined,
                        label: 'SERIES AUDIT',
                      ),
                      _buildBottomNavItem(
                        index: 3,
                        icon: Icons.tune_rounded,
                        label: 'SETTINGS',
                        onTap: _openSettings,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniSwatch(Color color, String label, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GameColors.carbon.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceMono(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : GameColors.carbon,
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        AudioService.instance.triggerSelectionHaptic();
        if (onTap != null) {
          onTap();
        } else {
          setState(() => _currentNavIndex = index);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? GameColors.signalLime : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                border: isSelected ? Border.all(color: GameColors.carbon, width: 1) : null,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? GameColors.carbon : GameColors.terrain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? GameColors.carbon : GameColors.terrain,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
