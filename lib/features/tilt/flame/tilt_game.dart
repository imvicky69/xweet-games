import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../logic/tilt_game_controller.dart';
import '../logic/tilt_physics_constants.dart';
import '../models/tilt_block_style.dart';
import '../models/tilt_game_state.dart';
import 'components/crane_cable_component.dart';
import 'components/foundation_body.dart';
import 'components/particle_effects.dart';
import 'components/stacked_block_body.dart';
import 'components/tilt_background_component.dart';

/// Flame + Forge2D physics game implementation for TILT.
/// Coordinates rigid-body stacking, natural pendulum swing, camera tracking,
/// collapse monitoring, and responsive one-tap mechanics.
class TiltGame extends Forge2DGame with TapCallbacks {
  final TiltGameController controller;

  late TiltBackgroundComponent background;
  late FoundationBody foundation;
  late CraneCableComponent crane;
  late ParticleEffectsComponent particles;

  final List<StackedBlockBody> stackedBlocks = [];
  StackedBlockBody? activeDroppingBlock;

  double cameraTargetY = 4.0;
  double cameraCurrentY = 4.0;
  double shakeTrauma = 0.0;
  final math.Random _rng = math.Random();

  bool _isGameOverTriggered = false;

  // Continuous block reload timer: spawns the next block directly onto the
  // moving cable while the current block is dropping.
  double? _reloadTimer;
  int _nextPendingFloor = 1;
  Vector2? _nextPendingPivot;

  TiltGame({required this.controller})
      : super(
          gravity: TiltPhysicsConstants.worldGravity,
          zoom: TiltPhysicsConstants.cameraZoom,
        );

  @override
  Color backgroundColor() => TiltBlockStyle.ivoryBg;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initial camera positioning
    cameraCurrentY = TiltPhysicsConstants.groundY -
        TiltPhysicsConstants.foundationHeight / 2 -
        TiltPhysicsConstants.cameraLeadHeight;
    cameraTargetY = cameraCurrentY;
    camera.viewfinder.position = Vector2(0, cameraCurrentY);

    // 0. Atmospheric Background & Parallax Skyline (Priority -100)
    background = TiltBackgroundComponent();
    world.add(background);

    // 1. Solid Foundation Plinth
    foundation = FoundationBody(yPosition: TiltPhysicsConstants.groundY);
    world.add(foundation);

    // 2. Dust & Impact Particle Effects
    particles = ParticleEffectsComponent();
    world.add(particles);

    // 3. Hanging Crane Cable
    final initialPivotY = TiltPhysicsConstants.groundY -
        TiltPhysicsConstants.foundationHeight / 2 -
        TiltPhysicsConstants.cableLength -
        TiltPhysicsConstants.dropHeightAboveTarget;

    crane = CraneCableComponent(
      pivotPosition: Vector2(0, initialPivotY),
      cableLength: TiltPhysicsConstants.cableLength,
    );
    world.add(crane);

    // Start swinging floor 1
    crane.prepareNextBlock(1, Vector2(0, initialPivotY));
    controller.startNewGame();
  }

  /// Restarts the game world
  void restartGame() {
    _isGameOverTriggered = false;
    _reloadTimer = null;
    _nextPendingPivot = null;

    // Completely purge ALL StackedBlockBody components currently in the world
    final allBlocks = world.children.whereType<StackedBlockBody>().toList();
    for (final block in allBlocks) {
      if (block.isMounted) {
        world.remove(block);
      }
    }
    stackedBlocks.clear();
    activeDroppingBlock = null;

    // Reset camera
    cameraCurrentY = TiltPhysicsConstants.groundY -
        TiltPhysicsConstants.foundationHeight / 2 -
        TiltPhysicsConstants.cameraLeadHeight;
    cameraTargetY = cameraCurrentY;
    camera.viewfinder.position = Vector2(0, cameraCurrentY);
    shakeTrauma = 0.0;

    // Reset crane cleanly to initial state
    final initialPivotY = TiltPhysicsConstants.groundY -
        TiltPhysicsConstants.foundationHeight / 2 -
        TiltPhysicsConstants.cableLength -
        TiltPhysicsConstants.dropHeightAboveTarget;
    crane.reset(Vector2(0, initialPivotY));

    controller.startNewGame();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!controller.status.isInteractive || _isGameOverTriggered) return;
    if (!crane.isHoldingBlock || crane.spawnProgress < 0.6) return;
    _doRelease();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (controller.status == TiltStatus.paused) return;

    _updateCamera(dt);
    _checkAutoDropRequest();
    _checkActiveDroppingBlock(dt);
    _checkReloadTimer(dt);
    _monitorTowerStability();
  }

  void _checkReloadTimer(double dt) {
    if (_reloadTimer != null) {
      _reloadTimer = _reloadTimer! - dt;
      if (_reloadTimer! <= 0) {
        _reloadTimer = null;
        if (!_isGameOverTriggered && _nextPendingPivot != null) {
          crane.prepareNextBlock(_nextPendingFloor, _nextPendingPivot!);
        }
      }
    }
  }

  /// Handles the crane's auto-drop request — fires when the player holds too long.
  void _checkAutoDropRequest() {
    if (!crane.autoDropRequested) return;
    if (!controller.status.isInteractive || _isGameOverTriggered) {
      crane.autoDropRequested = false;
      return;
    }
    // Trigger exactly as if the player tapped
    _doRelease();
  }

  void _doRelease() {
    final releaseData = crane.releaseBlock();
    if (releaseData == null) return;

    final dropping = StackedBlockBody(
      floorNumber: releaseData.floorNumber,
      style: releaseData.style,
      initialPosition: releaseData.position,
      initialAngle: releaseData.angle,
      initialLinearVelocity: releaseData.linearVelocity,
      initialAngularVelocity: releaseData.angularVelocity,
    );

    activeDroppingBlock = dropping;
    world.add(dropping);
    controller.setStatus(TiltStatus.falling);

    // CONTINUOUS MOTION PIPELINE:
    // The crane cable keeps swinging without interruption!
    // After a brief 0.35s reload delay (while the current block is dropping),
    // the next floor block smoothly spawns directly onto the moving crane hook.
    final nextFloor = releaseData.floorNumber + 1;
    final currentTopY = stackedBlocks.isEmpty
        ? (TiltPhysicsConstants.groundY - TiltPhysicsConstants.foundationHeight / 2)
        : stackedBlocks.last.body.position.y;
    final estimatedNextTopY = currentTopY - TiltPhysicsConstants.blockHeight;

    final nextPivotY = estimatedNextTopY -
        TiltPhysicsConstants.blockHeight / 2 -
        TiltPhysicsConstants.cableLength -
        TiltPhysicsConstants.dropHeightAboveTarget;

    _reloadTimer = 0.35;
    _nextPendingFloor = nextFloor;
    _nextPendingPivot = Vector2(0, nextPivotY);
  }

  void _updateCamera(double dt) {
    // Determine target top Y for camera tracking
    double topY = TiltPhysicsConstants.groundY - TiltPhysicsConstants.foundationHeight / 2;
    if (stackedBlocks.isNotEmpty) {
      topY = stackedBlocks.last.body.position.y;
    }

    cameraTargetY = topY - TiltPhysicsConstants.cameraLeadHeight;
    cameraCurrentY += (cameraTargetY - cameraCurrentY) * 3.8 * dt;

    // Screen Shake decay
    if (shakeTrauma > 0) {
      shakeTrauma = (shakeTrauma - dt * 2.8).clamp(0.0, 1.0);
    }

    final shakeX = shakeTrauma > 0 ? (_rng.nextDouble() - 0.5) * shakeTrauma * 0.12 : 0.0;
    final shakeY = shakeTrauma > 0 ? (_rng.nextDouble() - 0.5) * shakeTrauma * 0.16 : 0.0;

    camera.viewfinder.position = Vector2(shakeX, cameraCurrentY + shakeY);
  }

  void _checkActiveDroppingBlock(double dt) {
    final dropping = activeDroppingBlock;
    if (dropping == null || !dropping.isMounted) return;

    final dropPos = dropping.body.position;

    // Target surface (either foundation top or top stacked block)
    final double targetTopY;
    final double targetTopX;
    if (stackedBlocks.isEmpty) {
      targetTopY = TiltPhysicsConstants.groundY - TiltPhysicsConstants.foundationHeight / 2;
      targetTopX = 0.0;
    } else {
      targetTopY = stackedBlocks.last.body.position.y - TiltPhysicsConstants.blockHeight / 2;
      targetTopX = stackedBlocks.last.body.position.x;
    }

    // 1. Initial Contact Detection
    // We detect when the block's bottom surface reaches within range of the target surface.
    final distToTargetY = dropPos.y + TiltPhysicsConstants.blockHeight / 2 - targetTopY;
    if (!dropping.hasCollided && distToTargetY >= -0.20 && distToTargetY <= 1.2) {
      final deltaX = dropPos.x - targetTopX;
      final maxAllowedOffset = stackedBlocks.isEmpty
          ? TiltPhysicsConstants.foundationWidth / 2
          : TiltPhysicsConstants.blockWidth;

      if (deltaX.abs() < maxAllowedOffset) {
        dropping.hasCollided = true;

        // Immediately kill lateral velocity and spin on first contact —
        // heavy concrete doesn't bounce or slide, it absorbs into the structure.
        dropping.onFirstContact();

        final event = controller.evaluateLanding(deltaX);

        // Impact shake — subtle architectural thud (eliminates harsh jitter)
        shakeTrauma = event.isPerfect ? 0.16 : 0.08;
        particles.spawnImpact(
          position: Vector2(dropPos.x, targetTopY),
          isPerfect: event.isPerfect,
        );

        controller.setStatus(TiltStatus.settling);
      }
    }

    // 2. Settled Detection — block must be nearly stationary for a brief moment
    if (dropping.hasCollided && !dropping.isSettled) {
      final speedSq = dropping.body.linearVelocity.length2;
      final angSpeed = dropping.body.angularVelocity.abs();
      final blockAngle = dropping.body.angle.abs();

      // If the block landed at a catastrophic angle AND has had time to settle,
      // trigger collapse now — no point accepting a toppled block as "stacked".
      if (blockAngle > TiltPhysicsConstants.criticalTiltAngleRad && dropping.contactTimer > 0.3) {
        _triggerCollapse();
        return;
      }

      final isResting = speedSq < TiltPhysicsConstants.settlingVelocityThresholdSq &&
          angSpeed < TiltPhysicsConstants.settlingAngularVelocityThreshold;

      // Hard timeout — after 1.2s in contact, force-settle regardless of angle or velocity.
      // KEY FIX: previously the timeout also required isUpright, so a tilted block would
      // NEVER settle and the game would freeze permanently. Now we settle unconditionally
      // and let _monitorTowerStability() handle collapse detection on the next frame.
      final hardTimeout = dropping.contactTimer > 1.2;

      // Normal settle: low velocity, low spin, within a reasonable upright range (~37°)
      final isUpright = blockAngle < 0.65;
      final normalSettle = isResting &&
          dropping.contactTimer >= TiltPhysicsConstants.settlingTimeRequiredSec &&
          isUpright;

      if (normalSettle || hardTimeout) {
        // Confirmed stacked — lock it in place
        dropping.stabilize();
        stackedBlocks.add(dropping);
        activeDroppingBlock = null;

        // Refine crane target pivot to exact settled block height
        final actualTopY = dropping.body.position.y;
        final nextFloor = controller.floors + 1;
        final refinedPivotY = actualTopY -
            TiltPhysicsConstants.blockHeight / 2 -
            TiltPhysicsConstants.cableLength -
            TiltPhysicsConstants.dropHeightAboveTarget;

        crane.targetPivotPosition.y = refinedPivotY;

        // Ensure next block is present (in case reload timer was still pending)
        if (!crane.isHoldingBlock) {
          crane.prepareNextBlock(nextFloor, Vector2(0, refinedPivotY));
        }

        controller.setStatus(TiltStatus.swinging);
      }
    }

    // 3. Fall-through / Miss / Stray Drop Detection
    // A: Flew past target landing level without colliding (missed the tower)
    if (!dropping.hasCollided && (dropPos.y - targetTopY) > 2.0) {
      _triggerCollapse();
      return;
    }

    // B: Dropped block tumbled or fell below ground / off foundation
    if (dropPos.y > TiltPhysicsConstants.groundY + 1.5) {
      _triggerCollapse();
      return;
    }

    // C: Drop timeout safety — if after maxDropDurationSec the block hasn't resolved, it's stuck off-tower
    if (dropping.lifeTimer > TiltPhysicsConstants.maxDropDurationSec) {
      _triggerCollapse();
      return;
    }
  }

  void _monitorTowerStability() {
    if (_isGameOverTriggered || stackedBlocks.isEmpty) return;

    double maxTilt = 0.0;
    bool hasFallen = false;

    for (final block in stackedBlocks) {
      final tilt = block.body.angle.abs();
      if (tilt > maxTilt) maxTilt = tilt;

      // Check if block tumbled off foundation
      if (block.body.position.y > TiltPhysicsConstants.groundY + 2.0) {
        hasFallen = true;
      }
    }

    controller.updateTiltAngle(maxTilt);

    // Structural Collapse Check
    if (maxTilt > TiltPhysicsConstants.criticalTiltAngleRad || hasFallen) {
      _triggerCollapse();
    }
  }

  void _triggerCollapse() {
    if (_isGameOverTriggered) return;
    _isGameOverTriggered = true;
    _reloadTimer = null;
    _nextPendingPivot = null;
    shakeTrauma = 0.55; // significant rumble on structural failure
    controller.recordRunFinished();
  }
}
