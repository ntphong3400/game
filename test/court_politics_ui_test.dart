import 'support/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets(
      'official profiles hide live discontent and only senior roles show ambition at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store);
        await gateway.start(
          name: 'An',
          runId: 'politics-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((archive) {
          final s = archive.active!;
          s.court.removeWhere(
            (c) =>
                ![
                  'chancellor',
                  'doctor',
                  'consort_mai',
                  'consort_lan',
                ].contains(c.id),
          );
          for (final c in s.court) {
            c.investigated = true;
            c.discontent = 73;
            if (c.isConsort) c.inHarem = true;
          }
          s.court.firstWhere((c) => c.id == 'consort_lan').queen = true;
        });
        final controller = GameController(gateway);
        await controller.load();
        await tester.pumpWidget(
          GameApp(initialRoute: 'court', controller: controller),
        );
        await tester.pumpAndSettle();

        Future<void> navigate(String title) async {
          await openSection(tester, title);
          await tester.pumpAndSettle();
        }

        Future<void> check(String id, {required bool ambition}) async {
          final card = find.byKey(ValueKey('select-person-$id'));
          await tester.ensureVisible(card);
          await tester.tap(card);
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('meeting-back')));
          await tester.pumpAndSettle();
          final meter = find.byKey(ValueKey('discontent-$id'));
          await tester.ensureVisible(meter);
          expect(
            find.descendant(of: meter, matching: find.text('Chưa rõ')),
            findsOneWidget,
          );
          final qualities = find.byKey(ValueKey('qualities-$id'));
          await tester.ensureVisible(qualities);
          final text = tester.widget<Text>(qualities).data!;
          expect(text.contains('tham vọng'), ambition);
          expect(tester.takeException(), isNull);
        }

        await navigate('Triều thần');
        await check('chancellor', ambition: true);
        await check('doctor', ambition: false);
        expect(controller.archive.scores, isEmpty);
        await controller.load();
        expect(controller.state!.court.every((c) => c.discontent == 73), true);
      },
    );
  }
}
