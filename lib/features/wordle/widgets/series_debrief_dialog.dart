import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import '../models/series_summary.dart';

class SeriesDebriefDialog extends StatelessWidget {
  final SeriesSummary summary;
  final List<List<String>> emojiGrids;
  final bool isDaily;
  final VoidCallback onNewSeries;
  final VoidCallback onExit;

  const SeriesDebriefDialog({
    super.key,
    required this.summary,
    required this.emojiGrids,
    this.isDaily = false,
    required this.onNewSeries,
    required this.onExit,
  });

  static Future<void> show({
    required BuildContext context,
    required SeriesSummary summary,
    required List<List<String>> emojiGrids,
    bool isDaily = false,
    required VoidCallback onNewSeries,
    required VoidCallback onExit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SeriesDebriefDialog(
        summary: summary,
        emojiGrids: emojiGrids,
        isDaily: isDaily,
        onNewSeries: onNewSeries,
        onExit: onExit,
      ),
    );
  }

  void _shareSummary(BuildContext context) {
    final text = summary.generateShareText(emojiGrids: emojiGrids);
    Clipboard.setData(ClipboardData(text: text));
    AudioService.instance.triggerHeavyHaptic();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Result copied to clipboard!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWon = summary.solvedCount > 0;
    final lastRound = summary.rounds.isNotEmpty ? summary.rounds.last : null;

    return AlertDialog(
      backgroundColor: GameColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: GameColors.carbon, width: 1.4),
      ),
      contentPadding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rating Vector Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDaily ? isWon : summary.solvedCount > 0)
                    ? GameColors.signalLime
                    : GameColors.paper,
                shape: BoxShape.circle,
                border: Border.all(color: GameColors.carbon, width: 1.4),
              ),
              child: Icon(
                isDaily
                    ? (isWon ? Icons.military_tech_rounded : Icons.cancel_outlined)
                    : summary.rating.icon,
                size: 38,
                color: GameColors.carbon,
              ),
            ),
            const SizedBox(height: 8),

            // Rating Title
            Text(
              isDaily
                  ? (isWon ? 'Daily Wordle Solved!' : 'Daily Wordle Over')
                  : 'Survival Run Over',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: GameColors.carbon,
              ),
            ),
            const SizedBox(height: 4),

            // Rating Badge Description
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isDaily
                    ? (isWon ? GameColors.signalLime : GameColors.paper)
                    : GameColors.signalLime,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: GameColors.carbon, width: 1),
              ),
              child: Text(
                isDaily
                    ? (isWon ? 'GAME OF THE DAY SOLVED' : 'OUT OF ATTEMPTS')
                    : '${summary.solvedCount} Words Solved in a Row',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: GameColors.carbon,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Missed Word Info if not won
            if (lastRound != null && !lastRound.isWon) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: GameColors.paper,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GameColors.borderMuted),
                ),
                child: Column(
                  children: [
                    Text(
                      'The secret word was:',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: GameColors.terrain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lastRound.targetWord.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: GameColors.carbon,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Rounds Audit Trail (for survival run)
            if (!isDaily && summary.rounds.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GameColors.paper,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GameColors.borderMuted),
                ),
                child: Column(
                  children: summary.rounds.map((r) {
                    final numStr = r.roundNumber < 10 ? '0${r.roundNumber}' : '${r.roundNumber}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: r.isWon ? GameColors.signalLime : GameColors.terrain.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: GameColors.carbon.withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Text(
                                numStr,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: GameColors.carbon,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r.targetWord.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: GameColors.carbon,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Text(
                            r.isWon ? '${r.attemptsUsed}/6' : 'MISSED',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: r.isWon ? GameColors.carbon : GameColors.terrain,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareSummary(context),
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('SHARE'),
                  ),
                ),
                if (!isDaily) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onNewSeries();
                      },
                      child: const Text('PLAY AGAIN'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onExit();
              },
              child: Text(
                'Return to Lobby',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: GameColors.terrain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
