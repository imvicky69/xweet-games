import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import '../logic/tilt_game_controller.dart';
import '../models/tilt_score_event.dart';

class TiltFeedbackOverlay extends StatefulWidget {
  final TiltGameController controller;

  const TiltFeedbackOverlay({super.key, required this.controller});

  @override
  State<TiltFeedbackOverlay> createState() => _TiltFeedbackOverlayState();
}

class _TiltFeedbackOverlayState extends State<TiltFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  TiltScoreEvent? _currentEvent;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    widget.controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    final event = widget.controller.lastScoreEvent;
    if (event != null && event != _currentEvent) {
      _currentEvent = event;
      _anim.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        if (_anim.value == 0.0 || _anim.value == 1.0 || _currentEvent == null) {
          return const SizedBox.shrink();
        }

        final event = _currentEvent!;
        final opacity = (1.0 - _anim.value).clamp(0.0, 1.0);
        final translateY = -30.0 * _anim.value;
        final scale = 0.8 + 0.3 * (1.0 - (_anim.value - 0.3).abs() * 2).clamp(0.0, 1.0);

        final isPerfect = event.isPerfect;
        final bgColor = isPerfect ? GameColors.signalLime : GameColors.surfaceWhite;
        final textColor = GameColors.carbon;

        return Positioned(
          top: MediaQuery.of(context).size.height * 0.28 + translateY,
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: GameColors.carbon, width: 1.4),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.carbon.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPerfect) ...[
                        const Icon(Icons.stars_rounded, color: GameColors.carbon, size: 18),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        event.label,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+${event.pointsAwarded}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
