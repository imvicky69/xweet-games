import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';

class LadderKeyboard extends StatelessWidget {
  final ValueChanged<String> onKeyTapped;
  final VoidCallback onEnterTapped;
  final VoidCallback onDeleteTapped;

  const LadderKeyboard({
    super.key,
    required this.onKeyTapped,
    required this.onEnterTapped,
    required this.onDeleteTapped,
  });

  static const List<List<String>> _layout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'DEL'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _layout.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                final isSpecialKey = key == 'ENTER' || key == 'DEL';
                final flex = isSpecialKey ? 3 : 2;

                return Expanded(
                  flex: flex,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: _buildKey(key, isSpecialKey),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKey(String key, bool isSpecial) {
    Color bgColor = GameColors.surfaceWhite;
    Color textColor = GameColors.carbon;
    Border border = Border.all(color: GameColors.borderMuted, width: 1);

    if (isSpecial) {
      bgColor = GameColors.carbon;
      textColor = GameColors.paper;
      border = Border.all(color: GameColors.carbon, width: 1);
    }

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: border,
        boxShadow: [
          BoxShadow(
            color: GameColors.carbon.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            AudioService.instance.triggerHaptic();
            AudioService.instance.playTapSound();

            if (key == 'ENTER') {
              onEnterTapped();
            } else if (key == 'DEL') {
              onDeleteTapped();
            } else {
              onKeyTapped(key);
            }
          },
          child: Center(
            child: isSpecial && key == 'DEL'
                ? const Icon(
                    Icons.backspace_outlined,
                    size: 19,
                    color: GameColors.paper,
                  )
                : Text(
                    key,
                    style: GoogleFonts.outfit(
                      fontSize: isSpecial ? 12 : 17,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
