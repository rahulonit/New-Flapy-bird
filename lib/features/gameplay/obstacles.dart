import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'flapverse_game.dart';
import '../../core/audio_service.dart';

class ObstacleManager extends Component with HasGameRef<FlapverseGame> {
  final Random random = Random();
  double timer = 0;
  final double spawnInterval = 2.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameRef.isPlaying) return;

    timer += dt;
    if (timer > spawnInterval) {
      timer = 0;
      spawnObstacle();
    }
  }

  void reset() { timer = 0; }

  void spawnObstacle() {
    final double gapSize = gameRef.size.y * 0.35; // 35% of screen height
    final double minHeight = 50;
    final double maxHeight = gameRef.size.y - gapSize - minHeight;
    final double topHeight = minHeight + random.nextDouble() * (maxHeight - minHeight);

    final topObstacle = Obstacle(
      position: Vector2(gameRef.size.x, 0),
      size: Vector2(90, topHeight),
      isTop: true,
    );

    final bottomObstacle = Obstacle(
      position: Vector2(gameRef.size.x, topHeight + gapSize),
      size: Vector2(90, gameRef.size.y - (topHeight + gapSize)),
      isTop: false,
    );

    gameRef.add(topObstacle);
    gameRef.add(bottomObstacle);
  }
}

class Obstacle extends PositionComponent with HasGameRef<FlapverseGame>, CollisionCallbacks {
  final bool isTop;
  final double speed = 300.0;
  bool passed = false;

  Obstacle({required super.position, required super.size, required this.isTop});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox());
    
    // Cyber/Neon styling
    final paint = Paint()
      ..color = const Color(0xFF14D9FF).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
      
    add(RectangleComponent(size: size, paint: paint));
    add(RectangleComponent(size: size, paint: borderPaint));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameRef.isPlaying) return;

    position.x -= speed * dt;
    
    // Scoring logic
    if (isTop && !passed && position.x + size.x < gameRef.bird.position.x) {
      passed = true;
      gameRef.increaseScore();
      AudioService.playScore();
    }

    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }
}
