import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import '../models/discover_promo.dart';

class DiscoverPromoCard extends StatefulWidget {
  final bool isHorizontal;

  const DiscoverPromoCard({
    super.key,
    this.isHorizontal = false,
  });

  @override
  State<DiscoverPromoCard> createState() => _DiscoverPromoCardState();
}

class _DiscoverPromoCardState extends State<DiscoverPromoCard> {
  List<DiscoverPromo> _promos = DiscoverPromo.defaultPromos;
  int _currentIndex = 0;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    _loadPromos();
    _startTimer();
  }

  void _loadPromos() async {
    final loaded = await DiscoverPromo.loadFromAsset();
    if (mounted && loaded.isNotEmpty) {
      setState(() => _promos = loaded);
    }
  }

  void _startTimer() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (mounted && _promos.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _promos.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  void _nextPromo() {
    AudioService.instance.triggerSelectionHaptic();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _promos.length;
    });
    _startTimer();
  }

  Future<void> _openUrl(String url) async {
    AudioService.instance.triggerSelectionHaptic();
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Graceful fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_promos.isEmpty) return const SizedBox.shrink();
    final promo = _promos[_currentIndex % _promos.length];

    if (widget.isHorizontal) {
      return _buildHorizontalBanner(promo);
    }
    return _buildGridCard(promo);
  }

  Widget _buildGridCard(DiscoverPromo promo) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8F3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: GameColors.borderMuted,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.carbon.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _openUrl(promo.url),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Badge + Rotating index dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: GameColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: GameColors.carbon, width: 0.8),
                      ),
                      child: Text(
                        promo.badge,
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: GameColors.carbon,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    // Tap to cycle next item
                    GestureDetector(
                      onTap: _nextPromo,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: List.generate(_promos.length, (i) {
                          final isActive = i == _currentIndex;
                          return Container(
                            margin: const EdgeInsets.only(left: 3),
                            width: isActive ? 10 : 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isActive ? GameColors.carbon : GameColors.borderMuted,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Title
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    promo.title,
                    key: ValueKey('title_${promo.id}'),
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: GameColors.carbon,
                      letterSpacing: -0.3,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),

                // Description
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    promo.description,
                    key: ValueKey('desc_${promo.id}'),
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: GameColors.terrain,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const Spacer(),

                // CTA Link Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: GameColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GameColors.borderMuted, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          promo.cta,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: GameColors.carbon,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_outward_rounded,
                        size: 13,
                        color: GameColors.carbon,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalBanner(DiscoverPromo promo) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8F3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: GameColors.borderMuted,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.carbon.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _openUrl(promo.url),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: GameColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: GameColors.carbon, width: 0.8),
                            ),
                            child: Text(
                              promo.badge,
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: GameColors.carbon,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            promo.title,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: GameColors.carbon,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo.description,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: GameColors.terrain,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: GameColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GameColors.borderMuted, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        promo.cta,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: GameColors.carbon,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_outward_rounded,
                        size: 13,
                        color: GameColors.carbon,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
