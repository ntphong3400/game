import 'music_player.dart';

MusicPlayer createMusicPlayer() => _SilentMusicPlayer();

class _SilentMusicPlayer extends MusicPlayer {
  @override
  bool get supported => false;
  @override
  bool get initiallyEnabled => false;
  @override
  void setSource(String asset, {required bool loop}) {}
  @override
  Future<void> play() async {}
  @override
  void pause() {}
  @override
  void saveEnabled(bool enabled) {}
  @override
  void dispose() {}
}
