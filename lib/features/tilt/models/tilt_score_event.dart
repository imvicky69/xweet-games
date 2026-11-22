enum LandingAccuracy {
  perfect,
  great,
  good,
  tilt,
  miss,
}

class TiltScoreEvent {
  final LandingAccuracy accuracy;
  final int pointsAwarded;
  final int combo;
  final double offsetMeters;
  final String label;

  const TiltScoreEvent({
    required this.accuracy,
    required this.pointsAwarded,
    required this.combo,
    required this.offsetMeters,
    required this.label,
  });

  bool get isPerfect => accuracy == LandingAccuracy.perfect;
}
