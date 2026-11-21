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
  final bool isDaily;
  final bool strictDictionary;

  const WordlePlaygroundScreen({
    super.key,
    this.difficulty = WordleDifficulty.progressive,
    this.isDaily = false,
    this.strictDictionary = true,
  });

  @override
  State<WordlePlaygroundScreen> createState() => _WordlePlaygroundScreenState();
}

class _WordlePlaygroundScreenState extends State<WordlePlaygroundScreen> with SingleTickerProviderStateMixin {
  int _currentRound = 1;

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

    final String target;
    if (widget.isDaily) {
      target = await WordRepository.instance.selectDailyWord(DateTime.now());
    } else {
      target = await WordRepository.instance.selectTargetWord(
        difficulty: widget.difficulty,
        roundNumber: roundNum,
      );
    }

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

    if (widget.strictDictionary && !WordRepository.instance.isValidGuess(_currentInput)) {
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
      AudioService.instance.triggerHeavyHaptic();
    } else if (evaluation.isClose) {
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

      // Update virtual keyboard key colors
      for (int i = 0; i < 5; i++) {
        final char = guess[i];
        final newState = evaluation.tileStates[i];
        final existingState = _keyStates[char];

        if (existingState == TileState.correct) {
          continue;
        } else if (existingState == TileState.present && newState == TileState.absent) {
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

      if (widget.isDaily) {
        // Daily Wordle Finished
        await StorageService.instance.recordWordleDailyCompleted(won: won);
        if (!mounted) return;

        final summary = SeriesSummary(
          rounds: _roundHistory,
          solvedCount: won ? 1 : 0,
          totalRounds: 1,
          isDaily: true,
        );

        SeriesDebriefDialog.show(
          context: context,
          summary: summary,
          emojiGrids: _seriesEmojiGrids,
          isDaily: true,
          onNewSeries: () {
            setState(() {
              _roundHistory.clear();
              _seriesEmojiGrids.clear();
            });
            _startRound(1);
          },
          onExit: () => Navigator.of(context).pop(),
        );
      } else {
        // Endless Survival Mode
        if (won) {
          // Solved! Keep advancing endlessly: Round 1, 2, 3, ...
          MidSeriesModal.show(
            context: context,
            completedRound: _currentRound,
            isWon: true,
            attemptsUsed: _guesses.length,
            targetWord: _targetWord,
            onProceed: () => _startRound(_currentRound + 1),
          );
        } else {
          // Lost ("user get outs of box and get wrong then their round ends")
          final streak = _roundHistory.where((r) => r.isWon).length;
          await StorageService.instance.recordWordleSurvivalFinished(
            streak: streak,
            rounds: _roundHistory,
          );

          if (!mounted) return;
          final summary = SeriesSummary(
            rounds: _roundHistory,
            solvedCount: streak,
            totalRounds: _currentRound,
            isDaily: false,
          );

          SeriesDebriefDialog.show(
            context: context,
            summary: summary,
            emojiGrids: _seriesEmojiGrids,
            isDaily: false,
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
            'Leave Game?',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: GameColors.carbon,
            ),
          ),
          content: Text(
            widget.isDaily
                ? 'Your progress in today’s daily wordle will be lost if you exit.'
                : 'Your current survival streak will end if you exit now.',
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
          titleSpacing: 0,
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
                  widget.isDaily
                      ? 'DAILY WORDLE'
                      : 'ROUND ${_currentRound < 10 ? '0$_currentRound' : '$_currentRound'}',
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
                    Icon(
                      widget.isDaily ? Icons.pin_drop_outlined : Icons.local_fire_department_rounded,
                      size: 14,
                      color: widget.isDaily ? GameColors.carbon : Colors.deepOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.isDaily ? '6 Guesses' : 'Streak $solvedSoFar',
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
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: GameColors.carbon),
              tooltip: 'How to Play',
              onPressed: () => HowToPlayModal.show(context),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Error feedback toast
              SizedBox(
                height: 32,
                child: _toastMessage != null
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // 6x5 Wordle Matrix Grid
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: GameColors.carbon)
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          child: WordleGrid(
                            guesses: _guesses,
                            evaluations: _evaluations,
                            currentInput: _currentInput,
                            shakeAnimation: _shakeAnimation,
                          ),
                        ),
                ),
              ),

              // Tactical Keyboard
              WordleKeyboard(
                keyStates: _keyStates,
                onKeyTapped: _onKeyTapped,
                onEnterTapped: _onEnterTapped,
                onDeleteTapped: _onDeleteTapped,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
