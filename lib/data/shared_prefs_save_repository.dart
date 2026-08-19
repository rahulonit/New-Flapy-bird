import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/player_save.dart';
import 'save_repository.dart';

class SharedPrefsSaveRepository implements SaveRepository {
  static const String _saveKey = 'flapverse_player_save';

  @override
  Future<PlayerSave> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_saveKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return PlayerSave.fromJson(json);
      } catch (e) {
        // Fallback to default on parse error
      }
    }
    return const PlayerSave();
  }

  @override
  Future<void> save(PlayerSave value) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(value.toJson());
    await prefs.setString(_saveKey, jsonString);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }
}
