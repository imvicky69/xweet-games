import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/ladder_puzzle.dart';

enum LadderMoveError {
  none,
  invalidLength,
  sameWord,
  notInDictionary,
  multipleChanges,
  alreadyInLadder,
}

class LadderDictionary {
  LadderDictionary._();
  static final LadderDictionary instance = LadderDictionary._();

  bool _isLoaded = false;
  final Set<String> _validWords = {};
  final Map<String, List<String>> _wildcardMap = {};
  final Random _random = Random();

  /// Curated pool of common, familiar 4-letter English words
  /// verified to exist in the 4-letter dictionary
  static const List<String> curatedCommonWords = [
    'cold', 'warm', 'head', 'tail', 'word', 'game', 'play', 'fire', 'fast', 'slow',
    'blue', 'pink', 'lion', 'bear', 'rain', 'snow', 'dark', 'moon', 'star', 'tree',
    'leaf', 'wood', 'food', 'meat', 'fish', 'bird', 'walk', 'jump', 'fall', 'rise',
    'book', 'read', 'talk', 'sing', 'song', 'bell', 'ring', 'king', 'gold', 'iron',
    'lead', 'sand', 'rock', 'hill', 'road', 'path', 'city', 'town', 'home', 'room',
    'door', 'wall', 'roof', 'wind', 'wave', 'tide', 'lake', 'pond', 'pool', 'swim',
    'dive', 'hand', 'foot', 'face', 'nose', 'eyes', 'ears', 'hair', 'skin', 'bone',
    'mind', 'soul', 'love', 'hope', 'fear', 'calm', 'soft', 'hard', 'easy', 'tall',
    'wide', 'deep', 'high', 'good', 'best', 'fine', 'pure', 'rich', 'poor', 'free',
    'busy', 'idle', 'wild', 'tame', 'bold', 'safe', 'neat', 'cool', 'ship', 'boat',
    'sail', 'mast', 'deck', 'dock', 'port', 'yard', 'barn', 'farm', 'corn', 'rice',
    'bean', 'meal', 'soup', 'cake', 'bake', 'cook', 'boil', 'heat', 'melt', 'glow',
    'beam', 'lamp', 'bulb', 'wire', 'rust', 'dirt', 'soil', 'clay', 'muck', 'seed',
    'root', 'stem', 'bark', 'pine', 'rose', 'fern', 'moss', 'weed', 'frog', 'toad',
    'duck', 'swan', 'crow', 'hawk', 'dove', 'fawn', 'wolf', 'foal', 'deer', 'hare',
    'goat', 'bull', 'calf', 'lamb', 'colt', 'mule', 'pony', 'crab', 'seal', 'clam',
    'worm', 'ants', 'wasp', 'moth', 'flea', 'tick', 'silk', 'wool', 'lace', 'yarn',
    'cord', 'rope', 'knot', 'belt', 'boot', 'shoe', 'sock', 'coat', 'vest', 'band',
    'mask', 'cape', 'gown', 'suit', 'cash', 'coin', 'bill', 'bank', 'cost', 'deal',
    'gain', 'loss', 'debt', 'loan', 'card', 'dice', 'turn', 'race', 'goal', 'team',
    'club', 'crew', 'hero', 'lord', 'duke', 'page', 'monk', 'poet', 'bard', 'host',
    'mate', 'peer', 'ally', 'aide', 'boss', 'chef', 'maid', 'wait', 'stay', 'stop',
    'move', 'step', 'leap', 'skip', 'trip', 'pace', 'dash', 'rush', 'push', 'pull',
    'lift', 'drop', 'hold', 'keep', 'grab', 'take', 'give', 'lend', 'send', 'pass',
    'toss', 'kick', 'ride', 'roll', 'spin', 'bend', 'fold', 'tear', 'mend', 'bind',
    'lock', 'open', 'shut', 'hide', 'seek', 'find', 'save', 'help', 'harm', 'heal',
    'cure', 'rest', 'wake', 'soar', 'sink', 'wash', 'wipe', 'dust', 'tidy', 'spot',
    'mark', 'sign', 'note', 'text', 'line', 'poem', 'tune', 'drum', 'horn', 'harp',
    'pipe', 'echo', 'tone', 'hymn'
  ];

  static final Set<String> _curatedSet = curatedCommonWords.map((w) => w.toLowerCase()).toSet();

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/4-letter-words.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final List rawList = jsonMap['words'] as List;

      for (final raw in rawList) {
        final w = raw.toString().trim().toLowerCase();
        if (w.length == 4) {
          _validWords.add(w);
          for (int i = 0; i < 4; i++) {
            final p = '${w.substring(0, i)}*${w.substring(i + 1)}';
            _wildcardMap.putIfAbsent(p, () => []).add(w);
          }
        }
      }
      _isLoaded = true;
    } catch (_) {
      // Fallback
      for (final w in curatedCommonWords) {
        if (w.length == 4) {
          _validWords.add(w);
          for (int i = 0; i < 4; i++) {
            final p = '${w.substring(0, i)}*${w.substring(i + 1)}';
            _wildcardMap.putIfAbsent(p, () => []).add(w);
          }
        }
      }
      _isLoaded = true;
    }
  }

  bool isValidWord(String word) {
    return _validWords.contains(word.toLowerCase());
  }

  /// Verifies if a move is valid:
  /// - Length must be 4
  /// - Exists in the full dictionary
  /// - Differs by exactly ONE letter from current word
  LadderMoveError validateMove({
    required String currentWord,
    required String newWord,
    required List<String> existingLadder,
  }) {
    final cur = currentWord.toLowerCase();
    final candidate = newWord.toLowerCase();

    if (candidate.length != 4) {
      return LadderMoveError.invalidLength;
    }
    if (cur == candidate) {
      return LadderMoveError.sameWord;
    }
    if (existingLadder.map((w) => w.toLowerCase()).contains(candidate)) {
      return LadderMoveError.alreadyInLadder;
    }
    if (!_validWords.contains(candidate)) {
      return LadderMoveError.notInDictionary;
    }

    int diffCount = 0;
    for (int i = 0; i < 4; i++) {
      if (cur[i] != candidate[i]) {
        diffCount++;
      }
    }

    if (diffCount != 1) {
      return LadderMoveError.multipleChanges;
    }

    return LadderMoveError.none;
  }

  int getChangedIndex(String a, String b) {
    if (a.length != 4 || b.length != 4) return -1;
    for (int i = 0; i < 4; i++) {
      if (a[i].toLowerCase() != b[i].toLowerCase()) {
        return i;
      }
    }
    return -1;
  }

  /// Shortest path algorithm (BFS) using wildcard pattern map
  List<String>? findShortestPath(String start, String target) {
    final s = start.toLowerCase();
    final t = target.toLowerCase();

    if (s == t) return [s];
    if (!_validWords.contains(s) || !_validWords.contains(t)) return null;

    final visited = <String>{s};
    final queue = Queue<List<String>>();
    queue.add([s]);

    while (queue.isNotEmpty) {
      final path = queue.removeFirst();
      final current = path.last;

      for (int i = 0; i < 4; i++) {
        final pattern = '${current.substring(0, i)}*${current.substring(i + 1)}';
        final neighbors = _wildcardMap[pattern] ?? const [];

        for (final neighbor in neighbors) {
          if (neighbor == t) {
            return [...path, neighbor];
          }
          if (!visited.contains(neighbor)) {
            visited.add(neighbor);
            queue.add([...path, neighbor]);
          }
        }
      }
    }

    return null;
  }

  /// Generates a puzzle (start, target, optimal path) with shortest path between [minMoves] and [maxMoves]
  Future<LadderPuzzle> generateRandomPuzzle({
    int minMoves = 3,
    int maxMoves = 5,
    int? seed,
  }) async {
    await init();
    final rng = seed != null ? Random(seed) : _random;

    final shuffled = List<String>.from(curatedCommonWords)..shuffle(rng);

    for (final startWord in shuffled) {
      final s = startWord.toLowerCase();
      final distances = <String, int>{s: 0};
      final parent = <String, String?>{s: null};
      final queue = Queue<String>()..add(s);
      final candidates = <MapEntry<String, int>>[];

      while (queue.isNotEmpty) {
        final curr = queue.removeFirst();
        final d = distances[curr]!;

        if (d > maxMoves) break;

        if (d >= minMoves && _curatedSet.contains(curr) && curr != s) {
          candidates.add(MapEntry(curr, d));
        }

        for (int i = 0; i < 4; i++) {
          final pattern = '${curr.substring(0, i)}*${curr.substring(i + 1)}';
          final neighbors = _wildcardMap[pattern] ?? const [];

          for (final nbr in neighbors) {
            if (!distances.containsKey(nbr)) {
              distances[nbr] = d + 1;
              parent[nbr] = curr;
              queue.add(nbr);
            }
          }
        }
      }

      if (candidates.isNotEmpty) {
        final targetEntry = candidates[rng.nextInt(candidates.length)];
        final targetWord = targetEntry.key;

        // Reconstruct path
        final path = <String>[];
        String? trace = targetWord;
        while (trace != null) {
          path.add(trace);
          trace = parent[trace];
        }
        final optimalPath = path.reversed.toList();

        return LadderPuzzle(
          startWord: s.toUpperCase(),
          targetWord: targetWord.toUpperCase(),
          optimalMoves: optimalPath.length - 1,
          optimalPath: optimalPath.map((w) => w.toUpperCase()).toList(),
          isDaily: false,
          dateString: '',
          puzzleId: 'rnd_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    }

    // Curated high-reliability fallback if traversal exhausts
    final defaultPath = ['COLD', 'WOLD', 'WALD', 'WARD', 'WARM'];
    return LadderPuzzle(
      startWord: 'COLD',
      targetWord: 'WARM',
      optimalMoves: 4,
      optimalPath: defaultPath,
      isDaily: false,
      dateString: '',
      puzzleId: 'fallback',
    );
  }

  /// Generates the Daily Puzzle deterministically for a given [date]
  Future<LadderPuzzle> generateDailyPuzzle(DateTime date) async {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final seed = date.year * 10000 + date.month * 100 + date.day;

    final puzzle = await generateRandomPuzzle(minMoves: 3, maxMoves: 5, seed: seed);

    return LadderPuzzle(
      startWord: puzzle.startWord,
      targetWord: puzzle.targetWord,
      optimalMoves: puzzle.optimalMoves,
      optimalPath: puzzle.optimalPath,
      isDaily: true,
      dateString: dateString,
      puzzleId: 'daily_$dateString',
    );
  }
}
