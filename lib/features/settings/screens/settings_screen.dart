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
          backgroundColor: GameColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: GameColors.accentRose),
          ),
          title: Text(
            'Reset High Scores?',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: GameColors.accentRose,
            ),
          ),
          content: const Text(
            'This will clear all your saved game records. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.accentRose,
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
        const SnackBar(content: Text('All high scores have been reset')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'PREFERENCES',
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: GameColors.primaryNeon,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: GameColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GameColors.surfaceBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sound Effects'),
                  subtitle: const Text('In-game sound effects & audio cues'),
                  secondary: const Icon(Icons.volume_up_rounded, color: GameColors.primaryNeon),
                  value: _soundEnabled,
                  onChanged: (val) async {
                    setState(() => _soundEnabled = val);
                    await StorageService.instance.setSoundEnabled(val);
                    AudioService.instance.triggerHaptic();
                  },
                ),
                const Divider(height: 1, color: GameColors.surfaceBorder),
                SwitchListTile(
                  title: const Text('Haptic Feedback'),
                  subtitle: const Text('Vibrations on taps, hits & achievements'),
                  secondary: const Icon(Icons.vibration_rounded, color: GameColors.secondaryNeon),
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
          const SizedBox(height: 28),
          Text(
            'DATA & STORAGE',
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: GameColors.primaryNeon,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: GameColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GameColors.surfaceBorder),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: GameColors.accentRose),
              title: const Text('Reset All High Scores'),
              subtitle: const Text('Erase all saved scores and records'),
              trailing: const Icon(Icons.chevron_right_rounded, color: GameColors.textMuted),
              onTap: _resetScores,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'ABOUT APP',
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: GameColors.primaryNeon,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GameColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GameColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('App Name', style: TextStyle(color: GameColors.textSecondary)),
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: GameColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Package ID', style: TextStyle(color: GameColors.textSecondary)),
                    Text(
                      AppConstants.packageName,
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        color: GameColors.primaryNeon,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Version', style: TextStyle(color: GameColors.textSecondary)),
                    Text(
                      AppConstants.appVersion,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: GameColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Platform', style: TextStyle(color: GameColors.textSecondary)),
                    Text(
                      'Android Only',
                      style: TextStyle(fontWeight: FontWeight.bold, color: GameColors.accentEmerald),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
