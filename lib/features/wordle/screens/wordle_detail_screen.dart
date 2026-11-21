import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import '../models/round_record.dart';
import '../models/wordle_difficulty.dart';
import '../widgets/how_to_play_modal.dart';
import 'wordle_playground_screen.dart';

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

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _playDailyWordle() {
    AudioService.instance.triggerHeavyHaptic();
    AudioService.instance.playTapSound();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const WordlePlaygroundScreen(isDaily: true),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _lastRecords = StorageService.instance.getLastSeriesRecords();
        });
      }
    });
  }

  void _startEndlessRun() {
    AudioService.instance.triggerHeavyHaptic();
    AudioService.instance.playTapSound();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordlePlaygroundScreen(
          isDaily: false,
          difficulty: _selectedDifficulty,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _lastRecords = StorageService.instance.getLastSeriesRecords();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDailyDone = StorageService.instance.isWordleDailyCompletedToday();
    final todayFormatted = _formatDate(DateTime.now());

    return Scaffold(
      backgroundColor: GameColors.paper,
      appBar: AppBar(
        title: Text(
          'Wordle',
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
                          color: GameColors.signalLime,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: GameColors.carbon, width: 1),
                        ),
                        child: Text(
                          'DAILY & SURVIVAL',
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
                    'Wordle Expedition',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Play the synchronized Game of the Day or test your limits in Endless Survival mode where one mistake ends your run.',
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

            // Career Stats Row
            _buildGameStats(),

            const SizedBox(height: 22),

            // Mode 1: Daily Wordle Card (Game of the Day)
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
                          'GAME OF THE DAY',
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
                    'Daily Wordle',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'One 5-letter secret word for all players today. You have 6 attempts to deduce it with live color clues.',
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
                            'Completed today! Daily streak: ${StorageService.instance.wordleDailyStreak}',
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
                      onPressed: _playDailyWordle,
                      icon: Icon(
                        isDailyDone ? Icons.replay_rounded : Icons.play_arrow_rounded,
                        size: 22,
                      ),
                      label: Text(
                        isDailyDone ? 'REPLAY TODAY’S WORDLE' : 'PLAY DAILY WORDLE',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Mode 2: Endless Survival Run Card
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
                          color: GameColors.carbon,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          'ENDLESS SURVIVAL',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: GameColors.paper,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        'BEST: ${StorageService.instance.wordleSurvivalBestStreak} WORDS',
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
                    'Endless Streak Run',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solve consecutive words from Round 1 onward. If you run out of guesses on any round, your run ends immediately!',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: GameColors.terrain,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Difficulty Selection
                  _buildDifficultySelection(),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startEndlessRun,
                      icon: const Icon(Icons.local_fire_department_rounded, size: 22),
                      label: const Text('START ENDLESS RUN'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Recent Game Records Log
            _buildRecentRoundsLog(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStats() {
    final runs = StorageService.instance.wordleSurvivalTotalRuns;
    final wordsSolved = StorageService.instance.wordleSurvivalWordsSolved;
    final dailyStreak = StorageService.instance.wordleDailyStreak;
    final bestStreak = StorageService.instance.wordleSurvivalBestStreak;

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
          _buildStatPill('🎮', '$runs', 'Runs'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatPill('🏆', '$wordsSolved', 'Solved'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatPill('🗓️', '$dailyStreak', 'Daily'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatPill('🔥', '$bestStreak', 'Best Streak'),
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
          'Difficulty Setting',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: GameColors.carbon,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: WordleDifficulty.values.map((diff) {
            final isSelected = _selectedDifficulty == diff;
            return InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => _onDifficultySelected(diff),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? GameColors.signalLime : GameColors.paper,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isSelected ? GameColors.carbon : GameColors.borderMuted,
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                child: Text(
                  diff.title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: GameColors.carbon,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
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
              'Previous Run Records',
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
                        'No runs logged yet',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: GameColors.carbon,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Complete a daily puzzle or survival run to see your round records here.',
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
                final numStr = r.roundNumber < 10 ? '0${r.roundNumber}' : '${r.roundNumber}';
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
                            numStr,
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
