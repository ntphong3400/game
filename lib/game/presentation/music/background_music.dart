import 'package:flutter/foundation.dart';
import '../game_routes.dart';
import '../widgets/frontier_routes.dart';
import '../widgets/locality_routes.dart';
import 'music_player.dart';
import 'music_player_factory.dart';

enum MusicRegion {
  realm(['kinh_thanh_background', 'giang_son_background']),
  frontier(['bien_ai_background']),
  locality(['dia_phuong_background']),
  court(['trieu_chinh_background']);

  const MusicRegion(this.tracks);
  final List<String> tracks;

  static MusicRegion? forLocation(GameLocation? location) {
    if (location == null) return null;
    final section = location.backgroundSection;
    if (['home', 'ending', 'ending-summary'].contains(section)) return null;
    if (frontierCountry(section) != null) return frontier;
    if (section == 'locality' || LocalityPlace.fromRoute(section) != null) {
      return locality;
    }
    if (location.section == 'court') return court;
    return realm;
  }
}

/// One player for the entire app. Changing a URL within a region deliberately
/// does not touch the audio source, playback position, or playlist index.
class BackgroundMusicController extends ChangeNotifier {
  BackgroundMusicController({MusicPlayer? player})
    : _player = player ?? createMusicPlayer() {
    _enabled = _player.initiallyEnabled;
    _player.onEnded = _nextTrack;
    _player.onUserActivation = retry;
  }

  final MusicPlayer _player;
  late bool _enabled;
  bool _suspended = false, _playing = false, _pending = false;
  bool _needsInteraction = false, _disposed = false;
  MusicRegion? _region;
  int _trackIndex = 0, _generation = 0;

  bool get supported => _player.supported;
  bool get enabled => _enabled;
  bool get playing => _playing;
  bool get needsInteraction => _needsInteraction;
  MusicRegion? get region => _region;
  String? get currentAsset =>
      _region == null
          ? null
          : 'assets/audio/${_region!.tracks[_trackIndex]}.mp3';

  void selectLocation(GameLocation? location) {
    final next = MusicRegion.forLocation(location);
    if (_disposed || next == _region) return;
    _pause();
    _region = next;
    _trackIndex = 0;
    if (next != null) _loadTrack();
    notifyListeners();
  }

  void _loadTrack() {
    _player.setSource(currentAsset!, loop: _region!.tracks.length == 1);
    retry();
  }

  void _nextTrack() {
    if (_disposed || _region == null || !_enabled || _suspended) return;
    _pause();
    _trackIndex = (_trackIndex + 1) % _region!.tracks.length;
    _loadTrack();
    notifyListeners();
  }

  void setEnabled(bool value) {
    if (_disposed || value == _enabled) return;
    _enabled = value;
    _player.saveEnabled(value);
    if (value) {
      retry();
    } else {
      _pause();
    }
    notifyListeners();
  }

  void setSuspended(bool value) {
    if (_disposed || value == _suspended) return;
    _suspended = value;
    if (value) {
      _pause();
    } else {
      retry();
    }
    notifyListeners();
  }

  void _pause() {
    _generation++;
    _pending = _playing = _needsInteraction = false;
    _player.pause();
  }

  Future<void> retry() async {
    if (_disposed ||
        !supported ||
        !_enabled ||
        _suspended ||
        _region == null ||
        _playing ||
        _pending) {
      return;
    }
    final generation = _generation;
    _pending = true;
    try {
      // Call play synchronously during user activation, before any await.
      await _player.play();
      if (_disposed || generation != _generation) return;
      _playing = true;
      _needsInteraction = false;
    } catch (_) {
      if (_disposed || generation != _generation) return;
      // Autoplay denial and unavailable audio must not interrupt gameplay.
      _playing = false;
      _needsInteraction = true;
    } finally {
      if (!_disposed && generation == _generation) {
        _pending = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _player.dispose();
    super.dispose();
  }
}
