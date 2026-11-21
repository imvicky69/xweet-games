import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';

/// Ready-to-use Boilerplate Template for adding any new game to Xweet Games
class GameTemplateScreen extends StatefulWidget {
  final String gameTitle;
  final String gameId;

  const GameTemplateScreen({
    super.key,
    required this.gameTitle,
    required this.gameId,
  });

  @override
  State<GameTemplateScreen> createState() => _GameTemplateScreenState();
}

class _GameTemplateScreenState extends State<GameTemplateScreen> {
  int _score = 0;
  bool _isPaused = false;

  void _onAction() {
    AudioService.instance.triggerHaptic();
    setState(() {
      _score += 10;
    });
  }

  void _togglePause() {
    AudioService.instance.triggerSelectionHaptic();
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameTitle.toUpperCase()),
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
            onPressed: _togglePause,
            tooltip: _isPaused ? 'Resume' : 'Pause',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Game Canvas / World Area
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: GameColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GameColors.secondaryNeon.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.extension_rounded,
                            size: 48,
                            color: GameColors.secondaryNeon,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Ready to build: ${widget.gameTitle}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: GameColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This screen is a clean starting template.\nDrop your game loop, Flame canvas, or interactive widgets here.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(
                              fontSize: 14,
                              color: GameColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Score: $_score',
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: GameColors.primaryNeon,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isPaused ? null : _onAction,
                      icon: const Icon(Icons.sports_esports_rounded),
                      label: const Text('TRIGGER ACTION (+10)'),
                    ),
                  ],
                ),
              ),
            ),

            // Paused Overlay
            if (_isPaused)
              Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PAUSED',
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: GameColors.primaryNeon,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _togglePause,
                        child: const Text('RESUME GAME'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
