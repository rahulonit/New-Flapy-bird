import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/save_repository.dart';
import '../data/shared_prefs_save_repository.dart';
import '../domain/economy_service.dart';
import '../domain/player_save.dart';
import '../domain/level_content.dart';

final saveRepositoryProvider = Provider<SaveRepository>((ref) {
  return SharedPrefsSaveRepository();
});

final economyServiceProvider = Provider<EconomyService>((ref) {
  final repo = ref.watch(saveRepositoryProvider);
  return EconomyService(repo);
});

class PlayerSaveNotifier extends StateNotifier<AsyncValue<PlayerSave>> {
  final SaveRepository repository;

  PlayerSaveNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadSave();
  }

  Future<void> loadSave() async {
    try {
      PlayerSave save = await repository.load();

      save = _resetWeeklyIfNeeded(_resetDailyIfNeeded(save));
      await repository.save(save);
      state = AsyncValue.data(save);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> save(PlayerSave newSave) async {
    state = AsyncValue.data(newSave);
    await repository.save(newSave);
  }

  String _dayKey([DateTime? value]) {
    final date = value ?? DateTime.now();
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _weekKey([DateTime? value]) {
    final date = value ?? DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final thursday = day.add(Duration(days: 4 - day.weekday));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final weekOne = firstThursday.subtract(
      Duration(days: firstThursday.weekday - DateTime.monday),
    );
    final week = (thursday.difference(weekOne).inDays ~/ 7) + 1;
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }

  PlayerSave _resetDailyIfNeeded(PlayerSave save, [DateTime? now]) {
    final today = _dayKey(now);
    if (save.lastDailyMissionDate == today) return save;
    return save.copyWith(
      lastDailyMissionDate: today,
      missionCounters: const {},
      claimedMissionIds: const [],
      dailyBonusClaimed: false,
    );
  }

  PlayerSave _resetWeeklyIfNeeded(PlayerSave save, [DateTime? now]) {
    final week = _weekKey(now);
    if (save.lastWeeklyMissionKey == week) return save;
    return save.copyWith(
      lastWeeklyMissionKey: week,
      weeklyMissionCounters: const {},
      claimedWeeklyMissionIds: const [],
    );
  }

  Future<void> ensureDailyReset([DateTime? now]) async {
    final current = state.value;
    if (current == null) return;
    final updated = _resetWeeklyIfNeeded(
      _resetDailyIfNeeded(current, now),
      now,
    );
    if (identical(updated, current)) return;
    await save(updated);
  }

  Future<bool> claimDailyReward({int coins = 200, DateTime? now}) async {
    var current = state.value;
    if (current == null) return false;
    current = _resetDailyIfNeeded(current, now);
    final today = _dayKey(now);
    if (current.lastDailyRewardDate == today) {
      if (state.value != current) await save(current);
      return false;
    }
    if (!_dailyRewardTasksComplete(current.missionCounters)) return false;
    await save(
      current.copyWith(
        coins: current.coins + coins,
        lastDailyRewardDate: today,
      ),
    );
    return true;
  }

  Future<bool> claimWeeklyReward({
    int coins = 1500,
    int gems = 50,
    DateTime? now,
  }) async {
    var current = state.value;
    if (current == null) return false;
    current = _resetWeeklyIfNeeded(current, now);
    final week = _weekKey(now);
    if (current.lastWeeklyRewardKey == week) return false;
    if (!_weeklyRewardTasksComplete(current.weeklyMissionCounters)) {
      if (state.value != current) await save(current);
      return false;
    }
    await save(
      current.copyWith(
        coins: current.coins + coins,
        gems: current.gems + gems,
        lastWeeklyRewardKey: week,
      ),
    );
    return true;
  }

  Future<void> recordRun({
    required int score,
    required int obstacles,
    int collectedCoins = 0,
    int earnedDiamonds = 0,
    int? levelNumber,
  }) async {
    var current = state.value;
    if (current == null) return;
    current = _resetWeeklyIfNeeded(_resetDailyIfNeeded(current));
    final counters = Map<String, int>.from(current.missionCounters);
    counters['games'] = (counters['games'] ?? 0) + 1;
    counters['obstacles'] = (counters['obstacles'] ?? 0) + obstacles;
    counters['score'] = (counters['score'] ?? 0) + score;
    counters['coins'] = (counters['coins'] ?? 0) + collectedCoins;
    final weeklyCounters = Map<String, int>.from(current.weeklyMissionCounters);
    weeklyCounters['games'] = (weeklyCounters['games'] ?? 0) + 1;
    weeklyCounters['obstacles'] =
        (weeklyCounters['obstacles'] ?? 0) + obstacles;
    weeklyCounters['score'] = (weeklyCounters['score'] ?? 0) + score;
    weeklyCounters['coins'] = (weeklyCounters['coins'] ?? 0) + collectedCoins;
    final worldScores = Map<String, int>.from(current.worldScores);
    worldScores[current.selectedWorldId] =
        score > (worldScores[current.selectedWorldId] ?? 0)
        ? score
        : (worldScores[current.selectedWorldId] ?? 0);
    final worldCompletedLevels = Map<String, int>.from(
      current.worldCompletedLevels,
    );
    if (levelNumber != null && score >= levelTargetScore(levelNumber)) {
      final completed = worldCompletedLevels[current.selectedWorldId] ?? 0;
      final isNextUnlockedLevel = levelNumber <= completed + 1;
      if (levelNumber > completed && isNextUnlockedLevel) {
        worldCompletedLevels[current.selectedWorldId] = levelNumber.clamp(
          1,
          levelsPerWorld,
        );
      }
    }
    await save(
      current.copyWith(
        bestScore: score > current.bestScore ? score : current.bestScore,
        coins: current.coins + collectedCoins,
        gems: current.gems + earnedDiamonds,
        totalRuns: current.totalRuns + 1,
        missionCounters: counters,
        weeklyMissionCounters: weeklyCounters,
        worldScores: worldScores,
        worldCompletedLevels: worldCompletedLevels,
      ),
    );
  }

  /// Grants the extra coin copy earned from a rewarded ad without recording
  /// another run or incrementing mission counters.
  Future<void> grantRunBonusCoins(int coins) async {
    final current = state.value;
    if (current == null || coins <= 0) return;
    await save(current.copyWith(coins: current.coins + coins));
  }

  Future<void> grantRunBonusRewards({int coins = 0, int gems = 0}) async {
    final current = state.value;
    if (current == null || (coins <= 0 && gems <= 0)) return;
    await save(
      current.copyWith(coins: current.coins + coins, gems: current.gems + gems),
    );
  }

  Future<void> recordRewardedAdWatched() async {
    var current = state.value;
    if (current == null) return;
    current = _resetWeeklyIfNeeded(_resetDailyIfNeeded(current));
    final daily = Map<String, int>.from(current.missionCounters);
    final weekly = Map<String, int>.from(current.weeklyMissionCounters);
    daily['ads'] = (daily['ads'] ?? 0) + 1;
    weekly['ads'] = (weekly['ads'] ?? 0) + 1;
    await save(
      current.copyWith(missionCounters: daily, weeklyMissionCounters: weekly),
    );
  }

  bool _dailyRewardTasksComplete(Map<String, int> counters) =>
      (counters['games'] ?? 0) >= 10 &&
      (counters['obstacles'] ?? 0) >= 100 &&
      (counters['coins'] ?? 0) >= 100;

  bool _weeklyRewardTasksComplete(Map<String, int> counters) =>
      (counters['games'] ?? 0) >= 200 &&
      (counters['obstacles'] ?? 0) >= 700 &&
      (counters['score'] ?? 0) >= 300000 &&
      (counters['coins'] ?? 0) >= 700;

  Future<bool> claimMission(
    String id,
    int target,
    int reward, {
    int gems = 0,
    String? progressKey,
  }) async {
    var current = state.value;
    if (current == null) return false;
    current = _resetDailyIfNeeded(current);
    if ((current.missionCounters[progressKey ?? id] ?? 0) < target ||
        current.claimedMissionIds.contains(id)) {
      return false;
    }
    await save(
      current.copyWith(
        coins: current.coins + reward,
        gems: current.gems + gems,
        claimedMissionIds: [...current.claimedMissionIds, id],
      ),
    );
    return true;
  }

  Future<bool> claimWeeklyMission(
    String id,
    int target,
    int reward, {
    int gems = 0,
  }) async {
    var current = state.value;
    if (current == null) return false;
    current = _resetWeeklyIfNeeded(current);
    if ((current.weeklyMissionCounters[id] ?? 0) < target ||
        current.claimedWeeklyMissionIds.contains(id)) {
      return false;
    }
    await save(
      current.copyWith(
        coins: current.coins + reward,
        gems: current.gems + gems,
        claimedWeeklyMissionIds: [...current.claimedWeeklyMissionIds, id],
      ),
    );
    return true;
  }

  Future<void> selectWorld(String id) async {
    final current = state.value;
    if (current == null || !current.ownedWorldIds.contains(id)) return;
    await save(current.copyWith(selectedWorldId: id));
  }

  Future<void> selectCharacter(String id) async {
    final current = state.value;
    if (current == null || !current.ownedCharacterIds.contains(id)) return;
    await save(current.copyWith(selectedCharacterId: id));
  }

  Future<void> selectProfileAvatar(String id) async {
    final current = state.value;
    if (current == null) return;
    await save(current.copyWith(selectedProfileAvatarId: id));
  }

  Future<void> selectProfileFrame(String id) async {
    final current = state.value;
    if (current == null) return;
    await save(current.copyWith(selectedProfileFrameId: id));
  }

  Future<bool> purchaseTrail(String id, {required int coins}) async {
    final current = state.value;
    if (current == null ||
        current.coins < coins ||
        current.ownedTrailIds.contains(id)) {
      return false;
    }
    await save(
      current.copyWith(
        coins: current.coins - coins,
        ownedTrailIds: [...current.ownedTrailIds, id],
      ),
    );
    return true;
  }

  Future<void> selectTrail(String id) async {
    final current = state.value;
    if (current == null || !current.ownedTrailIds.contains(id)) return;
    await save(current.copyWith(selectedTrailId: id));
  }

  Future<bool> buyDiamonds({int coins = 1000, int gems = 100}) async {
    final current = state.value;
    if (current == null || coins <= 0 || gems <= 0 || current.coins < coins) {
      return false;
    }
    await save(
      current.copyWith(coins: current.coins - coins, gems: current.gems + gems),
    );
    return true;
  }

  Future<bool> exchangeDiamonds({int gems = 100, int coins = 750}) async {
    final current = state.value;
    if (current == null || gems <= 0 || coins <= 0 || current.gems < gems) {
      return false;
    }
    await save(
      current.copyWith(gems: current.gems - gems, coins: current.coins + coins),
    );
    return true;
  }

  Future<bool> purchaseShield() async {
    const cost = 20;
    final current = state.value;
    if (current == null || current.gems < cost) return false;
    await save(
      current.copyWith(
        gems: current.gems - cost,
        shieldCount: current.shieldCount + 1,
      ),
    );
    return true;
  }

  Future<bool> purchaseScoreBooster() async {
    const cost = 40;
    final current = state.value;
    if (current == null || current.gems < cost) return false;
    await save(
      current.copyWith(
        gems: current.gems - cost,
        scoreBoosterCount: current.scoreBoosterCount + 1,
      ),
    );
    return true;
  }

  Future<void> consumeShield() async {
    final current = state.value;
    if (current == null || current.shieldCount <= 0) return;
    await save(current.copyWith(shieldCount: current.shieldCount - 1));
  }

  Future<void> consumeScoreBooster() async {
    final current = state.value;
    if (current == null || current.scoreBoosterCount <= 0) return;
    await save(
      current.copyWith(scoreBoosterCount: current.scoreBoosterCount - 1),
    );
  }

  Future<bool> unlockWorldWithDiamonds(String id, {int gemCost = 5000}) async {
    final current = state.value;
    if (current == null ||
        current.gems < gemCost ||
        current.ownedWorldIds.contains(id)) {
      return false;
    }
    await save(
      current.copyWith(
        gems: current.gems - gemCost,
        ownedWorldIds: [...current.ownedWorldIds, id],
        selectedWorldId: id,
      ),
    );
    return true;
  }

  Future<bool> purchaseCharacter(
    String id, {
    required int coins,
    int gems = 0,
  }) async {
    final current = state.value;
    if (current == null ||
        current.coins < coins ||
        current.gems < gems ||
        current.ownedCharacterIds.contains(id)) {
      return false;
    }
    await save(
      current.copyWith(
        coins: current.coins - coins,
        gems: current.gems - gems,
        ownedCharacterIds: [...current.ownedCharacterIds, id],
      ),
    );
    return true;
  }
}

final playerSaveProvider =
    StateNotifierProvider<PlayerSaveNotifier, AsyncValue<PlayerSave>>((ref) {
      final repo = ref.watch(saveRepositoryProvider);
      return PlayerSaveNotifier(repo);
    });
