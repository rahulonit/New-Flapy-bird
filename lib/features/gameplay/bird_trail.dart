import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/trail_content.dart';
import 'flapverse_game.dart';

class BirdTrail extends Component with HasGameReference<FlapverseGame> {
  BirdTrail({required this.style});

  // Keep the effect deliberately small: blurred particle drawing is expensive
  // on older mobile GPUs and must never compete with gameplay physics.
  static const double _particleLifetime = 0.62;
  static const int _maximumParticles = 20;

  final TrailContent style;
  final List<_TrailParticle> _particles = [];
  final math.Random _random = math.Random();
  double _spawnTimer = 0;

  void reset() {
    _particles.clear();
    _spawnTimer = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final particle in _particles) {
      particle.age += dt;
      particle.position.x += particle.velocity.x * dt;
      particle.position.y += particle.velocity.y * dt;
      particle.velocity.y += particle.gravity * dt;
    }
    _particles.removeWhere((particle) => particle.age >= _particleLifetime);

    if (style.colors.isEmpty || !game.isPlaying || !game.bird.isActive) return;

    final birdIsRising = game.bird.velocity < -game.size.y * 0.12;
    final emissionInterval = birdIsRising ? 0.03 : 0.042;
    _spawnTimer = math.min(_spawnTimer + dt, emissionInterval * 2);
    while (_spawnTimer >= emissionInterval &&
        _particles.length < _maximumParticles) {
      _spawnTimer -= emissionInterval;
      _emitParticle(birdIsRising);
    }

    // Do not build up missed emissions while the list is full. This prevents
    // a burst of allocations after a slow frame or when particles expire.
    if (_particles.length >= _maximumParticles) _spawnTimer = 0;
  }

  void _emitParticle(bool birdIsRising) {
    final motion = _motionForStyle();
    final verticalSpread = birdIsRising ? 28.0 : 20.0;
    _particles.add(
      _TrailParticle(
        position: Vector2(
          game.bird.position.x - game.bird.size.x * 0.46,
          game.bird.position.y + (_random.nextDouble() - 0.5) * verticalSpread,
        ),
        velocity: Vector2(
          -35 - _random.nextDouble() * 55,
          motion.$1 + (_random.nextDouble() - 0.5) * motion.$2,
        ),
        gravity: motion.$3,
        colorIndex: _random.nextInt(style.colors.length),
        radius: 5 + _random.nextDouble() * (birdIsRising ? 11 : 8),
        sparkle: _random.nextDouble() < motion.$4,
      ),
    );
  }

  /// Vertical drift, spread, gravity and sparkle chance per visual style.
  (double, double, double, double) _motionForStyle() => switch (style.id) {
    'fire_burst' => (-24, 55, -18, 0.16),
    'royal_plasma' => (0, 72, 0, 0.28),
    'golden_comet' => (-4, 34, 10, 0.42),
    _ => (0, 22, 0, 0.24),
  };

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_particles.isEmpty || style.colors.isEmpty) return;

    _renderRibbon(canvas);
    _renderParticles(canvas);
  }

  void _renderRibbon(Canvas canvas) {
    for (var index = 1; index < _particles.length; index++) {
      final previous = _particles[index - 1];
      final current = _particles[index];
      final life = _life(current);
      if (life <= 0 || (current.position - previous.position).length > 55) {
        continue;
      }
      final color = style.colors[current.colorIndex];
      final start = Offset(previous.position.x, previous.position.y);
      final end = Offset(current.position.x, current.position.y);

      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = color.withValues(alpha: life * 0.22)
          ..strokeWidth = 24 * life
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = color.withValues(alpha: life * 0.72)
          ..strokeWidth = 7 * life
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _renderParticles(Canvas canvas) {
    for (final particle in _particles) {
      final life = _life(particle);
      if (life <= 0) continue;
      final color = style.colors[particle.colorIndex];
      final center = Offset(particle.position.x, particle.position.y);
      final radius = particle.radius * (0.35 + life * 0.65);

      canvas.drawCircle(
        center,
        radius * 1.9,
        Paint()..color = color.withValues(alpha: life * 0.20),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = color.withValues(alpha: life * 0.9),
      );
      canvas.drawCircle(
        center,
        radius * 0.32,
        Paint()..color = Colors.white.withValues(alpha: life * 0.9),
      );

      if (particle.sparkle && life > 0.35) {
        final sparkleSize = radius * 1.55 * life;
        final sparklePaint = Paint()
          ..color = Colors.white.withValues(alpha: life * 0.82)
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          center.translate(-sparkleSize, 0),
          center.translate(sparkleSize, 0),
          sparklePaint,
        );
        canvas.drawLine(
          center.translate(0, -sparkleSize),
          center.translate(0, sparkleSize),
          sparklePaint,
        );
      }
    }
  }

  double _life(_TrailParticle particle) {
    final normalized = (1 - particle.age / _particleLifetime).clamp(0.0, 1.0);
    return Curves.easeOut.transform(normalized);
  }
}

class _TrailParticle {
  _TrailParticle({
    required this.position,
    required this.velocity,
    required this.gravity,
    required this.colorIndex,
    required this.radius,
    required this.sparkle,
  });

  final Vector2 position;
  final Vector2 velocity;
  final double gravity;
  final int colorIndex;
  final double radius;
  final bool sparkle;
  double age = 0;
}
