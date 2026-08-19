import 'package:flame_audio/flame_audio.dart';

class AudioService {
  static Future<void> init() async {
    // Override the default prefix so FlameAudio looks in our folder
    FlameAudio.audioCache.prefix = 'assets/sound_and_music/';
    
    await FlameAudio.audioCache.loadAll([
      'Wing.mp3',
      'Point.mp3',
      'Hit.mp3',
      'Die.mp3',
      'game-music-491667.mp3'
    ]);
  }

  static void playBgm() {
    FlameAudio.bgm.play('game-music-491667.mp3', volume: 0.5);
  }

  static void stopBgm() {
    FlameAudio.bgm.stop();
  }

  static void playFlap() {
    FlameAudio.play('Wing.mp3');
  }

  static void playScore() {
    FlameAudio.play('Point.mp3');
  }

  static void playHit() {
    FlameAudio.play('Hit.mp3');
  }

  static void playDie() {
    FlameAudio.play('Die.mp3');
  }
}
