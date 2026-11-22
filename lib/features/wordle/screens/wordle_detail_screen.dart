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
  late bool _strictDictionary;
  late List<RoundRecord> _lastRecords;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = WordleDifficulty.fromId(StorageService.instance.wordleDifficulty);
    _strictDictionary = StorageService.instance.wordleStrictDictionary;
    _lastRecords = StorageService.instance.getLastSeriesRecords();
  }

  void _onDifficultySelected(WordleDifficulty difficulty) {
    AudioService.instance.triggerSelectionHaptic();
    setState(() {
      _selectedDifficulty = difficulty;
    });
    StorageService.instance.setWordleDifficulty(difficulty.id);
  }

  void _onToggleStrictDictionary(bool value) {
    AudioService.instance.triggerSelectionHaptic();
    setState(() {
      _strictDictionary = value;
    });
    StorageService.instance.setWordleStrictDictionary(value);
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
        builder: (_) => WordlePlaygroundScreen(
          isDaily: true,
          strictDictionary: _strictDictionary,
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

  void _startEndlessRun() {
    AudioService.instance.triggerHeavyHaptic();
    AudioService.instance.playTapSound();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordlePlaygroundScreen(
          isDaily: false,
          difficulty: _selectedDifficulty,
          strictDictionary: _strictDictionary,
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
          'Wordle Expedition',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: GameColors.carbon,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () => _showCareerStatsSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: GameColors.surfaceWhite,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: GameColors.borderMuted, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.leaderboard_rounded,
                    size: 13,
                    color: GameColors.carbon,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Records',
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: GameColors.carbon,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                AudioService.instance.triggerSelectionHaptic();
                HowToPlayModal.show(context);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: GameColors.surfaceWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: GameColors.borderMuted, width: 1),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  size: 16,
                  color: GameColors.carbon,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              // Mode 1: Daily Wordle Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GameColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDailyDone ? GameColors.borderMuted : GameColors.carbon,
                    width: isDailyDone ? 1.0 : 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDailyDone ? GameColors.carbon : GameColors.signalLime).withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: GameColors.signalLime,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: GameColors.carbon, width: 0.8),
                          ),
                          child: Text(
                            'GAME OF THE DAY',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: GameColors.carbon,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Text(
                          todayFormatted,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: GameColors.terrain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daily Wordle',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: GameColors.carbon,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.public_rounded, size: 12, color: GameColors.terrain),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '1 Secret Word • 6 Attempts • Worldwide Sync',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: GameColors.terrain,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (isDailyDone) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GameColors.signalLime.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: GameColors.carbon.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: GameColors.carbon, size: 13),
                            const SizedBox(width: 6),
                            Text(
                              'Completed today! Daily streak: ${StorageService.instance.wordleDailyStreak}',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: GameColors.carbon,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _playDailyWordle,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(
                          isDailyDone ? Icons.replay_rounded : Icons.play_arrow_rounded,
                          size: 17,
                        ),
                        label: Text(
                          isDailyDone ? 'REPLAY TODAY’S WORDLE' : 'PLAY DAILY WORDLE',
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Mode 2: Endless Survival Run Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GameColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: GameColors.borderMuted, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: GameColors.carbon.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: GameColors.carbon,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            'ENDLESS SURVIVAL',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: GameColors.paper,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Text(
                          'BEST: ${StorageService.instance.wordleSurvivalBestStreak} WORDS',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: GameColors.terrain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Endless Streak Run',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: GameColors.carbon,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 13, color: GameColors.terrain),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Continuous Series • 1 Mistake Ends Run',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: GameColors.terrain,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Compact Difficulty Slider Section
                    _buildDifficultySelection(),

                    const SizedBox(height: 8),

                    // Inline Dictionary Toggle
                    _buildDictionaryToggle(),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startEndlessRun,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.local_fire_department_rounded, size: 17),
                        label: Text(
                          'START ENDLESS RUN',
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelection() {
    final currentIndex = _selectedDifficulty.index;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      decoration: BoxDecoration(
        color: GameColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 13, color: GameColors.carbon),
                  const SizedBox(width: 5),
                  Text(
                    'Select Difficulty',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: GameColors.signalLime,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: GameColors.carbon, width: 0.8),
                ),
                child: Text(
                  '${_selectedDifficulty.badge} • ${_selectedDifficulty.poolSize}',
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: GameColors.carbon,
                  ),
                ),
              ),
            ],
          ),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: GameColors.carbon,
              inactiveTrackColor: GameColors.borderMuted,
              thumbColor: GameColors.signalLime,
              overlayColor: GameColors.signalLime.withValues(alpha: 0.25),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2.5),
              activeTickMarkColor: GameColors.signalLime,
              inactiveTickMarkColor: GameColors.carbon.withValues(alpha: 0.4),
            ),
            child: Slider(
              value: currentIndex.toDouble(),
              min: 0,
              max: 3,
              divisions: 3,
              onChanged: (val) {
                _onDifficultySelected(WordleDifficulty.values[val.round()]);
              },
            ),
          ),

          // 4 Step labels below the slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepLabel(WordleDifficulty.progressive, 'Ramp'),
                _buildStepLabel(WordleDifficulty.easy, 'Easy / Casual'),
                _buildStepLabel(WordleDifficulty.medium, 'Standard'),
                _buildStepLabel(WordleDifficulty.hard, 'Expert'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(WordleDifficulty diff, String label) {
    final isSelected = _selectedDifficulty == diff;
    return GestureDetector(
      onTap: () => _onDifficultySelected(diff),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? GameColors.carbon : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 9.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : GameColors.terrain,
          ),
        ),
      ),
    );
  }

  Widget _buildDictionaryToggle() {
    return Row(
      children: [
        const Icon(Icons.spellcheck_rounded, size: 15, color: GameColors.carbon),
        const SizedBox(width: 6),
        Text(
          'Dictionary Word Check',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: GameColors.carbon,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: _strictDictionary ? GameColors.surfaceWhite : GameColors.signalLime,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: GameColors.carbon, width: 0.8),
          ),
          child: Text(
            _strictDictionary ? 'STRICT' : 'FREE',
            style: GoogleFonts.outfit(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: GameColors.carbon,
            ),
          ),
        ),
        const Spacer(),
        Transform.scale(
          scale: 0.75,
          child: Switch.adaptive(
            value: _strictDictionary,
            onChanged: _onToggleStrictDictionary,
            activeThumbColor: GameColors.carbon,
            activeTrackColor: GameColors.signalLime,
          ),
        ),
      ],
    );
  }

  void _showCareerStatsSheet(BuildContext context) {
    AudioService.instance.triggerSelectionHaptic();
    final runs = StorageService.instance.wordleSurvivalTotalRuns;
    final wordsSolved = StorageService.instance.wordleSurvivalWordsSolved;
    final dailyStreak = StorageService.instance.wordleDailyStreak;
    final bestStreak = StorageService.instance.wordleSurvivalBestStreak;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: GameColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
            const SizedBox(height: 14),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Career Stats & Records',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: GameColors.carbon),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: GameColors.borderMuted, height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                children: [
                  // Career Overview Grid
                  Row(
                    children: [
                      Expanded(child: _buildSheetStatBox('Total Runs', '$runs', Icons.sports_esports_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildSheetStatBox('Words Solved', '$wordsSolved', Icons.military_tech_rounded)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildSheetStatBox('Daily Streak', '$dailyStreak', Icons.calendar_today_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildSheetStatBox('Best Streak', '$bestStreak Words', Icons.local_fire_department_rounded, iconColor: Colors.deepOrange)),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Recent Rounds
                  Text(
                    'Previous Run Records',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_lastRecords.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: GameColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: GameColors.borderMuted),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.sports_esports_outlined, color: GameColors.terrain, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            'No runs recorded yet',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: GameColors.carbon,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Complete a daily puzzle or survival run to see your round history here.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: GameColors.terrain,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._lastRecords.map((r) {
                      final numStr = r.roundNumber < 10 ? '0${r.roundNumber}' : '${r.roundNumber}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GameColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: GameColors.borderMuted),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: r.isWon ? GameColors.signalLime : GameColors.terrain.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: GameColors.carbon.withValues(alpha: 0.2)),
                              ),
                              child: Center(
                                child: Text(
                                  numStr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: GameColors.carbon,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  Text(
                                    r.isWon ? 'Solved in ${r.attemptsUsed}/6 guesses' : 'Unsolved',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: GameColors.terrain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: GameColors.carbon,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetStatBox(String label, String value, IconData icon, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: iconColor ?? GameColors.carbon),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: GameColors.terrain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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
    );
  }
}
