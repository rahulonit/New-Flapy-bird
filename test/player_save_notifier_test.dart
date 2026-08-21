import 'package:flutter_test/flutter_test.dart';

import 'package:flapverse_3d/application/providers.dart';
import 'package:flapverse_3d/data/save_repository.dart';
import 'package:flapverse_3d/domain/player_save.dart';

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

  test('only collected coins are saved after a run', () async {
    final repository = _MemorySaveRepository(const PlayerSave(coins: 100));
    final notifier = PlayerSaveNotifier(repository);
    await notifier.loadSave();

    await notifier.recordRun(score: 500, obstacles: 4, collectedCoins: 3);

    expect(notifier.state.value!.coins, 103);
    expect(notifier.state.value!.totalRuns, 1);
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
}
