import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/imperial_room.dart';

void main() {
  for (final (size, scale) in [
    (const Size(1440, 900), 1.0),
    (const Size(1280, 720), 1.0),
    (const Size(844, 390), 1.0),
    (const Size(760, 600), 1.0),
    (const Size(390, 844), 1.0),
    (const Size(320, 568), 1.0),
    (const Size(390, 844), 1.3),
    (const Size(1024, 1366), 1.0),
  ]) {
    testWidgets(
      'treasury dossiers stay reachable with responsive scrolling at $size scale=$scale',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store);
        await gateway.start(
          name: 'An',
          runId: 'treasury-layout',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((a) {
          final s = a.active!;
          s.projects = [
            WorkOrder(
              id: 'work',
              kind: 'commerce',
              officerId: 'treasurer',
              startedWeek: 1,
              duration: 5,
              progress: 0,
            ),
          ];
          s.pending = [
            Consequence(kind: 'audit', title: 'Kiểm toán đang chờ', dueWeek: 3),
          ];
        });
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.toJson();
        await tester.pumpWidget(
          GameApp(controller: controller, initialRoute: 'treasury'),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'initial layout');
        final hud = tester.getRect(find.byType(RoomHud));
        final portrait = size.height > size.width;
        final rects = <Rect>[];
        for (var i = 1; i <= 4; i++) {
          final button = find.byKey(ValueKey('treasury-open-$i'));
          final rect = tester.getRect(button);
          rects.add(rect);
          expect(rect.top, greaterThanOrEqualTo(hud.bottom));
          if (portrait) {
            expect(rect.width, greaterThan(size.width * .7));
            expect(rect.height, greaterThan(180));
            if (i > 1) {
              expect(rect.top, greaterThan(rects[i - 2].bottom));
              expect(rect.left, rects.first.left);
              expect(rect.width, rects.first.width);
            }
          } else {
            expect(button.hitTestable(), findsOneWidget);
            expect(rect.bottom, lessThan(size.height - 60));
          }
        }
        final scroll =
            tester
                .widget<SingleChildScrollView>(
                  find.byKey(const ValueKey('treasury-ledger-scroll')),
                )
                .controller!;
        expect(scroll.position.maxScrollExtent, greaterThan(0));
        await tester.drag(
          find.byKey(const ValueKey('treasury-ledger-scroll')),
          const Offset(0, -220),
        );
        await tester.pumpAndSettle();
        expect(scroll.offset, greaterThan(0));
        expect(tester.getRect(find.byType(RoomHud)), hud);
        if (portrait) {
          expect(
            tester.getRect(find.byKey(const ValueKey('treasury-open-1'))).top,
            lessThan(rects.first.top),
            reason: 'portrait cards scroll with the ledger',
          );
        } else {
          for (var i = 1; i <= 4; i++) {
            expect(
              tester.getRect(find.byKey(ValueKey('treasury-open-$i'))),
              rects[i - 1],
            );
          }
        }
        for (var i = 1; i <= 4; i++) {
          final button = find.byKey(ValueKey('treasury-open-$i'));
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'document $i');
          if (i == 1) {
            expect(
              find.byKey(const ValueKey('tax-policy-timing')),
              findsOneWidget,
            );
          }
          if (i == 2) {
            expect(
              find.byKey(const ValueKey('action-collect_arrears')),
              findsOneWidget,
            );
          }
          if (i == 3) {
            expect(
              find.byKey(const ValueKey('action-buy_grain')),
              findsOneWidget,
            );
          }
          if (i == 4) {
            expect(find.textContaining('Kiểm toán đang chờ'), findsOneWidget);
          }
          await tester.tap(find.byKey(const ValueKey('section-back')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(
          scroll.offset,
          greaterThan(0),
          reason: 'returning preserves ledger position',
        );
        expect(controller.state!.toJson(), before);
        expect((await gateway.load()).active!.toJson(), before);
      },
    );
  }

  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets(
      'long transaction ledger scrolls to the last entry without moving the HUD at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store);
        await gateway.start(
          name: 'An',
          runId: 'treasury-long',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((a) {
          final s = a.active!;
          s.treasury = 620;
          s.financialWeeks.clear();
          s.financialWeeks.add(
            FinanceWeek(
              week: s.week,
              openingBalance: 500,
              openingDebt: s.debt,
              closingBalance: 620,
              closingDebt: s.debt,
              entries: [
                for (var i = 0; i < 120; i++)
                  FinanceEntry(
                    title: 'Khoản thu $i',
                    detail: 'Nguồn thu thực nhận.',
                    category: 'event',
                    amount: 1,
                    requiredAmount: 0,
                    debtChange: 0,
                    balanceAfter: 501 + i,
                    debtAfter: s.debt,
                  ),
              ],
            ),
          );
        });
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.toJson();
        await tester.pumpWidget(
          GameApp(controller: controller, initialRoute: 'treasury'),
        );
        await tester.pumpAndSettle();
        final hudRect = tester.getRect(find.byType(RoomHud));
        final details = find.byKey(const ValueKey('finance-entries-1'));
        await tester.ensureVisible(details);
        await tester.tap(details);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Khoản thu 119'));
        await tester.pumpAndSettle();
        expect(find.text('Khoản thu 119').hitTestable(), findsOneWidget);
        expect(tester.getRect(find.byType(RoomHud)), hudRect);
        for (var i = 1; i <= 4; i++) {
          if (size.height > size.width) {
            await tester.ensureVisible(
              find.byKey(ValueKey('treasury-open-$i')),
            );
          }
          expect(
            find.byKey(ValueKey('treasury-open-$i')).hitTestable(),
            findsOneWidget,
          );
        }
        expect(controller.state!.toJson(), before);
        expect((await gateway.load()).active!.toJson(), before);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
