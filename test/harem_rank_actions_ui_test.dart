import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/meeting_scenes.dart';
import 'package:van_tue/game/presentation/widgets/harem_rank_badge.dart';

Finder action(String id) => find.byKey(ValueKey('meeting-action-$id'));

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    for (final mode in [
      'Tú nữ',
      'Phi tần',
      'Hoàng hậu',
      'study',
      'duty',
      'queen',
      'visit',
    ]) {
      testWidgets('harem badge and direct actions $mode at $size', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (const bool.fromEnvironment('HAREM_RANK_ACTION_PREVIEWS')) {
          for (final (family, path) in [
            ('Lora', 'assets/fonts/Lora.ttf'),
            ('BeVietnam', 'assets/fonts/BeVietnamPro-Regular.ttf'),
            ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
          ]) {
            await (FontLoader(family)..addFont(rootBundle.load(path))).load();
          }
        }
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store);
        await gateway.start(
          name: 'Thiên Hòa',
          runId: 'harem-rank-actions',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        final rank =
            ['Tú nữ', 'Phi tần', 'Hoàng hậu'].contains(mode) ? mode : 'Phi tần';
        await store.update((a) {
          final s = a.active!;
          s.nextCourtPersonnelTurn = 100000;
          final c = s.court.firstWhere((c) => c.id == 'consort_lan');
          c
            ..inHarem = rank != 'Tú nữ'
            ..queen = rank == 'Hoàng hậu'
            ..ability = 70
            ..affection = 75
            ..discontent = 0;
        });
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final initial = controller.state!, before = initial.toJson();
        final person = initial.court.firstWhere((c) => c.id == 'consort_lan');
        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: GameApp(controller: controller, initialRoute: 'harem'),
          ),
        );
        await tester.pumpAndSettle();
        Future<void> tap(Finder f) async {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        final cardBadge = find.byKey(const ValueKey('harem-rank-consort_lan'));
        expect(tester.widget<HaremRankBadge>(cardBadge).rank, rank);
        await tap(find.byKey(const ValueKey('meet-person-consort_lan')));
        final badge = find.byKey(const ValueKey('meeting-harem-rank'));
        expect(tester.widget<HaremRankBadge>(badge).rank, rank);
        expect(find.byKey(const ValueKey('meeting-profile')), findsNothing);
        expect(find.text('Hồ sơ & cung vụ'), findsNothing);
        for (final id in [
          'audience',
          'reward',
          'investigate',
          'invite',
          'expel',
          'demote',
        ]) {
          expect(action(id), findsOneWidget);
        }
        for (final id in ['palace-duty', 'palace-study', 'visit']) {
          expect(action(id), rank == 'Tú nữ' ? findsNothing : findsOneWidget);
        }
        expect(
          action('queen'),
          rank == 'Phi tần' ? findsOneWidget : findsNothing,
        );
        expect(controller.state!.toJson(), before);
        if (['study', 'duty', 'queen', 'visit'].contains(mode)) {
          Future<void> open() async {
            await tap(
              action(
                mode == 'study'
                    ? 'palace-study'
                    : mode == 'duty'
                    ? 'palace-duty'
                    : mode,
              ),
            );
            if (mode == 'duty') {
              await tap(find.byKey(const ValueKey('palace-group-Chi tiêu')));
              await tap(find.byKey(const ValueKey('palace-duty-wardrobe')));
            }
          }

          await open();
          if (mode == 'study' || mode == 'duty') {
            expect(
              find.byKey(const ValueKey('meeting-action-confirmation')),
              findsNothing,
            );
            expect(
              find.byKey(
                ValueKey(
                  'confirm-palace-${mode == 'study' ? 'study' : 'duty'}',
                ),
              ),
              findsOneWidget,
            );
            await tap(find.text('Hủy'));
          } else {
            expect(
              find.byKey(const ValueKey('meeting-action-confirmation')),
              findsOneWidget,
            );
            await tap(find.byKey(const ValueKey('meeting-action-cancel')));
          }
          expect(controller.state!.toJson(), before);
          await open();
          await tap(
            find.byKey(
              ValueKey(
                mode == 'study'
                    ? 'confirm-palace-study'
                    : mode == 'duty'
                    ? 'confirm-palace-duty'
                    : 'meeting-action-confirm',
              ),
            ),
          );
          final current = controller.state!;
          expect(current.points, initial.points - 1);
          expect(current.revision, initial.revision + 1);
          expect(
            current.treasury,
            initial.treasury -
                {
                  'study': 2000,
                  'duty': 800,
                  'queen': 6000,
                  'visit': 1000,
                }[mode]!,
          );
          if (mode == 'study' || mode == 'duty') {
            expect(current.palaceWorks.single.personId, 'consort_lan');
            expect(
              current.palaceWorks.single.kind,
              mode == 'study' ? 'study' : 'wardrobe',
            );
            expect(
              tester.widget<OutlinedButton>(action('palace-study')).onPressed,
              isNull,
            );
            expect(
              tester.widget<OutlinedButton>(action('palace-duty')).onPressed,
              isNull,
            );
          } else if (mode == 'queen') {
            expect(
              current.court.firstWhere((c) => c.id == person.id).queen,
              isTrue,
            );
            expect(tester.widget<HaremRankBadge>(badge).rank, 'Hoàng hậu');
            expect(action('queen'), findsNothing);
          } else {
            expect(current.revelThisWeek, initial.revelThisWeek + 1);
            expect(
              current.court.firstWhere((c) => c.id == person.id).affection,
              greaterThan(person.affection),
            );
          }
          expect((await gateway.load()).active!.toJson(), current.toJson());
        }
        if (const bool.fromEnvironment('HAREM_RANK_ACTION_PREVIEWS') &&
            ['Tú nữ', 'Phi tần', 'Hoàng hậu'].contains(mode)) {
          final context = tester.element(find.byType(GameApp));
          await tester.runAsync(() async {
            for (final asset in [
              'assets/images/harem-interior.webp',
              meetingCharacterAsset(person),
              'assets/images/imperial/panel.webp',
              'assets/images/imperial/parchment.webp',
            ]) {
              await precacheImage(AssetImage(asset), context);
            }
          });
          await tester.pumpAndSettle();
          await capture(
            tester,
            boundary,
            '${rank == 'Tú nữ'
                ? 'candidate'
                : rank == 'Phi tần'
                ? 'consort'
                : 'queen'}-${size.width.toInt()}',
          );
        }
        if (!['study', 'duty'].contains(mode)) {
          await tap(find.byKey(const ValueKey('meeting-back')));
          expect(
            tester.widget<HaremRankBadge>(cardBadge).rank,
            mode == 'queen' ? 'Hoàng hậu' : rank,
          );
        }
        if (const bool.fromEnvironment('HAREM_RANK_ACTION_PREVIEWS') &&
            size.width == 1440 &&
            mode == 'Tú nữ') {
          final gallery = GlobalKey();
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(fontFamily: 'BeVietnam'),
              home: Scaffold(
                body: Center(
                  child: RepaintBoundary(
                    key: gallery,
                    child: Container(
                      color: parchment,
                      padding: const EdgeInsets.all(24),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HaremRankBadge('Hoàng hậu'),
                          SizedBox(width: 24),
                          HaremRankBadge('Phi tần'),
                          SizedBox(width: 24),
                          HaremRankBadge('Tú nữ'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await capture(tester, gallery, 'three-rank-badges');
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}

Future<void> capture(WidgetTester tester, GlobalKey boundary, String name) =>
    tester.runAsync(() async {
      final image = await (boundary.currentContext!.findRenderObject()
              as RenderRepaintBoundary)
          .toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('output/harem-rank-actions').create(recursive: true);
      await File(
        'output/harem-rank-actions/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
