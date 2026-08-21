import 'package:flutter_test/flutter_test.dart';
import 'package:flapverse_3d/domain/player_level.dart';
import 'package:flapverse_3d/domain/player_save.dart';

void main() {
  group('PlayerLevelProgress', () {
    test('new player starts at level zero', () {
      final progress = PlayerLevelProgress.fromSave(const PlayerSave());

      expect(progress.level, 0);
      expect(progress.totalXp, 0);
      expect(progress.xpToNextLevel, 1500);
      expect(progress.progress, 0);
    });

    test('level requirements double after every level up', () {
      expect(PlayerLevelProgress.xpRequiredForNextLevel(0), 1500);
      expect(PlayerLevelProgress.xpRequiredForNextLevel(1), 3000);
      expect(PlayerLevelProgress.xpRequiredForNextLevel(2), 6000);
      expect(PlayerLevelProgress.xpRequiredForNextLevel(3), 12000);
    });

    test('lifetime runs and world scores increase progress', () {
      final progress = PlayerLevelProgress.fromSave(
        const PlayerSave(
          totalRuns: 10,
          bestScore: 5000,
          worldScores: {'default': 5000},
        ),
      );

      expect(progress.totalXp, 1500);
      expect(progress.level, 1);
      expect(progress.currentLevelXp, 0);
      expect(progress.nextLevelXp, 3000);
    });

    test(
      'world best scores are accumulated without double-counting bestScore',
      () {
        final progress = PlayerLevelProgress.fromSave(
          const PlayerSave(
            totalRuns: 2,
            bestScore: 3000,
            worldScores: {'default': 3000, 'metro': 2000},
          ),
        );

        expect(progress.totalXp, 700);
        expect(progress.level, 0);
        expect(progress.currentLevelXp, 700);
        expect(progress.nextLevelXp, 1500);
      },
    );
  });
}
