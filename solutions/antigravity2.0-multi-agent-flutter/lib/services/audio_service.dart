import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static bool enableSound = true;
  static final List<String> playedSounds = [];

  static void playClick() {
    playedSounds.add('click');
    if (!enableSound) return;
    _playSound(
      macSoundPath: '/System/Library/Sounds/Tink.aiff',
      fallbackType: SystemSoundType.click,
    );
  }

  static void playSuccess() {
    playedSounds.add('success');
    if (!enableSound) return;
    _playSound(
      macSoundPath: '/System/Library/Sounds/Glass.aiff',
      fallbackType: SystemSoundType.click,
    );
  }

  static void playFailure() {
    playedSounds.add('failure');
    if (!enableSound) return;
    _playSound(
      macSoundPath: '/System/Library/Sounds/Basso.aiff',
      fallbackType: SystemSoundType.alert,
    );
  }

  static void playCelebration() {
    playedSounds.add('celebration');
    if (!enableSound) return;
    _playSound(
      macSoundPath: '/System/Library/Sounds/Blow.aiff',
      fallbackType: SystemSoundType.click,
    );
  }

  static void _playSound({required String macSoundPath, required SystemSoundType fallbackType}) {
    if (kIsWeb) {
      SystemSound.play(fallbackType);
      return;
    }
    try {
      if (Platform.isMacOS) {
        Process.run('afplay', [macSoundPath]);
      } else {
        SystemSound.play(fallbackType);
      }
    } catch (e) {
      SystemSound.play(fallbackType);
    }
  }
}
