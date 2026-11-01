import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';

Future<(MemoryGameStore, GameController)> fixture() async {
  final store = MemoryGameStore();
  final gateway = LocalGameGateway(store, seasonal: false);
  await gateway.start(
    name: 'An',
    runId: 'reports-ui',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  await store.update((a) {
    final s = a.active!;
    s.petitions.clear();
    s.affairsThisWeek = s.workThisWeek = 1;
    s.factions.updateAll((k, v) => 60);
    for (final c in s.court) {
      c.loyalty = 100;
      c.ambition = c.plot = 0;
      c.ability = c.integrity = 100;
    }
    s.rng = 100;
  });
  return (store, GameController(gateway));
}

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets(
      'due results show once in a grouped popup and can be reread after reload at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final (store, controller) = await fixture();
        await store.update((a) {
          final s = a.active!;
          s.outcomes.add(
            const OutcomeReport(
              id: 'older',
              week: 0,
              title: 'Báo cáo cũ',
              status: 'success',
              detail: 'Kết quả đã xem.',
              changes: {'Ngân khố': 10},
            ),
          );
          s.projects.add(
            WorkOrder(
              id: 'trade',
              kind: 'commerce',
              officerId: 'treasurer',
              startedWeek: 1,
              duration: 1,
            ),
          );
          s.pending.addAll([
            Consequence(
              kind: 'eventOutcome',
              dueWeek: 1,
              title: 'Lô hàng bị hỏng',
              detail: 'Kiểm hàng: thất bại.',
              effects: {'treasury': -20, 'people': -4},
            ),
            Consequence(kind: 'school', dueWeek: 2),
          ]);
        });
        await controller.load();
        await tester.pumpWidget(
          GameApp(initialRoute: 'court', controller: controller),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('outcome-dialog')), findsNothing);
        await tester.tap(find.textContaining('Sang tuần').last);
        await tester.pumpAndSettle();
        final dialog = find.byKey(const ValueKey('outcome-dialog'));
        expect(dialog, findsOneWidget);
        expect(
          find.descendant(
            of: dialog,
            matching: find.text('Báo cáo kết quả · 2'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: dialog,
            matching: find.text('Tuần 1 · Thành công'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: dialog, matching: find.text('Tuần 1 · Thất bại')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: dialog, matching: find.text('Ngân khố −20')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: dialog, matching: find.text('Lòng dân −4')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: dialog, matching: find.text('Báo cáo cũ')),
          findsNothing,
        );
        expect(
          find.descendant(of: dialog, matching: find.text('Lớp học đầu tiên')),
          findsNothing,
        );
        final committed = controller.state!.toJson();
        expect(controller.state!.outcomes, hasLength(3));
        expect((await store.read()).active!.toJson(), committed);
        await tester.tap(find.byKey(const ValueKey('close-outcome-dialog')));
        await tester.pumpAndSettle();
        expect(find.text('Kết quả mới (1)'), findsOneWidget);
        final reopen = find.byKey(const ValueKey('open-outcomes'));
        await tester.ensureVisible(reopen);
        await tester.tap(reopen);
        await tester.pumpAndSettle();
        expect(dialog, findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('close-outcome-dialog')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('open-outcomes')), findsNothing);
        expect(controller.state!.toJson(), committed);

        // Recreate the entire UI/controller from the committed local archive.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        final restored = GameController(
          LocalGameGateway(store, seasonal: false),
        );
        await restored.load();
        await tester.pumpWidget(
          GameApp(initialRoute: 'court', controller: restored),
        );
        await tester.pumpAndSettle();
        expect(dialog, findsNothing);
        await tester.tap(find.text('Quốc sự').first);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('kingdom-open-4')));
        await tester.pumpAndSettle();
        final selector = find.byKey(const ValueKey('outcome-week-selector'));
        await tester.ensureVisible(selector);
        await tester.tap(selector);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Kết quả cuối tuần 0').last);
        await tester.pumpAndSettle();
        expect(find.text('Báo cáo cũ'), findsOneWidget);
        expect(restored.state!.toJson(), committed);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('no premature popup for unfinished work', (tester) async {
    final (store, controller) = await fixture();
    await store.update((a) {
      a.active!.pending.add(Consequence(kind: 'school', dueWeek: 3));
    });
    await controller.load();
    await tester.pumpWidget(
      GameApp(initialRoute: 'court', controller: controller),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Sang tuần').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('outcome-dialog')), findsNothing);
    expect(controller.state!.outcomes, isEmpty);
    expect(controller.state!.pending.single.kind, 'school');
    expect(tester.takeException(), isNull);
  });

  testWidgets('fatal delayed result is reported before showing the ending', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final (store, controller) = await fixture();
    await store.update((a) {
      a.active!.pending.add(
        Consequence(
          kind: 'eventOutcome',
          dueWeek: 1,
          title: 'Thuốc bị tráo',
          detail: 'Điều trị: thất bại.',
          effects: {'health': -200},
        ),
      );
    });
    await controller.load();
    await tester.pumpWidget(
      GameApp(initialRoute: 'court', controller: controller),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Sang tuần').last);
    await tester.pumpAndSettle();
    expect(controller.state!.ended, true);
    expect(find.byKey(const ValueKey('outcome-dialog')), findsOneWidget);
    expect(find.text('Sức khỏe −200'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('close-outcome-dialog')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ending-reason')), findsOneWidget);
    expect(find.byKey(const ValueKey('open-outcomes')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
