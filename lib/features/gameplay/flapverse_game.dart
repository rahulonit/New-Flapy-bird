import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

import 'obstacles.dart';
import '../../core/audio_service.dart';

class FlapverseGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late PlayerBird bird;
  late ObstacleManager obstacleManager;
  late ParallaxComponent background;
  bool isPlaying = false;
  
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> comboNotifier = ValueNotifier<int>(0);
  
  VoidCallback? onGameOver;
  
  @override
  Color backgroundColor() => const Color(0xFF051A3A);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    images.prefix = 'assets/';

    background = await loadParallaxComponent(
      [ParallaxImageData('world-atlas.png')],
      baseVelocity: Vector2(40, 0),
      velocityMultiplierDelta: Vector2(1.5, 1.0),
    );
    add(background);

    bird = PlayerBird();
    add(bird);
    
    obstacleManager = ObstacleManager();
    add(obstacleManager);
    
    AudioService.playBgm();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!isPlaying && bird.isActive == false) {
      isPlaying = true;
      bird.startFlying();
    } else if (isPlaying) {
      bird.flap();
    } else {
      resetGame();
    }
  }

  void resetGame() {
    scoreNotifier.value = 0;
    comboNotifier.value = 0;
    children.whereType<Obstacle>().forEach((obstacle) => obstacle.removeFromParent());
    bird.reset();
    obstacleManager.reset();
  }

  void gameOver() {
    if (!isPlaying) return;
    isPlaying = false;
    bird.isActive = false;
    AudioService.playHit();
    overlays.add('GameOverMenu');
    if (onGameOver != null) onGameOver!();
  }

  void increaseScore() {
    scoreNotifier.value += 100 + (comboNotifier.value * 10);
    comboNotifier.value += 1;
  }
}

class PlayerBird extends SpriteComponent with HasGameRef<FlapverseGame>, CollisionCallbacks {
  static const double gravity = 1200.0;
  static const double flapImpulse = -450.0;
  static const double maxVelocity = 700.0;
  
  double velocity = 0.0;
  bool isActive = false;

  PlayerBird() : super(size: Vector2(80, 80), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    sprite = await Sprite.load('flying-bird-3d-flap.png', images: gameRef.images);
    
    // Tightened hitbox for fairer physics
    add(CircleHitbox(radius: 25, position: Vector2(15, 15)));
    reset();
  }

  void reset() {
    position = Vector2(gameRef.size.x * 0.3, gameRef.size.y * 0.5);
    velocity = 0;
    isActive = false;
    angle = 0;
  }

  void startFlying() {
    isActive = true;
    flap();
  }

  void flap() {
    velocity = flapImpulse;
    AudioService.playFlap();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isActive) {
      velocity += gravity * dt;
      if (velocity > maxVelocity) velocity = maxVelocity;
      
      position.y += velocity * dt;
      
      // Dynamic Pitching Physics
      if (velocity < 0) {
        // Point up instantly when flapping
        angle = -0.4;
      } else {
        // Smoothly pitch down as gravity takes over
        angle = (-0.4 + (velocity / maxVelocity) * 1.2).clamp(-0.4, 0.8);
      }
      
      // Check ceiling and floor bounds
      if (position.y > gameRef.size.y - (size.y / 2) || position.y < (size.y / 2)) {
        gameRef.gameOver();
      }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Obstacle) {
      gameRef.gameOver();
    }
  }
}
