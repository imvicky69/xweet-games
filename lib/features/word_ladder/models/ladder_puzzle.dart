class LadderPuzzle {
  final String startWord;
  final String targetWord;
  final int optimalMoves;
  final List<String> optimalPath;
  final bool isDaily;
  final String dateString;
  final String puzzleId;

  const LadderPuzzle({
    required this.startWord,
    required this.targetWord,
    required this.optimalMoves,
    required this.optimalPath,
    required this.isDaily,
    required this.dateString,
    required this.puzzleId,
  });

  Map<String, dynamic> toJson() => {
    'startWord': startWord,
    'targetWord': targetWord,
    'optimalMoves': optimalMoves,
    'optimalPath': optimalPath,
    'isDaily': isDaily,
    'dateString': dateString,
    'puzzleId': puzzleId,
  };

  factory LadderPuzzle.fromJson(Map<String, dynamic> json) => LadderPuzzle(
    startWord: json['startWord'] as String,
    targetWord: json['targetWord'] as String,
    optimalMoves: json['optimalMoves'] as int,
    optimalPath: (json['optimalPath'] as List).cast<String>(),
    isDaily: json['isDaily'] as bool? ?? false,
    dateString: json['dateString'] as String? ?? '',
    puzzleId: json['puzzleId'] as String? ?? '',
  );
}
