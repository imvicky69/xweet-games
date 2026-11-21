import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/core/services/storage_service.dart';

class ReactionTapScreen extends StatefulWidget {
  const ReactionTapScreen({super.key});

  @override
  State<ReactionTapScreen> createState() => _ReactionTapScreenState();
}

class _ReactionTapScreenState extends State<ReactionTapScreen> {
  static const String gameId = 'reaction_tap';
  static const int gameDurationSeconds = 25;

  Timer? _gameTimer;
  Timer? _targetTimer;
  int _timeLeft = gameDurationSeconds;
  int _score = 0;
  int _combo = 0;
  bool _isPlaying = false;
  bool _isGameOver = false;

  // Target coordinates (normalized 0.1 to 0.85)
  double _targetX = 0.5;
  double _targetY = 0.5;
  final Random _random = Random();

  @override
  void dispose() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();

    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _combo = 0;
      _timeLeft = gameDurationSeconds;
    });

    _spawnNextTarget();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        _endGame();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void _spawnNextTarget() {
    setState(() {
      _targetX = 0.15 + _random.nextDouble() * 0.7;
      _targetY = 0.2 + _random.nextDouble() * 0.6;
    });

    _targetTimer?.cancel();
    // Target moves faster as score increases
    final speedMs = max(600, 1100 - (_score * 12));
    _targetTimer = Timer(Duration(milliseconds: speedMs), () {
      if (_isPlaying) {
        setState(() {
          _combo = 0; // Missed target resets combo
        });
        _spawnNextTarget();
      }
    });
  }

  void _onTargetTapped() {
    if (!_isPlaying) return;

    AudioService.instance.triggerHaptic();
    AudioService.instance.playTapSound();

    setState(() {
      _combo++;
      final points = 10 + (_combo > 3 ? (_combo * 5) : 0);
      _score += points;
    });

    _spawnNextTarget();
  }

  Future<void> _endGame() async {
    _gameTimer?.cancel();
    _targetTimer?.cancel();

    final isNewRecord = await StorageService.instance.setHighScore(gameId, _score);
    AudioService.instance.triggerHeavyHaptic();

    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });

    _showGameOverDialog(isNewRecord);
  }

  void _showGameOverDialog(bool isNewRecord) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GameColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: GameColors.primaryNeon, width: 1.5),
          ),
          title: Center(
            child: Text(
              isNewRecord ? 'NEW HIGH SCORE!' : 'GAME OVER',
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isNewRecord ? GameColors.accentAmber : GameColors.accentRose,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Final Score',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: GameColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$_score',
                style: GoogleFonts.orbitron(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: GameColors.primaryNeon,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Best: ${StorageService.instance.getHighScore(gameId)}',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: GameColors.accentAmber,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Exit to Hub'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CYBER REFLEX'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Time: ${_timeLeft}s',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _timeLeft <= 5 ? GameColors.accentRose : GameColors.primaryNeon,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Score and Combo HUD
            Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SCORE',
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          color: GameColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '$_score',
                        style: GoogleFonts.orbitron(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: GameColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (_combo > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: GameColors.secondaryNeon.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GameColors.secondaryNeon),
                      ),
                      child: Text(
                        'COMBO ${_combo}x',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: GameColors.secondaryNeon,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Game Arena / Target
            if (_isPlaying)
              LayoutBuilder(
                builder: (context, constraints) {
                  final targetLeft = _targetX * (constraints.maxWidth - 70);
                  final targetTop = _targetY * (constraints.maxHeight - 70);

                  return Positioned(
                    left: targetLeft,
                    top: targetTop,
                    child: GestureDetector(
                      onTapDown: (_) => _onTargetTapped(),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: GameColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: GameColors.primaryNeon.withValues(alpha: 0.7),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.bolt_rounded,
                            color: Colors.black,
                            size: 38,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Start Screen Overlay
            if (!_isPlaying && !_isGameOver)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GameColors.primaryNeon.withValues(alpha: 0.15),
                          border: Border.all(color: GameColors.primaryNeon, width: 2),
                        ),
                        child: const Icon(
                          Icons.touch_app_rounded,
                          size: 50,
                          color: GameColors.primaryNeon,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Tap targets as fast as you can before they vanish!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          color: GameColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _startGame,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('START GAME'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                        ),
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
