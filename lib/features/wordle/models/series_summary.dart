import 'package:flutter/material.dart';
import 'round_record.dart';

class SeriesRating {
  final String title;
  final String badge;
  final String emoji;
  final IconData icon;

  const SeriesRating({
    required this.title,
    required this.badge,
    required this.emoji,
    required this.icon,
  });

  static SeriesRating fromScore(int solvedCount) {
    if (solvedCount >= 10) {
      return const SeriesRating(
        title: 'Immortal Lexicographer',
        badge: '10+ Streak Mastery',
        emoji: '👑',
        icon: Icons.military_tech_rounded,
      );
    } else if (solvedCount >= 7) {
      return const SeriesRating(
        title: 'Grandmaster Wordsmith',
        badge: '7+ Words Survived',
        emoji: '🔥',
        icon: Icons.local_fire_department_rounded,
      );
    } else if (solvedCount >= 5) {
      return const SeriesRating(
        title: 'Master Cryptic Solver',
        badge: '5+ Words Survived',
        emoji: '🎖️',
        icon: Icons.workspace_premium_rounded,
      );
    } else if (solvedCount >= 3) {
      return const SeriesRating(
        title: 'Seasoned Wordsmith',
        badge: 'Solid Performance',
        emoji: '📜',
        icon: Icons.psychology_rounded,
      );
    } else if (solvedCount >= 1) {
      return const SeriesRating(
        title: 'Apprentice Explorer',
        badge: 'Off to a Good Start',
        emoji: '🧭',
        icon: Icons.explore_rounded,
      );
    } else {
      return const SeriesRating(
        title: 'Field Observer',
        badge: 'Run Ended Early',
        emoji: '🌱',
        icon: Icons.flag_rounded,
      );
    }
  }
}

class SeriesSummary {
  final List<RoundRecord> rounds;
  final int solvedCount;
  final int totalRounds;
  final SeriesRating rating;
  final bool isDaily;

  SeriesSummary({
    required this.rounds,
    required this.solvedCount,
    this.totalRounds = 5,
    this.isDaily = false,
  }) : rating = SeriesRating.fromScore(solvedCount);

  String generateShareText({required List<List<String>> emojiGrids}) {
    final buffer = StringBuffer();
    if (isDaily) {
      final r = rounds.isNotEmpty ? rounds.first : null;
      final tries = (r != null && r.isWon) ? '${r.attemptsUsed}/6' : 'X/6';
      buffer.writeln('Xweet Daily Wordle ($tries) 🎯');
      buffer.writeln();
      if (emojiGrids.isNotEmpty) {
        for (final row in emojiGrids.first) {
          buffer.writeln(row);
        }
      }
    } else {
      buffer.writeln('Xweet Wordle Survival: $solvedCount Words Solved in a Row ${rating.emoji}');
      buffer.writeln('Rating: ${rating.title}');
      buffer.writeln();

      for (int i = 0; i < rounds.length; i++) {
        final r = rounds[i];
        final tries = r.isWon ? '${r.attemptsUsed}/6' : 'X/6';
        final numStr = r.roundNumber < 10 ? '0${r.roundNumber}' : '${r.roundNumber}';
        buffer.writeln('Round $numStr ($tries):');
        if (i < emojiGrids.length) {
          for (final row in emojiGrids[i]) {
            buffer.writeln(row);
          }
        }
        buffer.writeln();
      }
    }

    buffer.writeln('https://xweet.in/wordle');
    return buffer.toString().trim();
  }
}
