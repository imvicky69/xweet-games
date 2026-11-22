import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class _Particle {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double size;
  double life;
  final double maxLife;

  _Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.maxLife,
  }) : life = maxLife;

  bool update(double dt) {
    life -= dt;
    position += velocity * dt;
    velocity.y += 10.0 * dt; // gravity on particles
    return life > 0;
  }
}

class _Shockwave {
  final Vector2 position;
  double radius;
  final double maxRadius;
  double life;
  final double maxLife;
  final Color color;

  _Shockwave({
    required this.position,
    required this.maxRadius,
    required this.maxLife,
    required this.color,
  })  : radius = 0.1,
        life = maxLife;

  bool update(double dt) {
    life -= dt;
    final progress = 1.0 - (life / maxLife).clamp(0.0, 1.0);
    radius = 0.1 + progress * maxRadius;
    return life > 0;
  }
}

/// Lightweight procedural dust & architectural impact particle burst
class ParticleEffectsComponent extends Component {
  final List<_Particle> _particles = [];
  final List<_Shockwave> _shockwaves = [];
  final math.Random _rng = math.Random();

  ParticleEffectsComponent() : super(priority: 50);

  void spawnImpact({
    required Vector2 position,
    required bool isPerfect,
    int count = 16,
  }) {
    final colors = isPerfect
        ? [
            const Color(0xFFD7F36A), // Signal Lime
            const Color(0xFF344D3B), // Forest Green
            const Color(0xFFFFFFFF),
            const Color(0xFFB7A7D9), // Mist
          ]
        : [
            const Color(0xFF858779), // Concrete Dust
            const Color(0xFFDCD8CF),
            const Color(0xFFBFBCB1),
            const Color(0xFF171815),
          ];

    final particleCount = isPerfect ? (count * 1.6).toInt() : count;

    // Spawn lateral dust puffs shooting out along the landing joint
    for (var i = 0; i < particleCount; i++) {
      final isLeft = i % 2 == 0;
      final speed = _rng.nextDouble() * 3.8 + 1.2;
      final vx = (isLeft ? -1.0 : 1.0) * speed * (0.7 + _rng.nextDouble() * 0.6);
      final vy = -(_rng.nextDouble() * 1.8 + 0.3); // shoot slightly upwards

      _particles.add(
        _Particle(
          position: position.clone(),
          velocity: Vector2(vx, vy),
          color: colors[_rng.nextInt(colors.length)],
          size: _rng.nextDouble() * 0.09 + 0.04,
          maxLife: _rng.nextDouble() * 0.38 + 0.22,
        ),
      );
    }

    // Expanding structural shockwave ring
    _shockwaves.add(
      _Shockwave(
        position: position.clone(),
        maxRadius: isPerfect ? 1.8 : 1.1,
        maxLife: isPerfect ? 0.35 : 0.22,
        color: isPerfect ? const Color(0xFFD7F36A) : const Color(0xFF858779),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _particles.removeWhere((p) => !p.update(dt));
    _shockwaves.removeWhere((s) => !s.update(dt));
  }

  @override
  void render(Canvas canvas) {
    // 1. Render expanding shockwave rings
    for (final s in _shockwaves) {
      final alpha = (s.life / s.maxLife).clamp(0.0, 1.0);
      final ringPaint = Paint()
        ..color = s.color.withValues(alpha: alpha * 0.45)
        ..strokeWidth = 0.035
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(s.position.x, s.position.y), s.radius, ringPaint);
    }

    // 2. Render dust particles
    for (final p in _particles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(p.position.x, p.position.y),
          width: p.size,
          height: p.size,
        ),
        paint,
      );
    }
  }
}

