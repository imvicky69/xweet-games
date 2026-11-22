import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../models/tilt_block_style.dart';
import '../../logic/tilt_physics_constants.dart';

/// The solid foundation plinth at the base of the tower.
/// Static rigid body anchored to the ground datum.
class FoundationBody extends BodyComponent {
  final double yPosition;

  FoundationBody({this.yPosition = TiltPhysicsConstants.groundY});

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(0, yPosition),
      type: BodyType.static,
      userData: this,
    );

    final shape = PolygonShape()
      ..setAsBoxXY(
        TiltPhysicsConstants.foundationWidth / 2,
        TiltPhysicsConstants.foundationHeight / 2,
      );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.88,
      restitution: 0.02,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final halfW = TiltPhysicsConstants.foundationWidth / 2;
    final halfH = TiltPhysicsConstants.foundationHeight / 2;
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: TiltPhysicsConstants.foundationWidth,
      height: TiltPhysicsConstants.foundationHeight,
    );

    // 1. Plinth Concrete Base Mass
    final fillPaint = Paint()
      ..color = const Color(0xFFDCD8CF)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(0.08)), fillPaint);

    // 2. Rusticated Masonry Grooves / Precast Segment Blocks
    final groovePaint = Paint()
      ..color = const Color(0xFFC4BFB2)
      ..strokeWidth = 0.025
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -halfH + 0.1), Offset(0, halfH - 0.2), groovePaint);
    canvas.drawLine(Offset(-halfW + 0.1, 0), Offset(halfW - 0.1, 0), groovePaint);

    // 3. Bottom & Right depth shadows
    final shadowPaint = Paint()
      ..color = const Color(0xFFBFB9AB)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(-halfW, halfH - 0.16, TiltPhysicsConstants.foundationWidth, 0.16),
      shadowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(halfW - 0.14, -halfH, 0.14, TiltPhysicsConstants.foundationHeight),
      shadowPaint,
    );

    // 4. Heavy Steel Bearing Plates (underneath target landing zone)
    final platePaint = Paint()
      ..color = const Color(0xFF344D3B)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(0, -halfH + 0.04), width: TiltPhysicsConstants.blockWidth, height: 0.07),
      platePaint,
    );

    // 5. Safety Hazard Stripes on Top Edges (Left & Right corners)
    final hazardPaint = Paint()
      ..color = const Color(0xFFD7F36A)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 2; i++) {
      // Left corner stripes
      final lx = -halfW + 0.06 + i * 0.12;
      canvas.drawRect(Rect.fromLTWH(lx, -halfH + 0.01, 0.07, 0.05), hazardPaint);
      // Right corner stripes
      final rx = halfW - 0.30 + i * 0.12;
      canvas.drawRect(Rect.fromLTWH(rx, -halfH + 0.01, 0.07, 0.05), hazardPaint);
    }

    // 6. Crisp Carbon Outline
    final outlinePaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..strokeWidth = 0.035
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(0.08)), outlinePaint);

    // 7. Structural Anchor Bolts on the plinth
    final boltPaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..style = PaintingStyle.fill;
    final washerPaint = Paint()
      ..color = const Color(0xFF858779)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.016;

    for (final x in [-halfW + 0.35, halfW - 0.35]) {
      canvas.drawCircle(Offset(x, 0.16), 0.05, boltPaint);
      canvas.drawCircle(Offset(x, 0.16), 0.08, washerPaint);
    }

    // 8. Surveyor Center Bullseye Target Marker
    final centerTargetPaint = Paint()
      ..color = const Color(0xFFD7F36A)
      ..strokeWidth = 0.035
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(0, -halfH), 0.14, centerTargetPaint);
    canvas.drawLine(Offset(-0.25, -halfH), Offset(0.25, -halfH), centerTargetPaint);
    canvas.drawLine(Offset(0, -halfH - 0.25), Offset(0, -halfH + 0.25), centerTargetPaint);
  }
}
