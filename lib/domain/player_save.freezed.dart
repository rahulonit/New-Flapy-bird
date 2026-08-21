// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_save.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayerSave {

 int get schemaVersion; int get coins; int get gems; String get selectedCharacterId; String get selectedWorldId; List<String> get ownedCharacterIds; List<String> get ownedWorldIds; String get selectedProfileAvatarId; String get selectedProfileFrameId; String get selectedTrailId; List<String> get ownedTrailIds; int get shieldCount; int get scoreBoosterCount; int get bestScore; Map<String, int> get worldScores; int get totalRuns; String? get lastDailyMissionDate; Map<String, int> get missionCounters; List<String> get claimedMissionIds; bool get dailyBonusClaimed; String? get lastDailyRewardDate; String? get lastWeeklyRewardKey; String? get lastWeeklyMissionKey; Map<String, int> get weeklyMissionCounters; bool get hapticsEnabled; bool get musicEnabled; bool get sfxEnabled; bool get hintsEnabled;
/// Create a copy of PlayerSave
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerSaveCopyWith<PlayerSave> get copyWith => _$PlayerSaveCopyWithImpl<PlayerSave>(this as PlayerSave, _$identity);

  /// Serializes this PlayerSave to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerSave&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.gems, gems) || other.gems == gems)&&(identical(other.selectedCharacterId, selectedCharacterId) || other.selectedCharacterId == selectedCharacterId)&&(identical(other.selectedWorldId, selectedWorldId) || other.selectedWorldId == selectedWorldId)&&const DeepCollectionEquality().equals(other.ownedCharacterIds, ownedCharacterIds)&&const DeepCollectionEquality().equals(other.ownedWorldIds, ownedWorldIds)&&(identical(other.selectedProfileAvatarId, selectedProfileAvatarId) || other.selectedProfileAvatarId == selectedProfileAvatarId)&&(identical(other.selectedProfileFrameId, selectedProfileFrameId) || other.selectedProfileFrameId == selectedProfileFrameId)&&(identical(other.selectedTrailId, selectedTrailId) || other.selectedTrailId == selectedTrailId)&&const DeepCollectionEquality().equals(other.ownedTrailIds, ownedTrailIds)&&(identical(other.shieldCount, shieldCount) || other.shieldCount == shieldCount)&&(identical(other.scoreBoosterCount, scoreBoosterCount) || other.scoreBoosterCount == scoreBoosterCount)&&(identical(other.bestScore, bestScore) || other.bestScore == bestScore)&&const DeepCollectionEquality().equals(other.worldScores, worldScores)&&(identical(other.totalRuns, totalRuns) || other.totalRuns == totalRuns)&&(identical(other.lastDailyMissionDate, lastDailyMissionDate) || other.lastDailyMissionDate == lastDailyMissionDate)&&const DeepCollectionEquality().equals(other.missionCounters, missionCounters)&&const DeepCollectionEquality().equals(other.claimedMissionIds, claimedMissionIds)&&(identical(other.dailyBonusClaimed, dailyBonusClaimed) || other.dailyBonusClaimed == dailyBonusClaimed)&&(identical(other.lastDailyRewardDate, lastDailyRewardDate) || other.lastDailyRewardDate == lastDailyRewardDate)&&(identical(other.lastWeeklyRewardKey, lastWeeklyRewardKey) || other.lastWeeklyRewardKey == lastWeeklyRewardKey)&&(identical(other.lastWeeklyMissionKey, lastWeeklyMissionKey) || other.lastWeeklyMissionKey == lastWeeklyMissionKey)&&const DeepCollectionEquality().equals(other.weeklyMissionCounters, weeklyMissionCounters)&&(identical(other.hapticsEnabled, hapticsEnabled) || other.hapticsEnabled == hapticsEnabled)&&(identical(other.musicEnabled, musicEnabled) || other.musicEnabled == musicEnabled)&&(identical(other.sfxEnabled, sfxEnabled) || other.sfxEnabled == sfxEnabled)&&(identical(other.hintsEnabled, hintsEnabled) || other.hintsEnabled == hintsEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,schemaVersion,coins,gems,selectedCharacterId,selectedWorldId,const DeepCollectionEquality().hash(ownedCharacterIds),const DeepCollectionEquality().hash(ownedWorldIds),selectedProfileAvatarId,selectedProfileFrameId,selectedTrailId,const DeepCollectionEquality().hash(ownedTrailIds),shieldCount,scoreBoosterCount,bestScore,const DeepCollectionEquality().hash(worldScores),totalRuns,lastDailyMissionDate,const DeepCollectionEquality().hash(missionCounters),const DeepCollectionEquality().hash(claimedMissionIds),dailyBonusClaimed,lastDailyRewardDate,lastWeeklyRewardKey,lastWeeklyMissionKey,const DeepCollectionEquality().hash(weeklyMissionCounters),hapticsEnabled,musicEnabled,sfxEnabled,hintsEnabled]);

@override
String toString() {
  return 'PlayerSave(schemaVersion: $schemaVersion, coins: $coins, gems: $gems, selectedCharacterId: $selectedCharacterId, selectedWorldId: $selectedWorldId, ownedCharacterIds: $ownedCharacterIds, ownedWorldIds: $ownedWorldIds, selectedProfileAvatarId: $selectedProfileAvatarId, selectedProfileFrameId: $selectedProfileFrameId, selectedTrailId: $selectedTrailId, ownedTrailIds: $ownedTrailIds, shieldCount: $shieldCount, scoreBoosterCount: $scoreBoosterCount, bestScore: $bestScore, worldScores: $worldScores, totalRuns: $totalRuns, lastDailyMissionDate: $lastDailyMissionDate, missionCounters: $missionCounters, claimedMissionIds: $claimedMissionIds, dailyBonusClaimed: $dailyBonusClaimed, lastDailyRewardDate: $lastDailyRewardDate, lastWeeklyRewardKey: $lastWeeklyRewardKey, lastWeeklyMissionKey: $lastWeeklyMissionKey, weeklyMissionCounters: $weeklyMissionCounters, hapticsEnabled: $hapticsEnabled, musicEnabled: $musicEnabled, sfxEnabled: $sfxEnabled, hintsEnabled: $hintsEnabled)';
}


}

/// @nodoc
abstract mixin class $PlayerSaveCopyWith<$Res>  {
  factory $PlayerSaveCopyWith(PlayerSave value, $Res Function(PlayerSave) _then) = _$PlayerSaveCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, int coins, int gems, String selectedCharacterId, String selectedWorldId, List<String> ownedCharacterIds, List<String> ownedWorldIds, String selectedProfileAvatarId, String selectedProfileFrameId, String selectedTrailId, List<String> ownedTrailIds, int shieldCount, int scoreBoosterCount, int bestScore, Map<String, int> worldScores, int totalRuns, String? lastDailyMissionDate, Map<String, int> missionCounters, List<String> claimedMissionIds, bool dailyBonusClaimed, String? lastDailyRewardDate, String? lastWeeklyRewardKey, String? lastWeeklyMissionKey, Map<String, int> weeklyMissionCounters, bool hapticsEnabled, bool musicEnabled, bool sfxEnabled, bool hintsEnabled
});




}
/// @nodoc
class _$PlayerSaveCopyWithImpl<$Res>
    implements $PlayerSaveCopyWith<$Res> {
  _$PlayerSaveCopyWithImpl(this._self, this._then);

  final PlayerSave _self;
  final $Res Function(PlayerSave) _then;

/// Create a copy of PlayerSave
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? coins = null,Object? gems = null,Object? selectedCharacterId = null,Object? selectedWorldId = null,Object? ownedCharacterIds = null,Object? ownedWorldIds = null,Object? selectedProfileAvatarId = null,Object? selectedProfileFrameId = null,Object? selectedTrailId = null,Object? ownedTrailIds = null,Object? shieldCount = null,Object? scoreBoosterCount = null,Object? bestScore = null,Object? worldScores = null,Object? totalRuns = null,Object? lastDailyMissionDate = freezed,Object? missionCounters = null,Object? claimedMissionIds = null,Object? dailyBonusClaimed = null,Object? lastDailyRewardDate = freezed,Object? lastWeeklyRewardKey = freezed,Object? lastWeeklyMissionKey = freezed,Object? weeklyMissionCounters = null,Object? hapticsEnabled = null,Object? musicEnabled = null,Object? sfxEnabled = null,Object? hintsEnabled = null,}) {
  return _then(PlayerSave(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,gems: null == gems ? _self.gems : gems // ignore: cast_nullable_to_non_nullable
as int,selectedCharacterId: null == selectedCharacterId ? _self.selectedCharacterId : selectedCharacterId // ignore: cast_nullable_to_non_nullable
as String,selectedWorldId: null == selectedWorldId ? _self.selectedWorldId : selectedWorldId // ignore: cast_nullable_to_non_nullable
as String,ownedCharacterIds: null == ownedCharacterIds ? _self.ownedCharacterIds : ownedCharacterIds // ignore: cast_nullable_to_non_nullable
as List<String>,ownedWorldIds: null == ownedWorldIds ? _self.ownedWorldIds : ownedWorldIds // ignore: cast_nullable_to_non_nullable
as List<String>,selectedProfileAvatarId: null == selectedProfileAvatarId ? _self.selectedProfileAvatarId : selectedProfileAvatarId // ignore: cast_nullable_to_non_nullable
as String,selectedProfileFrameId: null == selectedProfileFrameId ? _self.selectedProfileFrameId : selectedProfileFrameId // ignore: cast_nullable_to_non_nullable
as String,selectedTrailId: null == selectedTrailId ? _self.selectedTrailId : selectedTrailId // ignore: cast_nullable_to_non_nullable
as String,ownedTrailIds: null == ownedTrailIds ? _self.ownedTrailIds : ownedTrailIds // ignore: cast_nullable_to_non_nullable
as List<String>,shieldCount: null == shieldCount ? _self.shieldCount : shieldCount // ignore: cast_nullable_to_non_nullable
as int,scoreBoosterCount: null == scoreBoosterCount ? _self.scoreBoosterCount : scoreBoosterCount // ignore: cast_nullable_to_non_nullable
as int,bestScore: null == bestScore ? _self.bestScore : bestScore // ignore: cast_nullable_to_non_nullable
as int,worldScores: null == worldScores ? _self.worldScores : worldScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalRuns: null == totalRuns ? _self.totalRuns : totalRuns // ignore: cast_nullable_to_non_nullable
as int,lastDailyMissionDate: freezed == lastDailyMissionDate ? _self.lastDailyMissionDate : lastDailyMissionDate // ignore: cast_nullable_to_non_nullable
as String?,missionCounters: null == missionCounters ? _self.missionCounters : missionCounters // ignore: cast_nullable_to_non_nullable
as Map<String, int>,claimedMissionIds: null == claimedMissionIds ? _self.claimedMissionIds : claimedMissionIds // ignore: cast_nullable_to_non_nullable
as List<String>,dailyBonusClaimed: null == dailyBonusClaimed ? _self.dailyBonusClaimed : dailyBonusClaimed // ignore: cast_nullable_to_non_nullable
as bool,lastDailyRewardDate: freezed == lastDailyRewardDate ? _self.lastDailyRewardDate : lastDailyRewardDate // ignore: cast_nullable_to_non_nullable
as String?,lastWeeklyRewardKey: freezed == lastWeeklyRewardKey ? _self.lastWeeklyRewardKey : lastWeeklyRewardKey // ignore: cast_nullable_to_non_nullable
as String?,lastWeeklyMissionKey: freezed == lastWeeklyMissionKey ? _self.lastWeeklyMissionKey : lastWeeklyMissionKey // ignore: cast_nullable_to_non_nullable
as String?,weeklyMissionCounters: null == weeklyMissionCounters ? _self.weeklyMissionCounters : weeklyMissionCounters // ignore: cast_nullable_to_non_nullable
as Map<String, int>,hapticsEnabled: null == hapticsEnabled ? _self.hapticsEnabled : hapticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,musicEnabled: null == musicEnabled ? _self.musicEnabled : musicEnabled // ignore: cast_nullable_to_non_nullable
as bool,sfxEnabled: null == sfxEnabled ? _self.sfxEnabled : sfxEnabled // ignore: cast_nullable_to_non_nullable
as bool,hintsEnabled: null == hintsEnabled ? _self.hintsEnabled : hintsEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerSave].
extension PlayerSavePatterns on PlayerSave {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerSave value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerSave() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerSave value)  $default,){
final _that = this;
switch (_that) {
case _PlayerSave():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerSave value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerSave() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  int coins,  int gems,  String selectedCharacterId,  String selectedWorldId,  List<String> ownedCharacterIds,  List<String> ownedWorldIds,  String selectedProfileAvatarId,  String selectedProfileFrameId,  String selectedTrailId,  List<String> ownedTrailIds,  int shieldCount,  int scoreBoosterCount,  int bestScore,  Map<String, int> worldScores,  int totalRuns,  String? lastDailyMissionDate,  Map<String, int> missionCounters,  List<String> claimedMissionIds,  bool dailyBonusClaimed,  String? lastDailyRewardDate,  String? lastWeeklyRewardKey,  String? lastWeeklyMissionKey,  Map<String, int> weeklyMissionCounters,  bool hapticsEnabled,  bool musicEnabled,  bool sfxEnabled,  bool hintsEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerSave() when $default != null:
return $default(_that.schemaVersion,_that.coins,_that.gems,_that.selectedCharacterId,_that.selectedWorldId,_that.ownedCharacterIds,_that.ownedWorldIds,_that.selectedProfileAvatarId,_that.selectedProfileFrameId,_that.selectedTrailId,_that.ownedTrailIds,_that.shieldCount,_that.scoreBoosterCount,_that.bestScore,_that.worldScores,_that.totalRuns,_that.lastDailyMissionDate,_that.missionCounters,_that.claimedMissionIds,_that.dailyBonusClaimed,_that.lastDailyRewardDate,_that.lastWeeklyRewardKey,_that.lastWeeklyMissionKey,_that.weeklyMissionCounters,_that.hapticsEnabled,_that.musicEnabled,_that.sfxEnabled,_that.hintsEnabled);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  int coins,  int gems,  String selectedCharacterId,  String selectedWorldId,  List<String> ownedCharacterIds,  List<String> ownedWorldIds,  String selectedProfileAvatarId,  String selectedProfileFrameId,  String selectedTrailId,  List<String> ownedTrailIds,  int shieldCount,  int scoreBoosterCount,  int bestScore,  Map<String, int> worldScores,  int totalRuns,  String? lastDailyMissionDate,  Map<String, int> missionCounters,  List<String> claimedMissionIds,  bool dailyBonusClaimed,  String? lastDailyRewardDate,  String? lastWeeklyRewardKey,  String? lastWeeklyMissionKey,  Map<String, int> weeklyMissionCounters,  bool hapticsEnabled,  bool musicEnabled,  bool sfxEnabled,  bool hintsEnabled)  $default,) {final _that = this;
switch (_that) {
case _PlayerSave():
return $default(_that.schemaVersion,_that.coins,_that.gems,_that.selectedCharacterId,_that.selectedWorldId,_that.ownedCharacterIds,_that.ownedWorldIds,_that.selectedProfileAvatarId,_that.selectedProfileFrameId,_that.selectedTrailId,_that.ownedTrailIds,_that.shieldCount,_that.scoreBoosterCount,_that.bestScore,_that.worldScores,_that.totalRuns,_that.lastDailyMissionDate,_that.missionCounters,_that.claimedMissionIds,_that.dailyBonusClaimed,_that.lastDailyRewardDate,_that.lastWeeklyRewardKey,_that.lastWeeklyMissionKey,_that.weeklyMissionCounters,_that.hapticsEnabled,_that.musicEnabled,_that.sfxEnabled,_that.hintsEnabled);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  int coins,  int gems,  String selectedCharacterId,  String selectedWorldId,  List<String> ownedCharacterIds,  List<String> ownedWorldIds,  String selectedProfileAvatarId,  String selectedProfileFrameId,  String selectedTrailId,  List<String> ownedTrailIds,  int shieldCount,  int scoreBoosterCount,  int bestScore,  Map<String, int> worldScores,  int totalRuns,  String? lastDailyMissionDate,  Map<String, int> missionCounters,  List<String> claimedMissionIds,  bool dailyBonusClaimed,  String? lastDailyRewardDate,  String? lastWeeklyRewardKey,  String? lastWeeklyMissionKey,  Map<String, int> weeklyMissionCounters,  bool hapticsEnabled,  bool musicEnabled,  bool sfxEnabled,  bool hintsEnabled)?  $default,) {final _that = this;
switch (_that) {
case _PlayerSave() when $default != null:
return $default(_that.schemaVersion,_that.coins,_that.gems,_that.selectedCharacterId,_that.selectedWorldId,_that.ownedCharacterIds,_that.ownedWorldIds,_that.selectedProfileAvatarId,_that.selectedProfileFrameId,_that.selectedTrailId,_that.ownedTrailIds,_that.shieldCount,_that.scoreBoosterCount,_that.bestScore,_that.worldScores,_that.totalRuns,_that.lastDailyMissionDate,_that.missionCounters,_that.claimedMissionIds,_that.dailyBonusClaimed,_that.lastDailyRewardDate,_that.lastWeeklyRewardKey,_that.lastWeeklyMissionKey,_that.weeklyMissionCounters,_that.hapticsEnabled,_that.musicEnabled,_that.sfxEnabled,_that.hintsEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerSave implements PlayerSave {
  const _PlayerSave({this.schemaVersion = 6, this.coins = 0, this.gems = 0, this.selectedCharacterId = 'default', this.selectedWorldId = 'default',  List<String> ownedCharacterIds = const ['default'],  List<String> ownedWorldIds = const ['default'], this.selectedProfileAvatarId = 'avatar_1', this.selectedProfileFrameId = 'frame_1', this.selectedTrailId = 'none',  List<String> ownedTrailIds = const ['none'], this.shieldCount = 0, this.scoreBoosterCount = 0, this.bestScore = 0,  Map<String, int> worldScores = const {}, this.totalRuns = 0, this.lastDailyMissionDate,  Map<String, int> missionCounters = const {},  List<String> claimedMissionIds = const [], this.dailyBonusClaimed = false, this.lastDailyRewardDate, this.lastWeeklyRewardKey, this.lastWeeklyMissionKey,  Map<String, int> weeklyMissionCounters = const {}, this.hapticsEnabled = true, this.musicEnabled = true, this.sfxEnabled = true, this.hintsEnabled = true}): _ownedCharacterIds = ownedCharacterIds,_ownedWorldIds = ownedWorldIds,_ownedTrailIds = ownedTrailIds,_worldScores = worldScores,_missionCounters = missionCounters,_claimedMissionIds = claimedMissionIds,_weeklyMissionCounters = weeklyMissionCounters;
  factory _PlayerSave.fromJson(Map<String, dynamic> json) => _$PlayerSaveFromJson(json);

@override@JsonKey() final  int schemaVersion;
@override@JsonKey() final  int coins;
@override@JsonKey() final  int gems;
@override@JsonKey() final  String selectedCharacterId;
@override@JsonKey() final  String selectedWorldId;
 final  List<String> _ownedCharacterIds;
@override@JsonKey() List<String> get ownedCharacterIds {
  if (_ownedCharacterIds is EqualUnmodifiableListView) return _ownedCharacterIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedCharacterIds);
}

 final  List<String> _ownedWorldIds;
@override@JsonKey() List<String> get ownedWorldIds {
  if (_ownedWorldIds is EqualUnmodifiableListView) return _ownedWorldIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedWorldIds);
}

@override@JsonKey() final  String selectedProfileAvatarId;
@override@JsonKey() final  String selectedProfileFrameId;
@override@JsonKey() final  String selectedTrailId;
 final  List<String> _ownedTrailIds;
@override@JsonKey() List<String> get ownedTrailIds {
  if (_ownedTrailIds is EqualUnmodifiableListView) return _ownedTrailIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedTrailIds);
}

@override@JsonKey() final  int shieldCount;
@override@JsonKey() final  int scoreBoosterCount;
@override@JsonKey() final  int bestScore;
 final  Map<String, int> _worldScores;
@override@JsonKey() Map<String, int> get worldScores {
  if (_worldScores is EqualUnmodifiableMapView) return _worldScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_worldScores);
}

@override@JsonKey() final  int totalRuns;
@override final  String? lastDailyMissionDate;
 final  Map<String, int> _missionCounters;
@override@JsonKey() Map<String, int> get missionCounters {
  if (_missionCounters is EqualUnmodifiableMapView) return _missionCounters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_missionCounters);
}

 final  List<String> _claimedMissionIds;
@override@JsonKey() List<String> get claimedMissionIds {
  if (_claimedMissionIds is EqualUnmodifiableListView) return _claimedMissionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_claimedMissionIds);
}

@override@JsonKey() final  bool dailyBonusClaimed;
@override final  String? lastDailyRewardDate;
@override final  String? lastWeeklyRewardKey;
@override final  String? lastWeeklyMissionKey;
 final  Map<String, int> _weeklyMissionCounters;
@override@JsonKey() Map<String, int> get weeklyMissionCounters {
  if (_weeklyMissionCounters is EqualUnmodifiableMapView) return _weeklyMissionCounters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_weeklyMissionCounters);
}

@override@JsonKey() final  bool hapticsEnabled;
@override@JsonKey() final  bool musicEnabled;
@override@JsonKey() final  bool sfxEnabled;
@override@JsonKey() final  bool hintsEnabled;

/// Create a copy of PlayerSave
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerSaveCopyWith<_PlayerSave> get copyWith => __$PlayerSaveCopyWithImpl<_PlayerSave>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerSaveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerSave&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.gems, gems) || other.gems == gems)&&(identical(other.selectedCharacterId, selectedCharacterId) || other.selectedCharacterId == selectedCharacterId)&&(identical(other.selectedWorldId, selectedWorldId) || other.selectedWorldId == selectedWorldId)&&const DeepCollectionEquality().equals(other._ownedCharacterIds, _ownedCharacterIds)&&const DeepCollectionEquality().equals(other._ownedWorldIds, _ownedWorldIds)&&(identical(other.selectedProfileAvatarId, selectedProfileAvatarId) || other.selectedProfileAvatarId == selectedProfileAvatarId)&&(identical(other.selectedProfileFrameId, selectedProfileFrameId) || other.selectedProfileFrameId == selectedProfileFrameId)&&(identical(other.selectedTrailId, selectedTrailId) || other.selectedTrailId == selectedTrailId)&&const DeepCollectionEquality().equals(other._ownedTrailIds, _ownedTrailIds)&&(identical(other.shieldCount, shieldCount) || other.shieldCount == shieldCount)&&(identical(other.scoreBoosterCount, scoreBoosterCount) || other.scoreBoosterCount == scoreBoosterCount)&&(identical(other.bestScore, bestScore) || other.bestScore == bestScore)&&const DeepCollectionEquality().equals(other._worldScores, _worldScores)&&(identical(other.totalRuns, totalRuns) || other.totalRuns == totalRuns)&&(identical(other.lastDailyMissionDate, lastDailyMissionDate) || other.lastDailyMissionDate == lastDailyMissionDate)&&const DeepCollectionEquality().equals(other._missionCounters, _missionCounters)&&const DeepCollectionEquality().equals(other._claimedMissionIds, _claimedMissionIds)&&(identical(other.dailyBonusClaimed, dailyBonusClaimed) || other.dailyBonusClaimed == dailyBonusClaimed)&&(identical(other.lastDailyRewardDate, lastDailyRewardDate) || other.lastDailyRewardDate == lastDailyRewardDate)&&(identical(other.lastWeeklyRewardKey, lastWeeklyRewardKey) || other.lastWeeklyRewardKey == lastWeeklyRewardKey)&&(identical(other.lastWeeklyMissionKey, lastWeeklyMissionKey) || other.lastWeeklyMissionKey == lastWeeklyMissionKey)&&const DeepCollectionEquality().equals(other._weeklyMissionCounters, _weeklyMissionCounters)&&(identical(other.hapticsEnabled, hapticsEnabled) || other.hapticsEnabled == hapticsEnabled)&&(identical(other.musicEnabled, musicEnabled) || other.musicEnabled == musicEnabled)&&(identical(other.sfxEnabled, sfxEnabled) || other.sfxEnabled == sfxEnabled)&&(identical(other.hintsEnabled, hintsEnabled) || other.hintsEnabled == hintsEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,schemaVersion,coins,gems,selectedCharacterId,selectedWorldId,const DeepCollectionEquality().hash(_ownedCharacterIds),const DeepCollectionEquality().hash(_ownedWorldIds),selectedProfileAvatarId,selectedProfileFrameId,selectedTrailId,const DeepCollectionEquality().hash(_ownedTrailIds),shieldCount,scoreBoosterCount,bestScore,const DeepCollectionEquality().hash(_worldScores),totalRuns,lastDailyMissionDate,const DeepCollectionEquality().hash(_missionCounters),const DeepCollectionEquality().hash(_claimedMissionIds),dailyBonusClaimed,lastDailyRewardDate,lastWeeklyRewardKey,lastWeeklyMissionKey,const DeepCollectionEquality().hash(_weeklyMissionCounters),hapticsEnabled,musicEnabled,sfxEnabled,hintsEnabled]);

@override
String toString() {
  return 'PlayerSave(schemaVersion: $schemaVersion, coins: $coins, gems: $gems, selectedCharacterId: $selectedCharacterId, selectedWorldId: $selectedWorldId, ownedCharacterIds: $ownedCharacterIds, ownedWorldIds: $ownedWorldIds, selectedProfileAvatarId: $selectedProfileAvatarId, selectedProfileFrameId: $selectedProfileFrameId, selectedTrailId: $selectedTrailId, ownedTrailIds: $ownedTrailIds, shieldCount: $shieldCount, scoreBoosterCount: $scoreBoosterCount, bestScore: $bestScore, worldScores: $worldScores, totalRuns: $totalRuns, lastDailyMissionDate: $lastDailyMissionDate, missionCounters: $missionCounters, claimedMissionIds: $claimedMissionIds, dailyBonusClaimed: $dailyBonusClaimed, lastDailyRewardDate: $lastDailyRewardDate, lastWeeklyRewardKey: $lastWeeklyRewardKey, lastWeeklyMissionKey: $lastWeeklyMissionKey, weeklyMissionCounters: $weeklyMissionCounters, hapticsEnabled: $hapticsEnabled, musicEnabled: $musicEnabled, sfxEnabled: $sfxEnabled, hintsEnabled: $hintsEnabled)';
}


}

/// @nodoc
abstract mixin class _$PlayerSaveCopyWith<$Res> implements $PlayerSaveCopyWith<$Res> {
  factory _$PlayerSaveCopyWith(_PlayerSave value, $Res Function(_PlayerSave) _then) = __$PlayerSaveCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, int coins, int gems, String selectedCharacterId, String selectedWorldId, List<String> ownedCharacterIds, List<String> ownedWorldIds, String selectedProfileAvatarId, String selectedProfileFrameId, String selectedTrailId, List<String> ownedTrailIds, int shieldCount, int scoreBoosterCount, int bestScore, Map<String, int> worldScores, int totalRuns, String? lastDailyMissionDate, Map<String, int> missionCounters, List<String> claimedMissionIds, bool dailyBonusClaimed, String? lastDailyRewardDate, String? lastWeeklyRewardKey, String? lastWeeklyMissionKey, Map<String, int> weeklyMissionCounters, bool hapticsEnabled, bool musicEnabled, bool sfxEnabled, bool hintsEnabled
});




}
/// @nodoc
class __$PlayerSaveCopyWithImpl<$Res>
    implements _$PlayerSaveCopyWith<$Res> {
  __$PlayerSaveCopyWithImpl(this._self, this._then);

  final _PlayerSave _self;
  final $Res Function(_PlayerSave) _then;

/// Create a copy of PlayerSave
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? coins = null,Object? gems = null,Object? selectedCharacterId = null,Object? selectedWorldId = null,Object? ownedCharacterIds = null,Object? ownedWorldIds = null,Object? selectedProfileAvatarId = null,Object? selectedProfileFrameId = null,Object? selectedTrailId = null,Object? ownedTrailIds = null,Object? shieldCount = null,Object? scoreBoosterCount = null,Object? bestScore = null,Object? worldScores = null,Object? totalRuns = null,Object? lastDailyMissionDate = freezed,Object? missionCounters = null,Object? claimedMissionIds = null,Object? dailyBonusClaimed = null,Object? lastDailyRewardDate = freezed,Object? lastWeeklyRewardKey = freezed,Object? lastWeeklyMissionKey = freezed,Object? weeklyMissionCounters = null,Object? hapticsEnabled = null,Object? musicEnabled = null,Object? sfxEnabled = null,Object? hintsEnabled = null,}) {
  return _then(_PlayerSave(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,gems: null == gems ? _self.gems : gems // ignore: cast_nullable_to_non_nullable
as int,selectedCharacterId: null == selectedCharacterId ? _self.selectedCharacterId : selectedCharacterId // ignore: cast_nullable_to_non_nullable
as String,selectedWorldId: null == selectedWorldId ? _self.selectedWorldId : selectedWorldId // ignore: cast_nullable_to_non_nullable
as String,ownedCharacterIds: null == ownedCharacterIds ? _self._ownedCharacterIds : ownedCharacterIds // ignore: cast_nullable_to_non_nullable
as List<String>,ownedWorldIds: null == ownedWorldIds ? _self._ownedWorldIds : ownedWorldIds // ignore: cast_nullable_to_non_nullable
as List<String>,selectedProfileAvatarId: null == selectedProfileAvatarId ? _self.selectedProfileAvatarId : selectedProfileAvatarId // ignore: cast_nullable_to_non_nullable
as String,selectedProfileFrameId: null == selectedProfileFrameId ? _self.selectedProfileFrameId : selectedProfileFrameId // ignore: cast_nullable_to_non_nullable
as String,selectedTrailId: null == selectedTrailId ? _self.selectedTrailId : selectedTrailId // ignore: cast_nullable_to_non_nullable
as String,ownedTrailIds: null == ownedTrailIds ? _self._ownedTrailIds : ownedTrailIds // ignore: cast_nullable_to_non_nullable
as List<String>,shieldCount: null == shieldCount ? _self.shieldCount : shieldCount // ignore: cast_nullable_to_non_nullable
as int,scoreBoosterCount: null == scoreBoosterCount ? _self.scoreBoosterCount : scoreBoosterCount // ignore: cast_nullable_to_non_nullable
as int,bestScore: null == bestScore ? _self.bestScore : bestScore // ignore: cast_nullable_to_non_nullable
as int,worldScores: null == worldScores ? _self._worldScores : worldScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalRuns: null == totalRuns ? _self.totalRuns : totalRuns // ignore: cast_nullable_to_non_nullable
as int,lastDailyMissionDate: freezed == lastDailyMissionDate ? _self.lastDailyMissionDate : lastDailyMissionDate // ignore: cast_nullable_to_non_nullable
as String?,missionCounters: null == missionCounters ? _self._missionCounters : missionCounters // ignore: cast_nullable_to_non_nullable
as Map<String, int>,claimedMissionIds: null == claimedMissionIds ? _self._claimedMissionIds : claimedMissionIds // ignore: cast_nullable_to_non_nullable
as List<String>,dailyBonusClaimed: null == dailyBonusClaimed ? _self.dailyBonusClaimed : dailyBonusClaimed // ignore: cast_nullable_to_non_nullable
as bool,lastDailyRewardDate: freezed == lastDailyRewardDate ? _self.lastDailyRewardDate : lastDailyRewardDate // ignore: cast_nullable_to_non_nullable
as String?,lastWeeklyRewardKey: freezed == lastWeeklyRewardKey ? _self.lastWeeklyRewardKey : lastWeeklyRewardKey // ignore: cast_nullable_to_non_nullable
as String?,lastWeeklyMissionKey: freezed == lastWeeklyMissionKey ? _self.lastWeeklyMissionKey : lastWeeklyMissionKey // ignore: cast_nullable_to_non_nullable
as String?,weeklyMissionCounters: null == weeklyMissionCounters ? _self._weeklyMissionCounters : weeklyMissionCounters // ignore: cast_nullable_to_non_nullable
as Map<String, int>,hapticsEnabled: null == hapticsEnabled ? _self.hapticsEnabled : hapticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,musicEnabled: null == musicEnabled ? _self.musicEnabled : musicEnabled // ignore: cast_nullable_to_non_nullable
as bool,sfxEnabled: null == sfxEnabled ? _self.sfxEnabled : sfxEnabled // ignore: cast_nullable_to_non_nullable
as bool,hintsEnabled: null == hintsEnabled ? _self.hintsEnabled : hintsEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
