import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../flame/tilt_game.dart';
import '../logic/tilt_game_controller.dart';
import '../models/tilt_game_state.dart';
import '../widgets/tilt_feedback_overlay.dart';
import '../widgets/tilt_game_over_modal.dart';
import '../widgets/tilt_hud_overlay.dart';
import '../widgets/tilt_pause_modal.dart';

class TiltPlaygroundScreen extends StatefulWidget {
  const TiltPlaygroundScreen({super.key});

  @override
  State<TiltPlaygroundScreen> createState() => _TiltPlaygroundScreenState();
}

class _TiltPlaygroundScreenState extends State<TiltPlaygroundScreen> {
  late final TiltGameController _controller;
  late final TiltGame _game;

  @override
  void initState() {
    super.initState();
    _controller = TiltGameController();
    _game = TiltGame(controller: _controller);
  }

  void _onPause() {
    _controller.pauseGame();
  }

  void _onResume() {
    _controller.resumeGame();
  }

  void _onRestart() {
    _game.restartGame();
  }

  void _onQuit() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_controller.status == TiltStatus.swinging) {
          _controller.pauseGame();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3ED),
        body: Stack(
          children: [
            // 1. Interactive Flame + Forge2D Canvas
            GameWidget<TiltGame>(
              game: _game,
            ),

            // 2. Minimalist Architectural HUD Overlay
            TiltHudOverlay(
              controller: _controller,
              onPause: _onPause,
            ),

            // 3. Perfect / Great Impact Score Popups
            TiltFeedbackOverlay(
              controller: _controller,
            ),

            // 4. State Modals (Pause & Game Over)
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                if (_controller.status == TiltStatus.paused) {
                  return Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: TiltPauseModal(
                      onResume: _onResume,
                      onRestart: _onRestart,
                      onQuit: _onQuit,
                    ),
                  );
                }

                if (_controller.status == TiltStatus.gameOver) {
                  return Container(
                    color: Colors.black.withValues(alpha: 0.40),
                    child: TiltGameOverModal(
                      controller: _controller,
                      onRestart: _onRestart,
                      onQuit: _onQuit,
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
