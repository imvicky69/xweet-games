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

  // Wordle Career Statistics
  int get seriesPlayed => _prefs.getInt('wordle_series_played') ?? 0;
  int get seriesWon => _prefs.getInt('wordle_series_won') ?? 0;
  int get currentStreak => _prefs.getInt('wordle_current_streak') ?? 0;
  int get maxStreak => _prefs.getInt('wordle_max_streak') ?? 0;

  double get winRatePercent => seriesPlayed == 0 ? 0 : (seriesWon / seriesPlayed) * 100;

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

  Future<void> resetAllScores() async {
    await _prefs.remove('wordle_series_played');
    await _prefs.remove('wordle_series_won');
    await _prefs.remove('wordle_current_streak');
    await _prefs.remove('wordle_max_streak');
    await _prefs.remove('wordle_last_series_records');
    final keys = _prefs.getKeys().where((k) => k.startsWith(AppConstants.keyHighScorePrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
