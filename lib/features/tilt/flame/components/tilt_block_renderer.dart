import 'package:flutter/material.dart';
import '../../models/tilt_block_style.dart';
import '../../logic/tilt_physics_constants.dart';

/// Unified architectural renderer for TILT building blocks.
/// Used by both [StackedBlockBody] and [CraneCableComponent] for identical,
/// high-fidelity architectural presentation.
class TiltBlockRenderer {
  TiltBlockRenderer._();

  /// Renders a complete, highly-detailed architectural floor module at (0,0).
  ///
  /// [canvas]: Current canvas, already translated and rotated to the block center.
  /// [style]: The architectural style for this floor.
  /// [floorNumber]: The floor level number (1, 2, ...).
  /// [isHeldOnCrane]: True when hanging from the crane, false when placed.
  static void renderFloorBlock({
    required Canvas canvas,
    required TiltBlockStyle style,
    required int floorNumber,
    bool isHeldOnCrane = false,
  }) {
    final w = TiltPhysicsConstants.blockWidth;
    final h = TiltPhysicsConstants.blockHeight;
    final halfW = w / 2;
    final halfH = h / 2;
    final blockRect = Rect.fromCenter(center: Offset.zero, width: w, height: h);

    // -------------------------------------------------------------------------
    // 1. Soft Ambient Occlusion / Drop Shadow (Underneath)
    // -------------------------------------------------------------------------
    if (!isHeldOnCrane) {
      final aoPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.16),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(-halfW + 0.1, halfH, w - 0.2, 0.18));
      canvas.drawRect(Rect.fromLTWH(-halfW + 0.1, halfH, w - 0.2, 0.18), aoPaint);
    }

    // -------------------------------------------------------------------------
    // 2. Base Concrete Facade
    // -------------------------------------------------------------------------
    final basePaint = Paint()
      ..color = style.baseColor
      ..style = PaintingStyle.fill;
    final facadeRRect = RRect.fromRectAndRadius(blockRect, const Radius.circular(0.06));
    canvas.drawRRect(facadeRRect, basePaint);

    // -------------------------------------------------------------------------
    // 3. 3D Architectural Bevels & Depth Shadows
    // -------------------------------------------------------------------------
    // Bottom depth shadow / underside bevel
    final bottomShadowPaint = Paint()
      ..color = style.shadowColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(-halfW, halfH - 0.15, w, 0.15),
      bottomShadowPaint,
    );

    // Right-edge depth extrusion (gives 3D volumetric presence)
    final rightShadowPaint = Paint()
      ..color = style.shadowColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(halfW - 0.12, -halfH, 0.12, h),
      rightShadowPaint,
    );

    // Top sunlit roof slab lip (crisp highlight bevel)
    final topHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.50)
      ..strokeWidth = 0.035
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(-halfW + 0.06, -halfH + 0.02),
      Offset(halfW - 0.12, -halfH + 0.02),
      topHighlightPaint,
    );

    // -------------------------------------------------------------------------
    // 4. Concrete Panel Expansion Joints & Fluting
    // -------------------------------------------------------------------------
    final seamPaint = Paint()
      ..color = style.shadowColor.withValues(alpha: 0.65)
      ..strokeWidth = 0.018
      ..style = PaintingStyle.stroke;

    // Corner structural pilasters / vertical reveals
    canvas.drawLine(Offset(-halfW + 0.24, -halfH + 0.06), Offset(-halfW + 0.24, halfH - 0.16), seamPaint);
    canvas.drawLine(Offset(halfW - 0.24, -halfH + 0.06), Offset(halfW - 0.24, halfH - 0.16), seamPaint);

    // Horizontal slab division groove
    final slabGroovePaint = Paint()
      ..color = TiltBlockStyle.carbon.withValues(alpha: 0.15)
      ..strokeWidth = 0.015
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-halfW + 0.24, halfH - 0.18), Offset(halfW - 0.24, halfH - 0.18), slabGroovePaint);

    // -------------------------------------------------------------------------
    // 5. Architectural Windows & Glazing
    // -------------------------------------------------------------------------
    if (style.windowCount > 0) {
      _renderWindows(
        canvas: canvas,
        style: style,
        halfW: halfW,
        floorNumber: floorNumber,
      );
    }

    // -------------------------------------------------------------------------
    // 6. Balcony & Planter Box (if configured)
    // -------------------------------------------------------------------------
    if (style.hasBalcony) {
      _renderBalcony(canvas: canvas, style: style, halfW: halfW, halfH: halfH);
    }

    // -------------------------------------------------------------------------
    // 7. Roof Parapet & Crane Rigging Lifting Lugs
    // -------------------------------------------------------------------------
    _renderRoofLugs(canvas: canvas, style: style, halfW: halfW, halfH: halfH);

    // -------------------------------------------------------------------------
    // 8. Crisp Architectural Perimeter Outline
    // -------------------------------------------------------------------------
    final outlinePaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..strokeWidth = 0.035
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(facadeRRect, outlinePaint);

    // -------------------------------------------------------------------------
    // 9. Stamped Floor Identifier (Micro-Typography Stamp)
    // -------------------------------------------------------------------------
    _renderFloorStamp(canvas: canvas, floorNumber: floorNumber, halfW: halfW, halfH: halfH);
  }

  /// Renders deeply-recessed architectural windows with realistic framing,
  /// sill shadows, glass reflections, and warm interior illumination.
  static void _renderWindows({
    required Canvas canvas,
    required TiltBlockStyle style,
    required double halfW,
    required int floorNumber,
  }) {
    final count = style.windowCount;
    // Taller windows for squarish architectural floor module
    const windowH = 1.15;
    const windowY = -0.06;

    // Available width between the corner pilasters
    final innerW = TiltPhysicsConstants.blockWidth - 0.60;
    final spacing = innerW / count;
    final windowW = (spacing * 0.74).clamp(0.24, 0.48);
    final startX = -halfW + 0.30 + (spacing / 2);

    for (var i = 0; i < count; i++) {
      final cx = startX + i * spacing;
      final wRect = Rect.fromCenter(
        center: Offset(cx, windowY),
        width: windowW,
        height: windowH,
      );

      // A. Deep Recessed Cavity Shadow (top & left inner shadow)
      final cavityShadow = Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(wRect.left - 0.015, wRect.top - 0.015, wRect.width + 0.03, wRect.height + 0.03),
        cavityShadow,
      );

      // B. Window Glazing / Pane
      final isLit = ((floorNumber * 7 + i * 3) % 4) == 0;
      final glassColor = isLit
          ? const Color(0xFFFFF0D0) // Warm evening interior lamp glow
          : style.windowColor;

      final glassPaint = Paint()
        ..color = glassColor
        ..style = PaintingStyle.fill;
      final glassRRect = RRect.fromRectAndRadius(wRect, const Radius.circular(0.03));
      canvas.drawRRect(glassRRect, glassPaint);

      // C. Glass Specular Diagonal Glare Reflection (//)
      if (!isLit) {
        final glarePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..strokeWidth = 0.028
          ..style = PaintingStyle.stroke;
        canvas.save();
        canvas.clipRRect(glassRRect);
        // Diagonal highlight stripe across window
        canvas.drawLine(
          Offset(wRect.left - 0.15, wRect.bottom),
          Offset(wRect.right, wRect.top - 0.15),
          glarePaint,
        );
        canvas.restore();
      }

      // D. Architectural Window Sill
      final sillPaint = Paint()
        ..color = style.shadowColor
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(wRect.left - 0.03, wRect.bottom - 0.015, wRect.width + 0.06, 0.045),
        sillPaint,
      );

      // E. Window Frame & Mullions
      final framePaint = Paint()
        ..color = style.windowFrameColor.withValues(alpha: 0.85)
        ..strokeWidth = 0.022
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(glassRRect, framePaint);

      // Horizontal transome bar (upper vent)
      final mullionPaint = Paint()
        ..color = style.windowFrameColor.withValues(alpha: 0.60)
        ..strokeWidth = 0.016
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(wRect.left, windowY - 0.24),
        Offset(wRect.right, windowY - 0.24),
        mullionPaint,
      );
      // Lower transome bar
      canvas.drawLine(
        Offset(wRect.left, windowY + 0.28),
        Offset(wRect.right, windowY + 0.28),
        mullionPaint,
      );
      // Center vertical mullion if window is wide
      if (windowW > 0.38) {
        canvas.drawLine(
          Offset(cx, wRect.top),
          Offset(cx, wRect.bottom),
          mullionPaint,
        );
      }
    }
  }

  /// Renders a cantilevered balcony with steel balustrade and green terrace foliage.
  static void _renderBalcony({
    required Canvas canvas,
    required TiltBlockStyle style,
    required double halfW,
    required double halfH,
  }) {
    const balconyW = 1.8;
    const halfBalconyW = balconyW / 2;
    final balconyY = halfH - 0.20;

    // Balcony cantilevered floor slab
    final slabPaint = Paint()
      ..color = style.accentColor.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, balconyY), width: balconyW, height: 0.06),
        const Radius.circular(0.02),
      ),
      slabPaint,
    );

    // Balcony handrail
    final handrailPaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..strokeWidth = 0.022
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(-halfBalconyW, balconyY - 0.28),
      Offset(halfBalconyW, balconyY - 0.28),
      handrailPaint,
    );

    // Vertical balusters / railings
    final balusterPaint = Paint()
      ..color = TiltBlockStyle.carbon.withValues(alpha: 0.65)
      ..strokeWidth = 0.015
      ..style = PaintingStyle.stroke;
    const railCount = 7;
    final railStep = balconyW / (railCount - 1);
    for (var i = 0; i < railCount; i++) {
      final rx = -halfBalconyW + i * railStep;
      canvas.drawLine(
        Offset(rx, balconyY - 0.28),
        Offset(rx, balconyY - 0.03),
        balusterPaint,
      );
    }

    // Mini architectural terrace foliage / green planters on balcony ends
    final planterPaint = Paint()
      ..color = TiltBlockStyle.mutedForest
      ..style = PaintingStyle.fill;
    for (final px in [-halfBalconyW + 0.15, halfBalconyW - 0.15]) {
      canvas.drawCircle(Offset(px, balconyY - 0.16), 0.08, planterPaint);
      canvas.drawCircle(Offset(px + 0.04, balconyY - 0.20), 0.05, planterPaint);
    }
  }

  /// Renders precast steel lifting lugs on the roof where crane slings attach.
  static void _renderRoofLugs({
    required Canvas canvas,
    required TiltBlockStyle style,
    required double halfW,
    required double halfH,
  }) {
    final lugPaint = Paint()
      ..color = TiltBlockStyle.carbon
      ..strokeWidth = 0.030
      ..style = PaintingStyle.stroke;
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const lugOffset = 0.32; // Distance from left/right edges
    for (final lx in [-halfW + lugOffset, halfW - lugOffset]) {
      final lugRect = Rect.fromCenter(
        center: Offset(lx, -halfH + 0.02),
        width: 0.14,
        height: 0.12,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(lugRect, const Radius.circular(0.04)), lugPaint);
      canvas.drawCircle(Offset(lx, -halfH + 0.02), 0.025, holePaint);
    }
  }

  /// Renders a crisp technical architectural floor stamp (e.g. "FL · 04")
  static void _renderFloorStamp({
    required Canvas canvas,
    required int floorNumber,
    required double halfW,
    required double halfH,
  }) {
    if (floorNumber <= 0) return;

    final badgePaint = Paint()
      ..color = TiltBlockStyle.carbon.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final badgeBorder = Paint()
      ..color = TiltBlockStyle.carbon.withValues(alpha: 0.25)
      ..strokeWidth = 0.015
      ..style = PaintingStyle.stroke;

    final badgeRect = Rect.fromCenter(
      center: Offset(-halfW + 0.46, halfH - 0.28),
      width: 0.36,
      height: 0.14,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(0.02)), badgePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(0.02)), badgeBorder);

    // Minimalist technical dots/dashes representing floor level
    final dotPaint = Paint()
      ..color = TiltBlockStyle.carbon.withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-halfW + 0.36, halfH - 0.28), 0.020, dotPaint);
    canvas.drawCircle(Offset(-halfW + 0.46, halfH - 0.28), 0.020, dotPaint);
    canvas.drawCircle(Offset(-halfW + 0.56, halfH - 0.28), 0.020, dotPaint);
  }
}
