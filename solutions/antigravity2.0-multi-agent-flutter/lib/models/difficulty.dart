enum Difficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy (Seby)';
      case Difficulty.medium:
        return 'Medium (Alessandro)';
      case Difficulty.hard:
        return 'Hard (Master)';
    }
  }
}
