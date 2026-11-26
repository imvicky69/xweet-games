import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wordle_difficulty.dart';

class WordRepository {
  WordRepository._();
  static final WordRepository instance = WordRepository._();

  List<String> _allWords = [];
  Set<String> _validGuessSet = {};
  bool _isLoaded = false;
  final Random _random = Random();

  static const String _keyRecentWords = 'wordle_recent_target_words';

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/words.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final List rawList = jsonMap['words'] as List;

      _allWords = rawList.map((e) => e.toString().trim().toUpperCase()).toList();
      _validGuessSet = _allWords.toSet();
      _isLoaded = true;
    } catch (e) {
      // Fallback vocabulary if asset fails to load
      _allWords = [
        'WHICH', 'THERE', 'THEIR', 'ABOUT', 'WOULD', 'THESE', 'OTHER', 'WORDS', 'COULD', 'WRITE',
        'FIRST', 'WATER', 'AFTER', 'WHERE', 'RIGHT', 'THINK', 'THREE', 'YEARS', 'PLACE', 'SOUND',
        'GREAT', 'AGAIN', 'STILL', 'EVERY', 'SMALL', 'FOUND', 'THOSE', 'NEVER', 'UNDER', 'MIGHT',
      ];
      _validGuessSet = _allWords.toSet();
      _isLoaded = true;
    }
  }

  bool isValidGuess(String word) {
    if (word.length != 5) return false;
    return _validGuessSet.contains(word.toUpperCase());
  }

  /// Selects the deterministic daily word for a given [date] (Game of the Day),
  /// matching the exact algorithm on xweet.in/wordle.
  Future<String> selectDailyWord(DateTime date) async {
    await init();
    if (_allWords.isEmpty) return 'PLANT';
    final poolLimit = min(1500, _allWords.length);
    final utc = date.toUtc();
    final dateKey =
        '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';
    int hash = 5381;
    for (int i = 0; i < dateKey.length; i++) {
      hash = ((hash * 33) + dateKey.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return _allWords[hash % poolLimit];
  }

  /// Selects a target word according to difficulty tier, current round,
  /// and applies the Recency Anti-Repeat Filter (wordle.md Section 4)
  Future<String> selectTargetWord({
    required WordleDifficulty difficulty,
    required int roundNumber, // 1 to 5
  }) async {
    await init();
    if (_allWords.isEmpty) return 'PLANT';

    // 1. Determine candidate slice based on difficulty & round
    final int candidateLimit;
    switch (difficulty) {
      case WordleDifficulty.progressive:
        switch (roundNumber) {
          case 1:
            candidateLimit = min(900, _allWords.length);
            break;
          case 2:
            candidateLimit = min(1600, _allWords.length);
            break;
          case 3:
            candidateLimit = min(2600, _allWords.length);
            break;
          case 4:
            candidateLimit = min(3800, _allWords.length);
            break;
          case 5:
          default:
            candidateLimit = _allWords.length;
            break;
        }
        break;
      case WordleDifficulty.easy:
        candidateLimit = min(1200, _allWords.length);
        break;
      case WordleDifficulty.medium:
        candidateLimit = min(2800, _allWords.length);
        break;
      case WordleDifficulty.hard:
        candidateLimit = _allWords.length;
        break;
    }

    final candidates = _allWords.sublist(0, candidateLimit);

    // 2. Recency Anti-Repeat Filter
    final prefs = await SharedPreferences.getInstance();
    final recentList = prefs.getStringList(_keyRecentWords) ?? [];
    final recentSet = recentList.toSet();

    final pool = candidates.where((w) => !recentSet.contains(w)).toList();

    final chosen = (pool.length > 30)
        ? pool[_random.nextInt(pool.length)]
        : candidates[_random.nextInt(candidates.length)];

    // 3. Save to recents (keep last 50)
    final updatedRecents = [chosen, ...recentList.where((w) => w != chosen)];
    if (updatedRecents.length > 50) {
      updatedRecents.removeRange(50, updatedRecents.length);
    }
    await prefs.setStringList(_keyRecentWords, updatedRecents);

    return chosen;
  }
}
