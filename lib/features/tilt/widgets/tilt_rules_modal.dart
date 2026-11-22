import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import '../models/tilt_block_style.dart';

class TiltRulesModal extends StatelessWidget {
  const TiltRulesModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const TiltRulesModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: ListView(
            controller: scrollController,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: GameColors.borderMuted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: GameColors.signalLime,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: GameColors.carbon, width: 1),
                        ),
                        child: Text(
                          'PHYSICS BLUEPRINT',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: GameColors.carbon,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'How to Play TILT.',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: GameColors.carbon,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: GameColors.carbon),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _buildRuleItem(
                number: '01',
                title: 'One-Tap Drop Release',
                description:
                    'A concrete architectural floor swings naturally on a crane cable. Tap anywhere on screen to release the block.',
              ),
              const SizedBox(height: 12),
              _buildRuleItem(
                number: '02',
                title: 'Rigid-Body Physics & Momentum',
                description:
                    'When released, the floor inherits the cable\'s real tangential velocity and angular momentum. Drops at the peak have minimal lateral drift; drops during the swing arc carry speed!',
              ),
              const SizedBox(height: 12),
              _buildRuleItem(
                number: '03',
                title: 'Center of Mass & Wobbling',
                description:
                    'Misaligned drops shift the tower\'s center of gravity. As the tower grows taller, cumulative torque causes natural wobbling. Counterbalance an off-center lean by dropping the next floor to the opposite side!',
              ),
              const SizedBox(height: 12),
              _buildRuleItem(
                number: '04',
                title: 'Perfect Alignment Multipliers',
                description:
                    'Stack within 0.12m of center for a PERFECT rating (+250 pts), combo multipliers (up to 8x), and stabilizing settling absorption.',
              ),
              const SizedBox(height: 12),
              _buildRuleItem(
                number: '05',
                title: 'Structural Collapse Limit',
                description:
                    'If the tower tilts past 48° or a block falls completely off the foundation into the abyss, the expedition ends.',
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('GOT IT // START EXPEDITION'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRuleItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: GameColors.paper,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GameColors.borderMuted),
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: TiltBlockStyle.mutedForest,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: GameColors.carbon,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: GameColors.terrain,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
