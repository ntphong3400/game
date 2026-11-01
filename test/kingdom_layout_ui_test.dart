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
  ]) {
    testWidgets(
      'national affairs sections remain reachable without saving at $size, scale=$scale',
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
          runId: 'kingdom-layout',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((archive) {
          final s = archive.active!;
          s.projects = [
            WorkOrder(
              id: 'work',
              kind: 'farm',
              officerId: 'treasurer',
              startedWeek: 1,
              duration: 3,
              progress: 1,
            ),
          ];
          s.pending = [
            Consequence(kind: 'envoy', title: 'Sứ đoàn phương Bắc', dueWeek: 3),
          ];
          s.obligations = [
            Obligation(
              id: 'loan',
              kind: 'borrow',
              title: 'Hoàn trả khoản vay thế gia',
              nextWeek: 2,
              remaining: 3,
              amount: 50,
            ),
            Obligation(
              id: 'income',
              kind: 'income',
              title: 'Nguồn thu thương lộ',
              nextWeek: 2,
              remaining: 2,
              income: 5,
            ),
          ];
          s.outcomes = [
            const OutcomeReport(
              id: 'report-old',
              week: 0,
              title: 'Báo cáo trước',
              status: 'success',
              detail: 'Đã hoàn tất.',
              changes: {'Ngân khố': 10},
            ),
            const OutcomeReport(
              id: 'report-new',
              week: 1,
              title: 'Báo cáo hiện tại',
              status: 'success',
              detail: 'Đã hoàn tất.',
              changes: {'Lòng dân': 3},
            ),
          ];
        });
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.toJson();
        await tester.pumpWidget(
          GameApp(controller: controller, initialRoute: 'kingdom'),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'initial overview');
        final hud = tester.getRect(find.byType(RoomHud));
        Rect? previousDossier;
        for (final (index, _) in [
          (2, 'Nghĩa vụ và ảnh hưởng đang hiệu lực'),
          (3, 'Đối sách khẩn cấp'),
          (1, 'Đang thực hiện'),
          (4, 'Kết quả đã nhận'),
        ]) {
          final shortcut = find.byKey(ValueKey('kingdom-open-$index'));
          final tile = tester.getRect(shortcut);
          expect(tile.top, greaterThanOrEqualTo(hud.bottom));
          expect(tile.bottom, lessThan(size.height - 65));
          expect(shortcut.hitTestable(), findsOneWidget);
          if (size.width >= 1050) {
            if (previousDossier != null) {
              expect(tile.left, closeTo(previousDossier.left, 1));
              expect(tile.width, closeTo(previousDossier.width, 1));
              expect(tile.top, greaterThan(previousDossier.bottom));
            }
            previousDossier = tile;
          }
        }
        for (final (index, title) in [
          (2, 'Nghĩa vụ và ảnh hưởng đang hiệu lực'),
          (3, 'Đối sách khẩn cấp'),
          (1, 'Đang thực hiện'),
          (4, 'Kết quả đã nhận'),
        ]) {
          await tester.tap(find.byKey(ValueKey('kingdom-open-$index')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'detail $index');
          final dialog = find.byKey(ValueKey('kingdom-detail-$index'));
          expect(dialog, findsOneWidget);
          expect(
            find.descendant(of: dialog, matching: find.text(title)),
            findsOneWidget,
          );
          if (index == 1) {
            expect(find.textContaining('Sứ đoàn phương Bắc'), findsWidgets);
          }
          if (index == 2) {
            expect(find.textContaining('tổng còn 150'), findsOneWidget);
          }
          if (index == 3) {
            expect(
              find.byKey(const ValueKey('emergency-levy')),
              findsOneWidget,
            );
          }
          if (index == 4) {
            expect(
              find.byKey(const ValueKey('outcome-week-selector')),
              findsOneWidget,
            );
          }
          await tester.tap(find.byKey(const ValueKey('close-kingdom-detail')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        // Browsing and jumping between sections must never issue a game command.
        expect(controller.state!.toJson(), before);
        expect((await gateway.load()).active!.toJson(), before);
        expect(find.textContaining('Thế cục'), findsNothing);
        expect(find.textContaining('Đại biến cố'), findsNothing);
      },
    );
  }
  testWidgets(
    'detail navigation handles long ledgers and refreshes after an emergency',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store);
      await gateway.start(
        name: 'An',
        runId: 'ledger-live',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((archive) {
        final s = archive.active!;
        s.obligations = [
          for (var i = 0; i < 30; i++)
            Obligation(
              id: 'o$i',
              kind: 'income',
              title: 'Thương lộ $i',
              nextWeek: 2,
              remaining: 2,
              income: 2,
            ),
        ];
        s.outcomes = [
          for (var i = 0; i < 30; i++)
            OutcomeReport(
              id: 'r$i',
              week: i,
              title: 'Báo cáo $i',
              status: 'success',
              detail: 'Đã hoàn tất.',
              changes: const {},
            ),
        ];
      });
      final controller = GameController(gateway);
      await controller.load();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'kingdom'),
      );
      await tester.pumpAndSettle();
      for (final section in [1, 2, 3, 4]) {
        expect(
          find.byKey(ValueKey('kingdom-open-$section')).hitTestable(),
          findsOneWidget,
        );
      }
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('kingdom-count-2'))).data,
        '30',
      );
      await tester.tap(find.byKey(const ValueKey('kingdom-open-3')));
      await tester.pumpAndSettle();
      final before = controller.state!.copy();
      await tester.tap(find.byKey(const ValueKey('emergency-levy')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-emergency')));
      await tester.pumpAndSettle();
      expect(controller.state!.revision, before.revision + 1);
      expect(controller.state!.points, before.points - 1);
      expect(
        controller.state!.obligations.where((o) => o.kind == 'levy'),
        hasLength(1),
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const ValueKey('emergency-levy')),
            )
            .onPressed,
        isNull,
      );
      expect(find.text('Nghĩa vụ trước vẫn còn hiệu lực.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('close-kingdom-detail')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('kingdom-count-2'))).data,
        '31',
      );
      await tester.tap(find.byKey(const ValueKey('kingdom-open-2')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('kingdom-detail-2')),
          matching: find.text('Tuyển quân khẩn cấp'),
        ),
        findsOneWidget,
      );
      expect(
        (await gateway.load()).active!.toJson(),
        controller.state!.toJson(),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
