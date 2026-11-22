import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import '../logic/tilt_game_controller.dart';
import '../models/tilt_block_style.dart';

class TiltGameOverModal extends StatelessWidget {
  final TiltGameController controller;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const TiltGameOverModal({
    super.key,
    required this.controller,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    final isNewRecord = controller.score >= controller.personalBestScore && controller.score > 0;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GameColors.surfaceWhite,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: GameColors.carbon, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: GameColors.carbon.withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: GameColors.error.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: GameColors.error),
                  const SizedBox(width: 5),
                  Text(
                    'STRUCTURAL COLLAPSE',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: GameColors.error,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'TILT.',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: GameColors.carbon,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'The tower reached critical equilibrium limits.',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: GameColors.terrain,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 18),

            // Big Score Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: GameColors.paper,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GameColors.borderMuted),
              ),
              child: Column(
                children: [
                  Text(
                    '${controller.score}',
                    style: GoogleFonts.outfit(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: GameColors.carbon,
                      letterSpacing: -1.0,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'FINAL ARCHITECTURAL SCORE',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: GameColors.terrain,
                      letterSpacing: 0.6,
                    ),
                  ),
                  if (isNewRecord) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: GameColors.signalLime,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: GameColors.carbon, width: 1),
                      ),
                      child: Text(
                        'NEW PERSONAL BEST!',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: GameColors.carbon,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricPill(
                    icon: Icons.apartment_rounded,
                    label: 'Floors',
                    value: '${controller.floors}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricPill(
                    icon: Icons.straighten_rounded,
                    label: 'Height',
                    value: '${controller.currentHeightMeters.toStringAsFixed(1)}m',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricPill(
                    icon: Icons.stars_rounded,
                    label: 'Perfect',
                    value: '${controller.perfectDrops}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  AudioService.instance.triggerSelectionHaptic();
                  onRestart();
                },
                icon: const Icon(Icons.replay_rounded, size: 20),
                label: const Text('STACK AGAIN'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  AudioService.instance.triggerSelectionHaptic();
                  onQuit();
                },
                child: const Text('RETURN TO LOBBY'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: GameColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GameColors.borderMuted),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: TiltBlockStyle.mutedForest),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: GameColors.carbon,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: GameColors.terrain,
            ),
          ),
        ],
      ),
    );
  }
}
