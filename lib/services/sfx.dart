import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Sound { click, chime, ding, stamp }

/// Sound effects. Off by default; the nav has a speaker toggle, and the
/// visitor's choice is remembered.
///
/// The sounds are synthesized by tool/make_sfx.py into assets/sfx/.
class Sfx {
  Sfx._();

  static const _prefsKey = 'sound_on';
  static final enabled = ValueNotifier<bool>(false);
  static final _players = <Sound, AudioPlayer>{};

  /// Restores the saved choice. Safe to skip (e.g. in tests): sound just
  /// stays off.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      enabled.value = prefs.getBool(_prefsKey) ?? false;
    } catch (_) {
      // Storage blocked (private window etc.) — keep the default.
    }
  }

  static Future<void> toggle() async {
    enabled.value = !enabled.value;
    if (enabled.value) play(Sound.click);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, enabled.value);
    } catch (_) {}
  }

  static void play(Sound sound) {
    if (!enabled.value) return;
    final player = _players.putIfAbsent(
      sound,
      () => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
    );
    // Restart from the top if it's still ringing from the last play.
    player
        .stop()
        .then((_) => player.play(AssetSource('sfx/${sound.name}.wav')))
        .catchError((_) {});
  }
}
