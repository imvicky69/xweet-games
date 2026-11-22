import 'package:flame_forge2d/flame_forge2d.dart';

/// Physics and world dimension constants for TILT.
/// Tuned for the feeling of heavy concrete blocks on a construction crane:
///  - block hangs perfectly level on cable (no rotation from swing)
///  - drops with realistic horizontal momentum only
///  - lands with a solid thud, zero bounce, settles fast
///  - stacked blocks stay put, slight angular drift only from real imbalance
class TiltPhysicsConstants {
  TiltPhysicsConstants._();

  // World Gravity (m/s^2) — heavier gravity = snappier drops, solid feel
  static final Vector2 worldGravity = Vector2(0, 28.0);

  // Block & Foundation Dimensions (in meters)
  // Compact, squarish architectural floor cubes (1.25:1 aspect ratio)
  // Smaller profile prevents clutter while keeping real center-of-mass balance challenge
  static const double blockWidth = 2.5;
  static const double blockHeight = 2.0;

  // Compact architectural plinth matched to block width
  static const double foundationWidth = 2.9;
  static const double foundationHeight = 1.4;

  // Initial Ground / Foundation Anchor Position
  static const double groundY = 8.0;

  // Rigid Body Material Properties
  // High density = feels heavy and settles fast under its own weight
  static const double blockDensity = 4.0;

  // High friction = blocks don't slide on each other (concrete on concrete)
  static const double blockFriction = 0.95;

  // ZERO restitution = no bounce. Like a concrete block hitting concrete.
  static const double blockRestitution = 0.0;

  // High linear damping = kills residual sliding velocity fast
  static const double blockLinearDamping = 3.5;

  // Very high angular damping = blocks don't spin freely, resist rotation
  static const double blockAngularDamping = 8.0;

  // Crane & Pendulum Settings
  // Increased cable length & high vertical drop clearance for genuine lead-time targeting challenge
  static const double cableLength = 5.8; // meters (was 5.2)
  // Slower swing feels more like a heavy load on a construction crane
  static const double baseSwingFrequency = 1.0; // rad/s
  // Modest amplitude — heavy blocks don't swing wildly
  static const double maxSwingAmplitude = 0.52; // radians (~30 deg max)
  // Hangs the pendulum high above the target tower (~5.6m open drop clearance)
  // Requires genuine lead-time prediction and horizontal momentum timing
  static const double dropHeightAboveTarget = 6.6; // meters clearance (was 3.6)

  // Alignment Evaluation Thresholds (horizontal offset from center in meters)
  static const double perfectThreshold = 0.12;
  static const double greatThreshold = 0.40;
  static const double goodThreshold = 0.85;
  static const double tiltThreshold = 1.35;

  // Scoring Values
  static const int scorePerfect = 250;
  static const int scoreGreat = 120;
  static const int scoreGood = 60;
  static const int scoreTilt = 30;

  // Maximum combo multiplier
  static const int maxCombo = 8;

  // Structural Stability Thresholds
  static const double criticalTiltAngleRad = 0.85; // ~48.7 degrees
  static const double warningTiltAngleRad = 0.28;  // ~16.0 degrees

  // Settling Detection — tight thresholds so blocks snap to rest quickly
  // A heavy concrete block should stop moving almost immediately after landing
  static const double settlingVelocityThresholdSq = 0.08;       // (m/s)^2 — very slow
  static const double settlingAngularVelocityThreshold = 0.08;  // rad/s   — nearly stopped
  static const double settlingTimeRequiredSec = 0.18;           // seconds at rest to confirm
  static const double maxDropDurationSec = 3.5;                 // timeout safety

  // Camera Settings
  static const double cameraZoom = 32.0; // pixels per Forge2D meter
  // Vertically centered to capture the high swinging pendulum in upper viewport
  // and the top of the tower / stacked blocks in the lower viewport
  static const double cameraLeadHeight = 5.4; // meters above top block (was 3.6)

  // On-contact impulse absorption — fraction of lateral velocity kept on first land.
  // Higher value = block slides/drifts more on landing → visible offset stacking.
  // Lower value = block snaps to nearly-still → invisible misalignment.
  // 0.30 means we keep 30% of horizontal momentum so off-center drops LOOK offset.
  static const double landingLateralKill = 0.30;   // keep 30% of sideways speed (was 0.08)
  static const double landingAngularKill = 0.05;   // keep only 5% of spin
}
