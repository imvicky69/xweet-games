import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import '../models/tilt_game_state.dart';
import '../models/tilt_score_event.dart';
import 'tilt_physics_constants.dart';

/// Pure game state controller managing scores, combos, floor count,
/// stability metrics, and audio/haptic event dispatches.
class TiltGameController extends ChangeNotifier {
  TiltStatus _status = TiltStatus.ready;
  int _score = 0;
  int _floors = 0;
  int _combo = 1;
  int _maxCombo = 1;
  int _perfectDrops = 0;
  double _currentTiltDegrees = 0.0;
  TiltScoreEvent? _lastScoreEvent;

  int _personalBestScore = 0;
  int _personalMaxHeight = 0;

  TiltGameController() {
    _loadPersonalBest();
  }

  // Getters
  TiltStatus get status => _status;
  int get score => _score;
  int get floors => _floors;
  int get combo => _combo;
  int get maxCombo => _maxCombo;
  int get perfectDrops => _perfectDrops;
  double get currentTiltDegrees => _currentTiltDegrees;
  TiltScoreEvent? get lastScoreEvent => _lastScoreEvent;
  int get personalBestScore => _personalBestScore;
  int get personalMaxHeight => _personalMaxHeight;

  // Current building height in meters (approx 3.2m per floor in real-world terms)
  double get currentHeightMeters => _floors * 3.2;

  bool get isWarningTilt => _currentTiltDegrees.abs() >= (TiltPhysicsConstants.warningTiltAngleRad * 180 / math.pi);

  void _loadPersonalBest() {
    _personalBestScore = StorageService.instance.tiltHighScore;
    _personalMaxHeight = StorageService.instance.tiltMaxHeight;
    notifyListeners();
  }

  void startNewGame() {
    _status = TiltStatus.swinging;
    _score = 0;
    _floors = 0;
    _combo = 1;
    _maxCombo = 1;
    _perfectDrops = 0;
    _currentTiltDegrees = 0.0;
    _lastScoreEvent = null;
    _loadPersonalBest();
    notifyListeners();
  }

  void setStatus(TiltStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    notifyListeners();
  }

  void updateTiltAngle(double angleRadians) {
    _currentTiltDegrees = (angleRadians * 180 / math.pi);
    notifyListeners();
  }

  /// Evaluates horizontal landing offset and updates score, combo, and statistics
  TiltScoreEvent evaluateLanding(double offsetMeters) {
    final absOffset = offsetMeters.abs();
    LandingAccuracy accuracy;
    int basePoints;
    String label;

    if (absOffset <= TiltPhysicsConstants.perfectThreshold) {
      accuracy = LandingAccuracy.perfect;
      basePoints = TiltPhysicsConstants.scorePerfect;
      label = 'PERFECT!';
      _perfectDrops++;
      _combo = math.min(_combo + 1, TiltPhysicsConstants.maxCombo);
      if (_combo > _maxCombo) _maxCombo = _combo;
      AudioService.instance.triggerSelectionHaptic();
      AudioService.instance.playTapSound();
    } else if (absOffset <= TiltPhysicsConstants.greatThreshold) {
      accuracy = LandingAccuracy.great;
      basePoints = TiltPhysicsConstants.scoreGreat;
      label = 'GREAT';
      AudioService.instance.triggerHaptic();
    } else if (absOffset <= TiltPhysicsConstants.goodThreshold) {
      accuracy = LandingAccuracy.good;
      basePoints = TiltPhysicsConstants.scoreGood;
      label = 'GOOD';
      _combo = 1;
      AudioService.instance.triggerHaptic();
    } else if (absOffset <= TiltPhysicsConstants.tiltThreshold) {
      accuracy = LandingAccuracy.tilt;
      basePoints = TiltPhysicsConstants.scoreTilt;
      label = 'TILT!';
      _combo = 1;
      AudioService.instance.triggerHaptic();
    } else {
      accuracy = LandingAccuracy.miss;
      basePoints = 0;
      label = 'MISS';
      _combo = 1;
    }

    final pointsEarned = basePoints * (accuracy == LandingAccuracy.perfect ? _combo : 1);
    _score += pointsEarned;
    _floors++;

    final event = TiltScoreEvent(
      accuracy: accuracy,
      pointsAwarded: pointsEarned,
      combo: _combo,
      offsetMeters: offsetMeters,
      label: label,
    );

    _lastScoreEvent = event;
    notifyListeners();
    return event;
  }

  /// Called when the run ends (either structural collapse or block missed)
  Future<void> recordRunFinished() async {
    _status = TiltStatus.gameOver;
    AudioService.instance.triggerHeavyHaptic();

    await StorageService.instance.recordTiltRun(
      score: _score,
      floors: _floors,
      perfectDrops: _perfectDrops,
    );

    _loadPersonalBest();
    notifyListeners();
  }

  void pauseGame() {
    if (_status != TiltStatus.gameOver) {
      _status = TiltStatus.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_status == TiltStatus.paused) {
      _status = TiltStatus.swinging;
      notifyListeners();
    }
  }
}
