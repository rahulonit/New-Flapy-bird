/// Central gameplay tuning values. Ratios are based on the live game viewport,
/// so controls feel consistent across phones and resolutions.
abstract final class GameplayTuning {
  static const double gravityPerScreenHeight = 0.82;
  static const double flapVelocityPerScreenHeight = 0.39;
  static const double maxFallVelocityPerScreenHeight = 0.68;
  // Allow gameplay to remain time-correct down to 20 FPS. The previous 30 FPS
  // cap discarded elapsed time on slower frames and made long runs feel sticky.
  static const double maxPhysicsStep = 1 / 20;

  static const double birdStartX = 0.28;
  static const double birdStartY = 0.50;
  static const double birdHitboxRadius = 22;
  static const double rotationResponse = 10;
  static const double riseAngle = -0.38;
  static const double fallAngle = 0.72;

  static const double obstacleGapHeight = 0.34;
  static const double obstacleWidth = 0.10;
  static const double obstacleMinimumHeight = 0.08;
  static const double obstacleSpeedPerScreenWidth = 0.14;
  static const double obstacleMinSpeed = 280;
  static const double obstacleMaxSpeed = 380;
  static const double obstacleSpawnInterval = 2.05;
}
