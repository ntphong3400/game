import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'music_player.dart';

MusicPlayer createMusicPlayer() => BrowserMusicPlayer();

class BrowserMusicPlayer extends MusicPlayer {
  BrowserMusicPlayer() {
    _audio
      ..preload = 'none'
      ..volume = .25
      ..setAttribute('data-background-music', '')
      ..style.display = 'none';
    web.document.body?.append(_audio);
    _subscriptions.add(_audio.onEnded.listen((_) => onEnded?.call()));
    _subscriptions.add(
      const web.EventStreamProvider<web.PointerEvent>(
        'pointerup',
      ).forTarget(web.document).listen((_) {
        onUserActivation?.call();
      }),
    );
    _subscriptions.add(
      web.EventStreamProviders.keyDownEvent.forTarget(web.document).listen((
        event,
      ) {
        if (!event.repeat) onUserActivation?.call();
      }),
    );
  }

  static const _preferenceKey = 'van-tue.background-music.enabled';
  final _audio = web.HTMLAudioElement();
  final _subscriptions = <StreamSubscription<web.Event>>[];

  @override
  bool get supported => true;

  @override
  bool get initiallyEnabled {
    try {
      return web.window.localStorage.getItem(_preferenceKey) != 'false';
    } catch (_) {
      return true;
    }
  }

  @override
  void saveEnabled(bool enabled) {
    try {
      web.window.localStorage.setItem(_preferenceKey, '$enabled');
    } catch (_) {
      // Storage may be disabled; playback still works for this visit.
    }
  }

  @override
  void setSource(String asset, {required bool loop}) {
    _audio.pause();
    _audio.loop = loop;
    // Flutter bundles asset keys beneath the deployment's assets/ directory.
    // Resolve against <base> so hosting under a subpath works as well.
    _audio.src =
        Uri.parse(web.document.baseURI).resolve('assets/$asset').toString();
  }

  @override
  Future<void> play() => _audio.play().toDart;

  @override
  void pause() => _audio.pause();

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _audio.pause();
    _audio.removeAttribute('src');
    _audio.load();
    _audio.remove();
    onEnded = onUserActivation = null;
  }
}
