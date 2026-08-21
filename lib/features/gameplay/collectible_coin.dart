import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../core/gameplay_tuning.dart';
import 'flapverse_game.dart';

class CollectibleCoin extends SpriteComponent
    with HasGameReference<FlapverseGame>, CollisionCallbacks {
  CollectibleCoin({required super.position})
    : super(size: Vector2.all(52), anchor: Anchor.center);

  bool _collected = false;

  double get speed => (game.size.x * GameplayTuning.obstacleSpeedPerScreenWidth)
      .clamp(GameplayTuning.obstacleMinSpeed, GameplayTuning.obstacleMaxSpeed);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = Sprite(await game.images.load('Icons/Coin.png'));
    final radius = size.x * 0.34;
    add(
      CircleHitbox(
        radius: radius,
        position: Vector2(size.x / 2 - radius, size.y / 2 - radius),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) return;
    position.x -= speed * min(dt, GameplayTuning.maxPhysicsStep);
    angle += dt * 2.4;
    if (position.x + size.x < 0) removeFromParent();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!_collected && other is PlayerBird) {
      _collected = true;
      game.collectCoin();
      removeFromParent();
    }
  }
}
