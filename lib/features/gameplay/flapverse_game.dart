import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

import 'obstacles.dart';
import '../../core/audio_service.dart';
import '../../core/gameplay_tuning.dart';
import '../../domain/trail_content.dart';
import '../../domain/level_content.dart';
import 'bird_trail.dart';
import 'collectible_coin.dart';

enum GameOverCause { obstacle, outOfBounds }

class FlapverseGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final String backgroundAsset;
  final String gameOverAsset;
  final String playPanelAsset;
  final String gameOverBaseAsset;
  final String birdAsset;
  final String selectedTrailId;
  final bool hasShield;
  final bool hasScoreBooster;
  final int levelNumber;
  final int? targetScore;
  final LevelDifficulty difficulty;

  FlapverseGame({
    required this.backgroundAsset,
    required this.gameOverAsset,
    required this.playPanelAsset,
    required this.gameOverBaseAsset,
    required this.birdAsset,
    required this.selectedTrailId,
    required this.hasShield,
    required this.hasScoreBooster,
    this.levelNumber = 1,
    this.targetScore,
    this.difficulty = const LevelDifficulty(
      speedMultiplier: 1,
      gapMultiplier: 1,
      spawnIntervalMultiplier: 1,
    ),
  });

  late PlayerBird bird;
  late ObstacleManager obstacleManager;
  late BirdTrail birdTrail;
  late ParallaxComponent background;
  bool isPlaying = false;
  bool _isShuttingDown = false;
  bool _scoreBoosterConsumed = false;
  bool _levelCompleted = false;

  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> comboNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> obstaclesPassedNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> collectedCoinsNotifier = ValueNotifier<int>(0);
  late final ValueNotifier<bool> shieldNotifier = ValueNotifier<bool>(
    hasShield,
  );
  late final ValueNotifier<bool> scoreBoosterNotifier = ValueNotifier<bool>(
    hasScoreBooster,
  );

  VoidCallback? onGameOver;
  VoidCallback? onLevelComplete;
  VoidCallback? onShieldUsed;
  VoidCallback? onScoreBoosterUsed;

  @override
  Color backgroundColor() => const Color(0xFF051A3A);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    images.prefix = 'assets/';

    // Decode obstacle variants before flight begins. Loading a new large PNG
    // during an active run causes a visible hitch on mobile GPUs.
    if (backgroundAsset.contains('MysticForest_world_assets')) {
      await images.loadAll([
        for (var variant = 1; variant <= 7; variant++)
          'MysticForest_world_assets/${variant == 1 ? 'up 1' : 'up$variant'}.png',
        for (var variant = 1; variant <= 7; variant++)
          'MysticForest_world_assets/down$variant.png',
      ]);
      if (_isShuttingDown) return;
    }

    final loadedBackground = await loadParallaxComponent(
      [ParallaxImageData(backgroundAsset.replaceFirst('assets/', ''))],
      baseVelocity: Vector2(40, 0),
      velocityMultiplierDelta: Vector2(1.5, 1.0),
      filterQuality: FilterQuality.medium,
    );
    if (_isShuttingDown) return;
    background = _DepthBlurParallaxComponent(
      parallax: loadedBackground.parallax,
    );
    add(background);

    birdTrail = BirdTrail(style: trailById(selectedTrailId));
    add(birdTrail);

    bird = PlayerBird(asset: birdAsset.replaceFirst('assets/', ''));
    add(bird);

    obstacleManager = ObstacleManager();
    add(obstacleManager);

    if (!_isShuttingDown) AudioService.playBgm();
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
    obstaclesPassedNotifier.value = 0;
    collectedCoinsNotifier.value = 0;
    children.whereType<Obstacle>().forEach(
      (obstacle) => obstacle.removeFromParent(),
    );
    children.whereType<CollectibleCoin>().forEach(
      (coin) => coin.removeFromParent(),
    );
    birdTrail.reset();
    shieldNotifier.value = false;
    scoreBoosterNotifier.value = false;
    _scoreBoosterConsumed = false;
    _levelCompleted = false;
    bird.reset();
    obstacleManager.reset();
  }

  void gameOver({required GameOverCause cause}) {
    if (!isPlaying) return;
    isPlaying = false;
    bird.isActive = false;
    AudioService.pauseBgm();
    AudioService.stopAllSfx();
    if (cause == GameOverCause.obstacle) {
      AudioService.playHit();
    } else {
      AudioService.playDie();
    }
    overlays.add('GameOverMenu');
    pauseEngine();
    if (onGameOver != null) onGameOver!();
  }

  void increaseScore() {
    final baseScore = 100 + (comboNotifier.value * 10);
    scoreNotifier.value += scoreBoosterNotifier.value
        ? baseScore * 2
        : baseScore;
    comboNotifier.value += 1;
    obstaclesPassedNotifier.value += 1;
    if (targetScore != null &&
        scoreNotifier.value >= targetScore! &&
        !_levelCompleted) {
      completeLevel();
    }
  }

  void completeLevel() {
    if (!isPlaying || _levelCompleted) return;
    _levelCompleted = true;
    isPlaying = false;
    bird.isActive = false;
    AudioService.pauseBgm();
    AudioService.stopAllSfx();
    overlays.add('LevelCompleteMenu');
    pauseEngine();
    onLevelComplete?.call();
  }

  void collectCoin() {
    if (!isPlaying) return;
    collectedCoinsNotifier.value += 1;
    AudioService.playCoin();
  }

  bool activateShield() {
    if (!isPlaying ||
        overlays.isActive('PauseMenu') ||
        overlays.isActive('GameOverMenu') ||
        overlays.isActive('LevelCompleteMenu') ||
        shieldNotifier.value) {
      return false;
    }
    shieldNotifier.value = true;
    return true;
  }

  bool activateScoreBooster() {
    if (!isPlaying ||
        overlays.isActive('PauseMenu') ||
        overlays.isActive('GameOverMenu') ||
        overlays.isActive('LevelCompleteMenu') ||
        scoreBoosterNotifier.value ||
        _scoreBoosterConsumed) {
      return false;
    }
    scoreBoosterNotifier.value = true;
    _scoreBoosterConsumed = true;
    return true;
  }

  void handleObstacleHit(Obstacle obstacle) {
    if (!isPlaying) return;
    if (shieldNotifier.value) {
      shieldNotifier.value = false;
      onShieldUsed?.call();
      AudioService.playShield();
      final hitX = obstacle.position.x;
      children
          .whereType<Obstacle>()
          .where((candidate) {
            return (candidate.position.x - hitX).abs() < candidate.size.x * 1.5;
          })
          .forEach((candidate) => candidate.removeFromParent());
      bird.flap();
      return;
    }
    gameOver(cause: GameOverCause.obstacle);
  }

  void pauseGameplay() {
    if (_isShuttingDown) return;
    pauseEngine();
    AudioService.pauseBgm();
  }

  void resumeGameplay() {
    if (_isShuttingDown) return;
    resumeEngine();
    AudioService.resumeBgm();
  }

  void shutdown() {
    if (_isShuttingDown) return;
    _isShuttingDown = true;
    isPlaying = false;
    onGameOver = null;
    onLevelComplete = null;
    onShieldUsed = null;
    onScoreBoosterUsed = null;
    pauseEngine();
    overlays.clear();
    AudioService.stopAll();
  }

  @override
  void onRemove() {
    shutdown();
    super.onRemove();
  }
}

/// Keeps the moving world art softly out of focus while every interactive
/// gameplay component added above it remains crisp. The low blur radius gives
/// visible depth without the cost of a strong full-screen blur on mobile.
class _DepthBlurParallaxComponent extends ParallaxComponent<FlapverseGame> {
  _DepthBlurParallaxComponent({required super.parallax})
    : super(priority: -100);

  final Paint _depthPaint = Paint()
    ..imageFilter = ui.ImageFilter.blur(sigmaX: 2.4, sigmaY: 2.4);
  final Paint _atmospherePaint = Paint()
    ..color = const Color(0x16051A3A)
    ..blendMode = BlendMode.srcOver;

  @override
  void render(Canvas canvas) {
    final bounds = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.saveLayer(bounds, _depthPaint);
    super.render(canvas);
    canvas.restore();
    canvas.drawRect(bounds, _atmospherePaint);
  }
}

class PlayerBird extends SpriteAnimationComponent
    with HasGameReference<FlapverseGame>, CollisionCallbacks {
  double velocity = 0.0;
  bool isActive = false;

  double _flightTime = 0;
  double _flapKick = 0;
  double _visualScaleX = 1;
  double _visualScaleY = 1;
  double _visualOffsetY = 0;

  final Paint _shadowPaint = Paint()..color = const Color(0x52000A28);
  final Paint _shieldFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0x3214D9FF);
  final Paint _shieldInnerPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = const Color(0x9914D9FF);
  final Paint _shieldOuterPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.5
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFF7EEDFF);
  final Paint _shieldHighlightPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xDDFFFFFF);

  final String asset;

  PlayerBird({required this.asset})
    : super(size: Vector2(80, 80), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final image = await game.images.load(asset);
    if (image.width > image.height * 1.5) {
      animation = SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 0.065,
          textureSize: Vector2(image.width / 2, image.height.toDouble()),
        ),
      );
    } else {
      animation = SpriteAnimation.spriteList([Sprite(image)], stepTime: 1);
    }

    // Tightened hitbox for fairer physics
    final radius = GameplayTuning.birdHitboxRadius;
    add(
      CircleHitbox(
        radius: radius,
        position: Vector2(size.x / 2 - radius, size.y / 2 - radius),
      ),
    );
    reset();
  }

  void reset() {
    position = Vector2(
      game.size.x * GameplayTuning.birdStartX,
      game.size.y * GameplayTuning.birdStartY,
    );
    velocity = 0;
    isActive = false;
    angle = 0;
    _flightTime = 0;
    _flapKick = 0;
    _visualScaleX = 1;
    _visualScaleY = 1;
    _visualOffsetY = 0;
  }

  void startFlying() {
    isActive = true;
    flap();
  }

  void flap() {
    velocity = -game.size.y * GameplayTuning.flapVelocityPerScreenHeight;
    _flapKick = 1;
    AudioService.playFlap();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final animationDt = math.min(dt, 1 / 20);
    _flightTime += animationDt;
    _flapKick = math.max(0, _flapKick - animationDt * 7.5);

    // A rapid wing beat while climbing, easing into a slower glide while
    // falling. The small inverse X/Y scale gives even static character art a
    // convincing flap without changing its collision shape.
    final riseAmount = velocity < 0
        ? (-velocity /
                  (game.size.y * GameplayTuning.flapVelocityPerScreenHeight))
              .clamp(0.0, 1.0)
        : 0.0;
    final beatSpeed = isActive ? 12.0 + riseAmount * 6.0 : 3.2;
    final wingBeat = math.sin(_flightTime * beatSpeed * math.pi * 2);
    final beatStrength = isActive ? 0.028 + riseAmount * 0.018 : 0.014;
    final kickCurve = math.sin((1 - _flapKick) * math.pi).clamp(0.0, 1.0);
    _visualScaleY = 1 - wingBeat * beatStrength - kickCurve * 0.025;
    _visualScaleX = 1 + wingBeat * beatStrength * 0.36 + kickCurve * 0.014;
    _visualOffsetY = isActive
        ? -kickCurve * 2.5
        : math.sin(_flightTime * math.pi * 2) * 2.5;

    if (isActive) {
      final physicsDt = math.min(dt, GameplayTuning.maxPhysicsStep);
      final gravity = game.size.y * GameplayTuning.gravityPerScreenHeight;
      final maxFallVelocity =
          game.size.y * GameplayTuning.maxFallVelocityPerScreenHeight;
      velocity = math.min(velocity + gravity * physicsDt, maxFallVelocity);

      position.y += velocity * physicsDt;

      final fallProgress = (velocity / maxFallVelocity).clamp(0.0, 1.0);
      final targetAngle = velocity < 0
          ? GameplayTuning.riseAngle
          : GameplayTuning.riseAngle +
                (GameplayTuning.fallAngle - GameplayTuning.riseAngle) *
                    fallProgress;
      final rotationBlend =
          1 - math.exp(-GameplayTuning.rotationResponse * physicsDt);
      angle += (targetAngle - angle) * rotationBlend;

      // Check ceiling and floor bounds
      if (position.y > game.size.y - (size.y / 2) ||
          position.y < (size.y / 2)) {
        game.gameOver(cause: GameOverCause.outOfBounds);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // A cheap contact shadow adds depth without using per-frame blur filters,
    // which can cause jank on older mobile GPUs.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x * 0.48, size.y * 0.78),
        width: size.x * 0.58,
        height: size.y * 0.16,
      ),
      _shadowPaint,
    );
    final shieldActive = game.shieldNotifier.value;
    final shieldCenter = Offset(size.x / 2, size.y / 2);
    final shieldPulse = (math.sin(_flightTime * math.pi * 3) + 1) * 0.5;
    final shieldRadius = size.x * (0.57 + shieldPulse * 0.025);

    if (shieldActive) {
      // Layered translucent circles produce an energy-bubble effect without a
      // blur filter, keeping the effect inexpensive on older mobile GPUs.
      canvas.drawCircle(shieldCenter, shieldRadius, _shieldFillPaint);
      canvas.drawCircle(
        shieldCenter,
        shieldRadius - 5 - shieldPulse * 2,
        _shieldInnerPaint,
      );
    }
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2 + _visualOffsetY);
    canvas.scale(_visualScaleX, _visualScaleY);
    canvas.translate(-size.x / 2, -size.y / 2);
    super.render(canvas);
    canvas.restore();
    if (shieldActive) {
      final ringRect = Rect.fromCircle(
        center: shieldCenter,
        radius: shieldRadius,
      );
      canvas.drawCircle(shieldCenter, shieldRadius, _shieldOuterPaint);
      canvas.drawArc(
        ringRect,
        -2.65 + shieldPulse * 0.12,
        0.92,
        false,
        _shieldHighlightPaint,
      );
      canvas.drawArc(
        ringRect,
        0.35 + shieldPulse * 0.12,
        0.48,
        false,
        _shieldHighlightPaint,
      );
      canvas.drawCircle(
        Offset(
          shieldCenter.dx - shieldRadius * 0.56,
          shieldCenter.dy - shieldRadius * 0.60,
        ),
        3.5 + shieldPulse * 1.5,
        _shieldHighlightPaint..style = PaintingStyle.fill,
      );
      _shieldHighlightPaint.style = PaintingStyle.stroke;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Obstacle) {
      game.handleObstacleHit(other);
    }
  }
}
