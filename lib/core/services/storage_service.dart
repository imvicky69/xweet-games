import 'package:shared_preferences/shared_preferences.dart';
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

  int getHighScore(String gameId) {
    return _prefs.getInt('${AppConstants.keyHighScorePrefix}$gameId') ?? 0;
  }

  Future<bool> setHighScore(String gameId, int score) async {
    final currentHigh = getHighScore(gameId);
    if (score > currentHigh) {
      await _prefs.setInt('${AppConstants.keyHighScorePrefix}$gameId', score);
      return true; // New high score!
    }
    return false;
  }

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

  String get playerName => _prefs.getString(AppConstants.keyPlayerName) ?? 'Player 1';
  Future<void> setPlayerName(String name) async {
    await _prefs.setString(AppConstants.keyPlayerName, name);
  }

  Future<void> resetAllScores() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(AppConstants.keyHighScorePrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
