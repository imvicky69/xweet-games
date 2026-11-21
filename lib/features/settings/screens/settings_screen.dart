import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xweet_games/core/constants/app_constants.dart';
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

  @override
  void initState() {
    super.initState();
    _soundEnabled = StorageService.instance.soundEnabled;
    _hapticsEnabled = StorageService.instance.hapticsEnabled;
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
            'Reset Series Records?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: GameColors.carbon,
            ),
          ),
          content: Text(
            'This will clear all your saved series ratings and round audit history. This action cannot be undone.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: GameColors.terrain,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  color: GameColors.terrain,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.error,
                foregroundColor: Colors.white,
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
        const SnackBar(content: Text('All series scores and audit history reset')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.paper,
      appBar: AppBar(
        title: Text(
          'SETTINGS & TELEMETRY',
          style: GoogleFonts.spaceMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: GameColors.carbon,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Logo and App Branding Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GameColors.surfaceWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: GameColors.borderMuted),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/xweet_logo.png',
                  height: 52,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xweet Games',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: GameColors.carbon,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tactile Editorial Light Edition',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: GameColors.terrain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'FEEDBACK & AUDIO',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: GameColors.terrain,
              letterSpacing: 1.2,
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
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                      color: GameColors.carbon,
                    ),
                  ),
                  subtitle: Text(
                    'correct.mp3, boom.mp3, close.mp3 audio triggers',
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, color: GameColors.terrain),
                  ),
                  secondary: const Icon(Icons.volume_up_outlined, color: GameColors.carbon),
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
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                      color: GameColors.carbon,
                    ),
                  ),
                  subtitle: Text(
                    'Tactile vibrations on keypresses and letter reveals',
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, color: GameColors.terrain),
                  ),
                  secondary: const Icon(Icons.vibration_rounded, color: GameColors.carbon),
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

          Text(
            'DATA & AUDIT',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: GameColors.terrain,
              letterSpacing: 1.2,
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
              leading: const Icon(Icons.delete_outline_rounded, color: GameColors.error),
              title: Text(
                'Reset Series History',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                  color: GameColors.error,
                ),
              ),
              subtitle: Text(
                'Erase all recorded series audits and statistics',
                style: GoogleFonts.spaceGrotesk(fontSize: 12, color: GameColors.terrain),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: GameColors.terrain),
              onTap: _resetScores,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'TELEMETRY & BUILD INFO',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: GameColors.terrain,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: GameColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GameColors.borderMuted),
            ),
            child: Column(
              children: [
                _buildInfoRow('App Name', AppConstants.appName),
                const SizedBox(height: 10),
                _buildInfoRow('Global Package ID', AppConstants.packageName),
                const SizedBox(height: 10),
                _buildInfoRow('Design System', 'Tactile Editorial (Light)'),
                const SizedBox(height: 10),
                _buildInfoRow('Platform', 'Android Native'),
                const SizedBox(height: 10),
                _buildInfoRow('Version', AppConstants.appVersion),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: GameColors.terrain,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: GameColors.carbon,
          ),
        ),
      ],
    );
  }
}
