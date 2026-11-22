import 'package:flutter/material.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import '../models/tilt_block_style.dart';

/// Compact, crisp vector illustration of an architectural tower
/// used on the GameCard and Tilt Lobby.
class TiltPreviewWidget extends StatelessWidget {
  final double width;
  final double height;

  const TiltPreviewWidget({
    super.key,
    this.width = double.infinity,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: TiltBlockStyle.ivoryBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.borderMuted),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _TiltPreviewPainter(),
        ),
      ),
    );
  }
}

class _TiltPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bottomY = size.height - 10.0;

    // 0. Overhead Gantry Truss
    final gantryY = 10.0;
    final gantryPaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..strokeWidth = 1.6;
    canvas.drawLine(Offset(0, gantryY), Offset(size.width, gantryY), gantryPaint);
    canvas.drawLine(Offset(0, gantryY + 4), Offset(size.width, gantryY + 4), gantryPaint);

    // Diagonal truss lacing
    final trussPaint = Paint()
      ..color = const Color(0xFF858779).withValues(alpha: 0.5)
      ..strokeWidth = 0.8;
    for (var x = 0.0; x <= size.width; x += 12.0) {
      canvas.drawLine(Offset(x, gantryY + 4), Offset(x + 6, gantryY), trussPaint);
      canvas.drawLine(Offset(x + 6, gantryY), Offset(x + 12, gantryY + 4), trussPaint);
    }

    // 1. Plinth / Foundation (Compact architectural base)
    final plinthW = 70.0;
    final plinthH = 14.0;
    final plinthRect = Rect.fromCenter(
      center: Offset(cx, bottomY - plinthH / 2),
      width: plinthW,
      height: plinthH,
    );
    final plinthPaint = Paint()..color = const Color(0xFFDCD8CF);
    canvas.drawRRect(RRect.fromRectAndRadius(plinthRect, const Radius.circular(3)), plinthPaint);

    // Hazard stripes on plinth corners
    final hazardPaint = Paint()..color = const Color(0xFFD7F36A);
    canvas.drawRect(Rect.fromLTWH(cx - plinthW / 2 + 3, bottomY - plinthH, 8, 3), hazardPaint);
    canvas.drawRect(Rect.fromLTWH(cx + plinthW / 2 - 11, bottomY - plinthH, 8, 3), hazardPaint);

    final plinthBorder = Paint()
      ..color = TiltBlockStyle.carbon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(RRect.fromRectAndRadius(plinthRect, const Radius.circular(3)), plinthBorder);

    // 2. Stacked Floor 1 (Compact squarish architectural block)
    final blockW = 60.0;
    final blockH = 48.0;
    _drawFloorBlock(canvas, cx + 1, bottomY - plinthH - blockH / 2, blockW, blockH, 0.0);

    // 3. Stacked Floor 2 (slightly offset)
    _drawFloorBlock(canvas, cx + 4, bottomY - plinthH - blockH * 1.5 + 1, blockW, blockH, 0.025);

    // 4. Swinging Floor 3 on Crane Rigging
    final swingX = cx - 14.0;
    final swingY = bottomY - plinthH - blockH * 2.3 - 2;
    final hookY = swingY - blockH / 2 - 6;

    // Twin Suspension Cables
    final cablePaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx - 2, gantryY + 4), Offset(swingX - 2, hookY), cablePaint);
    canvas.drawLine(Offset(cx + 2, gantryY + 4), Offset(swingX + 2, hookY), cablePaint);

    // Trolley
    final trolleyPaint = Paint()..color = TiltBlockStyle.carbon;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, gantryY + 4), width: 22, height: 7), const Radius.circular(2)),
      trolleyPaint,
    );
    // Lime beacon
    final beaconPaint = Paint()..color = const Color(0xFFD7F36A);
    canvas.drawCircle(Offset(cx, gantryY + 1), 2.0, beaconPaint);

    // Crane Hoist Block with hook
    final hoistRect = Rect.fromCenter(center: Offset(swingX, hookY), width: 10, height: 6);
    canvas.drawRRect(RRect.fromRectAndRadius(hoistRect, const Radius.circular(1.5)), trolleyPaint);

    // Diagonal Rigging Slings to block roof
    final slingPaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..strokeWidth = 0.9;
    canvas.drawLine(Offset(swingX, hookY + 3), Offset(swingX - blockW / 2 + 8, swingY - blockH / 2), slingPaint);
    canvas.drawLine(Offset(swingX, hookY + 3), Offset(swingX + blockW / 2 - 8, swingY - blockH / 2), slingPaint);

    // Hanging Block
    _drawFloorBlock(canvas, swingX, swingY, blockW, blockH, 0.0);
  }

  void _drawFloorBlock(Canvas canvas, double x, double y, double w, double h, double angle) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final fillPaint = Paint()..color = const Color(0xFFE8E5DD);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), fillPaint);

    // Underside shadow bevel
    final shadowPaint = Paint()..color = const Color(0xFFD4D0C4);
    canvas.drawRect(Rect.fromLTWH(-w / 2, h / 2 - 3, w, 3), shadowPaint);

    // Top highlight
    final topHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(-w / 2 + 2, -h / 2 + 1), Offset(w / 2 - 2, -h / 2 + 1), topHighlight);

    // Windows with recessed frames
    final winCount = 4;
    final winW = 8.5;
    final winH = 26.0;
    final spacing = (w - 16) / winCount;
    final winPaint = Paint()..color = Colors.white;
    final winBorder = Paint()
      ..color = const Color(0xFF858779)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var i = 0; i < winCount; i++) {
      final wx = -w / 2 + 8 + (spacing * i) + winW / 2;
      final wRect = Rect.fromCenter(center: Offset(wx, -0.5), width: winW, height: winH);
      canvas.drawRRect(RRect.fromRectAndRadius(wRect, const Radius.circular(1.5)), winPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(wRect, const Radius.circular(1.5)), winBorder);
    }

    // Outer Border
    final borderPaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), borderPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
