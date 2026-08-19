import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_save.freezed.dart';
part 'player_save.g.dart';

@freezed
abstract class PlayerSave with _$PlayerSave {

  const factory PlayerSave({
    @Default(1) int schemaVersion,
    @Default(0) int coins,
    @Default(0) int gems,
    
    // Customization
    @Default('default') String selectedCharacterId,
    @Default('default') String selectedWorldId,
    @Default(['default']) List<String> ownedCharacterIds,
    @Default(['default']) List<String> ownedWorldIds,
    
    // Stats & Scores
    @Default(0) int bestScore,
    @Default({}) Map<String, int> worldScores,
    @Default(0) int totalRuns,
    
    // Daily Missions & Rewards
    String? lastDailyMissionDate,
    @Default({}) Map<String, int> missionCounters,
    @Default([]) List<String> claimedMissionIds,
    @Default(false) bool dailyBonusClaimed,
    String? lastDailyRewardDate,
    
    // Settings
    @Default(true) bool hapticsEnabled,
    @Default(true) bool musicEnabled,
    @Default(true) bool sfxEnabled,
    @Default(true) bool hintsEnabled,
  }) = _PlayerSave;

  factory PlayerSave.fromJson(Map<String, dynamic> json) => _$PlayerSaveFromJson(json);
}
