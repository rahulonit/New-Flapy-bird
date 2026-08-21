import 'package:flutter_test/flutter_test.dart';

import 'package:flapverse_3d/application/providers.dart';
import 'package:flapverse_3d/data/save_repository.dart';
import 'package:flapverse_3d/domain/player_save.dart';
import 'package:flapverse_3d/domain/level_content.dart';

class _MemorySaveRepository implements SaveRepository {
  PlayerSave value;

  _MemorySaveRepository(this.value);

  @override
  Future<void> clearAll() async => value = const PlayerSave();

  @override
  Future<PlayerSave> load() async => value;

  @override
  Future<void> save(PlayerSave value) async => this.value = value;
}

void main() {
  test('daily reward can only be claimed once per local day', () async {
    final repository = _MemorySaveRepository(const PlayerSave());
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();
    await notifier.save(
      notifier.state.value!.copyWith(
        missionCounters: const {'games': 5, 'obstacles': 10, 'coins': 30},
      ),
    );
    expect(await notifier.claimDailyReward(), isFalse);
    await notifier.save(
      notifier.state.value!.copyWith(
        missionCounters: const {'games': 10, 'obstacles': 100, 'coins': 100},
      ),
    );

    expect(await notifier.claimDailyReward(), isTrue);
    expect(await notifier.claimDailyReward(), isFalse);
    expect(notifier.state.value!.coins, 200);
  });

  test('weekly reward can only be claimed once per calendar week', () async {
    final repository = _MemorySaveRepository(const PlayerSave());
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();
    final monday = DateTime(2026, 8, 17);
    await notifier.save(
      notifier.state.value!.copyWith(
        lastWeeklyMissionKey: '2026-W34',
        weeklyMissionCounters: const {
          'games': 30,
          'obstacles': 300,
          'score': 100000,
          'coins': 300,
        },
      ),
    );
    expect(await notifier.claimWeeklyReward(now: monday), isFalse);
    await notifier.save(
      notifier.state.value!.copyWith(
        lastWeeklyMissionKey: '2026-W34',
        weeklyMissionCounters: const {
          'games': 200,
          'obstacles': 700,
          'score': 300000,
          'coins': 700,
        },
      ),
    );

    expect(await notifier.claimWeeklyReward(now: monday), isTrue);
    expect(
      await notifier.claimWeeklyReward(
        now: monday.add(const Duration(days: 6)),
      ),
      isFalse,
    );
    expect(
      await notifier.claimWeeklyReward(
        now: monday.add(const Duration(days: 7)),
      ),
      isFalse,
    );
    expect(notifier.state.value!.coins, 1500);
    expect(notifier.state.value!.gems, 50);
  });

  test(
    'daily reset clears mission state and preserves lifetime progress',
    () async {
      final repository = _MemorySaveRepository(
        const PlayerSave(
          bestScore: 4200,
          totalRuns: 9,
          lastDailyMissionDate: '2020-01-01',
          missionCounters: {'games': 3, 'score': 10000},
          claimedMissionIds: ['games'],
          dailyBonusClaimed: true,
        ),
      );
      final notifier = PlayerSaveNotifier(repository);
      await notifier.loadSave();

      final save = notifier.state.value!;
      expect(save.missionCounters, isEmpty);
      expect(save.claimedMissionIds, isEmpty);
      expect(save.dailyBonusClaimed, isFalse);
      expect(save.bestScore, 4200);
      expect(save.totalRuns, 9);
    },
  );

  test('trail purchase spends coins and selected trail persists', () async {
    final repository = _MemorySaveRepository(const PlayerSave(coins: 1000));
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();

    expect(await notifier.purchaseTrail('cyan_pulse', coins: 400), isTrue);
    expect(notifier.state.value!.coins, 600);
    expect(notifier.state.value!.ownedTrailIds, contains('cyan_pulse'));

    await notifier.selectTrail('cyan_pulse');
    expect(notifier.state.value!.selectedTrailId, 'cyan_pulse');
    expect(repository.value.selectedTrailId, 'cyan_pulse');
  });

  test('only collected run rewards are saved after a run', () async {
    final repository = _MemorySaveRepository(const PlayerSave(coins: 100));
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();

    await notifier.recordRun(
      score: 20500,
      obstacles: 4,
      collectedCoins: 3,
      earnedDiamonds: 2,
    );

    expect(notifier.state.value!.coins, 103);
    expect(notifier.state.value!.gems, 2);
    expect(notifier.state.value!.totalRuns, 1);
  });

  test('rewarded run bonus can double coins and diamonds once', () async {
    final repository = _MemorySaveRepository(
      const PlayerSave(coins: 20, gems: 2),
    );
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();

    await notifier.grantRunBonusRewards(coins: 20, gems: 2);

    expect(notifier.state.value!.coins, 40);
    expect(notifier.state.value!.gems, 4);
  });

  test('meeting a level target unlocks the next world level', () async {
    final repository = _MemorySaveRepository(const PlayerSave());
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();

    await notifier.recordRun(
      score: levelTargetScore(1) - 1,
      obstacles: 4,
      levelNumber: 1,
    );
    expect(notifier.state.value!.worldCompletedLevels['default'] ?? 0, 0);

    await notifier.recordRun(
      score: levelTargetScore(1),
      obstacles: 10,
      levelNumber: 1,
    );
    expect(notifier.state.value!.worldCompletedLevels['default'], 1);
    expect(
      isLevelUnlocked(notifier.state.value!.worldCompletedLevels, 'default', 2),
      isTrue,
    );
  });

  test('worlds contain 30 levels with increasing targets and difficulty', () {
    final levels = levelsForWorld('default');
    expect(levels, hasLength(30));
    expect(levels.first.targetScore, 1500);
    expect(levels.last.targetScore, 45000);

    final first = LevelDifficulty.forLevel(1);
    final last = LevelDifficulty.forLevel(30);
    expect(last.speedMultiplier, greaterThan(first.speedMultiplier));
    expect(last.gapMultiplier, lessThan(first.gapMultiplier));
    expect(
      last.spawnIntervalMultiplier,
      lessThan(first.spawnIntervalMultiplier),
    );
  });

  test('a locked level cannot be completed through an invalid jump', () async {
    final repository = _MemorySaveRepository(const PlayerSave());
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();

    await notifier.recordRun(
      score: levelTargetScore(30),
      obstacles: 100,
      levelNumber: 30,
    );

    expect(notifier.state.value!.worldCompletedLevels['default'] ?? 0, 0);
  });

  test('diamond exchange updates both balances atomically', () async {
    final repository = _MemorySaveRepository(
      const PlayerSave(coins: 2000, gems: 100),
    );
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();

    expect(await notifier.buyDiamonds(), isTrue);
    expect(notifier.state.value!.coins, 1000);
    expect(notifier.state.value!.gems, 200);

    expect(await notifier.exchangeDiamonds(), isTrue);
    expect(notifier.state.value!.coins, 1750);
    expect(notifier.state.value!.gems, 100);
  });

  test('power-ups and world unlock spend diamonds', () async {
    final repository = _MemorySaveRepository(const PlayerSave(gems: 5060));
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();

    expect(await notifier.purchaseShield(), isTrue);
    expect(await notifier.purchaseScoreBooster(), isTrue);
    expect(notifier.state.value!.shieldCount, 1);
    expect(notifier.state.value!.scoreBoosterCount, 1);
    expect(notifier.state.value!.gems, 5000);

    expect(await notifier.unlockWorldWithDiamonds('metro'), isTrue);
    expect(notifier.state.value!.gems, 0);
    expect(notifier.state.value!.ownedWorldIds, contains('metro'));
    expect(notifier.state.value!.selectedWorldId, 'metro');
  });

  test('rewarded ads advance and pay daily and weekly missions', () async {
    final repository = _MemorySaveRepository(const PlayerSave());
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();

    for (var index = 0; index < 20; index++) {
      await notifier.recordRewardedAdWatched();
    }
    expect(notifier.state.value!.missionCounters['ads'], 20);
    expect(await notifier.claimMission('ads', 10, 100), isTrue);
    expect(
      await notifier.claimMission(
        'ads_20',
        20,
        150,
        gems: 5,
        progressKey: 'ads',
      ),
      isTrue,
    );
    expect(
      await notifier.claimMission(
        'ads_20',
        20,
        150,
        gems: 5,
        progressKey: 'ads',
      ),
      isFalse,
    );
    expect(notifier.state.value!.coins, 250);
    expect(notifier.state.value!.gems, 5);

    for (var index = 20; index < 140; index++) {
      await notifier.recordRewardedAdWatched();
    }
    expect(notifier.state.value!.weeklyMissionCounters['ads'], 140);
    expect(
      await notifier.claimWeeklyMission('ads', 140, 1000, gems: 50),
      isTrue,
    );
    expect(
      await notifier.claimWeeklyMission('ads', 140, 1000, gems: 50),
      isFalse,
    );
    expect(notifier.state.value!.coins, 1250);
    expect(notifier.state.value!.gems, 55);
  });

  test('character purchase deducts coins and gems atomically', () async {
    final repository = _MemorySaveRepository(
      const PlayerSave(coins: 25000, gems: 74),
    );
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();

    expect(
      await notifier.purchaseCharacter('byte', coins: 25000, gems: 75),
      isFalse,
    );
    expect(notifier.state.value!.coins, 25000);
    expect(notifier.state.value!.gems, 74);
    expect(notifier.state.value!.ownedCharacterIds, isNot(contains('byte')));

    await notifier.save(notifier.state.value!.copyWith(gems: 75));
    expect(
      await notifier.purchaseCharacter('byte', coins: 25000, gems: 75),
      isTrue,
    );
    expect(notifier.state.value!.coins, 0);
    expect(notifier.state.value!.gems, 0);
    expect(notifier.state.value!.ownedCharacterIds, contains('byte'));
  });
}
