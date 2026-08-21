import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'flapverse_game.dart';
import '../../core/gameplay_tuning.dart';
import 'collectible_coin.dart';

class ObstacleManager extends Component with HasGameReference<FlapverseGame> {
  final Random random = Random();
  double timer = 0;
  double get spawnInterval =>
      GameplayTuning.obstacleSpawnInterval *
      game.difficulty.spawnIntervalMultiplier;

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) return;

    timer += dt;
    if (timer > spawnInterval) {
      timer = 0;
      spawnObstacle();
    }
  }

  void reset() {
    timer = 0;
  }

  void spawnObstacle() {
    final double gapSize =
        game.size.y *
        GameplayTuning.obstacleGapHeight *
        game.difficulty.gapMultiplier;
    final double minHeight = game.size.y * GameplayTuning.obstacleMinimumHeight;
    final double maxHeight = game.size.y - gapSize - minHeight;
    final double topHeight =
        minHeight + random.nextDouble() * (maxHeight - minHeight);
    final bool useMysticForestArt = game.backgroundAsset.contains(
      'MysticForest_world_assets',
    );
    final double obstacleWidth = game.size.x * GameplayTuning.obstacleWidth;
    final int variant = random.nextInt(7) + 1;
    final String? topAsset = useMysticForestArt
        ? 'MysticForest_world_assets/${variant == 1 ? 'up 1' : 'up$variant'}.png'
        : null;
    final String? bottomAsset = useMysticForestArt
        ? 'MysticForest_world_assets/down$variant.png'
        : null;

    final topObstacle = Obstacle(
      position: Vector2(game.size.x, 0),
      size: Vector2(obstacleWidth, topHeight),
      isTop: true,
      asset: topAsset,
    );

    final bottomObstacle = Obstacle(
      position: Vector2(game.size.x, topHeight + gapSize),
      size: Vector2(obstacleWidth, game.size.y - (topHeight + gapSize)),
      isTop: false,
      asset: bottomAsset,
    );

    game.add(topObstacle);
    game.add(bottomObstacle);

    if (random.nextDouble() < 0.72) {
      final safePadding = gapSize * 0.22;
      final safeRange = gapSize - safePadding * 2;
      final centerY = topHeight + safePadding + random.nextDouble() * safeRange;
      game.add(
        CollectibleCoin(
          position: Vector2(game.size.x + obstacleWidth / 2, centerY),
        ),
      );
    }
  }
}

class Obstacle extends PositionComponent
    with HasGameReference<FlapverseGame>, CollisionCallbacks {
  final bool isTop;
  final String? asset;
  bool passed = false;

  double get speed =>
      (game.size.x * GameplayTuning.obstacleSpeedPerScreenWidth).clamp(
        GameplayTuning.obstacleMinSpeed,
        GameplayTuning.obstacleMaxSpeed,
      ) *
      game.difficulty.speedMultiplier;

  Obstacle({
    required super.position,
    required super.size,
    required this.isTop,
    this.asset,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (asset != null) {
      final image = await game.images.load(asset!);
      final sourceSize = Vector2(
        image.width.toDouble(),
        image.height.toDouble(),
      );
      // Width always fills 10% of the screen. Height follows the source aspect
      // ratio and is allowed to extend beyond the viewport instead of deforming.
      final scale = size.x / sourceSize.x;
      final renderSize = sourceSize * scale;
      final isShorterThanSlot = renderSize.y < size.y;
      final renderPosition = Vector2(
        (size.x - renderSize.x) / 1,
        isTop
            ? (isShorterThanSlot ? 0 : size.y - renderSize.y)
            : (isShorterThanSlot ? size.y - renderSize.y : 0),
      );

      add(
        SpriteComponent(
          sprite: Sprite(image),
          position: renderPosition,
          size: renderSize,
        ),
      );

      // Follow only the visible, proportionally scaled obstacle artwork.
      final hitboxWidth = renderSize.x * 0.64;
      add(
        RectangleHitbox(
          position: Vector2(
            renderPosition.x + (renderSize.x - hitboxWidth) / 2,
            renderPosition.y,
          ),
          size: Vector2(hitboxWidth, renderSize.y),
        ),
      );
      return;
    }

    add(RectangleHitbox());

    // Cyber/Neon styling
    final paint = Paint()
      ..color = const Color(0xFF14D9FF).withValues(alpha: 0.8)
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
    if (!game.isPlaying) return;

    final movementDt = min(dt, GameplayTuning.maxPhysicsStep);
    position.x -= speed * movementDt;

    // Scoring logic
    if (isTop && !passed && position.x + size.x < game.bird.position.x) {
      passed = true;
      game.increaseScore();
    }

    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }
}
