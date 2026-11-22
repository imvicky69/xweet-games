import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import '../logic/tilt_game_controller.dart';
import '../models/tilt_block_style.dart';

class TiltHudOverlay extends StatelessWidget {
  final TiltGameController controller;
  final VoidCallback onPause;

  const TiltHudOverlay({
    super.key,
    required this.controller,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final tiltDeg = controller.currentTiltDegrees.abs();
        final isWarning = controller.isWarningTilt;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              children: [
                // Top Row: Pause Button, Height/Floor Tag, Best Score
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pause Button
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        AudioService.instance.triggerSelectionHaptic();
                        onPause();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: GameColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: GameColors.borderMuted, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: GameColors.carbon.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pause_rounded,
                          size: 20,
                          color: GameColors.carbon,
                        ),
                      ),
                    ),

                    // Tower Height & Level Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: GameColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: GameColors.borderMuted),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.apartment_rounded, size: 14, color: TiltBlockStyle.mutedForest),
                          const SizedBox(width: 6),
                          Text(
                            'FLOOR ${controller.floors}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: GameColors.carbon,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '//  ${controller.currentHeightMeters.toStringAsFixed(1)}M',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: GameColors.terrain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Best Score Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: GameColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: GameColors.borderMuted),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: GameColors.carbon,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${controller.personalBestScore}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: GameColors.carbon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Center Score & Stability Tilt Gauge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Score Counter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.score}',
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: GameColors.carbon,
                            height: 1.0,
                            letterSpacing: -1.0,
                          ),
                        ),
                        if (controller.combo > 1)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: GameColors.signalLime,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: GameColors.carbon, width: 1),
                            ),
                            child: Text(
                              '${controller.combo}X COMBO',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: GameColors.carbon,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Real-Time Tilt Stability Meter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isWarning
                            ? GameColors.warning.withValues(alpha: 0.15)
                            : GameColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isWarning ? GameColors.warning : GameColors.borderMuted,
                          width: isWarning ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: 14,
                            color: isWarning ? GameColors.warning : GameColors.terrain,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'TILT ${tiltDeg.toStringAsFixed(1)}°',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isWarning ? const Color(0xFFB5701A) : GameColors.carbon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
