class LadderStep {
  final String word;
  final int changedIndex; // 0..3, or -1 for the start word
  final int stepNumber;

  const LadderStep({
    required this.word,
    required this.changedIndex,
    required this.stepNumber,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'changedIndex': changedIndex,
    'stepNumber': stepNumber,
  };

  factory LadderStep.fromJson(Map<String, dynamic> json) => LadderStep(
    word: json['word'] as String,
    changedIndex: json['changedIndex'] as int,
    stepNumber: json['stepNumber'] as int,
  );
}
