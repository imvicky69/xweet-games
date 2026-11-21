import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';

class XweetAppHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const XweetAppHeader({
    super.key,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: GameColors.paper,
        border: Border(
          bottom: BorderSide(color: GameColors.borderMuted, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Xweet Logo (clean transparent PNG)
          Hero(
            tag: 'xweet_brand_logo',
            child: Image.asset(
              'assets/images/xweet_logo.png',
              height: 38,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.sports_esports_rounded,
                size: 32,
                color: GameColors.carbon,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Brand Wordmark
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'XWEET',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: GameColors.carbon,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: GameColors.signalLime,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: GameColors.carbon, width: 0.8),
                      ),
                      child: Text(
                        'GAMES',
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: GameColors.carbon,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Tactile Gaming Platform',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: GameColors.terrain,
                  ),
                ),
              ],
            ),
          ),

          // Settings Action Button
          Container(
            decoration: BoxDecoration(
              color: GameColors.surfaceWhite,
              shape: BoxShape.circle,
              border: Border.all(color: GameColors.borderMuted, width: 1),
            ),
            child: IconButton(
              onPressed: () {
                AudioService.instance.triggerSelectionHaptic();
                onSettingsTap();
              },
              icon: const Icon(
                Icons.tune_rounded,
                size: 20,
                color: GameColors.carbon,
              ),
              tooltip: 'Settings',
            ),
          ),
        ],
      ),
    );
  }
}
