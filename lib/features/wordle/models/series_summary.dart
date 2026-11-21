import 'round_record.dart';

class SeriesRating {
  final String title;
  final String badge;
  final String emoji;

  const SeriesRating({
    required this.title,
    required this.badge,
    required this.emoji,
  });

  static SeriesRating fromScore(int solvedCount) {
    switch (solvedCount) {
      case 5:
        return const SeriesRating(
          title: 'Grandmaster Lexicographer',
          badge: 'Flawless Deductions',
          emoji: '👑',
        );
      case 4:
        return const SeriesRating(
          title: 'Master Cryptic Solver',
          badge: '80% Precision',
          emoji: '🎖️',
        );
      case 3:
        return const SeriesRating(
          title: 'Seasoned Wordsmith',
          badge: '60% Accuracy',
          emoji: '📜',
        );
      case 2:
      case 1:
        return const SeriesRating(
          title: 'Apprentice Explorer',
          badge: 'Keep Honing',
          emoji: '🧭',
        );
      default:
        return const SeriesRating(
          title: 'Field Observer',
          badge: 'Try Another Series',
          emoji: '🌱',
        );
    }
  }
}

class SeriesSummary {
  final List<RoundRecord> rounds;
  final int solvedCount;
  final int totalRounds;
  final SeriesRating rating;

  SeriesSummary({
    required this.rounds,
    required this.solvedCount,
    this.totalRounds = 5,
  }) : rating = SeriesRating.fromScore(solvedCount);

  String generateShareText({required List<List<String>> emojiGrids}) {
    final buffer = StringBuffer();
    buffer.writeln('Xweet Wordle 5-Round Series: 0$solvedCount/0$totalRounds Solved ${rating.emoji}');
    buffer.writeln('Rating: ${rating.title}');
    buffer.writeln();

    for (int i = 0; i < rounds.length; i++) {
      final r = rounds[i];
      final tries = r.isWon ? '${r.attemptsUsed}/6' : 'X/6';
      buffer.writeln('Round 0${r.roundNumber} ($tries):');
      if (i < emojiGrids.length) {
        for (final row in emojiGrids[i]) {
          buffer.writeln(row);
        }
      }
      buffer.writeln();
    }

    buffer.writeln('https://xweet.in/wordle');
    return buffer.toString().trim();
  }
}
