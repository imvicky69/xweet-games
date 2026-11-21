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
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: GameColors.carbon, width: 1.2),
          ),
          title: Text(
            'Expedition Ready',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: GameColors.carbon,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Difficulty: ${_selectedDifficulty.title}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: GameColors.carbon,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Word Pool: ${_selectedDifficulty.poolSize}',
                style: GoogleFonts.spaceMono(
                  fontSize: 13,
                  color: GameColors.terrain,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your 5-Round Series configuration is locked in. Ready to enter the interactive playground in the next step!',
                style: GoogleFonts.spaceGrotesk(
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
              child: const Text('READY TO PLAY'),
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
          'XWEET WORDLE',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: GameColors.carbon,
            letterSpacing: 0.8,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => HowToPlayModal.show(context),
            icon: const Icon(Icons.help_outline_rounded, size: 18, color: GameColors.carbon),
            label: Text(
              'How to Play',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: GameColors.carbon,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  // Hero Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: GameColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: GameColors.borderMuted),
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
                                '5-ROUND TOURNAMENT',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
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
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: GameColors.carbon,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Deduce 5 secret words in a row with progressive ramp difficulty, live color clues, and instant audio triggers.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: GameColors.terrain,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Career Statistics Strip
                  _buildCareerStats(),

                  const SizedBox(height: 24),

                  // Last Round / Series Audit Log
                  _buildLastSeriesAudit(),

                  const SizedBox(height: 24),

                  // Difficulty Tier Configuration Selector
                  _buildDifficultySelector(),
                ],
              ),
            ),

            // Bottom Action Container with Clean White Background
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
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => HowToPlayModal.show(context),
                    child: const Text('HOW TO PLAY'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onStartGame,
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: Text('START ${_selectedDifficulty.title.toUpperCase()}'),
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

  Widget _buildCareerStats() {
    final played = StorageService.instance.seriesPlayed;
    final won = StorageService.instance.seriesWon;
    final winRate = StorageService.instance.winRatePercent.toStringAsFixed(0);
    final streak = StorageService.instance.currentStreak;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: GameColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameColors.borderMuted),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('PLAYED', '$played'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatItem('WON', '$won'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatItem('WIN %', '$winRate%'),
          Container(width: 1, height: 32, color: GameColors.borderMuted),
          _buildStatItem('STREAK', '$streak'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceMono(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: GameColors.carbon,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: GameColors.terrain,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLastSeriesAudit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LAST SERIES AUDIT LOG',
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: GameColors.carbon,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              _lastRecords.isEmpty ? 'NO LOGS' : '${_lastRecords.length} ROUNDS',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GameColors.borderMuted),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: GameColors.paper,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_edu_rounded,
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
                        'No previous rounds logged',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: GameColors.carbon,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Complete your first 5-round series to see your target words, attempts, and rank audit here.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GameColors.borderMuted),
            ),
            child: Column(
              children: _lastRecords.map((r) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: r.isWon ? GameColors.signalLime : GameColors.terrain.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: GameColors.carbon.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text(
                            '0${r.roundNumber}',
                            style: GoogleFonts.spaceMono(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
                              style: GoogleFonts.spaceMono(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: GameColors.carbon,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              r.isWon ? 'Solved in ${r.attemptsUsed}/6 tries' : 'Unsolved (6/6 attempts)',
                              style: GoogleFonts.spaceGrotesk(
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
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXPEDITION DIFFICULTY',
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: GameColors.carbon,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'WORDLE.MD SPEC',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: GameColors.terrain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...WordleDifficulty.values.map((diff) {
          final isSelected = _selectedDifficulty == diff;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: GameColors.surfaceWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? GameColors.carbon : GameColors.borderMuted,
                width: isSelected ? 1.6 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: GameColors.signalLime.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _onDifficultySelected(diff),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Radio Circle
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
                      const SizedBox(width: 14),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  diff.title,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: GameColors.carbon,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected ? GameColors.signalLime : GameColors.paper,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: GameColors.carbon, width: 0.8),
                                  ),
                                  child: Text(
                                    diff.badge,
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: GameColors.carbon,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              diff.description,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: GameColors.terrain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        diff.poolSize,
                        style: GoogleFonts.spaceMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: GameColors.carbon,
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
}
