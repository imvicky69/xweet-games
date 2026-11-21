enum WordleDifficulty {
  progressive(
    id: 'progressive',
    title: 'Progressive Ramp',
    badge: 'RECOMMENDED',
    subtitle: 'Dynamic ramp (900 → 5,757 words)',
    description: 'Early rounds feature common words; final rounds test true mastery.',
    poolSize: 'Dynamic',
  ),
  easy(
    id: 'easy',
    title: 'Easy / Casual',
    badge: 'TOP 1,200',
    subtitle: 'Everyday vocabulary',
    description: 'Familiar words like WATER, APPLE, LIGHT, and PLANT.',
    poolSize: '1,200 words',
  ),
  medium(
    id: 'medium',
    title: 'Medium / Standard',
    badge: 'TOP 2,800',
    subtitle: 'Balanced tournament challenge',
    description: 'Matches classic daily word puzzle difficulty standards.',
    poolSize: '2,800 words',
  ),
  hard(
    id: 'hard',
    title: 'Hard / Lexicographer',
    badge: 'FULL 5,757',
    subtitle: 'Unrestricted dictionary',
    description: 'Includes literary, archaic, and rare English vocabulary.',
    poolSize: '5,757 words',
  );

  final String id;
  final String title;
  final String badge;
  final String subtitle;
  final String description;
  final String poolSize;

  const WordleDifficulty({
    required this.id,
    required this.title,
    required this.badge,
    required this.subtitle,
    required this.description,
    required this.poolSize,
  });

  static WordleDifficulty fromId(String id) {
    return WordleDifficulty.values.firstWhere(
      (d) => d.id == id,
      orElse: () => WordleDifficulty.progressive,
    );
  }
}
