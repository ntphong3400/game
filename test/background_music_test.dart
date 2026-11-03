import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/game_routes.dart';
import 'package:van_tue/game/presentation/music/background_music.dart';
import 'package:van_tue/game/presentation/music/music_player.dart';

class FakeMusicPlayer extends MusicPlayer {
  @override
  bool get supported => true;
  @override
  bool initiallyEnabled = true;
  final sources = <String>[];
  bool loop = false, disposed = false;
  int plays = 0, pauses = 0;
  bool? savedEnabled;
  Future<void> Function()? playResult;

  @override
  void setSource(String asset, {required bool loop}) {
    sources.add(asset);
    this.loop = loop;
  }

  @override
  Future<void> play() {
    plays++;
    return playResult?.call() ?? Future.value();
  }

  @override
  void pause() => pauses++;
  @override
  void saveEnabled(bool enabled) => savedEnabled = enabled;
  @override
  void dispose() => disposed = true;
}

GameLocation location(String path) => GameLocation.parse(Uri.parse(path))!;

void main() {
  late FakeMusicPlayer player;
  late BackgroundMusicController music;
  setUp(() {
    player = FakeMusicPlayer();
    music = BackgroundMusicController(player: player);
  });
  tearDown(() => music.dispose());

  test('every public destination inherits the requested regional music', () {
    for (final entry in GameLocation.sectionPaths.entries) {
      final section = entry.key;
      final expected = switch (section) {
        'home' || 'ending' || 'ending-summary' => null,
        'court' => MusicRegion.court,
        'locality' => MusicRegion.locality,
        _ when section.startsWith('local-') => MusicRegion.locality,
        _ when section.startsWith('frontier-') => MusicRegion.frontier,
        _ => MusicRegion.realm,
      };
      expect(
        MusicRegion.forLocation(location(entry.value)),
        expected,
        reason: entry.value,
      );
    }
    expect(MusicRegion.forLocation(null), isNull);
    expect(
      MusicRegion.forLocation(
        location('/people/meet/official?from=/locality/administration'),
      ),
      MusicRegion.locality,
    );
    // Only the court page uses its exclusive track, not character meetings.
    expect(
      MusicRegion.forLocation(location('/people/meet/official?from=/court')),
      MusicRegion.realm,
    );
  });

  test(
    'frontier and locality children never pause or reload their region',
    () async {
      for (final paths in [
        [
          '/frontier/north',
          '/frontier/north/camp',
          '/frontier/north/command',
          '/frontier/west/gate',
          '/frontier/south',
        ],
        [
          '/locality',
          '/locality/administration',
          '/locality/agriculture',
          '/locality/irrigation',
          '/locality/granary',
          '/locality/commerce',
          '/locality/village',
          '/people/meet/official?from=/locality/village',
        ],
      ]) {
        music.selectLocation(location(paths.first));
        await Future<void>.delayed(Duration.zero);
        final loads = player.sources.length,
            pauses = player.pauses,
            plays = player.plays;
        expect(player.loop, isTrue);
        for (final path in paths.skip(1)) {
          music.selectLocation(location(path));
          expect(player.sources.length, loads, reason: path);
          expect(player.pauses, pauses, reason: path);
          expect(player.plays, plays, reason: path);
        }
      }
      expect(player.sources.map((s) => s.split('/').last), [
        'bien_ai_background.mp3',
        'dia_phuong_background.mp3',
      ]);
    },
  );

  test(
    'realm playlist alternates forever and survives capital/child navigation',
    () async {
      music.selectLocation(location('/citadel'));
      await Future<void>.delayed(Duration.zero);
      expect(music.currentAsset, endsWith('kinh_thanh_background.mp3'));
      expect(player.loop, isFalse);
      for (final path in [
        '/capital',
        '/harem',
        '/harem/management',
        '/treasury',
        '/country/north',
        '/country/north/palace',
        '/citadel',
      ]) {
        music.selectLocation(location(path));
      }
      expect(player.sources, hasLength(1));
      player.onEnded!();
      await Future<void>.delayed(Duration.zero);
      expect(music.currentAsset, endsWith('giang_son_background.mp3'));
      music.selectLocation(location('/capital'));
      expect(player.sources, hasLength(2));
      player.onEnded!();
      await Future<void>.delayed(Duration.zero);
      expect(music.currentAsset, endsWith('kinh_thanh_background.mp3'));
      music.selectLocation(location('/court'));
      expect(music.currentAsset, endsWith('trieu_chinh_background.mp3'));
      expect(player.loop, isTrue);
      music.selectLocation(location('/kingdom'));
      expect(music.region, MusicRegion.realm);
    },
  );

  test(
    'mute and lifecycle pause preserve the current track without reload',
    () async {
      music.selectLocation(location('/capital'));
      await Future<void>.delayed(Duration.zero);
      player.onEnded!();
      await Future<void>.delayed(Duration.zero);
      music.setEnabled(false);
      expect(music.playing, isFalse);
      expect(player.savedEnabled, isFalse);
      player.onUserActivation!();
      final plays = player.plays;
      music.selectLocation(location('/harem'));
      expect(player.plays, plays);
      music.setEnabled(true);
      await Future<void>.delayed(Duration.zero);
      expect(player.savedEnabled, isTrue);
      music.setSuspended(true);
      expect(music.playing, isFalse);
      player.onUserActivation!();
      expect(player.plays, plays + 1);
      music.setSuspended(false);
      await Future<void>.delayed(Duration.zero);
      expect(music.playing, isTrue);
      expect(music.currentAsset, endsWith('giang_son_background.mp3'));
      expect(player.sources, hasLength(2));
      music.selectLocation(location('/'));
      expect(music.playing, isFalse);
      expect(music.region, isNull);
    },
  );

  test(
    'autoplay denial retries on user action and ignores stale play results',
    () async {
      player.playResult = () => Future.error(StateError('autoplay denied'));
      music.selectLocation(location('/locality'));
      await Future<void>.delayed(Duration.zero);
      expect(music.needsInteraction, isTrue);
      player.playResult = () => Future.value();
      player.onUserActivation!();
      await Future<void>.delayed(Duration.zero);
      expect(music.playing, isTrue);
      expect(player.sources, hasLength(1));

      final pending = Completer<void>();
      player.playResult = () => pending.future;
      music.selectLocation(location('/court'));
      music.setEnabled(false);
      pending.complete();
      await Future<void>.delayed(Duration.zero);
      expect(music.playing, isFalse);
      expect(music.needsInteraction, isFalse);
    },
  );

  for (final width in [390.0, 1440.0]) {
    testWidgets('router, back navigation and music control at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final gateway = LocalGameGateway(MemoryGameStore());
      await gateway.start(
        name: 'An',
        runId: 'music',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      final game = GameController(gateway);
      await game.load();
      addTearDown(game.dispose);
      await tester.pumpWidget(
        GameApp(
          controller: game,
          initialRoute: 'citadel',
          musicController: music,
        ),
      );
      await tester.pumpAndSettle();
      final router = GoRouter.of(tester.element(find.byType(GameShell)));
      final toggle = find.byKey(const ValueKey('background-music-toggle'));
      expect(toggle, findsOneWidget);
      final sources = player.sources.length;
      router.go('/capital');
      await tester.pumpAndSettle();
      expect(player.sources.length, sources);
      await tester.tap(find.byKey(const ValueKey('section-back')));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/citadel');
      expect(player.sources.length, sources);
      router.go('/locality/agriculture');
      await tester.pumpAndSettle();
      expect(music.region, MusicRegion.locality);
      final localitySources = player.sources.length;
      await tester.tap(find.byKey(const ValueKey('section-back')));
      await tester.pumpAndSettle();
      expect(player.sources.length, localitySources);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(music.enabled, isFalse);
      expect(find.byTooltip('Bật nhạc nền'), findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(music.enabled, isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
