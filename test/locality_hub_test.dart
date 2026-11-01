import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/locality_hub.dart';
import 'package:van_tue/game/presentation/widgets/citadel_hub.dart';
import 'package:van_tue/game/presentation/widgets/locality_routes.dart';

void viewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<GameController> controller({bool qualified = false}) async {
  final store = MemoryGameStore();
  final gateway = LocalGameGateway(store);
  await gateway.start(
    name: 'Thiên Hòa',
    runId: 'locality-test',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  if (qualified) {
    await store.update((a) {
      a.active!.court.firstWhere((p) => p.id == 'treasurer').ability = 80;
    });
  }
  final c = GameController(gateway);
  await c.load();
  addTearDown(c.dispose);
  return c;
}

Future<void> tap(WidgetTester tester, Finder target) async {
  await Scrollable.ensureVisible(tester.element(target), alignment: .5);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(1024, 768),
    const Size(844, 390),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets('locality and six workspaces preserve save at $size', (
      tester,
    ) async {
      viewport(tester, size);
      final c = await controller();
      final before = c.state!.toJson();
      await tester.pumpWidget(GameApp(controller: c, initialRoute: 'citadel'));
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const ValueKey('giang-son-farms')));
      expect(find.byType(LocalityHub), findsOneWidget);
      for (final place in LocalityPlace.values) {
        await tap(
          tester,
          find.byKey(ValueKey('locality-location-${place.name}')),
        );
        expect(
          find.byKey(ValueKey('locality-panel-${place.name}')),
          findsOneWidget,
        );
        await tap(tester, find.byKey(const ValueKey('locality-detail-back')));
        expect(find.byType(LocalityHub), findsOneWidget);
      }
      await tap(tester, find.byKey(const ValueKey('locality-back')));
      expect(find.byType(CitadelHub), findsOneWidget);
      expect(c.state!.toJson(), before);
      expect((await c.gateway.load()).active!.toJson(), before);
    });
  }

  for (final size in [const Size(1440, 900), const Size(320, 568)]) {
    testWidgets(
      'assignment uses confirmation and shared personnel record at $size',
      (tester) async {
        viewport(tester, size);
        final c = await controller(qualified: true);
        await tester.pumpWidget(
          GameApp(controller: c, initialRoute: LocalityPlace.agriculture.route),
        );
        await tester.pumpAndSettle();
        final before = c.state!.toJson();
        await tap(tester, find.byKey(const ValueKey('action-upgrade_farm')));
        await tap(
          tester,
          find.byKey(const ValueKey('assign-upgrade_farm-treasurer')),
        );
        expect(c.state!.toJson(), before);
        await tap(tester, find.text('Cân nhắc lại'));
        expect(c.state!.toJson(), before);
        await tap(tester, find.byKey(const ValueKey('action-upgrade_farm')));
        await tap(
          tester,
          find.byKey(const ValueKey('assign-upgrade_farm-treasurer')),
        );
        await tap(tester, find.text('Xác nhận giao việc'));
        expect(c.state!.points, (before['points'] as int) - 1);
        expect(c.state!.projects.single.kind, 'upgrade_farm');
        expect(
          (await c.gateway.load()).active!.projects.single.officerId,
          'treasurer',
        );
        await tap(tester, find.byKey(const ValueKey('locality-detail-back')));
        await tap(
          tester,
          find.byKey(const ValueKey('locality-location-administration')),
        );
        await tap(tester, find.byKey(const ValueKey('locality-tab-1')));
        expect(
          find.byKey(const ValueKey('locality-person-treasurer')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('locality-person-general')),
          findsNothing,
        );
        await tap(
          tester,
          find.byKey(const ValueKey('locality-person-treasurer')),
        );
        await tap(tester, find.byKey(const ValueKey('meeting-promotion')));
        expect(
          find.byKey(const ValueKey('court-promotion-dialog')),
          findsOneWidget,
        );
        expect(find.textContaining('Năng lực 80'), findsOneWidget);
        for (final option in tester.widgetList<RadioListTile<int>>(
          find.byType(RadioListTile<int>),
        )) {
          expect(option.onChanged, isNull);
        }
        await tester.tap(find.byKey(const ValueKey('close-imperial-dialog')));
        await tester.pumpAndSettle();
        await tap(tester, find.byKey(const ValueKey('meeting-back')));
        await tap(tester, find.byKey(const ValueKey('locality-personnel')));
        expect(
          find.byKey(const ValueKey('locality-personnel-back')),
          findsOneWidget,
        );
        await tap(
          tester,
          find.byKey(const ValueKey('locality-personnel-back')),
        );
        expect(
          find.byKey(const ValueKey('locality-panel-administration')),
          findsOneWidget,
        );
      },
    );
  }

  testWidgets(
    'commerce policies update shared state and stock actions are scoped',
    (tester) async {
      viewport(tester, const Size(1440, 900));
      final c = await controller();
      await tester.pumpWidget(
        GameApp(controller: c, initialRoute: LocalityPlace.commerce.route),
      );
      await tester.pumpAndSettle();
      final points = c.state!.points;
      await tap(tester, find.byKey(const ValueKey('locality-tax-0')));
      expect(c.state!.tax, 0);
      expect(c.state!.points, points - 1);
      expect((await c.gateway.load()).active!.tax, 0);
      expect(find.byKey(const ValueKey('action-repair')), findsNothing);
      expect(find.byKey(const ValueKey('action-commerce')), findsOneWidget);
      await tap(
        tester,
        find.byKey(const ValueKey('locality-production-balanced')),
      );
      expect(c.state!.population!.nextPolicy, 'balanced');
      expect(c.state!.points, points - 2);
    },
  );

  testWidgets(
    'real irrigation petition opens existing decision without spending actions',
    (tester) async {
      viewport(tester, const Size(1440, 900));
      final c = await controller();
      final river = events.firstWhere((e) => e.id == 'levee_warning');
      c.state!.petitions = [
        Petition(
          id: 'local-river',
          definitionId: river.id,
          openedWeek: 1,
          deadline: 2,
        ),
      ];
      final before = c.state!.toJson();
      await tester.pumpWidget(
        GameApp(controller: c, initialRoute: LocalityPlace.irrigation.route),
      );
      await tester.pumpAndSettle();
      await tap(
        tester,
        find.byKey(const ValueKey('locality-petition-local-river')),
      );
      expect(find.byType(Dialog), findsOneWidget);
      await tester.tapAt(const Offset(2, 200));
      await tester.pumpAndSettle();
      expect(c.state!.toJson(), before);
    },
  );

  testWidgets(
    'locality end turn preserves expiry confirmation and can be cancelled',
    (tester) async {
      viewport(tester, const Size(1440, 900));
      final c = await controller();
      c.state!.petitions.first.deadline = c.state!.week;
      final before = c.state!.toJson();
      await tester.pumpWidget(GameApp(controller: c, initialRoute: 'locality'));
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const ValueKey('locality-end-turn')));
      expect(find.text('Còn tấu chương tới hạn'), findsOneWidget);
      await tap(tester, find.text('Quay lại xử lý'));
      expect(c.state!.toJson(), before);
    },
  );

  testWidgets('locality disables duplicate end turn while saving', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 900));
    final c = await controller();
    var ends = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocalityHub(
            state: c.state!,
            busy: true,
            onNavigate: (_) {},
            onEndTurn: () => ends++,
            onOvertime: () {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const ValueKey('locality-end-turn')));
    expect(ends, 0);
  });

  test(
    'local work filters omit military work and retain delayed revenue',
    () async {
      final c = await controller();
      final s = c.state!;
      expect(LocalityPlace.administration.tasks, isNot(contains('train')));
      expect(LocalityPlace.administration.tasks, isNot(contains('govern')));
      final delayed = Consequence(
        kind: 'eventOutcome',
        title: 'Truy thu thuế tồn',
        dueWeek: 2,
      );
      expect(LocalityPlace.commerce.includesConsequence(s, delayed), isTrue);
      expect(
        LocalityPlace.administration.includesConsequence(s, delayed),
        isTrue,
      );
      expect(LocalityPlace.irrigation.includesConsequence(s, delayed), isFalse);
    },
  );
}
