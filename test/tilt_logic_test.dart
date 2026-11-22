import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xweet_games/core/services/storage_service.dart';
import 'package:xweet_games/features/tilt/logic/tilt_game_controller.dart';
import 'package:xweet_games/features/tilt/logic/tilt_physics_constants.dart';
import 'package:xweet_games/features/tilt/models/tilt_block_style.dart';
import 'package:xweet_games/features/tilt/models/tilt_game_state.dart';
import 'package:xweet_games/features/tilt/models/tilt_score_event.dart';
import 'package:xweet_games/features/tilt/flame/components/crane_cable_component.dart';
import 'package:flame/components.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  group('TiltGameController Logic', () {
    test('initial state and start new game', () {
      final controller = TiltGameController();
      expect(controller.status, TiltStatus.ready);
      expect(controller.score, 0);
      expect(controller.floors, 0);
      expect(controller.combo, 1);
      expect(controller.perfectDrops, 0);

      controller.startNewGame();
      expect(controller.status, TiltStatus.swinging);
      expect(controller.currentHeightMeters, 0.0);
    });

    test('evaluateLanding ratings and combo scaling', () {
      final controller = TiltGameController();
      controller.startNewGame();

      // 1. Exact Center Drop (offset 0.04m) -> PERFECT
      final event1 = controller.evaluateLanding(0.04);
      expect(event1.accuracy, LandingAccuracy.perfect);
      expect(event1.isPerfect, true);
      expect(event1.pointsAwarded, TiltPhysicsConstants.scorePerfect * 2); // combo increased to 2
      expect(controller.combo, 2);
      expect(controller.floors, 1);
      expect(controller.perfectDrops, 1);
      expect(controller.currentHeightMeters, 3.2);

      // 2. Second Perfect Drop -> combo 3
      final event2 = controller.evaluateLanding(0.08);
      expect(event2.accuracy, LandingAccuracy.perfect);
      expect(event2.pointsAwarded, TiltPhysicsConstants.scorePerfect * 3);
      expect(controller.combo, 3);
      expect(controller.perfectDrops, 2);

      // 3. Great Drop (offset 0.25m) -> GREAT (maintains current combo without resetting)
      final event3 = controller.evaluateLanding(0.25);
      expect(event3.accuracy, LandingAccuracy.great);
      expect(event3.pointsAwarded, TiltPhysicsConstants.scoreGreat);
      expect(controller.floors, 3);

      // 4. Good Drop (offset 0.65m) -> resets combo to 1
      final event4 = controller.evaluateLanding(0.65);
      expect(event4.accuracy, LandingAccuracy.good);
      expect(event4.pointsAwarded, TiltPhysicsConstants.scoreGood);
      expect(controller.combo, 1);

      // 5. Large Tilt Drop (offset 1.10m) -> TILT
      final event5 = controller.evaluateLanding(1.10);
      expect(event5.accuracy, LandingAccuracy.tilt);
      expect(event5.pointsAwarded, TiltPhysicsConstants.scoreTilt);
      expect(controller.combo, 1);

      // 6. Miss Drop (offset 1.80m) -> MISS
      final event6 = controller.evaluateLanding(1.80);
      expect(event6.accuracy, LandingAccuracy.miss);
      expect(event6.pointsAwarded, 0);
    });

    test('tilt angle updating and warning threshold', () {
      final controller = TiltGameController();
      controller.startNewGame();

      controller.updateTiltAngle(0.10); // ~5.7 deg
      expect(controller.isWarningTilt, false);

      controller.updateTiltAngle(0.35); // ~20.0 deg (> 16 deg warning)
      expect(controller.isWarningTilt, true);
      expect(controller.currentTiltDegrees, closeTo(20.05, 0.2));
    });

    test('recordRunFinished updates StorageService records', () async {
      final controller = TiltGameController();
      controller.startNewGame();

      controller.evaluateLanding(0.05); // Perfect
      controller.evaluateLanding(0.05); // Perfect
      expect(controller.score, greaterThan(0));

      await controller.recordRunFinished();
      expect(controller.status, TiltStatus.gameOver);

      expect(StorageService.instance.tiltHighScore, controller.score);
      expect(StorageService.instance.tiltMaxHeight, 2);
      expect(StorageService.instance.tiltGamesPlayed, 1);
      expect(StorageService.instance.tiltPerfectDrops, 2);

      // Reset scores
      await StorageService.instance.resetAllScores();
      expect(StorageService.instance.tiltHighScore, 0);
      expect(StorageService.instance.tiltMaxHeight, 0);
      expect(StorageService.instance.tiltGamesPlayed, 0);
    });

    test('pause and resume transitions', () {
      final controller = TiltGameController();
      controller.startNewGame();
      expect(controller.status, TiltStatus.swinging);

      controller.pauseGame();
      expect(controller.status, TiltStatus.paused);

      controller.resumeGame();
      expect(controller.status, TiltStatus.swinging);
    });
  });

  group('CraneCableComponent Pendulum Kinematics', () {
    test('natural swinging mathematics and momentum generation', () {
      final crane = CraneCableComponent(
        pivotPosition: Vector2(0, 0),
        cableLength: 5.0,
      );

      expect(crane.isHoldingBlock, true);

      // Advance physics time
      crane.update(0.25);
      final blockPos = crane.getBlockPosition();
      expect(blockPos.y, greaterThan(0));

      final releaseData = crane.releaseBlock();
      expect(releaseData, isNotNull);
      expect(crane.isHoldingBlock, false);
      expect(releaseData!.position.y, closeTo(blockPos.y, 0.001));
      expect(releaseData.linearVelocity, isNotNull);

      // Subsequent release while empty returns null
      expect(crane.releaseBlock(), isNull);
    });
  });

  group('TiltBlockStyle Palette & Styles', () {
    test('distinct architectural floor themes and color compliance', () {
      final style1 = TiltBlockStyle.forFloor(1);
      final style2 = TiltBlockStyle.forFloor(2);
      final styleFoundation = TiltBlockStyle.foundation;

      expect(styleFoundation.name, contains('Foundation'));
      expect(style1.name, isNotEmpty);
      expect(style2.name, isNotEmpty);
      expect(style1.accentColor, TiltBlockStyle.mutedForest);
    });
  });
}
