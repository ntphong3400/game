import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets(
      'petition selection can change or cancel and only explicit confirmation commits at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store, seasonal: false);
        await gateway.start(
          name: 'An',
          runId: 'confirm',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        final event = events.firstWhere(
          (e) => e.title == 'Lính canh bán ca trực',
        );
        await store.update((archive) {
          archive.active!.petitions = [
            Petition(
              id: 'confirm-event',
              definitionId: event.id,
              openedWeek: 1,
              deadline: 2,
            ),
          ];
        });
        final controller = GameController(gateway);
        await controller.load();
        final before = controller.state!.copy();
        await tester.pumpWidget(
          GameApp(initialRoute: 'court', controller: controller),
        );
        await tester.pumpAndSettle();
        final open = find.byKey(const ValueKey('read-petition-confirm-event'));
        await tester.ensureVisible(open);
        await tester.tap(open);
        await tester.pumpAndSettle();
        final confirm = find.byKey(const ValueKey('confirm-petition'));
        expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
        expect(find.byKey(const ValueKey('petition-details-0')), findsNothing);
        for (final i in [0, 1]) {
          final choice = find.byKey(ValueKey('petition-choice-$i'));
          await tester.ensureVisible(choice);
          await tester.tap(choice);
          await tester.pumpAndSettle();
          expect(
            find.byType(AlertDialog),
            size.width < 700 ? findsOneWidget : findsNothing,
          );
          expect(find.byKey(ValueKey('petition-details-$i')), findsOneWidget);
          expect(
            find.byKey(ValueKey('petition-details-${1 - i}')),
            findsNothing,
          );
          expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
          expect(controller.state!.toJson(), before.toJson());
          expect((await gateway.load()).active!.toJson(), before.toJson());
        }
        await tester.ensureVisible(find.text('Đọc sau'));
        await tester.tap(find.text('Đọc sau'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(controller.state!.toJson(), before.toJson());
        await tester.ensureVisible(open);
        await tester.tap(open);
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
        final selected = find.byKey(const ValueKey('petition-choice-1'));
        await tester.ensureVisible(selected);
        await tester.tap(selected);
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
        expect(controller.state!.revision, before.revision);
        await tester.ensureVisible(confirm);
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        final after = controller.state!;
        expect(after.revision, before.revision + 1);
        expect(after.treasury, before.treasury + 20);
        expect(after.points, before.points);
        expect(after.fatigue, before.fatigue);
        expect(after.authority, before.authority);
        expect(after.petitions, isEmpty);
        expect(after.financialWeeks.single.entries, hasLength(1));
        expect(after.history.single['option'], '1');
        expect((await gateway.load()).active!.toJson(), after.toJson());
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('unaffordable petition choices cannot enable confirmation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MemoryGameStore();
    final gateway = LocalGameGateway(store, seasonal: false);
    await gateway.start(
      name: 'An',
      runId: 'no-cash',
      seed: 42,
      previousRunId: null,
      previousRevision: null,
    );
    await store.update((archive) {
      final s = archive.active!;
      s.treasury = 0;
      s.petitions = [
        Petition(
          id: 'poor-event',
          definitionId: 'finance_02',
          openedWeek: 1,
          deadline: 2,
        ),
      ];
    });
    final controller = GameController(gateway);
    await controller.load();
    final before = controller.state!.toJson();
    await tester.pumpWidget(
      GameApp(initialRoute: 'court', controller: controller),
    );
    await tester.pumpAndSettle();
    final open = find.byKey(const ValueKey('read-petition-poor-event'));
    await tester.ensureVisible(open);
    await tester.tap(open);
    await tester.pumpAndSettle();
    final confirm = find.byKey(const ValueKey('confirm-petition'));
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey('petition-choice-0')),
          )
          .onPressed,
      isNull,
    );
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    final free = find.byKey(const ValueKey('petition-choice-1'));
    await tester.ensureVisible(free);
    await tester.tap(free);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
    await tester.tap(find.text('Đọc sau'));
    await tester.pumpAndSettle();
    expect(controller.state!.toJson(), before);
    expect((await gateway.load()).active!.toJson(), before);
    expect(tester.takeException(), isNull);
  });
}
