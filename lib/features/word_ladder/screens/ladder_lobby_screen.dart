import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import '../logic/ladder_dictionary.dart';
import '../widgets/ladder_rules_modal.dart';
import 'ladder_playground_screen.dart';

class LadderLobbyScreen extends StatefulWidget {
  const LadderLobbyScreen({super.key});

  @override
  State<LadderLobbyScreen> createState() => _LadderLobbyScreenState();
}

class _LadderLobbyScreenState extends State<LadderLobbyScreen> {
  bool _isLoadingDaily = false;
  bool _isLoadingRandom = false;

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _playDailyPuzzle() async {
    if (_isLoadingDaily || _isLoadingRandom) return;
    AudioService.instance.triggerHeavyHaptic();
    AudioService.instance.playTapSound();

    setState(() => _isLoadingDaily = true);
    try {
      final puzzle = await LadderDictionary.instance.generateDailyPuzzle(DateTime.now());
      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LadderPlaygroundScreen(initialPuzzle: puzzle),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingDaily = false);
      }
    }
  }

  Future<void> _playRandomPuzzle() async {
    if (_isLoadingDaily || _isLoadingRandom) return;
    AudioService.instance.triggerHeavyHaptic();
    AudioService.instance.playTapSound();

    setState(() => _isLoadingRandom = true);
    try {
      final puzzle = await LadderDictionary.instance.generateRandomPuzzle(minMoves: 3, maxMoves: 5);
      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LadderPlaygroundScreen(initialPuzzle: puzzle),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingRandom = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDailyDone = StorageService.instance.isDailyCompletedToday();
    final todayFormatted = _formatDate(DateTime.now());

    return Scaffold(
      backgroundColor: GameColors.paper,
      appBar: AppBar(
        title: Text(
          'Word Ladder',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: GameColors.carbon,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                AudioService.instance.triggerSelectionHaptic();
                LadderRulesModal.show(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: GameColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: GameColors.borderMuted, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.help_outline_rounded,
                      size: 16,
                      color: GameColors.carbon,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'How to Play',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: GameColors.carbon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            // Game Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameColors.surfaceWhite,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: GameColors.borderMuted),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.carbon.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GameColors.mist,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: GameColors.carbon, width: 1),
                        ),
                        child: Text(
                          'ONE-LETTER SHIFT',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: GameColors.carbon,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Word Ladder (Shift)',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Transform a starting word into a target word by changing exactly one letter per move. Every word must exist in the dictionary.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: GameColors.terrain,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Visual preview: COLD -> CORD -> WORD -> WARM
                  _buildPreviewLadder(),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Game Statistics Pill Row
            _buildGameStats(),

            const SizedBox(height: 22),

            // Mode 1: Daily Puzzle Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameColors.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDailyDone ? GameColors.borderMuted : GameColors.carbon,
                  width: isDailyDone ? 1.0 : 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDailyDone ? GameColors.carbon : GameColors.signalLime).withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GameColors.signalLime,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: GameColors.carbon, width: 1),
                        ),
                        child: Text(
                          'DAILY PUZZLE',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: GameColors.carbon,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        todayFormatted,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: GameColors.terrain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Daily Word Shift',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A new curated puzzle each calendar day, identical for every player worldwide. Compete for streak and optimal move count!',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: GameColors.terrain,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (isDailyDone)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: GameColors.signalLime.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GameColors.carbon.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: GameColors.carbon, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Completed today! Streak increased.',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: GameColors.carbon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingDaily ? null : _playDailyPuzzle,
                      icon: _isLoadingDaily
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: GameColors.carbon),
                            )
                          : Icon(
                              isDailyDone ? Icons.replay_rounded : Icons.play_arrow_rounded,
                              size: 22,
                            ),
                      label: Text(
                        isDailyDone ? 'REPLAY TODAY’S PUZZLE' : 'PLAY DAILY PUZZLE',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Mode 2: Free Run / Unlimited Play Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameColors.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: GameColors.borderMuted, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.carbon.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GameColors.mist.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: GameColors.carbon, width: 1),
                        ),
                        child: Text(
                          'UNLIMITED FREE RUN',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: GameColors.carbon,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        'INFINITE',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: GameColors.terrain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Practice & Free Play',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Endless dynamically generated 4-letter puzzles. Tested for solvability in 3 to 5 optimal moves using on-device graph traversal.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: GameColors.terrain,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoadingRandom ? null : _playRandomPuzzle,
                      icon: _isLoadingRandom
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: GameColors.carbon),
                            )
                          : const Icon(Icons.shuffle_rounded, size: 20),
                      label: const Text('PLAY RANDOM PUZZLE'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: GameColors.paper,
                        side: const BorderSide(color: GameColors.carbon, width: 1.5),
                        foregroundColor: GameColors.carbon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStats() {
    final played = StorageService.instance.ladderPlayed;
    final won = StorageService.instance.ladderWon;
    final streak = StorageService.instance.ladderStreak;
    final bestStreak = StorageService.instance.ladderBestStreak;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: GameColors.surfaceWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GameColors.borderMuted),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatPill('🎮', '$played', 'Played'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatPill('🏆', '$won', 'Solved'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatPill('🔥', '$streak', 'Streak'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatPill('⚡', '$bestStreak', 'Best'),
        ],
      ),
    );
  }

  Widget _buildStatPill(String emoji, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: GameColors.carbon,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: GameColors.terrain,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewLadder() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.borderMuted),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMiniWordChip('COLD', changedIdx: -1, isStart: true),
          const Icon(Icons.arrow_forward_rounded, size: 16, color: GameColors.terrain),
          _buildMiniWordChip('CORD', changedIdx: 2),
          const Icon(Icons.arrow_forward_rounded, size: 16, color: GameColors.terrain),
          _buildMiniWordChip('WORD', changedIdx: 0),
          const Icon(Icons.arrow_forward_rounded, size: 16, color: GameColors.terrain),
          _buildMiniWordChip('WARM', changedIdx: 1, isTarget: true),
        ],
      ),
    );
  }

  Widget _buildMiniWordChip(String word, {required int changedIdx, bool isStart = false, bool isTarget = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTarget
            ? GameColors.signalLime
            : isStart
                ? GameColors.surfaceWhite
                : GameColors.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTarget ? GameColors.carbon : GameColors.borderMuted,
          width: isTarget ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (i) {
          final isChanged = i == changedIdx;
          return Text(
            word[i],
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isChanged
                  ? (isTarget ? GameColors.carbon : const Color(0xFF6B4EE6))
                  : GameColors.carbon,
            ),
          );
        }),
      ),
    );
  }
}
