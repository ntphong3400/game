import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/petition_decision.dart';
import 'package:van_tue/game/presentation/widgets/imperial_room.dart';

void viewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<GameController> makeController({
  Future<void> Function(MemoryGameStore)? prepare,
}) async {
  final store = MemoryGameStore();
  final gateway = LocalGameGateway(store);
  await gateway.start(
    name: 'Thiên Hòa',
    runId: 'interiors',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  if (prepare != null) await prepare(store);
  final controller = GameController(gateway);
  await controller.load();
  return controller;
}

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(1280, 720),
    const Size(844, 390),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    for (final route in [
      'court',
      'treasury',
      'people',
      'harem',
      'health',
      'kingdom',
      'journal',
      'scores',
    ]) {
      testWidgets(
        '$route interior renders without overflow or game mutation at $size',
        (tester) async {
          viewport(tester, size);
          final controller = await makeController();
          final before = controller.state!.toJson();
          await tester.pumpWidget(
            GameApp(controller: controller, initialRoute: route),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(ValueKey('scene-header-$route')),
            route == 'court' ? findsNothing : findsOneWidget,
          );
          if (route == 'court') {
            expect(
              find.byKey(const ValueKey('court-overview')),
              findsOneWidget,
            );
            expect(find.byKey(const ValueKey('court-affairs')), findsNothing);
            for (final entry
                in {
                  'authority': controller.state!.authority,
                  'stability': controller.state!.stability,
                  'people': controller.state!.people,
                  'health': controller.state!.health,
                }.entries) {
              expect(
                find.descendant(
                  of: find.byKey(ValueKey('court-stat-${entry.key}')),
                  matching: find.text('${entry.value}/100'),
                ),
                findsOneWidget,
              );
            }
          }
          expect(controller.state!.toJson(), before);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'inline desk selection and assignee preview are local until explicit confirmation',
    (tester) async {
      viewport(tester, const Size(1600, 1100));
      final controller = await makeController(
        prepare: (store) async {
          await store.update((archive) {
            archive.active!.petitions = [
              Petition(
                id: 'desk-test',
                definitionId: 'finance_02',
                openedWeek: 1,
                deadline: 2,
              ),
            ];
          });
        },
      );
      final before = controller.state!.toJson();
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'court'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('read-petition-desk-test')));
      await tester.pumpAndSettle();
      expect(find.byType(PetitionDecision), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.ensureVisible(
        find.byKey(const ValueKey('petition-choice-0')),
      );
      await tester.tap(find.byKey(const ValueKey('petition-choice-0')));
      await tester.pumpAndSettle();
      final assignee = find.byKey(const ValueKey('petition-assignee'));
      await tester.ensureVisible(assignee);
      await tester.tap(assignee);
      await tester.pumpAndSettle();
      final person = find.byKey(const ValueKey('petition-person-treasurer'));
      await tester.ensureVisible(person);
      await tester.tap(person);
      await tester.pumpAndSettle();
      expect(controller.state!.toJson(), before);
      expect((await controller.gateway.load()).active!.toJson(), before);
      final confirm = find.byKey(const ValueKey('confirm-petition'));
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(controller.state!.revision, (before['revision'] as int) + 1);
      expect(controller.state!.petitions, isEmpty);
      expect(
        controller.state!.pending.single.assignment!.assigneeId,
        'treasurer',
      );
      expect(find.byKey(const ValueKey('court-complete')), findsOneWidget);
      expect(
        (await controller.gateway.load()).active!.toJson(),
        controller.state!.toJson(),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'official portrait, compare list and profile action preserve known qualities',
    (tester) async {
      viewport(tester, const Size(1440, 1000));
      final controller = await makeController();
      const id = 'treasurer';
      final c = controller.state!.court.firstWhere((c) => c.id == id);
      final before = controller.state!.toJson();
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'people'),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('people-search-false')),
        c.name,
      );
      await tester.pumpAndSettle();
      final portrait = find.byKey(ValueKey('select-person-$id'));
      await tester.ensureVisible(portrait);
      await tester.tap(portrait);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('meeting-back')));
      await tester.pumpAndSettle();
      final profile = find.byKey(const ValueKey('character-profile-false'));
      expect(
        find.descendant(of: profile, matching: find.text(c.qualitiesText)),
        findsOneWidget,
      );
      expect(c.investigated, false);
      await tester.ensureVisible(
        find.byKey(const ValueKey('roster-list-false')),
      );
      await tester.tap(find.byKey(const ValueKey('roster-list-false')));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('list-profile-$id')), findsOneWidget);
      expect(controller.state!.toJson(), before);
      final talk = find.byKey(ValueKey('profile-action-$id-audience'));
      await tester.ensureVisible(talk);
      await tester.tap(talk);
      await tester.pumpAndSettle();
      expect(controller.state!.revision, (before['revision'] as int) + 1);
      expect(controller.state!.points, (before['points'] as int) - 1);
      expect(
        (await controller.gateway.load()).active!.toJson(),
        controller.state!.toJson(),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('care preview does not spend resources before the action arrow', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 900));
    final controller = await makeController();
    final before = controller.state!.toJson();
    await tester.pumpWidget(
      GameApp(controller: controller, initialRoute: 'health'),
    );
    await tester.pumpAndSettle();
    final preview = find.byKey(const ValueKey('care-preview-treat'));
    await tester.ensureVisible(preview);
    await tester.tap(preview);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('care-preview-panel')), findsOneWidget);
    expect(controller.state!.toJson(), before);
    expect((await controller.gateway.load()).active!.toJson(), before);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'treasury panes scroll while HUD and resources stay fixed without season control',
    (tester) async {
      viewport(tester, const Size(1440, 900));
      final controller = await makeController();
      final before = controller.state!.toJson();
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'treasury'),
      );
      await tester.pumpAndSettle();
      final hud = find.byType(RoomHud);
      final endSeason = find.widgetWithText(FilledButton, 'Khép lại mùa  →');
      final hudRect = tester.getRect(hud);
      expect(endSeason, findsNothing);
      expect(
        find.text(
          '${controller.state!.grain} thóc · Đê điều ${controller.state!.levee}/100',
        ),
        findsOneWidget,
      );
      final ledger = find.byKey(const ValueKey('treasury-ledger-scroll'));
      final scroll = tester.widget<SingleChildScrollView>(ledger).controller!;
      await tester.drag(ledger, const Offset(0, -220));
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(0));
      await tester.tap(find.byKey(const ValueKey('treasury-open-3')));
      await tester.pumpAndSettle();
      final work = find.byKey(const ValueKey('action-repair'));
      await tester.ensureVisible(work);
      await tester.pumpAndSettle();
      expect(work.hitTestable(), findsOneWidget);
      expect(tester.getRect(hud), hudRect);
      expect(endSeason, findsNothing);
      expect(controller.state!.toJson(), before);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('all five workspaces have upright rectangular reading surfaces', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 900));
    final controller = await makeController();
    for (final route in [
      'court',
      'treasury',
      'people',
      'harem',
      'health',
      'kingdom',
      'journal',
      'scores',
    ]) {
      await tester.pumpWidget(
        GameApp(
          key: ValueKey(route),
          controller: controller,
          initialRoute: route,
        ),
      );
      await tester.pumpAndSettle();
      final box = tester.renderObject<RenderBox>(
        find.byType(ImperialWorkspace),
      );
      final origin = box.localToGlobal(Offset.zero);
      final right = box.localToGlobal(Offset(box.size.width, 0));
      final bottom = box.localToGlobal(Offset(0, box.size.height));
      expect(right.dy, closeTo(origin.dy, .01));
      expect(bottom.dx, closeTo(origin.dx, .01));
      expect(right.dx - origin.dx, closeTo(box.size.width, .01));
      expect(bottom.dy - origin.dy, closeTo(box.size.height, .01));
      expect(tester.takeException(), isNull);
    }
  });

  for (final size in [
    const Size(1440, 900),
    const Size(1280, 720),
    const Size(844, 390),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets(
      'palace management opens separately and returns without mutations at $size',
      (tester) async {
        viewport(tester, size);
        final controller = await makeController();
        final before = controller.state!.toJson();
        await tester.pumpWidget(
          GameApp(controller: controller, initialRoute: 'harem'),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('harem-quest-panel')), findsNothing);
        final open = find.byKey(const ValueKey('open-palace-management'));
        await tester.ensureVisible(open);
        await tester.tap(open);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('harem-quest-panel')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('character-profile-true')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('open-palace-duties')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('open-palace-study')), findsNothing);
        expect(controller.state!.toJson(), before);
        expect(tester.takeException(), isNull);
        final back = find.byKey(const ValueKey('section-back'));
        await tester.ensureVisible(back);
        await tester.tap(back);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('harem-quest-panel')), findsNothing);
        expect(
          find.byKey(const ValueKey('character-profile-true')),
          findsNothing,
        );
        expect(controller.state!.toJson(), before);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets('score room opens without an active reign at $size', (
      tester,
    ) async {
      viewport(tester, size);
      final controller = GameController(LocalGameGateway(MemoryGameStore()));
      await controller.load();
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'scores'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ImperialWorkspace), findsOneWidget);
      expect(find.byKey(const ValueKey('scene-header-scores')), findsOneWidget);
      expect(find.text('Sử sách vẫn đang chờ tên bạn'), findsOneWidget);
      expect(find.textContaining('Khép lại mùa'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets('score room remains available after a reign ends at $size', (
      tester,
    ) async {
      viewport(tester, size);
      final controller = await makeController(
        prepare: (store) async {
          await store.update((archive) {
            archive.active!.endReason = 'Triều đại khép lại';
          });
        },
      );
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'scores'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ImperialWorkspace), findsOneWidget);
      expect(find.text('Những triều đại dài nhất'), findsOneWidget);
      expect(find.textContaining('Khép lại mùa'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'chronicle selection changes the reading page without saving a command',
    (tester) async {
      viewport(tester, const Size(1440, 900));
      final controller = await makeController(
        prepare: (store) async {
          await store.update((archive) {
            archive.active!.journal = [
              Chronicle(2, 'Bản ghi thứ hai', 'Nội dung thứ hai'),
              Chronicle(1, 'Bản ghi đầu', 'Nội dung đầu'),
            ];
          });
        },
      );
      final before = controller.state!.toJson();
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'journal'),
      );
      await tester.pumpAndSettle();
      final page = find.byKey(const ValueKey('chronicle-reading'));
      expect(
        find.descendant(of: page, matching: find.text('Nội dung thứ hai')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('chronicle-entry-1')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: page, matching: find.text('Nội dung đầu')),
        findsOneWidget,
      );
      expect(controller.state!.toJson(), before);
      expect((await controller.gateway.load()).active!.toJson(), before);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'new score room preserves personal bests, shared ranks and rule filters',
    (tester) async {
      viewport(tester, const Size(1440, 900));
      final store = MemoryGameStore();
      await store.update((archive) {
        archive.scores = [
          ScoreEntry('a0', 'An', 1, seasonal: true),
          ScoreEntry('a', 'An', 8, seasonal: true),
          ScoreEntry('b', 'Bình', 8, seasonal: true),
          ScoreEntry('c', 'Chi', 4, seasonal: true),
          ScoreEntry('old', 'Cựu triều', 100, rules: 'mvp-0.18.0'),
        ];
      });
      final controller = GameController(LocalGameGateway(store));
      await controller.load();
      final before = controller.archive.toJson();
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'scores'),
      );
      await tester.pumpAndSettle();
      expect(find.text('An'), findsOneWidget);
      expect(find.text('01'), findsNWidgets(2));
      expect(find.text('03'), findsOneWidget);
      expect(find.text('Cựu triều'), findsNothing);
      await tester.tap(find.text('Luật 0.18 (cũ)'));
      await tester.pumpAndSettle();
      expect(find.text('Cựu triều'), findsOneWidget);
      expect(find.text('An'), findsNothing);
      expect(controller.archive.toJson(), before);
      expect(tester.takeException(), isNull);
    },
  );
}
