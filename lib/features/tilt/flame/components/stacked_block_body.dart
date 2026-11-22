import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../models/tilt_block_style.dart';
import '../../logic/tilt_physics_constants.dart';
import 'tilt_block_renderer.dart';

/// A stacked architectural building block.
///
/// Physics tuning philosophy:
/// - Spawns with angle = 0 (block was hanging level on the cable)
/// - Zero initial angular velocity (block wasn't spinning)
/// - On first contact, lateral velocity and spin are killed instantly
///   (mass absorption into the structure — heavy concrete doesn't bounce)
/// - Very high damping so it comes to rest in under a second
/// - Zero restitution — no bounce whatsoever
class StackedBlockBody extends BodyComponent {
  final int floorNumber;
  final TiltBlockStyle style;
  final Vector2 initialPosition;
  final double initialAngle;
  final Vector2 initialLinearVelocity;
  final double initialAngularVelocity;

  bool isSettled = false;
  bool hasCollided = false;
  bool _firstContactDone = false;
  double contactTimer = 0.0;
  double lifeTimer = 0.0;

  StackedBlockBody({
    required this.floorNumber,
    required this.style,
    required this.initialPosition,
    required this.initialAngle,
    required this.initialLinearVelocity,
    required this.initialAngularVelocity,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition,
      angle: initialAngle,       // Will be 0 — block was hanging level
      linearVelocity: initialLinearVelocity,
      angularVelocity: initialAngularVelocity, // Will be 0 — no spin
      type: BodyType.dynamic,
      linearDamping: TiltPhysicsConstants.blockLinearDamping,
      angularDamping: TiltPhysicsConstants.blockAngularDamping,
      allowSleep: true,
      userData: this,
    );

    final shape = PolygonShape()
      ..setAsBoxXY(
        TiltPhysicsConstants.blockWidth / 2,
        TiltPhysicsConstants.blockHeight / 2,
      );

    final fixtureDef = FixtureDef(
      shape,
      density: TiltPhysicsConstants.blockDensity,
      friction: TiltPhysicsConstants.blockFriction,
      restitution: TiltPhysicsConstants.blockRestitution, // 0.0 — no bounce
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  /// Called the moment the block first makes contact with the surface below.
  /// Immediately kills most lateral motion and all spin — heavy concrete
  /// doesn't slide or spin when it lands, it just sits.
  void onFirstContact() {
    if (_firstContactDone) return;
    _firstContactDone = true;

    final vel = body.linearVelocity;
    // Kill lateral (X) velocity according to absorption ratio
    // Absorb downward velocity on first contact so block doesn't compress/tunnel into structure
    body.linearVelocity = Vector2(
      vel.x * TiltPhysicsConstants.landingLateralKill,
      0.0,
    );
    // Kill all angular velocity — no spinning after landing
    body.angularVelocity = body.angularVelocity * TiltPhysicsConstants.landingAngularKill;
  }

  /// Locks the block firmly once confirmed settled.
  void stabilize() {
    isSettled = true;
    // Max out damping to prevent any further drift
    body.linearDamping = 20.0;
    body.angularDamping = 20.0;

    // Zero out any residual micro-velocity
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifeTimer += dt;
    if (hasCollided && !isSettled) {
      contactTimer += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    TiltBlockRenderer.renderFloorBlock(
      canvas: canvas,
      style: style,
      floorNumber: floorNumber,
      isHeldOnCrane: false,
    );
  }
}
