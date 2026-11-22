import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';

class TiltPauseModal extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const TiltPauseModal({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GameColors.surfaceWhite,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: GameColors.carbon, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: GameColors.carbon.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: GameColors.paper,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: GameColors.borderMuted),
              ),
              child: Text(
                'PHYSICS PAUSED',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: GameColors.carbon,
                  letterSpacing: 0.5,
                ),
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
            const SizedBox(height: 6),
            Text(
              'Take a breath. Stacking equilibrium is suspended.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: GameColors.terrain,
              ),
            ),
            const SizedBox(height: 24),

            // Resume CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  AudioService.instance.triggerSelectionHaptic();
                  onResume();
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('RESUME RUN'),
              ),
            ),
            const SizedBox(height: 10),

            // Restart Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  AudioService.instance.triggerSelectionHaptic();
                  onRestart();
                },
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('RESTART TOWER'),
              ),
            ),
            const SizedBox(height: 10),

            // Quit Button
            TextButton(
              onPressed: () {
                AudioService.instance.triggerSelectionHaptic();
                onQuit();
              },
              child: Text(
                'EXIT TO HUB',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: GameColors.terrain,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
