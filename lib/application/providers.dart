import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/save_repository.dart';
import '../data/shared_prefs_save_repository.dart';
import '../domain/economy_service.dart';
import '../domain/player_save.dart';

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
      
      // Check Daily Reset
      final today = DateTime.now().toIso8601String().split('T').first;
      bool needsSave = false;
      
      if (save.lastDailyMissionDate != today) {
        save = save.copyWith(
          lastDailyMissionDate: today,
          missionCounters: {},
          claimedMissionIds: [],
          dailyBonusClaimed: false,
        );
        needsSave = true;
      }
      
      if (needsSave) {
        await repository.save(save);
      }
      
      state = AsyncValue.data(save);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> save(PlayerSave newSave) async {
    state = AsyncValue.data(newSave);
    await repository.save(newSave);
  }
}

final playerSaveProvider = StateNotifierProvider<PlayerSaveNotifier, AsyncValue<PlayerSave>>((ref) {
  final repo = ref.watch(saveRepositoryProvider);
  return PlayerSaveNotifier(repo);
});
