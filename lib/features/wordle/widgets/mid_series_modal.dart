import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';

class MidSeriesModal extends StatelessWidget {
  final int completedRound;
  final bool isWon;
  final int attemptsUsed;
  final String targetWord;
  final VoidCallback onProceed;

  const MidSeriesModal({
    super.key,
    required this.completedRound,
    required this.isWon,
    required this.attemptsUsed,
    required this.targetWord,
    required this.onProceed,
  });

  static Future<void> show({
    required BuildContext context,
    required int completedRound,
    required bool isWon,
    required int attemptsUsed,
    required String targetWord,
    required VoidCallback onProceed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MidSeriesModal(
        completedRound: completedRound,
        isWon: isWon,
        attemptsUsed: attemptsUsed,
        targetWord: targetWord,
        onProceed: onProceed,
      ),
    );
  }

  Future<void> _lookupDefinition(String word) async {
    final uri = Uri.parse('https://www.google.com/search?q=define+$word');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextRound = completedRound + 1;

    return AlertDialog(
      backgroundColor: GameColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: GameColors.carbon, width: 1.4),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Verdict Emoji / Icon
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isWon ? GameColors.signalLime : GameColors.paper,
              shape: BoxShape.circle,
              border: Border.all(color: GameColors.carbon, width: 1.2),
            ),
            child: Center(
              child: Icon(
                isWon ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
                size: 32,
                color: GameColors.carbon,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            isWon ? 'Splendid Deduction!' : 'Round Missed',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: GameColors.carbon,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            isWon
                ? 'Solved in $attemptsUsed of 6 attempts • +1 Point awarded'
                : 'All 6 attempts used for this round.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: GameColors.terrain,
            ),
          ),
          const SizedBox(height: 18),

          // Target Word Reveal Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: GameColors.paper,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GameColors.borderMuted),
            ),
            child: Column(
              children: [
                Text(
                  'SECRET WORD',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: GameColors.terrain,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  targetWord.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: GameColors.carbon,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          if (!isWon) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _lookupDefinition(targetWord),
              icon: const Icon(Icons.open_in_new_rounded, size: 16, color: GameColors.carbon),
              label: Text(
                'Look up "$targetWord" on Google',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: GameColors.carbon,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),

          // Proceed Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                AudioService.instance.triggerSelectionHaptic();
                Navigator.of(context).pop();
                onProceed();
              },
              child: Text('PROCEED TO ROUND 0$nextRound'),
            ),
          ),
        ],
      ),
    );
  }
}
