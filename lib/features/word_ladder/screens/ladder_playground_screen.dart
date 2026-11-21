import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import '../logic/ladder_dictionary.dart';
import '../logic/ladder_game_controller.dart';
import '../models/ladder_puzzle.dart';
import '../widgets/ladder_completion_modal.dart';
import '../widgets/ladder_keyboard.dart';
import '../widgets/ladder_rules_modal.dart';
import '../widgets/ladder_vertical_timeline.dart';

class LadderPlaygroundScreen extends StatefulWidget {
  final LadderPuzzle initialPuzzle;

  const LadderPlaygroundScreen({
    super.key,
    required this.initialPuzzle,
  });

  @override
  State<LadderPlaygroundScreen> createState() => _LadderPlaygroundScreenState();
}

class _LadderPlaygroundScreenState extends State<LadderPlaygroundScreen> with SingleTickerProviderStateMixin {
  late final LadderGameController _controller;
  late final ScrollController _scrollController;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  bool _isGeneratingNext = false;

  @override
  void initState() {
    super.initState();
    _controller = LadderGameController()..initPuzzle(widget.initialPuzzle);
    _scrollController = ScrollController();

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

    ServicesBinding.instance.keyboard.addHandler(_handlePhysicalKey);
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handlePhysicalKey);
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _scrollController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (_controller.isCompleted) {
      AudioService.instance.triggerHeavyHaptic();
      AudioService.instance.playTapSound();

      final state = _controller.state!;
      StorageService.instance.recordLadderCompleted(
        isDaily: state.puzzle.isDaily,
        moves: state.moveCount,
        optimalMoves: state.optimalMoves,
      );

      LadderCompletionModal.show(
        context: context,
        state: state,
        onPlayNext: _playNextPuzzle,
        onExit: () => Navigator.of(context).pop(),
      );
    }
  }

  bool _handlePhysicalKey(KeyEvent event) {
    if (event is! KeyDownEvent || _controller.isCompleted) return false;

    final keyLabel = event.logicalKey.keyLabel.toUpperCase();
    if (RegExp(r'^[A-Z]$').hasMatch(keyLabel)) {
      _controller.addLetter(keyLabel);
      return true;
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _onSubmit();
      return true;
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _controller.deleteLetter();
      return true;
    }
    return false;
  }

  void _onSubmit() {
    final err = _controller.submitWord();
    if (err != LadderMoveError.none) {
      AudioService.instance.triggerHeavyHaptic();
      _shakeController.reset();
      _shakeController.forward();
    } else {
      AudioService.instance.triggerHaptic();
      AudioService.instance.playTapSound();
      // Scroll to show newly added row
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _playNextPuzzle() async {
    setState(() => _isGeneratingNext = true);
    final next = await LadderDictionary.instance.generateRandomPuzzle(minMoves: 3, maxMoves: 5);
    if (!mounted) return;
    setState(() {
      _isGeneratingNext = false;
      _controller.initPuzzle(next);
    });
  }

  Future<bool> _onWillPop() async {
    if (_controller.state == null || _controller.state!.steps.length <= 1) return true;
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
            'Leave Puzzle?',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: GameColors.carbon,
            ),
          ),
          content: Text(
            'Your ladder progress on this puzzle will be lost.',
            style: GoogleFonts.outfit(fontSize: 14, color: GameColors.terrain),
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
              child: const Text('LEAVE'),
            ),
          ],
        );
      },
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        if (state == null || _isGeneratingNext) {
          return const Scaffold(
            backgroundColor: GameColors.paper,
            body: Center(
              child: CircularProgressIndicator(color: GameColors.carbon),
            ),
          );
        }

        final puzzle = state.puzzle;
        final moveCount = state.moveCount;

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
                      color: puzzle.isDaily ? GameColors.signalLime : GameColors.paper,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: GameColors.carbon, width: 1),
                    ),
                    child: Text(
                      puzzle.isDaily ? 'DAILY LADDER' : 'FREE SHIFT',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: GameColors.carbon,
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
                    child: Text(
                      'Moves: $moveCount',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: GameColors.carbon,
                      ),
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                // Undo Button
                IconButton(
                  icon: const Icon(Icons.undo_rounded, color: GameColors.carbon),
                  tooltip: 'Undo Move',
                  onPressed: state.steps.length > 1 ? () {
                    AudioService.instance.triggerSelectionHaptic();
                    _controller.undoMove();
                  } : null,
                ),
                // Restart Button
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: GameColors.carbon),
                  tooltip: 'Restart Puzzle',
                  onPressed: state.steps.length > 1 ? () {
                    AudioService.instance.triggerSelectionHaptic();
                    _controller.restart();
                  } : null,
                ),
                // Rules
                IconButton(
                  icon: const Icon(Icons.help_outline_rounded, color: GameColors.carbon),
                  tooltip: 'Rules',
                  onPressed: () => LadderRulesModal.show(context),
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Toast error banner
                  SizedBox(
                    height: 28,
                    child: _controller.errorMessage != null
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: GameColors.carbon,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                _controller.errorMessage!,
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

                  // Center Vertical Timeline
                  Expanded(
                    child: LadderVerticalTimeline(
                      state: state,
                      currentInput: _controller.currentInput,
                      scrollController: _scrollController,
                      shakeAnimation: _shakeAnimation,
                    ),
                  ),

                  // Virtual Keyboard
                  LadderKeyboard(
                    onKeyTapped: _controller.addLetter,
                    onEnterTapped: _onSubmit,
                    onDeleteTapped: _controller.deleteLetter,
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
