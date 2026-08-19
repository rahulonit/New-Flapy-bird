// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_save.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerSave _$PlayerSaveFromJson(Map<String, dynamic> json) => _PlayerSave(
  schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
  coins: (json['coins'] as num?)?.toInt() ?? 0,
  gems: (json['gems'] as num?)?.toInt() ?? 0,
  selectedCharacterId: json['selectedCharacterId'] as String? ?? 'default',
  selectedWorldId: json['selectedWorldId'] as String? ?? 'default',
  ownedCharacterIds:
      (json['ownedCharacterIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['default'],
  ownedWorldIds:
      (json['ownedWorldIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['default'],
  bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
  worldScores:
      (json['worldScores'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  totalRuns: (json['totalRuns'] as num?)?.toInt() ?? 0,
  lastDailyMissionDate: json['lastDailyMissionDate'] as String?,
  missionCounters:
      (json['missionCounters'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  claimedMissionIds:
      (json['claimedMissionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  dailyBonusClaimed: json['dailyBonusClaimed'] as bool? ?? false,
  lastDailyRewardDate: json['lastDailyRewardDate'] as String?,
  hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
  musicEnabled: json['musicEnabled'] as bool? ?? true,
  sfxEnabled: json['sfxEnabled'] as bool? ?? true,
  hintsEnabled: json['hintsEnabled'] as bool? ?? true,
);

Map<String, dynamic> _$PlayerSaveToJson(_PlayerSave instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'coins': instance.coins,
      'gems': instance.gems,
      'selectedCharacterId': instance.selectedCharacterId,
      'selectedWorldId': instance.selectedWorldId,
      'ownedCharacterIds': instance.ownedCharacterIds,
      'ownedWorldIds': instance.ownedWorldIds,
      'bestScore': instance.bestScore,
      'worldScores': instance.worldScores,
      'totalRuns': instance.totalRuns,
      'lastDailyMissionDate': instance.lastDailyMissionDate,
      'missionCounters': instance.missionCounters,
      'claimedMissionIds': instance.claimedMissionIds,
      'dailyBonusClaimed': instance.dailyBonusClaimed,
      'lastDailyRewardDate': instance.lastDailyRewardDate,
      'hapticsEnabled': instance.hapticsEnabled,
      'musicEnabled': instance.musicEnabled,
      'sfxEnabled': instance.sfxEnabled,
      'hintsEnabled': instance.hintsEnabled,
    };
