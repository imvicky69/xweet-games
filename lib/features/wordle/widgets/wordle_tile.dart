import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import '../models/tile_state.dart';

class WordleTile extends StatefulWidget {
  final String letter;
  final TileState state;
  final int index; // 0 to 4 for staggered flip animation
  final bool animateFlip;

  const WordleTile({
    super.key,
    required this.letter,
    required this.state,
    this.index = 0,
    this.animateFlip = false,
  });

  @override
  State<WordleTile> createState() => _WordleTileState();
}

class _WordleTileState extends State<WordleTile> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    if (widget.animateFlip && widget.state != TileState.empty && widget.state != TileState.tbd) {
      Future.delayed(Duration(milliseconds: widget.index * 120), () {
        if (mounted) _flipController.forward();
      });
    } else {
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant WordleTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateFlip && oldWidget.state != widget.state && widget.state != TileState.empty && widget.state != TileState.tbd) {
      _flipController.reset();
      Future.delayed(Duration(milliseconds: widget.index * 120), () {
        if (mounted) _flipController.forward();
      });
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final isPassedHalf = _flipAnimation.value >= 0.5;
        final angle = _flipAnimation.value * pi;

        // Tile colors
        Color bgColor;
        Color textColor;
        Border border;

        final displayState = isPassedHalf || !widget.animateFlip ? widget.state : TileState.tbd;

        switch (displayState) {
          case TileState.correct:
            bgColor = GameColors.signalLime;
            textColor = GameColors.carbon;
            border = Border.all(color: GameColors.carbon, width: 1.2);
            break;
          case TileState.present:
            bgColor = GameColors.mist;
            textColor = GameColors.carbon;
            border = Border.all(color: GameColors.carbon, width: 1.2);
            break;
          case TileState.absent:
            bgColor = GameColors.terrain.withValues(alpha: 0.35);
            textColor = GameColors.carbon.withValues(alpha: 0.8);
            border = Border.all(color: GameColors.borderMuted, width: 1);
            break;
          case TileState.tbd:
            bgColor = GameColors.surfaceWhite;
            textColor = GameColors.carbon;
            border = Border.all(color: GameColors.borderActive, width: 2);
            break;
          case TileState.empty:
            bgColor = GameColors.surfaceWhite.withValues(alpha: 0.8);
            textColor = GameColors.carbon;
            border = Border.all(color: GameColors.borderMuted, width: 1.2);
            break;
        }

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(angle),
          alignment: Alignment.center,
          child: Transform(
            // Flip content back right-side up after crossing 90 degrees
            transform: Matrix4.identity()..rotateX(isPassedHalf ? pi : 0),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: border,
                boxShadow: [
                  BoxShadow(
                    color: GameColors.carbon.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.letter.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
