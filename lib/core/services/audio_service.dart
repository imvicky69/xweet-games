import 'package:flutter/services.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  bool soundEnabled = true;
  bool hapticsEnabled = true;

  void triggerHaptic() {
    if (!hapticsEnabled) return;
    HapticFeedback.lightImpact();
  }

  void triggerHeavyHaptic() {
    if (!hapticsEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void triggerSelectionHaptic() {
    if (!hapticsEnabled) return;
    HapticFeedback.selectionClick();
  }

  void playTapSound() {
    if (!soundEnabled) return;
    // SystemSound provides zero-dependency instant native click feedback
    SystemSound.play(SystemSoundType.click);
  }
}
