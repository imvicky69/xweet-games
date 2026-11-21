import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import '../logic/word_repository.dart';
import '../logic/wordle_evaluator.dart';
import '../models/guess_evaluation.dart';
import '../models/round_record.dart';
import '../models/series_summary.dart';
import '../models/tile_state.dart';
import '../models/wordle_difficulty.dart';
import '../widgets/how_to_play_modal.dart';
import '../widgets/mid_series_modal.dart';
import '../widgets/series_debrief_dialog.dart';
import '../widgets/wordle_grid.dart';
import '../widgets/wordle_keyboard.dart';

class WordlePlaygroundScreen extends StatefulWidget {
  final WordleDifficulty difficulty;

  const WordlePlaygroundScreen({
    super.key,
    required this.difficulty,
  });

  @override
  State<WordlePlaygroundScreen> createState() => _WordlePlaygroundScreenState();
}

class _WordlePlaygroundScreenState extends State<WordlePlaygroundScreen> with SingleTickerProviderStateMixin {
  int _currentRound = 1;
  final int _totalRounds = 5;

  String _targetWord = '';
  final List<String> _guesses = [];
  final List<GuessEvaluation> _evaluations = [];
  String _currentInput = '';
  final Map<String, TileState> _keyStates = {};

  final List<RoundRecord> _roundHistory = [];
  final List<List<String>> _seriesEmojiGrids = [];
  List<String> _currentRoundEmojiRows = [];

  bool _isLoading = true;
  bool _isProcessingGuess = false;
  String? _toastMessage;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    ServicesBinding.instance.keyboard.addHandler(_handlePhysicalKeyEvent);
    _startRound(1);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handlePhysicalKeyEvent);
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _startRound(int roundNum) async {
    setState(() {
      _isLoading = true;
      _currentRound = roundNum;
      _guesses.clear();
      _evaluations.clear();
      _currentInput = '';
      _keyStates.clear();
      _currentRoundEmojiRows = [];
      _toastMessage = null;
    });

    final target = await WordRepository.instance.selectTargetWord(
      difficulty: widget.difficulty,
      roundNumber: roundNum,
    );

    if (!mounted) return;
    setState(() {
      _targetWord = target.toUpperCase();
      _isLoading = false;
    });
  }

  bool _handlePhysicalKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || _isLoading || _isProcessingGuess) return false;

    final keyLabel = event.logicalKey.keyLabel.toUpperCase();
    if (RegExp(r'^[A-Z]$').hasMatch(keyLabel)) {
      _onKeyTapped(keyLabel);
      return true;
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _onEnterTapped();
      return true;
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _onDeleteTapped();
      return true;
    }
    return false;
  }

  void _onKeyTapped(String letter) {
    if (_currentInput.length >= 5 || _guesses.length >= 6) return;
    setState(() {
      _currentInput += letter.toUpperCase();
      _toastMessage = null;
    });
  }

  void _onDeleteTapped() {
    if (_currentInput.isEmpty) return;
    setState(() {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      _toastMessage = null;
    });
  }

  void _triggerShake(String message) {
    setState(() {
      _toastMessage = message;
    });
    AudioService.instance.triggerHeavyHaptic();
    _shakeController.reset();
    _shakeController.forward();
  }

  Future<void> _onEnterTapped() async {
    if (_isProcessingGuess || _guesses.length >= 6) return;

    if (_currentInput.length < 5) {
      _triggerShake('Not enough letters');
      return;
    }

    if (!WordRepository.instance.isValidGuess(_currentInput)) {
      _triggerShake('Not in word list');
      return;
    }

    _isProcessingGuess = true;
    final guess = _currentInput;
    final evaluation = WordleEvaluator.evaluateGuess(guess, _targetWord);

    // Audio cues and haptics as per wordle.md Section 6
    if (evaluation.isWinning) {
      AudioService.instance.triggerHeavyHaptic();
      AudioService.instance.playTapSound();
    } else if (evaluation.allMissing) {
      // Boom sound trigger (all letters absent)
      AudioService.instance.triggerHeavyHaptic();
    } else if (evaluation.isClose) {
      // Close call trigger
      AudioService.instance.triggerHaptic();
    }

    // Build emoji row for this guess
    final emojiRow = evaluation.tileStates.map((s) {
      switch (s) {
        case TileState.correct:
          return '🟩';
        case TileState.present:
          return '🟪';
        default:
          return '⬛';
      }
    }).join('');
    _currentRoundEmojiRows.add(emojiRow);

    setState(() {
      _guesses.add(guess);
      _evaluations.add(evaluation);
      _currentInput = '';
      _toastMessage = null;

      // Update virtual keyboard key colors with resolution priority:
      // CORRECT > PRESENT > ABSENT > UNTOUCHED
      for (int i = 0; i < 5; i++) {
        final char = guess[i];
        final newState = evaluation.tileStates[i];
        final existingState = _keyStates[char];

        if (existingState == TileState.correct) {
          // Correct trumps everything
          continue;
        } else if (existingState == TileState.present && newState == TileState.absent) {
          // Present trumps absent
          continue;
        } else {
          _keyStates[char] = newState;
        }
      }
    });

    // Wait for tile flip animation to settle
    await Future.delayed(const Duration(milliseconds: 900));
    _isProcessingGuess = false;

    if (!mounted) return;

    // Check round outcome
    final won = evaluation.isWinning;
    final lost = _guesses.length >= 6 && !won;

    if (won || lost) {
      final record = RoundRecord(
        roundNumber: _currentRound,
        targetWord: _targetWord,
        attemptsUsed: _guesses.length,
        isWon: won,
      );
      _roundHistory.add(record);
      _seriesEmojiGrids.add(List.from(_currentRoundEmojiRows));

      if (_currentRound < _totalRounds) {
        // Mid-Series Modal (Rounds 1–4)
        MidSeriesModal.show(
          context: context,
          completedRound: _currentRound,
          isWon: won,
          attemptsUsed: _guesses.length,
          targetWord: _targetWord,
          onProceed: () => _startRound(_currentRound + 1),
        );
      } else {
        // Final Series Debrief (After Round 5)
        final solvedCount = _roundHistory.where((r) => r.isWon).length;
        final summary = SeriesSummary(
          rounds: _roundHistory,
          solvedCount: solvedCount,
          totalRounds: _totalRounds,
        );

        // Record career stats
        await StorageService.instance.recordSeriesFinished(
          won: solvedCount >= 3,
          rounds: _roundHistory,
        );

        if (!mounted) return;
        SeriesDebriefDialog.show(
          context: context,
          summary: summary,
          emojiGrids: _seriesEmojiGrids,
          onNewSeries: () {
            setState(() {
              _roundHistory.clear();
              _seriesEmojiGrids.clear();
            });
            _startRound(1);
          },
          onExit: () => Navigator.of(context).pop(),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_roundHistory.isEmpty && _guesses.isEmpty) return true;
    if (!mounted) return false;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: GameColors.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: GameColors.carbon, width: 1.2),
          ),
          title: Text(
            'Leave Expedition?',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: GameColors.carbon,
            ),
          ),
          content: Text(
            'Your progress in this 5-round tournament will be lost if you exit now.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: GameColors.terrain,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('STAY'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('EXIT GAME'),
            ),
          ],
        );
      },
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final solvedSoFar = _roundHistory.where((r) => r.isWon).length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final canExit = await _onWillPop();
        if (canExit && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: GameColors.paper,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: GameColors.carbon),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final canExit = await _onWillPop();
              if (canExit && mounted) {
                navigator.pop();
              }
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GameColors.signalLime,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: GameColors.carbon, width: 1),
                ),
                child: Text(
                  'ROUND 0$_currentRound / 0$_totalRounds',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: GameColors.carbon,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GameColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: GameColors.borderMuted),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: GameColors.carbon),
                    const SizedBox(width: 4),
                    Text(
                      '$solvedSoFar Pt${solvedSoFar == 1 ? '' : 's'}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: GameColors.carbon,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            // Sound Mute Toggle
            IconButton(
              icon: Icon(
                AudioService.instance.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: GameColors.carbon,
              ),
              onPressed: () {
                setState(() {
                  AudioService.instance.soundEnabled = !AudioService.instance.soundEnabled;
                });
                StorageService.instance.setSoundEnabled(AudioService.instance.soundEnabled);
              },
              tooltip: 'Toggle Sound',
            ),
            // Help Modal
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: GameColors.carbon),
              onPressed: () => HowToPlayModal.show(context),
              tooltip: 'Rules',
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: GameColors.carbon),
                )
              : Column(
                  children: [
                    // Difficulty indicator pill
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${widget.difficulty.title} Mode • 6 Attempts',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: GameColors.terrain,
                        ),
                      ),
                    ),

                    // Toast message banner on error/shake
                    SizedBox(
                      height: 26,
                      child: _toastMessage != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: GameColors.carbon,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                _toastMessage!,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: GameColors.paper,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Center 5x6 Wordle Grid
                    Expanded(
                      child: Center(
                        child: WordleGrid(
                          guesses: _guesses,
                          evaluations: _evaluations,
                          currentInput: _currentInput,
                          maxAttempts: 6,
                          shakeAnimation: _shakeAnimation,
                        ),
                      ),
                    ),

                    // Virtual Keyboard
                    WordleKeyboard(
                      keyStates: _keyStates,
                      onKeyTapped: _onKeyTapped,
                      onEnterTapped: _onEnterTapped,
                      onDeleteTapped: _onDeleteTapped,
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
        ),
      ),
    );
  }
}
