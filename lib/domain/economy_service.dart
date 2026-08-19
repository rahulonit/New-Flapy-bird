import 'player_save.dart';
import '../data/save_repository.dart';

class EconomyService {
  final SaveRepository repository;
  
  EconomyService(this.repository);

  Future<PlayerSave> grantCoins(int amount) async {
    final save = await repository.load();
    final updated = save.copyWith(coins: save.coins + amount);
    await repository.save(updated);
    return updated;
  }

  Future<PlayerSave> grantGems(int amount) async {
    final save = await repository.load();
    final updated = save.copyWith(gems: save.gems + amount);
    await repository.save(updated);
    return updated;
  }

  Future<PlayerSave?> purchaseCharacter(String characterId, int costCoins) async {
    final save = await repository.load();
    if (save.coins >= costCoins && !save.ownedCharacterIds.contains(characterId)) {
      final updated = save.copyWith(
        coins: save.coins - costCoins,
        ownedCharacterIds: [...save.ownedCharacterIds, characterId],
      );
      await repository.save(updated);
      return updated;
    }
    return null; // Transaction failed
  }
}
