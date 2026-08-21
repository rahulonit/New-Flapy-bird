import 'player_save.dart';

/// Persistent player progression derived from lifetime save statistics.
///
/// Using existing saved values keeps old save files compatible and prevents
/// level progress from being affected by the daily mission reset.
class PlayerLevelProgress {
  const PlayerLevelProgress({
    required this.level,
    required this.totalXp,
    required this.currentLevelXp,
    required this.nextLevelXp,
  });

  static const int maxLevel = 50;
  static const int startingLevel = 0;
  static const int startingLevelXp = 1500;

  final int level;
  final int totalXp;
  final int currentLevelXp;
  final int nextLevelXp;

  double get progress => level >= maxLevel
      ? 1
      : (currentLevelXp / nextLevelXp).clamp(0.0, 1.0).toDouble();

  int get xpToNextLevel => level >= maxLevel
      ? 0
      : (nextLevelXp - currentLevelXp).clamp(0, nextLevelXp).toInt();

  static int totalXpFromSave(PlayerSave save) {
    final totalWorldBest = save.worldScores.values.fold<int>(
      0,
      (total, score) => total + score,
    );
    final scoredXp = totalWorldBest > 0 ? totalWorldBest : save.bestScore;
    return (save.totalRuns * 100) + (scoredXp ~/ 10);
  }

  /// Level 0 starts at 1,500 XP and every later requirement doubles.
  static int xpRequiredForNextLevel(int level) {
    final safeLevel = level.clamp(startingLevel, maxLevel - 1).toInt();
    return startingLevelXp * (1 << safeLevel);
  }

  factory PlayerLevelProgress.fromSave(PlayerSave save) {
    final totalXp = totalXpFromSave(save);
    var remainingXp = totalXp;
    var level = startingLevel;

    while (level < maxLevel) {
      final required = xpRequiredForNextLevel(level);
      if (remainingXp < required) break;
      remainingXp -= required;
      level++;
    }

    return PlayerLevelProgress(
      level: level,
      totalXp: totalXp,
      currentLevelXp: level >= maxLevel ? 0 : remainingXp,
      nextLevelXp: level >= maxLevel ? 0 : xpRequiredForNextLevel(level),
    );
  }
}
