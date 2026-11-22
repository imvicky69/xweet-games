import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import '../logic/ladder_dictionary.dart';
import '../models/ladder_puzzle.dart';
import '../models/ladder_step.dart';
import 'ladder_word_row.dart';

class LadderSolutionModal extends StatefulWidget {
  final LadderPuzzle puzzle;
  final VoidCallback onPlayNext;
  final VoidCallback onExit;

  const LadderSolutionModal({
    super.key,
    required this.puzzle,
    required this.onPlayNext,
    required this.onExit,
  });

  static Future<void> show({
    required BuildContext context,
    required LadderPuzzle puzzle,
    required VoidCallback onPlayNext,
    required VoidCallback onExit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LadderSolutionModal(
        puzzle: puzzle,
        onPlayNext: onPlayNext,
        onExit: onExit,
      ),
    );
  }

  @override
  State<LadderSolutionModal> createState() => _LadderSolutionModalState();
}

class _LadderSolutionModalState extends State<LadderSolutionModal> {
  late final List<String> _path;
  late final List<int> _changedIndices;
  late final ScrollController _scrollController;

  int _revealedCount = 1;
  bool _isPlaying = true;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    _path = widget.puzzle.optimalPath.isNotEmpty
        ? widget.puzzle.optimalPath
        : (LadderDictionary.instance.findShortestPath(
              widget.puzzle.startWord,
              widget.puzzle.targetWord,
            ) ??
            [widget.puzzle.startWord, widget.puzzle.targetWord]);

    _changedIndices = [];
    for (int i = 0; i < _path.length; i++) {
      if (i == 0) {
        _changedIndices.add(-1);
      } else {
        _changedIndices.add(LadderDictionary.instance.getChangedIndex(_path[i - 1], _path[i]));
      }
    }

    _scrollController = ScrollController();
    _startAnimation();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _stepTimer?.cancel();
    setState(() => _isPlaying = true);

    _stepTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_revealedCount < _path.length) {
        setState(() {
          _revealedCount++;
        });
        AudioService.instance.triggerSelectionHaptic();
        AudioService.instance.playTapSound();

        // Auto-scroll to show newly revealed step
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        if (_revealedCount == _path.length) {
          AudioService.instance.triggerHeavyHaptic();
          setState(() => _isPlaying = false);
          timer.cancel();
        }
      } else {
        setState(() => _isPlaying = false);
        timer.cancel();
      }
    });
  }

  void _pauseAnimation() {
    _stepTimer?.cancel();
    setState(() => _isPlaying = false);
  }

  void _replayAnimation() {
    _stepTimer?.cancel();
    setState(() {
      _revealedCount = 1;
      _isPlaying = true;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    _startAnimation();
  }

  void _stepForward() {
    if (_revealedCount < _path.length) {
      _pauseAnimation();
      setState(() => _revealedCount++);
      AudioService.instance.triggerSelectionHaptic();
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final optimalSteps = _path.length - 1;
    final isFullyRevealed = _revealedCount >= _path.length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: GameColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: GameColors.borderMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: GameColors.carbon,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Optimal Solution Flow',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: GameColors.carbon,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.puzzle.startWord.toUpperCase()} ➔ ${widget.puzzle.targetWord.toUpperCase()} • $optimalSteps optimal steps',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: GameColors.terrain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: GameColors.carbon),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Divider(color: GameColors.borderMuted, height: 1),

            // Progress Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: GameColors.surfaceWhite,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isFullyRevealed ? GameColors.signalLime : GameColors.paper,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: GameColors.carbon, width: 0.8),
                    ),
                    child: Text(
                      isFullyRevealed ? 'SOLUTION COMPLETE' : 'ANIMATING STEPS',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: GameColors.carbon,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _revealedCount / _path.length,
                        backgroundColor: GameColors.borderMuted,
                        valueColor: const AlwaysStoppedAnimation<Color>(GameColors.carbon),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$_revealedCount / ${_path.length}',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: GameColors.carbon,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: GameColors.borderMuted, height: 1),

            // Scrollable Animated Step List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: _revealedCount,
                itemBuilder: (context, index) {
                  final word = _path[index];
                  final isStart = index == 0;
                  final isTarget = index == _path.length - 1;
                  final changedIndex = _changedIndices[index];

                  final step = LadderStep(
                    word: word,
                    changedIndex: changedIndex,
                    stepNumber: index,
                  );

                  String transitionNote = '';
                  if (isStart) {
                    transitionNote = 'Starting Word';
                  } else if (isTarget) {
                    transitionNote = 'Target Goal Reached';
                  } else {
                    final prevChar = _path[index - 1][changedIndex].toUpperCase();
                    final newChar = word[changedIndex].toUpperCase();
                    transitionNote = 'Shift: $prevChar ➔ $newChar';
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      children: [
                        LadderWordRow(
                          step: step,
                          isStart: isStart,
                          isTarget: isTarget,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isStart
                                    ? Icons.play_arrow_rounded
                                    : isTarget
                                        ? Icons.verified_rounded
                                        : Icons.arrow_downward_rounded,
                                size: 12,
                                color: isTarget ? GameColors.carbon : GameColors.terrain,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                transitionNote,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: isTarget ? FontWeight.w800 : FontWeight.w600,
                                  color: isTarget ? GameColors.carbon : GameColors.terrain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Playback and Action Controls
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: GameColors.surfaceWhite,
                border: Border(top: BorderSide(color: GameColors.borderMuted)),
              ),
              child: Column(
                children: [
                  // Playback row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Replay button
                      IconButton(
                        icon: const Icon(Icons.replay_rounded, color: GameColors.carbon),
                        tooltip: 'Replay Animation',
                        onPressed: _replayAnimation,
                      ),
                      const SizedBox(width: 10),
                      // Play / Pause button
                      ElevatedButton.icon(
                        onPressed: _isPlaying ? _pauseAnimation : (_revealedCount >= _path.length ? _replayAnimation : _startAnimation),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.carbon,
                          foregroundColor: GameColors.paper,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _isPlaying ? 'PAUSE' : (_revealedCount >= _path.length ? 'REPLAY' : 'PLAY'),
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Step next button
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: GameColors.carbon),
                        tooltip: 'Step Next',
                        onPressed: _revealedCount < _path.length ? _stepForward : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Bottom action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onExit();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: GameColors.carbon),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            'EXIT PUZZLE',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: GameColors.carbon,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (!widget.puzzle.isDaily) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onPlayNext();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GameColors.signalLime,
                              foregroundColor: GameColors.carbon,
                              side: const BorderSide(color: GameColors.carbon),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              'NEXT PUZZLE',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
