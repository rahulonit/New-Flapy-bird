import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';

class AudioService {
  static bool musicEnabled = true;
  static bool sfxEnabled = true;
  static bool hapticsEnabled = true;
  static bool _bgmRequested = false;
  static bool _bgmPlaying = false;
  static bool _bgmPaused = false;
  static bool _bgmLoaded = false;
  static int _bgmGeneration = 0;
  static Future<void>? _bgmOperation;
  static Timer? _bgmRetryTimer;
  static int _sfxGeneration = 0;
  static final Set<AudioPlayer> _activeSfx = <AudioPlayer>{};
  static final Map<String, AudioPlayer> _activeSfxByAsset =
      <String, AudioPlayer>{};
  static final Map<String, int> _sfxRequestToken = <String, int>{};
  static int _pendingSfx = 0;
  static int _lastFlapSoundMs = 0;
  static int _lastCoinSoundMs = 0;

  static Future<void> init() async {
    FlameAudio.audioCache.prefix = 'assets/sound_and_music/';
    await FlameAudio.audioCache.loadAll([
      'Wing.mp3',
      'Point.mp3',
      'Hit.mp3',
      'Die.mp3',
      'Swooshing.mp3',
      'game-music-491667.mp3',
    ]);
  }

  static void configure({
    required bool music,
    required bool sfx,
    required bool haptics,
  }) {
    musicEnabled = music;
    sfxEnabled = sfx;
    hapticsEnabled = haptics;
    if (!sfx) stopAllSfx();
    if (!music) {
      pauseBgm();
    } else if (_bgmRequested) {
      resumeBgm();
    }
  }

  static void playBgm() {
    _bgmRequested = true;
    _bgmPaused = false;
    _startBgm();
  }

  static void _startBgm() {
    if (!musicEnabled ||
        !_bgmRequested ||
        _bgmPaused ||
        _bgmPlaying ||
        _bgmOperation != null) {
      return;
    }
    if (_bgmLoaded) {
      _resumeLoadedBgm();
      return;
    }
    final generation = _bgmGeneration;
    _bgmOperation = () async {
      try {
        await FlameAudio.bgm.play('game-music-491667.mp3', volume: 0.34);
        _bgmLoaded = true;
        if (!_bgmRequested || !musicEnabled) {
          await FlameAudio.bgm.stop();
          _bgmLoaded = false;
        } else if (generation != _bgmGeneration || _bgmPaused) {
          await FlameAudio.bgm.pause();
        } else {
          _bgmPlaying = true;
        }
      } catch (_) {
        _bgmPlaying = false;
      } finally {
        _bgmOperation = null;
        if (_bgmRequested && !_bgmPaused && musicEnabled && !_bgmPlaying) {
          _scheduleBgmRetry();
        }
      }
    }();
  }

  static void _resumeLoadedBgm() {
    if (_bgmOperation != null || !_bgmLoaded) return;
    final generation = _bgmGeneration;
    _bgmOperation = () async {
      try {
        await FlameAudio.bgm.resume();
        if (!_bgmRequested || !musicEnabled) {
          await FlameAudio.bgm.stop();
          _bgmLoaded = false;
        } else if (generation != _bgmGeneration || _bgmPaused) {
          await FlameAudio.bgm.pause();
        } else {
          _bgmPlaying = true;
        }
      } catch (_) {
        _bgmPlaying = false;
        _bgmLoaded = false;
      } finally {
        _bgmOperation = null;
        if (_bgmRequested && !_bgmPaused && musicEnabled && !_bgmPlaying) {
          _scheduleBgmRetry();
        }
      }
    }();
  }

  static void _scheduleBgmRetry() {
    if (_bgmRetryTimer?.isActive ?? false) return;
    _bgmRetryTimer = Timer(const Duration(milliseconds: 750), () {
      _bgmRetryTimer = null;
      _startBgm();
    });
  }

  static void pauseBgm() {
    _bgmRetryTimer?.cancel();
    _bgmRetryTimer = null;
    _bgmPaused = true;
    _bgmGeneration++;
    _bgmPlaying = false;
    unawaited(FlameAudio.bgm.pause());
  }

  static void resumeBgm() {
    if (!_bgmRequested || !musicEnabled) return;
    _bgmPaused = false;
    _bgmGeneration++;
    _bgmRetryTimer?.cancel();
    _bgmRetryTimer = null;
    _startBgm();
  }

  static void stopBgm() {
    _bgmRetryTimer?.cancel();
    _bgmRetryTimer = null;
    _bgmRequested = false;
    _bgmPaused = false;
    _bgmGeneration++;
    _bgmPlaying = false;
    _bgmLoaded = false;
    unawaited(FlameAudio.bgm.stop());
  }

  static void stopAllSfx() {
    _sfxGeneration++;
    final players = _activeSfx.toList(growable: false);
    _activeSfx.clear();
    _activeSfxByAsset.clear();
    _sfxRequestToken.clear();
    for (final player in players) {
      unawaited(player.stop().whenComplete(player.dispose));
    }
  }

  static void stopAll() {
    stopBgm();
    stopAllSfx();
  }

  static void _playSfx(
    String asset, {
    double volume = 1,
    bool replaceExisting = false,
  }) {
    if (!sfxEnabled || _activeSfx.length + _pendingSfx >= 8) return;
    final generation = _sfxGeneration;
    final requestToken = (_sfxRequestToken[asset] ?? 0) + 1;
    _sfxRequestToken[asset] = requestToken;
    if (replaceExisting) {
      final previous = _activeSfxByAsset.remove(asset);
      if (previous != null) {
        _activeSfx.remove(previous);
        unawaited(previous.stop().whenComplete(previous.dispose));
      }
    }
    _pendingSfx++;
    unawaited(() async {
      var waitingForPlayer = true;
      try {
        final player = await FlameAudio.play(asset, volume: volume);
        _pendingSfx--;
        waitingForPlayer = false;
        if (generation != _sfxGeneration ||
            !sfxEnabled ||
            (replaceExisting && _sfxRequestToken[asset] != requestToken)) {
          await player.stop();
          await player.dispose();
          return;
        }
        _activeSfx.add(player);
        if (replaceExisting) _activeSfxByAsset[asset] = player;
        unawaited(
          player.onPlayerComplete.first.then((_) {
            _activeSfx.remove(player);
            if (identical(_activeSfxByAsset[asset], player)) {
              _activeSfxByAsset.remove(asset);
            }
            return player.dispose();
          }),
        );
      } catch (_) {
        if (waitingForPlayer && _pendingSfx > 0) _pendingSfx--;
        // Audio failures must never interrupt gameplay.
      }
    }());
  }

  static void playFlap() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastFlapSoundMs >= 85) {
      _lastFlapSoundMs = now;
      _playSfx('Wing.mp3', volume: 0.42, replaceExisting: true);
    }
    if (hapticsEnabled) HapticFeedback.lightImpact();
  }

  static void playCoin() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastCoinSoundMs >= 70) {
      _lastCoinSoundMs = now;
      _playSfx('Point.mp3', volume: 0.76, replaceExisting: true);
    }
    if (hapticsEnabled) HapticFeedback.selectionClick();
  }

  static void playHit() {
    _playSfx('Hit.mp3');
    if (hapticsEnabled) HapticFeedback.heavyImpact();
  }

  static void playShield() {
    _playSfx('Swooshing.mp3', volume: 0.85);
    if (hapticsEnabled) HapticFeedback.mediumImpact();
  }

  static void playDie() {
    _playSfx('Die.mp3', volume: 0.9);
  }
}
