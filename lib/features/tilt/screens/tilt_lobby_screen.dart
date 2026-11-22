import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import '../models/tilt_block_style.dart';
import '../widgets/tilt_preview_widget.dart';
import '../widgets/tilt_rules_modal.dart';
import 'tilt_playground_screen.dart';

class TiltLobbyScreen extends StatefulWidget {
  const TiltLobbyScreen({super.key});

  @override
  State<TiltLobbyScreen> createState() => _TiltLobbyScreenState();
}

class _TiltLobbyScreenState extends State<TiltLobbyScreen> {
  void _startPlayground() {
    AudioService.instance.triggerHeavyHaptic();
    AudioService.instance.playTapSound();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TiltPlaygroundScreen(),
      ),
    ).then((_) {
      // Refresh statistics after returning from run
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final highScore = StorageService.instance.tiltHighScore;
    final maxHeight = StorageService.instance.tiltMaxHeight;
    final gamesPlayed = StorageService.instance.tiltGamesPlayed;
    final perfectDrops = StorageService.instance.tiltPerfectDrops;

    return Scaffold(
      backgroundColor: GameColors.paper,
      appBar: AppBar(
        title: Text(
          'TILT.',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: GameColors.carbon,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                AudioService.instance.triggerSelectionHaptic();
                TiltRulesModal.show(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: GameColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: GameColors.borderMuted, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.help_outline_rounded,
                      size: 16,
                      color: GameColors.carbon,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'How to Play',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: GameColors.carbon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            // Game Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameColors.surfaceWhite,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: GameColors.borderMuted),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.carbon.withValues(alpha: 0.04),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GameColors.signalLime,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: GameColors.carbon, width: 1),
                        ),
                        child: Text(
                          'FORGE2D PHYSICS ARCADE',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: GameColors.carbon,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'TILT.',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: GameColors.carbon,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Architectural tower stacking powered by rigid-body physics. Time your release, master pendulum momentum, and counterbalance center-of-mass wobbles.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: GameColors.terrain,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TiltPreviewWidget(height: 84),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Statistics Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: GameColors.surfaceWhite,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: GameColors.borderMuted),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatPill('⚡', '$highScore', 'Best Score'),
                  Container(width: 1, height: 32, color: GameColors.borderMuted),
                  _buildStatPill('🏢', '$maxHeight', 'Max Floors'),
                  Container(width: 1, height: 32, color: GameColors.borderMuted),
                  _buildStatPill('⭐', '$perfectDrops', 'Perfects'),
                  Container(width: 1, height: 32, color: GameColors.borderMuted),
                  _buildStatPill('🎮', '$gamesPlayed', 'Runs'),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Main Play Action Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameColors.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: GameColors.carbon, width: 1.6),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.signalLime.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: TiltBlockStyle.mutedForest,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: GameColors.carbon, width: 1),
                        ),
                        child: Text(
                          'ENDLESS EQUILIBRIUM',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        'INFINITE HEIGHT',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: GameColors.terrain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Modern Skyscraper Stacking',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stack floors endlessly with dynamic pendulum acceleration, organic harmonic sway, and real center-of-mass wobbling.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: GameColors.terrain,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startPlayground,
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: const Text('START EXPEDITION'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String emoji, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: GameColors.carbon,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: GameColors.terrain,
          ),
        ),
      ],
    );
  }
}
