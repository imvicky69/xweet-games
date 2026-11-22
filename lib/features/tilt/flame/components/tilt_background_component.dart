import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../../models/tilt_block_style.dart';
import '../../logic/tilt_physics_constants.dart';
import '../tilt_game.dart';

class _Cloud {
  double x;
  final double y;
  final double width;
  final double height;
  final double speed;
  final double opacity;

  _Cloud({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
    required this.opacity,
  });

  void update(double dt) {
    x += speed * dt;
    if (x > 14.0) {
      x = -14.0;
    }
  }
}

/// Rich, atmospheric architectural backdrop for TILT.
///
/// Features:
/// 1. Subtle altitude-reactive sky atmosphere
/// 2. Parallax distant architectural skyline (spires, towers, cranes)
/// 3. Construction ground horizon & bedrock strata
/// 4. Procedural drifting clouds across altitudes
/// 5. Blueprint elevation scale with technical telemetry markers (+10M, +25M...)
class TiltBackgroundComponent extends Component with HasGameReference<TiltGame> {
  final List<_Cloud> _clouds = [];

  TiltBackgroundComponent() : super(priority: -100) {
    _initClouds();
  }

  void _initClouds() {
    // Distribute architectural clouds across various altitude bands
    final rng = math.Random(42);
    final altitudes = [3.0, -4.0, -14.0, -26.0, -42.0, -60.0, -82.0, -110.0];

    for (final alt in altitudes) {
      final w = rng.nextDouble() * 3.5 + 2.5;
      final h = rng.nextDouble() * 0.8 + 0.6;
      final x = (rng.nextDouble() * 20.0) - 10.0;
      final speed = rng.nextDouble() * 0.25 + 0.15;
      final op = rng.nextDouble() * 0.22 + 0.35;
      _clouds.add(_Cloud(x: x, y: alt, width: w, height: h, speed: speed, opacity: op));

      // Extra secondary puff for richer cloud formations
      _clouds.add(_Cloud(
        x: x + 1.2,
        y: alt - 0.2,
        width: w * 0.65,
        height: h * 0.85,
        speed: speed,
        opacity: op * 0.9,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final cloud in _clouds) {
      cloud.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    final cameraY = game.cameraCurrentY;
    final topY = cameraY - 18.0;
    final bottomY = cameraY + 18.0;
    const viewHalfW = 8.0;

    // -------------------------------------------------------------------------
    // 1. Sky Atmosphere (Subtle architectural gradient shift)
    // -------------------------------------------------------------------------
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _getSkyColorForAltitude(topY),
          _getSkyColorForAltitude(bottomY),
        ],
      ).createShader(Rect.fromLTRB(-viewHalfW, topY, viewHalfW, bottomY));
    canvas.drawRect(Rect.fromLTRB(-viewHalfW, topY, viewHalfW, bottomY), skyPaint);

    // -------------------------------------------------------------------------
    // 2. Parallax Distant City Skyline
    // -------------------------------------------------------------------------
    _renderParallaxCity(canvas, cameraY);

    // -------------------------------------------------------------------------
    // 3. Ground Level & Bedrock Strata (when in view near base)
    // -------------------------------------------------------------------------
    _renderGroundStrata(canvas, topY, bottomY);

    // -------------------------------------------------------------------------
    // 4. Drifting Minimalist Clouds
    // -------------------------------------------------------------------------
    _renderClouds(canvas, topY, bottomY);

    // -------------------------------------------------------------------------
    // 5. Architectural Altitude & Blueprint Telemetry Ruler
    // -------------------------------------------------------------------------
    _renderAltitudeRuler(canvas, topY, bottomY);
  }

  Color _getSkyColorForAltitude(double y) {
    // ground is at y = 8.0; altitude = 8.0 - y meters
    final alt = 8.0 - y;
    if (alt <= 0) return const Color(0xFFF5F3ED); // Warm Ivory
    if (alt < 30) {
      // Warm ivory to serene architectural morning tone
      final t = (alt / 30.0).clamp(0.0, 1.0);
      return Color.lerp(const Color(0xFFF5F3ED), const Color(0xFFEBEAE2), t)!;
    }
    if (alt < 80) {
      // Clear architectural troposphere
      final t = ((alt - 30) / 50.0).clamp(0.0, 1.0);
      return Color.lerp(const Color(0xFFEBEAE2), const Color(0xFFE4E7DF), t)!;
    }
    // Stratosphere serene tint
    return const Color(0xFFDCE2DC);
  }

  /// Draws 2 layers of parallax architectural silhouettes that sink gently as the camera ascends
  void _renderParallaxCity(Canvas canvas, double cameraY) {
    final groundY = TiltPhysicsConstants.groundY;

    // --- Far Skyline (Parallax factor 0.20) ---
    final farOffset = (cameraY - 5.0) * 0.20;
    final farBaseY = groundY + 0.5 + farOffset;

    final farPaint = Paint()
      ..color = const Color(0xFFE2DED4).withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;

    // Distant skyscraper silhouettes (left & right sides of screen)
    final farBuildings = [
      // Left cluster
      const Rect.fromLTWH(-7.5, -9.0, 2.2, 10.0),
      const Rect.fromLTWH(-5.6, -14.0, 1.8, 15.0),
      const Rect.fromLTWH(-4.0, -7.0, 1.5, 8.0),
      // Right cluster
      const Rect.fromLTWH(2.6, -8.0, 1.6, 9.0),
      const Rect.fromLTWH(4.0, -16.0, 2.0, 17.0),
      const Rect.fromLTWH(5.8, -11.0, 2.2, 12.0),
    ];

    canvas.save();
    canvas.translate(0, farBaseY);
    for (final b in farBuildings) {
      canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(0.05)), farPaint);
    }
    // Spires & masts
    final farMastPaint = Paint()
      ..color = const Color(0xFFD6D1C6).withValues(alpha: 0.85)
      ..strokeWidth = 0.04
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-4.7, -14.0), const Offset(-4.7, -16.8), farMastPaint);
    canvas.drawLine(const Offset(5.0, -16.0), const Offset(5.0, -19.2), farMastPaint);
    canvas.restore();

    // --- Mid Skyline (Parallax factor 0.45) ---
    final midOffset = (cameraY - 5.0) * 0.45;
    final midBaseY = groundY + midOffset;

    final midPaint = Paint()
      ..color = const Color(0xFFD5D0C3).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final midBuildings = [
      // Left mid buildings
      const Rect.fromLTWH(-7.2, -5.5, 1.9, 6.0),
      const Rect.fromLTWH(-5.5, -9.5, 1.6, 10.0),
      const Rect.fromLTWH(-4.1, -4.2, 1.3, 5.0),
      // Right mid buildings
      const Rect.fromLTWH(2.9, -6.0, 1.5, 6.5),
      const Rect.fromLTWH(4.2, -10.5, 1.7, 11.0),
      const Rect.fromLTWH(5.7, -7.0, 2.0, 7.5),
    ];

    canvas.save();
    canvas.translate(0, midBaseY);
    for (final b in midBuildings) {
      canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(0.06)), midPaint);
    }
    // Mid communication spire
    final midSpirePaint = Paint()
      ..color = const Color(0xFFC7C1B2)
      ..strokeWidth = 0.05
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-4.7, -9.5), const Offset(-4.7, -11.5), midSpirePaint);
    canvas.drawLine(const Offset(5.0, -10.5), const Offset(5.0, -13.0), midSpirePaint);
    canvas.restore();
  }

  /// Ground strata, bedrock hatching, and street-level greenery
  void _renderGroundStrata(Canvas canvas, double topY, double bottomY) {
    const groundY = TiltPhysicsConstants.groundY;
    if (bottomY < groundY - 2.0) return; // Completely off screen

    // Sub-surface bedrock fill
    final bedrockPaint = Paint()
      ..color = const Color(0xFFECE8DE)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTRB(-15.0, groundY + 0.8, 15.0, groundY + 25.0), bedrockPaint);

    // Bedrock diagonal structural hatch lines
    final hatchPaint = Paint()
      ..color = const Color(0xFFDFDACD).withValues(alpha: 0.50)
      ..strokeWidth = 0.03
      ..style = PaintingStyle.stroke;

    for (var x = -15.0; x <= 15.0; x += 1.2) {
      canvas.drawLine(
        Offset(x, groundY + 1.0),
        Offset(x + 1.5, groundY + 12.0),
        hatchPaint,
      );
    }

    // Street-level park trees / minimalist geometric greenery
    final treePaint = Paint()
      ..color = TiltBlockStyle.mutedForest.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;
    final treeTrunkPaint = Paint()
      ..color = TiltBlockStyle.carbon.withValues(alpha: 0.35)
      ..strokeWidth = 0.03
      ..style = PaintingStyle.stroke;

    for (final tx in [-5.8, -4.5, -3.8, 3.8, 4.6, 6.0]) {
      // Trunk
      canvas.drawLine(Offset(tx, groundY + 0.8), Offset(tx, groundY - 0.3), treeTrunkPaint);
      // Canopy (geometric circle)
      canvas.drawCircle(Offset(tx, groundY - 0.5), 0.32, treePaint);
      canvas.drawCircle(Offset(tx + 0.05, groundY - 0.7), 0.22, treePaint);
    }
  }

  /// Soft, procedural floating clouds drifting through the scene
  void _renderClouds(Canvas canvas, double topY, double bottomY) {
    for (final cloud in _clouds) {
      if (cloud.y < topY - 2.0 || cloud.y > bottomY + 2.0) continue;

      final cloudPaint = Paint()
        ..color = Colors.white.withValues(alpha: cloud.opacity)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cloud.x, cloud.y),
          width: cloud.width,
          height: cloud.height,
        ),
        Radius.circular(cloud.height / 2),
      );
      canvas.drawRRect(rrect, cloudPaint);
    }
  }

  /// Blueprint drafting elevation scale along the left edge
  void _renderAltitudeRuler(Canvas canvas, double topY, double bottomY) {
    const rulerX = -5.5;

    // Vertical drafting datum line
    final datumLinePaint = Paint()
      ..color = const Color(0xFF858779).withValues(alpha: 0.25)
      ..strokeWidth = 0.02
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(rulerX, topY), Offset(rulerX, bottomY), datumLinePaint);

    // Minor and major ticks every 1m and 5m
    final startY = (topY / 1.0).floor() * 1.0;
    final majorTickPaint = Paint()
      ..color = const Color(0xFF858779).withValues(alpha: 0.50)
      ..strokeWidth = 0.03
      ..style = PaintingStyle.stroke;
    final minorTickPaint = Paint()
      ..color = const Color(0xFF858779).withValues(alpha: 0.25)
      ..strokeWidth = 0.015
      ..style = PaintingStyle.stroke;

    final gridLinePaint = Paint()
      ..color = const Color(0xFF858779).withValues(alpha: 0.08)
      ..strokeWidth = 0.015
      ..style = PaintingStyle.stroke;

    for (var y = startY; y <= bottomY; y += 1.0) {
      final isMajor = (y.round() % 5) == 0;
      if (isMajor) {
        // Major 5m tick
        canvas.drawLine(Offset(rulerX - 0.25, y), Offset(rulerX + 0.25, y), majorTickPaint);
        // Faint horizontal floor grid line across the world
        canvas.drawLine(Offset(-12.0, y), Offset(12.0, y), gridLinePaint);

        // Technical crosshair mark at center
        final crosshairPaint = Paint()
          ..color = const Color(0xFF858779).withValues(alpha: 0.18)
          ..strokeWidth = 0.015
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(-0.15, y), Offset(0.15, y), crosshairPaint);
        canvas.drawLine(Offset(0, y - 0.15), Offset(0, y + 0.15), crosshairPaint);
      } else {
        // Minor 1m tick
        canvas.drawLine(Offset(rulerX - 0.10, y), Offset(rulerX + 0.10, y), minorTickPaint);
      }
    }
  }
}
