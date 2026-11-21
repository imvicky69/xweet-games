import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import '../models/tile_state.dart';

class WordleKeyboard extends StatelessWidget {
  final Map<String, TileState> keyStates;
  final ValueChanged<String> onKeyTapped;
  final VoidCallback onEnterTapped;
  final VoidCallback onDeleteTapped;

  const WordleKeyboard({
    super.key,
    required this.keyStates,
    required this.onKeyTapped,
    required this.onEnterTapped,
    required this.onDeleteTapped,
  });

  static const List<List<String>> _keyboardLayout = [
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
        children: _keyboardLayout.map((row) {
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
                    child: _buildKeyButton(key, isSpecialKey),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyButton(String key, bool isSpecialKey) {
    final state = keyStates[key];

    Color bgColor = GameColors.surfaceWhite;
    Color textColor = GameColors.carbon;
    Border border = Border.all(color: GameColors.borderMuted, width: 1);

    if (state != null) {
      switch (state) {
        case TileState.correct:
          bgColor = GameColors.signalLime;
          textColor = GameColors.carbon;
          border = Border.all(color: GameColors.carbon, width: 1.2);
          break;
        case TileState.present:
          bgColor = GameColors.mist;
          textColor = GameColors.carbon;
          border = Border.all(color: GameColors.carbon, width: 1.2);
          break;
        case TileState.absent:
          bgColor = GameColors.terrain.withValues(alpha: 0.25);
          textColor = GameColors.terrain.withValues(alpha: 0.7);
          border = Border.all(color: GameColors.borderMuted, width: 1);
          break;
        default:
          break;
      }
    }

    if (isSpecialKey) {
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
            child: isSpecialKey && key == 'DEL'
                ? const Icon(
                    Icons.backspace_outlined,
                    size: 19,
                    color: GameColors.paper,
                  )
                : Text(
                    key,
                    style: GoogleFonts.outfit(
                      fontSize: isSpecialKey ? 12 : 17,
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
