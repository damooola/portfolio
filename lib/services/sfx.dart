import 'package:flutter/foundation.dart';

enum Sound { click, chime, ding, stamp }

/// Sound effects. Off by default; the nav has a speaker toggle.
class Sfx {
  Sfx._();

  static final enabled = ValueNotifier<bool>(false);

  static void play(Sound sound) {
    if (!enabled.value) return;
  }
}
