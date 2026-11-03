import 'package:flutter/foundation.dart';

/// Browser playback is kept behind this boundary so routing can be tested
/// without requiring an audio device or browser autoplay permission.
abstract class MusicPlayer {
  bool get supported;
  bool get initiallyEnabled;
  VoidCallback? onEnded;
  VoidCallback? onUserActivation;
  void setSource(String asset, {required bool loop});
  Future<void> play();
  void pause();
  void saveEnabled(bool enabled);
  void dispose();
}
