import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xweet_games/core/constants/game_colors.dart';
import 'package:xweet_games/core/services/audio_service.dart';
import 'package:xweet_games/core/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _hapticsEnabled;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Xweet Games',
    packageName: 'in.xweet.games',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );

  @override
  void initState() {
    super.initState();
    _soundEnabled = StorageService.instance.soundEnabled;
    _hapticsEnabled = StorageService.instance.hapticsEnabled;
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageInfo = info;
        });
      }
    } catch (_) {
      // Graceful fallback to default version
    }
  }

  Future<void> _launchXweetWebsite() async {
    AudioService.instance.triggerSelectionHaptic();
    final uri = Uri.parse('https://xweet.in');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open xweet.in')),
      );
    }
  }

  Future<void> _resetScores() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GameColors.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: GameColors.error, width: 1.2),
          ),
          title: Text(
            'Reset Game Records?',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: GameColors.carbon,
            ),
          ),
          content: Text(
            'This will clear all your saved series ratings and round audit history. This action cannot be undone.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: GameColors.terrain,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: GameColors.terrain,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reset All'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await StorageService.instance.resetAllScores();
      AudioService.instance.triggerHeavyHaptic();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All game scores and history reset')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final versionDisplay = _packageInfo.version.isNotEmpty
        ? 'v${_packageInfo.version} (${_packageInfo.buildNumber})'
        : 'v1.0.0 (1)';

    return Scaffold(
      backgroundColor: GameColors.paper,
      appBar: AppBar(
        backgroundColor: GameColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: GameColors.carbon),
          onPressed: () {
            AudioService.instance.triggerSelectionHaptic();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: GameColors.carbon,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Branding Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: GameColors.surfaceWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: GameColors.borderMuted),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'xweet_brand_logo',
                  child: Image.asset(
                    'assets/images/xweet_logo.png',
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'XWEET GAMES',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: GameColors.carbon,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        versionDisplay,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: GameColors.terrain,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Feedback & Audio Section Header
          Text(
            'FEEDBACK & AUDIO',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: GameColors.terrain,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: GameColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GameColors.borderMuted),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeTrackColor: GameColors.signalLime,
                  activeThumbColor: GameColors.carbon,
                  title: Text(
                    'Sound Triggers',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      color: GameColors.carbon,
                      fontSize: 15,
                    ),
                  ),
                  secondary: const Icon(Icons.volume_up_outlined, color: GameColors.carbon, size: 22),
                  value: _soundEnabled,
                  onChanged: (val) async {
                    setState(() => _soundEnabled = val);
                    await StorageService.instance.setSoundEnabled(val);
                    AudioService.instance.triggerHaptic();
                  },
                ),
                Divider(height: 1, color: GameColors.borderMuted),
                SwitchListTile(
                  activeTrackColor: GameColors.signalLime,
                  activeThumbColor: GameColors.carbon,
                  title: Text(
                    'Haptic Feedback',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      color: GameColors.carbon,
                      fontSize: 15,
                    ),
                  ),
                  secondary: const Icon(Icons.vibration_rounded, color: GameColors.carbon, size: 22),
                  value: _hapticsEnabled,
                  onChanged: (val) async {
                    setState(() => _hapticsEnabled = val);
                    await StorageService.instance.setHapticsEnabled(val);
                    AudioService.instance.triggerHaptic();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data & Records Section Header
          Text(
            'DATA & RECORDS',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: GameColors.terrain,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: GameColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GameColors.borderMuted),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: const Icon(Icons.delete_outline_rounded, color: GameColors.error, size: 22),
              title: Text(
                'Reset All Records',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: GameColors.error,
                  fontSize: 15,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: GameColors.terrain),
              onTap: _resetScores,
            ),
          ),

          const SizedBox(height: 36),

          // Footer: A XWEET APP • URL Redirection to xweet.in
          Center(
            child: InkWell(
              onTap: _launchXweetWebsite,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: GameColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GameColors.borderMuted),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'a xweet app',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: GameColors.terrain,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: GameColors.terrain,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'xweet.in',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: GameColors.carbon,
                        letterSpacing: 0.2,
                        decoration: TextDecoration.underline,
                        decorationColor: GameColors.carbon,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_outward_rounded,
                      size: 14,
                      color: GameColors.carbon,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Dynamic Version & Build Info
          Center(
            child: Text(
              versionDisplay,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: GameColors.terrain.withValues(alpha: 0.6),
                letterSpacing: 0.4,
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
