class RoundRecord {
  final int roundNumber;
  final String targetWord;
  final int attemptsUsed; // 1 to 6, or 0 if missed
  final bool isWon;

  const RoundRecord({
    required this.roundNumber,
    required this.targetWord,
    required this.attemptsUsed,
    required this.isWon,
  });

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'targetWord': targetWord,
    'attemptsUsed': attemptsUsed,
    'isWon': isWon,
  };

  factory RoundRecord.fromJson(Map<String, dynamic> json) => RoundRecord(
    roundNumber: json['roundNumber'] as int,
    targetWord: json['targetWord'] as String,
    attemptsUsed: json['attemptsUsed'] as int,
    isWon: json['isWon'] as bool,
  );
}
