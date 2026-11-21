import 'package:flutter/foundation.dart';
import '../models/ladder_game_state.dart';
import '../models/ladder_puzzle.dart';
import '../models/ladder_step.dart';
import 'ladder_dictionary.dart';

class LadderGameController extends ChangeNotifier {
  LadderGameState? _state;
  String _currentInput = '';
  String? _errorMessage;

  LadderGameState? get state => _state;
  String get currentInput => _currentInput;
  String? get errorMessage => _errorMessage;

  bool get isReady => _state != null;
  bool get isCompleted => _state?.isCompleted ?? false;

  void initPuzzle(LadderPuzzle puzzle) {
    final initialStep = LadderStep(
      word: puzzle.startWord,
      changedIndex: -1,
      stepNumber: 0,
    );

    _state = LadderGameState(
      puzzle: puzzle,
      steps: [initialStep],
      isCompleted: false,
    );
    _currentInput = '';
    _errorMessage = null;
    notifyListeners();
  }

  void addLetter(String letter) {
    if (isCompleted || _currentInput.length >= 4) return;
    _currentInput += letter.toUpperCase();
    _errorMessage = null;
    notifyListeners();
  }

  void deleteLetter() {
    if (isCompleted || _currentInput.isEmpty) return;
    _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    _errorMessage = null;
    notifyListeners();
  }

  LadderMoveError submitWord() {
    if (_state == null || isCompleted) return LadderMoveError.none;

    final input = _currentInput.trim().toUpperCase();
    final currentWord = _state!.currentWord;
    final ladderHistory = _state!.steps.map((s) => s.word).toList();

    final validation = LadderDictionary.instance.validateMove(
      currentWord: currentWord,
      newWord: input,
      existingLadder: ladderHistory,
    );

    if (validation != LadderMoveError.none) {
      switch (validation) {
        case LadderMoveError.invalidLength:
          _errorMessage = 'Must be 4 letters';
          break;
        case LadderMoveError.sameWord:
          _errorMessage = 'Same as current word';
          break;
        case LadderMoveError.alreadyInLadder:
          _errorMessage = 'Word already used';
          break;
        case LadderMoveError.notInDictionary:
          _errorMessage = 'Not in dictionary';
          break;
        case LadderMoveError.multipleChanges:
          _errorMessage = 'Change only 1 letter!';
          break;
        default:
          _errorMessage = 'Invalid move';
      }
      notifyListeners();
      return validation;
    }

    final changedIndex = LadderDictionary.instance.getChangedIndex(currentWord, input);
    final newStep = LadderStep(
      word: input,
      changedIndex: changedIndex,
      stepNumber: _state!.steps.length,
    );

    final updatedSteps = List<LadderStep>.from(_state!.steps)..add(newStep);
    final completed = input == _state!.puzzle.targetWord;

    _state = _state!.copyWith(
      steps: updatedSteps,
      isCompleted: completed,
    );
    _currentInput = '';
    _errorMessage = null;
    notifyListeners();

    return LadderMoveError.none;
  }

  void undoMove() {
    if (_state == null || _state!.steps.length <= 1) return;

    final updatedSteps = List<LadderStep>.from(_state!.steps)..removeLast();
    _state = _state!.copyWith(
      steps: updatedSteps,
      isCompleted: false,
    );
    _currentInput = '';
    _errorMessage = null;
    notifyListeners();
  }

  void restart() {
    if (_state == null) return;
    initPuzzle(_state!.puzzle);
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
