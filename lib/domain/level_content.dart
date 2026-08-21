const int levelsPerWorld = 30;

class GameLevel {
  const GameLevel({required this.number, required this.targetScore});

  final int number;
  final int targetScore;
}

List<GameLevel> levelsForWorld(String worldId) => List.generate(
  levelsPerWorld,
  (index) =>
      GameLevel(number: index + 1, targetScore: levelTargetScore(index + 1)),
  growable: false,
);

int levelTargetScore(int levelNumber) =>
    1500 * levelNumber.clamp(1, levelsPerWorld);

class LevelDifficulty {
  const LevelDifficulty({
    required this.speedMultiplier,
    required this.gapMultiplier,
    required this.spawnIntervalMultiplier,
  });

  final double speedMultiplier;
  final double gapMultiplier;
  final double spawnIntervalMultiplier;

  factory LevelDifficulty.forLevel(int levelNumber) {
    final level = levelNumber.clamp(1, levelsPerWorld);
    final progress = (level - 1) / (levelsPerWorld - 1);
    return LevelDifficulty(
      speedMultiplier: 1 + (0.65 * progress),
      gapMultiplier: 1 - (0.25 * progress),
      spawnIntervalMultiplier: 1 - (0.28 * progress),
    );
  }
}

int completedLevelsFor(Map<String, int> progress, String worldId) =>
    (progress[worldId] ?? 0).clamp(0, levelsPerWorld);

bool isLevelUnlocked(
  Map<String, int> progress,
  String worldId,
  int levelNumber,
) => levelNumber <= completedLevelsFor(progress, worldId) + 1;
