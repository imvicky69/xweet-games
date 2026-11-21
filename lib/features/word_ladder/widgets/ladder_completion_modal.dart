import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import '../models/ladder_game_state.dart';

class LadderCompletionModal extends StatelessWidget {
  final LadderGameState state;
  final VoidCallback onPlayNext;
  final VoidCallback onExit;

  const LadderCompletionModal({
    super.key,
    required this.state,
    required this.onPlayNext,
    required this.onExit,
  });

  static Future<void> show({
    required BuildContext context,
    required LadderGameState state,
    required VoidCallback onPlayNext,
    required VoidCallback onExit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LadderCompletionModal(
        state: state,
        onPlayNext: onPlayNext,
        onExit: onExit,
      ),
    );
  }

  void _shareResult(BuildContext context) {
    final puzzle = state.puzzle;
    final buffer = StringBuffer();
    buffer.writeln('Xweet Word Ladder (Shift)');
    buffer.writeln('${puzzle.startWord} ➔ ${puzzle.targetWord}');
    buffer.writeln('Solved in ${state.moveCount} moves! (Optimal: ${puzzle.optimalMoves})');
    buffer.writeln();
    buffer.writeln('Ladder:');
    for (int i = 0; i < state.steps.length; i++) {
      buffer.writeln('${i == 0 ? "START" : i == state.steps.length - 1 ? "GOAL " : "0$i   "}: ${state.steps[i].word}');
    }
    buffer.writeln();
    buffer.writeln('https://xweet.in');

    Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    AudioService.instance.triggerHeavyHaptic();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Word Ladder solution copied to clipboard!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = state.puzzle;
    final moves = state.moveCount;
    final optimal = puzzle.optimalMoves;
    final isOptimal = moves <= optimal;

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
            // Trophy Emoji
            Text(isOptimal ? '🏆' : '🎉', style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 8),

            Text(
              isOptimal ? 'Flawless Solution!' : 'Ladder Completed!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: GameColors.carbon,
              ),
            ),
            const SizedBox(height: 4),

            // Performance Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isOptimal ? GameColors.signalLime : GameColors.mist,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: GameColors.carbon, width: 1),
              ),
              child: Text(
                isOptimal ? 'PERFECT SHORTEST PATH' : '$moves MOVES (OPTIMAL: $optimal)',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: GameColors.carbon,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Transformation Summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GameColors.paper,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: GameColors.borderMuted),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        puzzle.startWord,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: GameColors.carbon,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_forward_rounded, size: 18, color: GameColors.carbon),
                      ),
                      Text(
                        puzzle.targetWord,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: GameColors.carbon,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your Ladder Path: ${state.steps.map((s) => s.word).join(" ➔ ")}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: GameColors.terrain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isOptimal && puzzle.optimalPath.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Divider(height: 1, color: GameColors.borderMuted),
                    const SizedBox(height: 8),
                    Text(
                      'Optimal Shortest Path:\n${puzzle.optimalPath.join(" ➔ ")}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: GameColors.carbon,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareResult(context),
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('SHARE'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onPlayNext();
                    },
                    child: Text(puzzle.isDaily ? 'FREE PLAY' : 'NEXT PUZZLE'),
                  ),
                ),
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
