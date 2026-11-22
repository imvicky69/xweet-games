import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../../models/tilt_block_style.dart';
import '../../logic/tilt_physics_constants.dart';
import 'tilt_block_renderer.dart';

class ReleasedBlockData {
  final Vector2 position;
  /// Always 0 — the block hangs perfectly level on the cable
  final double angle;
  final Vector2 linearVelocity;
  /// Near-zero — a hanging block does not spin freely
  final double angularVelocity;
  final TiltBlockStyle style;
  final int floorNumber;

  const ReleasedBlockData({
    required this.position,
    required this.angle,
    required this.linearVelocity,
    required this.angularVelocity,
    required this.style,
    required this.floorNumber,
  });
}

/// The swinging crane cable that suspends the pending block.
///
/// Features:
/// - Heavy industrial overhead crane gantry with structural steel lattice truss
/// - Motorized trolley with dual flanged runner wheels and pulsing warning beacon
/// - Twin braided steel suspension cables
/// - Heavy-duty hoist block with signal-lime hazard stripes & drop-forged hook
/// - Dual diagonal spreader sling rigging hooking into the block's roof lugs
/// - Precision laser alignment guide with target reticle
/// - The BLOCK always hangs level (angle = 0) with realistic horizontal-only release momentum
class CraneCableComponent extends Component {
  Vector2 pivotPosition;
  late Vector2 targetPivotPosition;
  double cableLength;
  /// Global time for visual animations (beacon pulse)
  double time = 0.0;
  int currentFloor = 1;
  TiltBlockStyle currentStyle = TiltBlockStyle.forFloor(1);

  bool isHoldingBlock = true;
  double currentAngle = 0.0;
  double currentAngularVelocity = 0.0;

  /// Continuous phase accumulator — advances by freq * dt every frame.
  /// GUARANTEES zero teleportation / zero phase jumping across floor changes.
  double swingPhase = 0.0;
  double currentAmp = TiltPhysicsConstants.maxSwingAmplitude;
  double currentFreq = TiltPhysicsConstants.baseSwingFrequency;

  /// Smooth fade & hoist spawn animation progress (0.0 to 1.0)
  double spawnProgress = 1.0;

  /// Auto-drop timer: how long this block has been swinging without a tap.
  double _autoDropTimer = 0.0;
  /// Auto-drop threshold (seconds). Caller can read this to trigger the drop.
  static const double autoDropAfterSec = 4.8;

  /// Set to true when auto-drop fires this frame; caller consumes it.
  bool autoDropRequested = false;

  CraneCableComponent({
    required this.pivotPosition,
    this.cableLength = TiltPhysicsConstants.cableLength,
  }) {
    targetPivotPosition = pivotPosition.clone();
  }

  /// Resets the crane state completely for a fresh game start.
  void reset(Vector2 initialPivot) {
    currentFloor = 1;
    currentStyle = TiltBlockStyle.forFloor(1);
    pivotPosition = initialPivot.clone();
    targetPivotPosition = initialPivot.clone();
    swingPhase = 0.0;
    time = 0.0;
    currentFreq = TiltPhysicsConstants.baseSwingFrequency;
    currentAmp = TiltPhysicsConstants.maxSwingAmplitude;
    currentAngle = 0.0;
    currentAngularVelocity = 0.0;
    isHoldingBlock = true;
    _autoDropTimer = 0.0;
    autoDropRequested = false;
    spawnProgress = 1.0;
  }

  /// Prepares the next block while the crane is in active motion.
  /// CRUCIAL PHYSICS FIX: swingPhase, currentAngle, and currentAngularVelocity
  /// are strictly preserved so the pendulum continues swinging seamlessly
  /// without ANY interruption, jerk, or snap back to center.
  void prepareNextBlock(int floor, Vector2 newPivot) {
    currentFloor = floor;
    currentStyle = TiltBlockStyle.forFloor(floor);
    targetPivotPosition = newPivot;
    if (floor == 1) {
      pivotPosition = newPivot.clone();
    }
    isHoldingBlock = true;
    _autoDropTimer = 0.0;
    autoDropRequested = false;
    spawnProgress = 0.0; // Trigger smooth fade spawn animation onto the moving hook
  }

  ReleasedBlockData? releaseBlock() {
    if (!isHoldingBlock) return null;
    isHoldingBlock = false;
    _autoDropTimer = 0.0;
    autoDropRequested = false;

    final blockPos = getBlockPosition();

    // Real crane physics: released load keeps only horizontal velocity.
    // vx = L * ω * cos(θ)  — tangential velocity projected onto X axis.
    // No spin — a hanging block doesn't rotate when let go of a cable.
    final vx = cableLength * currentAngularVelocity * math.cos(currentAngle);

    return ReleasedBlockData(
      position: blockPos,
      angle: 0.0,
      linearVelocity: Vector2(vx, 0.0),
      angularVelocity: 0.0,
      style: currentStyle,
      floorNumber: currentFloor,
    );
  }

  /// Bottom-center of the hanging block in world space.
  Vector2 getBlockPosition() {
    final x = pivotPosition.x + cableLength * math.sin(currentAngle);
    final y = pivotPosition.y + cableLength * math.cos(currentAngle);
    return Vector2(x, y);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Continuous time for secondary visual effects
    time += dt;

    // Progressive frequency & amplitude targets based on floor difficulty
    final targetFreq = (TiltPhysicsConstants.baseSwingFrequency + currentFloor * 0.030)
        .clamp(TiltPhysicsConstants.baseSwingFrequency, 1.80);
    final targetAmp = (TiltPhysicsConstants.maxSwingAmplitude + currentFloor * 0.008)
        .clamp(0.35, 0.68);

    // Smoothly blend physics parameters across frames
    currentFreq += (targetFreq - currentFreq) * 2.5 * dt;
    currentAmp += (targetAmp - currentAmp) * 2.0 * dt;

    // CONTINUOUS PHASE ACCUMULATION:
    // d(phase)/dt = currentFreq.
    // Because phase advances smoothly frame-by-frame, the pendulum trajectory
    // is mathematically C^1 continuous: zero teleportation, zero phase jumping!
    swingPhase += currentFreq * dt;

    // Harmonic pendulum with subtle organic cable resonance
    currentAngle = currentAmp * (0.95 * math.sin(swingPhase) + 0.05 * math.sin(1.7 * swingPhase));
    currentAngularVelocity = currentAmp * currentFreq * (0.95 * math.cos(swingPhase) + 0.05 * 1.7 * math.cos(1.7 * swingPhase));

    // Smoothly glide the crane gantry upward with the camera (eliminates snap/teleport jitter)
    pivotPosition.y += (targetPivotPosition.y - pivotPosition.y) * 4.5 * dt;

    // Smooth fade spawn animation for new block
    if (isHoldingBlock && spawnProgress < 1.0) {
      spawnProgress = (spawnProgress + dt * 3.8).clamp(0.0, 1.0);
    }

    // Auto-drop countdown — only ticks while holding
    if (isHoldingBlock) {
      _autoDropTimer += dt;
      if (_autoDropTimer >= autoDropAfterSec) {
        autoDropRequested = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final blockPos = getBlockPosition();
    final halfH = TiltPhysicsConstants.blockHeight / 2;
    final halfW = TiltPhysicsConstants.blockWidth / 2;

    // -------------------------------------------------------------------------
    // 1. Overhead Crane Gantry Truss (Spans across the sky at pivot Y)
    // -------------------------------------------------------------------------
    _renderCraneGantry(canvas);

    // -------------------------------------------------------------------------
    // 2. Motorized Crane Hoist Trolley
    // -------------------------------------------------------------------------
    _renderTrolley(canvas);

    // -------------------------------------------------------------------------
    // 3. Twin Braided Steel Suspension Cables
    // -------------------------------------------------------------------------
    // Calculate hoist block position at the cable tip
    final hoistBlockY = blockPos.y - halfH - 0.55;
    final hoistBlockPos = Offset(blockPos.x, hoistBlockY);

    _renderTwinCables(canvas, hoistBlockPos);

    // -------------------------------------------------------------------------
    // 4. Industrial Hoist Pulley Block & Heavy Safety Hook
    // -------------------------------------------------------------------------
    _renderHoistBlockAndHook(canvas, hoistBlockPos);

    // -------------------------------------------------------------------------
    // 5. Dual Diagonal Spreader Sling Rigging & Hanging Block Preview
    // -------------------------------------------------------------------------
    if (isHoldingBlock) {
      final ease = Curves.easeOut.transform(spawnProgress);

      _renderSlingRigging(canvas, hoistBlockPos, blockPos, halfW, halfH, ease);

      canvas.save();
      canvas.translate(blockPos.x, blockPos.y);

      if (ease < 0.99) {
        final layerPaint = Paint()..color = Colors.white.withValues(alpha: ease);
        canvas.saveLayer(
          Rect.fromCenter(
            center: Offset.zero,
            width: TiltPhysicsConstants.blockWidth + 0.6,
            height: TiltPhysicsConstants.blockHeight + 0.6,
          ),
          layerPaint,
        );
      }

      TiltBlockRenderer.renderFloorBlock(
        canvas: canvas,
        style: currentStyle,
        floorNumber: currentFloor,
        isHeldOnCrane: true,
      );

      if (ease < 0.99) {
        canvas.restore(); // restore saveLayer
      }
      canvas.restore(); // restore translate
    }
  }

  /// Horizontal steel gantry truss across the upper sky
  void _renderCraneGantry(Canvas canvas) {
    const gantryW = 32.0;
    const gantryHalfW = gantryW / 2;
    final gy = pivotPosition.y;
    const gh = 0.46;
    final topY = gy - gh / 2;
    final bottomY = gy + gh / 2;

    // Gantry main beam background
    final beamBg = Paint()
      ..color = const Color(0xFFE2DFD6)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(-gantryHalfW, topY, gantryW, gh), beamBg);

    // Top and bottom heavy steel chord rails
    final chordPaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..strokeWidth = 0.05
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-gantryHalfW, topY), Offset(gantryHalfW, topY), chordPaint);
    canvas.drawLine(Offset(-gantryHalfW, bottomY), Offset(gantryHalfW, bottomY), chordPaint);

    // Warren truss diagonal cross-braces
    final trussPaint = Paint()
      ..color = const Color(0xFF6B7268)
      ..strokeWidth = 0.028
      ..style = PaintingStyle.stroke;

    const step = 0.60;
    var up = true;
    for (var x = -gantryHalfW; x <= gantryHalfW; x += step) {
      if (up) {
        canvas.drawLine(Offset(x, bottomY), Offset(x + step, topY), trussPaint);
      } else {
        canvas.drawLine(Offset(x, topY), Offset(x + step, bottomY), trussPaint);
      }
      up = !up;
    }

    // Trolley runner rail on bottom edge
    final railPaint = Paint()
      ..color = const Color(0xFFD7F36A)
      ..strokeWidth = 0.035
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-gantryHalfW, bottomY + 0.02), Offset(gantryHalfW, bottomY + 0.02), railPaint);
  }

  /// Heavy motorized hoist trolley on gantry
  void _renderTrolley(Canvas canvas) {
    final px = pivotPosition.x;
    final py = pivotPosition.y;

    // 4 Runner Wheels clamped on the rails
    final wheelPaint = Paint()
      ..color = const Color(0xFF383B34)
      ..style = PaintingStyle.fill;
    final wheelBorder = Paint()
      ..color = TiltBlockStyle.carbon
      ..strokeWidth = 0.025
      ..style = PaintingStyle.stroke;

    for (final wx in [-0.55, -0.22, 0.22, 0.55]) {
      final wOffset = Offset(px + wx, py + 0.28);
      canvas.drawCircle(wOffset, 0.07, wheelPaint);
      canvas.drawCircle(wOffset, 0.07, wheelBorder);
    }

    // Trolley Main Chassis Frame
    final chassisRect = Rect.fromCenter(
      center: Offset(px, py + 0.40),
      width: 1.40,
      height: 0.38,
    );
    final chassisPaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(chassisRect, const Radius.circular(0.06)), chassisPaint);

    // High-visibility hazard stripe on the trolley chassis
    final hazardPaint = Paint()
      ..color = const Color(0xFFD7F36A)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 4; i++) {
      final hx = px - 0.48 + i * 0.28;
      final path = Path()
        ..moveTo(hx, py + 0.23)
        ..lineTo(hx + 0.14, py + 0.23)
        ..lineTo(hx + 0.06, py + 0.57)
        ..lineTo(hx - 0.08, py + 0.57)
        ..close();
      canvas.drawPath(path, hazardPaint);
    }

    // Dual cable hoist drums
    final drumPaint = Paint()
      ..color = const Color(0xFF5E645A)
      ..style = PaintingStyle.fill;
    for (final dx in [-0.20, 0.20]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(px + dx, py + 0.42), width: 0.22, height: 0.18),
          const Radius.circular(0.03),
        ),
        drumPaint,
      );
    }

    // Amber / Signal-Lime Pulsing Warning Beacon on top
    final pulse = 0.65 + 0.35 * math.sin(time * 4.5);
    final beaconGlowPaint = Paint()
      ..color = const Color(0xFFD7F36A).withValues(alpha: pulse * 0.45)
      ..style = PaintingStyle.fill;
    final beaconPaint = Paint()
      ..color = const Color(0xFFD7F36A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(px, py + 0.16), 0.12, beaconGlowPaint);
    canvas.drawCircle(Offset(px, py + 0.16), 0.05, beaconPaint);
  }

  /// Twin parallel braided steel suspension cables
  void _renderTwinCables(Canvas canvas, Offset hoistBlockPos) {
    final px = pivotPosition.x;
    final py = pivotPosition.y + 0.58; // Exit bottom of trolley

    const cableSpacing = 0.12;
    final leftTop = Offset(px - cableSpacing / 2, py);
    final rightTop = Offset(px + cableSpacing / 2, py);
    final leftBottom = Offset(hoistBlockPos.dx - cableSpacing / 2, hoistBlockPos.dy);
    final rightBottom = Offset(hoistBlockPos.dx + cableSpacing / 2, hoistBlockPos.dy);

    // Cable Core Shadow
    final cableCore = Paint()
      ..color = TiltBlockStyle.carbon
      ..strokeWidth = 0.038
      ..style = PaintingStyle.stroke;
    canvas.drawLine(leftTop, leftBottom, cableCore);
    canvas.drawLine(rightTop, rightBottom, cableCore);

    // Metallic Highlight Line (gives metallic sheen)
    final cableShine = Paint()
      ..color = const Color(0xFFC8CEC4)
      ..strokeWidth = 0.016
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(leftTop.dx + 0.008, leftTop.dy),
      Offset(leftBottom.dx + 0.008, leftBottom.dy),
      cableShine,
    );
    canvas.drawLine(
      Offset(rightTop.dx + 0.008, rightTop.dy),
      Offset(rightBottom.dx + 0.008, rightBottom.dy),
      cableShine,
    );
  }

  /// Industrial crane hoist pulley block with hazard stripes and heavy forged hook
  void _renderHoistBlockAndHook(Canvas canvas, Offset pos) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    // Hoist Block Case
    const blockW = 0.48;
    const blockH = 0.36;
    final caseRect = Rect.fromCenter(center: Offset.zero, width: blockW, height: blockH);
    final casePaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(caseRect, const Radius.circular(0.05)), casePaint);

    // Signal-lime safety hazard diagonals on the block
    final hazardPaint = Paint()
      ..color = const Color(0xFFD7F36A)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 3; i++) {
      final hx = -0.16 + i * 0.15;
      final path = Path()
        ..moveTo(hx, -blockH / 2)
        ..lineTo(hx + 0.07, -blockH / 2)
        ..lineTo(hx + 0.01, blockH / 2)
        ..lineTo(hx - 0.06, blockH / 2)
        ..close();
      canvas.drawPath(path, hazardPaint);
    }

    // Center pulley sheave wheel & bolt
    final sheavePaint = Paint()
      ..color = const Color(0xFF858C80)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 0.07, sheavePaint);
    final boltPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 0.025, boltPaint);

    // Drop-Forged Steel Crane Hook
    final hookPaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..strokeWidth = 0.055
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final hookPath = Path()
      ..moveTo(0, blockH / 2)
      ..lineTo(0, blockH / 2 + 0.10)
      ..arcToPoint(
        Offset(0.12, blockH / 2 + 0.22),
        radius: const Radius.circular(0.12),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(-0.06, blockH / 2 + 0.28),
        radius: const Radius.circular(0.12),
        clockwise: false,
      )
      ..lineTo(-0.08, blockH / 2 + 0.20);
    canvas.drawPath(hookPath, hookPaint);

    // Hook safety spring latch
    final latchPaint = Paint()
      ..color = const Color(0xFFD7F36A)
      ..strokeWidth = 0.022
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, blockH / 2 + 0.10), Offset(-0.08, blockH / 2 + 0.20), latchPaint);

    canvas.restore();
  }

  /// Two diagonal high-tensile steel sling cables hooking to the floor's roof lugs
  void _renderSlingRigging(
    Canvas canvas,
    Offset hookPos,
    Vector2 blockPos,
    double halfW,
    double halfH,
    double alphaProgress,
  ) {
    const lugOffset = 0.32;
    final hookEye = Offset(hookPos.dx, hookPos.dy + 0.28);
    final targetY = blockPos.y - halfH + 0.02;
    final leftLug = Offset(blockPos.x - halfW + lugOffset, targetY);
    final rightLug = Offset(blockPos.x + halfW - lugOffset, targetY);

    final slingPaint = Paint()
      ..color = TiltBlockStyle.carbon.withValues(alpha: alphaProgress)
      ..strokeWidth = 0.035
      ..style = PaintingStyle.stroke;

    final slingShine = Paint()
      ..color = const Color(0xFFCED4C8).withValues(alpha: alphaProgress)
      ..strokeWidth = 0.015
      ..style = PaintingStyle.stroke;

    // Left diagonal sling
    canvas.drawLine(hookEye, leftLug, slingPaint);
    canvas.drawLine(hookEye, leftLug, slingShine);

    // Right diagonal sling
    canvas.drawLine(hookEye, rightLug, slingPaint);
    canvas.drawLine(hookEye, rightLug, slingShine);

    // D-Shackles at the lugs
    final shacklePaint = Paint()
      ..color = const Color(0xFF344D3B).withValues(alpha: alphaProgress)
      ..strokeWidth = 0.035
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(leftLug, 0.045, shacklePaint);
    canvas.drawCircle(rightLug, 0.045, shacklePaint);
  }
}

