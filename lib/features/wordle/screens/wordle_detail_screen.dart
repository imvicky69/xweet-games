import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import '../models/round_record.dart';
import '../models/wordle_difficulty.dart';
import '../widgets/how_to_play_modal.dart';

class WordleDetailScreen extends StatefulWidget {
  const WordleDetailScreen({super.key});

  @override
  State<WordleDetailScreen> createState() => _WordleDetailScreenState();
}

class _WordleDetailScreenState extends State<WordleDetailScreen> {
  late WordleDifficulty _selectedDifficulty;
  late List<RoundRecord> _lastRecords;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = WordleDifficulty.fromId(StorageService.instance.wordleDifficulty);
    _lastRecords = StorageService.instance.getLastSeriesRecords();
  }

  void _onDifficultySelected(WordleDifficulty difficulty) {
    AudioService.instance.triggerSelectionHaptic();
    setState(() {
      _selectedDifficulty = difficulty;
    });
    StorageService.instance.setWordleDifficulty(difficulty.id);
  }

  void _onStartGame() {
    AudioService.instance.triggerHeavyHaptic();
    AudioService.instance.playTapSound();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GameColors.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: GameColors.carbon, width: 1.4),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: GameColors.signalLime,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_esports_rounded,
                  color: GameColors.carbon,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ready to Play!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: GameColors.carbon,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Mode',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: GameColors.terrain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_selectedDifficulty.title} (${_selectedDifficulty.poolSize})',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: GameColors.carbon,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'You will play 5 consecutive rounds. Each round has a secret 5-letter word and 6 attempts.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: GameColors.carbon.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('LET’S GO!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.paper,
      appBar: AppBar(
        title: Text(
          'Xweet Wordle',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: GameColors.carbon,
          ),
        ),
        actions: [
          // Single, elegant "How to Play" action in header
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                AudioService.instance.triggerSelectionHaptic();
                HowToPlayModal.show(context);
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
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                                color: GameColors.signalLime,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: GameColors.carbon, width: 1),
                              ),
                              child: Text(
                                '5-ROUND CHALLENGE',
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
                          'Wordle Tournament',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: GameColors.carbon,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Guess 5 secret words in a row with live color hints and sound effects. Can you solve all 5?',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: GameColors.terrain,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Player Stats Cards (Game-friendly with icons)
                  _buildGameStats(),

                  const SizedBox(height: 22),

                  // Difficulty Selection
                  _buildDifficultySelection(),

                  const SizedBox(height: 22),

                  // Recent Games Record Log
                  _buildRecentRoundsLog(),
                ],
              ),
            ),

            // Single Prominent, Full-Width Bottom CTA Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: BoxDecoration(
                color: GameColors.surfaceWhite,
                border: Border(
                  top: BorderSide(color: GameColors.borderMuted, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.carbon.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onStartGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        'START 5-ROUND GAME',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: GameColors.carbon.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          _selectedDifficulty.badge,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: GameColors.carbon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStats() {
    final played = StorageService.instance.seriesPlayed;
    final won = StorageService.instance.seriesWon;
    final winRate = StorageService.instance.winRatePercent.toStringAsFixed(0);
    final streak = StorageService.instance.currentStreak;

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
          _buildStatPill('🎮', '$played', 'Games'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatPill('🏆', '$won', 'Wins'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatPill('🎯', '$winRate%', 'Accuracy'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatPill('🔥', '$streak', 'Streak'),
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

  Widget _buildDifficultySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Difficulty',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: GameColors.carbon,
          ),
        ),
        const SizedBox(height: 10),
        ...WordleDifficulty.values.map((diff) {
          final isSelected = _selectedDifficulty == diff;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : GameColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? GameColors.carbon : GameColors.borderMuted,
                width: isSelected ? 1.6 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: GameColors.signalLime.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _onDifficultySelected(diff),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Radio indicator
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? GameColors.carbon : GameColors.terrain,
                                width: 2,
                              ),
                              color: isSelected ? GameColors.signalLime : Colors.transparent,
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: GameColors.carbon,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          // Title & Badge
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  diff.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: GameColors.carbon,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected ? GameColors.signalLime : GameColors.paper,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: isSelected ? GameColors.carbon : GameColors.borderMuted,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    diff.badge,
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: GameColors.carbon,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Pool size
                          Text(
                            diff.poolSize,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? GameColors.carbon : GameColors.terrain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 34),
                        child: Text(
                          diff.description,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: GameColors.terrain,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentRoundsLog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Previous Game Records',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: GameColors.carbon,
              ),
            ),
            Text(
              _lastRecords.isEmpty ? 'Empty' : '${_lastRecords.length} Rounds',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: GameColors.terrain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_lastRecords.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GameColors.surfaceWhite,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: GameColors.borderMuted),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: GameColors.paper,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sports_esports_outlined,
                    color: GameColors.terrain,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No games logged yet',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: GameColors.carbon,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Complete your first 5-round game to see your rounds, words, and scores logged here.',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: GameColors.terrain,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GameColors.surfaceWhite,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: GameColors.borderMuted),
            ),
            child: Column(
              children: _lastRecords.map((r) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: r.isWon ? GameColors.signalLime : GameColors.terrain.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GameColors.carbon.withValues(alpha: 0.25)),
                        ),
                        child: Center(
                          child: Text(
                            '0${r.roundNumber}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: GameColors.carbon,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.targetWord.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: GameColors.carbon,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              r.isWon ? 'Solved in ${r.attemptsUsed}/6 attempts' : 'Unsolved',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: GameColors.terrain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: r.isWon ? GameColors.signalLime : GameColors.paper,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: r.isWon ? GameColors.carbon : GameColors.borderMuted,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          r.isWon ? 'SOLVED' : 'MISSED',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: r.isWon ? GameColors.carbon : GameColors.terrain,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
