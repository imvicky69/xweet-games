import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/wordle/models/round_record.dart';
import '../constants/app_constants.dart';
import 'audio_service.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    AudioService.instance.soundEnabled = _prefs.getBool(AppConstants.keySoundEnabled) ?? true;
    AudioService.instance.hapticsEnabled = _prefs.getBool(AppConstants.keyHapticsEnabled) ?? true;
  }

  // Audio & Haptics
  bool get soundEnabled => _prefs.getBool(AppConstants.keySoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool(AppConstants.keySoundEnabled, value);
    AudioService.instance.soundEnabled = value;
  }

  bool get hapticsEnabled => _prefs.getBool(AppConstants.keyHapticsEnabled) ?? true;
  Future<void> setHapticsEnabled(bool value) async {
    await _prefs.setBool(AppConstants.keyHapticsEnabled, value);
    AudioService.instance.hapticsEnabled = value;
  }

  // Player Name
  String get playerName => _prefs.getString(AppConstants.keyPlayerName) ?? 'Explorer 1';
  Future<void> setPlayerName(String name) async {
    await _prefs.setString(AppConstants.keyPlayerName, name);
  }

  // Wordle Difficulty
  String get wordleDifficulty => _prefs.getString('wordle_difficulty') ?? 'progressive';
  Future<void> setWordleDifficulty(String diff) async {
    await _prefs.setString('wordle_difficulty', diff);
  }

  // Wordle Dictionary Check (Allow Any 5-Letter Word if false)
  bool get wordleStrictDictionary => _prefs.getBool('wordle_strict_dictionary') ?? true;
  Future<void> setWordleStrictDictionary(bool value) async {
    await _prefs.setBool('wordle_strict_dictionary', value);
  }

  // Wordle Career Statistics
  int get seriesPlayed => _prefs.getInt('wordle_series_played') ?? 0;
  int get seriesWon => _prefs.getInt('wordle_series_won') ?? 0;
  int get currentStreak => _prefs.getInt('wordle_current_streak') ?? 0;
  int get maxStreak => _prefs.getInt('wordle_max_streak') ?? 0;

  double get winRatePercent => seriesPlayed == 0 ? 0 : (seriesWon / seriesPlayed) * 100;

  // Daily Wordle (Game of the Day)
  int get wordleDailyPlayed => _prefs.getInt('wordle_daily_played') ?? 0;
  int get wordleDailyWon => _prefs.getInt('wordle_daily_won') ?? 0;
  int get wordleDailyStreak => _prefs.getInt('wordle_daily_streak') ?? 0;
  int get wordleDailyBestStreak => _prefs.getInt('wordle_daily_best_streak') ?? 0;
  String? get wordleLastDailyDate => _prefs.getString('wordle_last_daily_date');

  bool isWordleDailyCompletedToday() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return wordleLastDailyDate == todayStr;
  }

  Future<void> recordWordleDailyCompleted({required bool won}) async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _prefs.setString('wordle_last_daily_date', todayStr);

    final played = wordleDailyPlayed + 1;
    final wins = wordleDailyWon + (won ? 1 : 0);
    final streak = won ? (wordleDailyStreak + 1) : 0;
    final best = streak > wordleDailyBestStreak ? streak : wordleDailyBestStreak;

    await _prefs.setInt('wordle_daily_played', played);
    await _prefs.setInt('wordle_daily_won', wins);
    await _prefs.setInt('wordle_daily_streak', streak);
    await _prefs.setInt('wordle_daily_best_streak', best);
  }

  // Wordle Endless Survival Mode
  int get wordleSurvivalBestStreak => _prefs.getInt('wordle_survival_best_streak') ?? maxStreak;
  int get wordleSurvivalTotalRuns => _prefs.getInt('wordle_survival_total_runs') ?? seriesPlayed;
  int get wordleSurvivalWordsSolved => _prefs.getInt('wordle_survival_words_solved') ?? seriesWon;

  Future<void> recordWordleSurvivalFinished({
    required int streak,
    required List<RoundRecord> rounds,
  }) async {
    final runs = wordleSurvivalTotalRuns + 1;
    final solved = wordleSurvivalWordsSolved + streak;
    final best = streak > wordleSurvivalBestStreak ? streak : wordleSurvivalBestStreak;

    await _prefs.setInt('wordle_survival_total_runs', runs);
    await _prefs.setInt('wordle_survival_words_solved', solved);
    await _prefs.setInt('wordle_survival_best_streak', best);
    await _prefs.setInt('wordle_series_played', runs);
    await _prefs.setInt('wordle_series_won', solved);
    await _prefs.setInt('wordle_max_streak', best);
    await saveLastSeriesRecords(rounds);
  }

  // Last Series Round Audit Records
  List<RoundRecord> getLastSeriesRecords() {
    final raw = _prefs.getString('wordle_last_series_records');
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw) as List;
      return decoded.map((e) => RoundRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLastSeriesRecords(List<RoundRecord> records) async {
    final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
    await _prefs.setString('wordle_last_series_records', encoded);
  }

  Future<void> recordSeriesFinished({
    required bool won,
    required List<RoundRecord> rounds,
  }) async {
    final played = seriesPlayed + 1;
    final wins = seriesWon + (won ? 1 : 0);
    final streak = won ? (currentStreak + 1) : 0;
    final bestStreak = streak > maxStreak ? streak : maxStreak;

    await _prefs.setInt('wordle_series_played', played);
    await _prefs.setInt('wordle_series_won', wins);
    await _prefs.setInt('wordle_current_streak', streak);
    await _prefs.setInt('wordle_max_streak', bestStreak);
    await saveLastSeriesRecords(rounds);
  }

  // Word Ladder (Shift) Statistics
  int get ladderPlayed => _prefs.getInt('ladder_total_played') ?? 0;
  int get ladderWon => _prefs.getInt('ladder_total_won') ?? 0;
  int get ladderStreak => _prefs.getInt('ladder_daily_streak') ?? 0;
  int get ladderBestStreak => _prefs.getInt('ladder_best_streak') ?? 0;
  String? get lastDailyCompletedDate => _prefs.getString('ladder_last_daily_date');

  bool isDailyCompletedToday() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastDailyCompletedDate == todayStr;
  }

  Future<void> recordLadderCompleted({
    required bool isDaily,
    required int moves,
    required int optimalMoves,
  }) async {
    final played = ladderPlayed + 1;
    final won = ladderWon + 1;
    await _prefs.setInt('ladder_total_played', played);
    await _prefs.setInt('ladder_total_won', won);

    if (isDaily) {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await _prefs.setString('ladder_last_daily_date', todayStr);

      final newStreak = ladderStreak + 1;
      final best = newStreak > ladderBestStreak ? newStreak : ladderBestStreak;
      await _prefs.setInt('ladder_daily_streak', newStreak);
      await _prefs.setInt('ladder_best_streak', best);
    }
  }

  // TILT Architecture Tower Stacking Statistics
  int get tiltHighScore => _prefs.getInt(AppConstants.keyTiltHighScore) ?? 0;
  int get tiltMaxHeight => _prefs.getInt(AppConstants.keyTiltMaxHeight) ?? 0;
  int get tiltGamesPlayed => _prefs.getInt(AppConstants.keyTiltGamesPlayed) ?? 0;
  int get tiltTotalFloors => _prefs.getInt(AppConstants.keyTiltTotalFloors) ?? 0;
  int get tiltPerfectDrops => _prefs.getInt(AppConstants.keyTiltPerfectDrops) ?? 0;

  Future<void> recordTiltRun({
    required int score,
    required int floors,
    required int perfectDrops,
  }) async {
    final currentHigh = tiltHighScore;
    if (score > currentHigh) {
      await _prefs.setInt(AppConstants.keyTiltHighScore, score);
    }

    final currentMaxHeight = tiltMaxHeight;
    if (floors > currentMaxHeight) {
      await _prefs.setInt(AppConstants.keyTiltMaxHeight, floors);
    }

    await _prefs.setInt(AppConstants.keyTiltGamesPlayed, tiltGamesPlayed + 1);
    await _prefs.setInt(AppConstants.keyTiltTotalFloors, tiltTotalFloors + floors);
    await _prefs.setInt(AppConstants.keyTiltPerfectDrops, tiltPerfectDrops + perfectDrops);
  }

  Future<void> resetAllScores() async {
    await _prefs.remove('wordle_series_played');
    await _prefs.remove('wordle_series_won');
    await _prefs.remove('wordle_current_streak');
    await _prefs.remove('wordle_max_streak');
    await _prefs.remove('wordle_last_series_records');
    await _prefs.remove('ladder_total_played');
    await _prefs.remove('ladder_total_won');
    await _prefs.remove('ladder_daily_streak');
    await _prefs.remove('ladder_best_streak');
    await _prefs.remove('ladder_last_daily_date');
    await _prefs.remove(AppConstants.keyTiltHighScore);
    await _prefs.remove(AppConstants.keyTiltMaxHeight);
    await _prefs.remove(AppConstants.keyTiltGamesPlayed);
    await _prefs.remove(AppConstants.keyTiltTotalFloors);
    await _prefs.remove(AppConstants.keyTiltPerfectDrops);
    final keys = _prefs.getKeys().where((k) => k.startsWith(AppConstants.keyHighScorePrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
