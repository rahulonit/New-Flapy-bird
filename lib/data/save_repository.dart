import '../domain/player_save.dart';

abstract class SaveRepository {
  Future<PlayerSave> load();
  Future<void> save(PlayerSave value);
  Future<void> clearAll();
}
