import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/court_rules.dart';
import 'package:van_tue/game/logic/investigation_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';

Future<(GameController, MemoryGameStore, String)> setup(
  WidgetTester tester,
  Size size, {
  int? plot,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  if (const bool.fromEnvironment('COVERT_PREVIEWS')) {
    for (final (family, path) in [
      ('Lora', 'assets/fonts/Lora.ttf'),
      ('BeVietnam', 'assets/fonts/BeVietnamPro-Regular.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(path))).load();
    }
  }
  final store = MemoryGameStore(), gateway = LocalGameGateway(store);
  await gateway.start(
    name: 'Thiên Hòa',
    runId: 'covert-ui',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  var id = '';
  await store.update((a) {
    final s = a.active!;
    s.treasury = 50000;
    final c =
        courtOfficeHolder(
          s,
          s.courtOffices.firstWhere((o) => o.role == 'Thân vương'),
        )!;
    id = c.id;
    if (plot != null) {
      c.lastInvestigation = CharacterInvestigation(
        week: s.week,
        plot: plot,
        discontent: 30,
      );
      c.evidenceTurn = s.week;
    }
  });
  final controller = GameController(gateway);
  await controller.load();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey('covert-canvas'),
      child: GameApp(controller: controller, initialRoute: 'people'),
    ),
  );
  await tester.pumpAndSettle();
  await tap(tester, find.byKey(const ValueKey('open-court-government')));
  final office = controller.state!.courtOffices.firstWhere(
    (o) => o.holderId == id,
  );
  await tap(tester, find.byKey(ValueKey('government-meet-${office.id}')));
  return (controller, store, id);
}

Finder action(String id) => find.byKey(ValueKey('meeting-action-$id'));
Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('COVERT_PREVIEWS')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('covert-canvas')),
  );
  await tester.runAsync(() async {
    await Directory('output/covert-preview').create(recursive: true);
    final image = await boundary.toImage(pixelRatio: 1),
        data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      'output/covert-preview/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  for (final size in [const Size(1440, 900), const Size(320, 568)]) {
    testWidgets(
      'investigation requires spy choice, previews funding and risks, and commits only on confirmation at $size',
      (tester) async {
        final (c, _, id) = await setup(tester, size);
        final before = c.state!.copy();
        expect(
          tester.widget<OutlinedButton>(action('demote-court')).onPressed,
          isNull,
        );
        expect(
          tester.widget<OutlinedButton>(action('convict')).onPressed,
          isNull,
        );
        await tap(tester, action('investigate'));
        expect(
          find.byKey(const ValueKey('covert-investigation-dialog')),
          findsOneWidget,
        );
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const ValueKey('confirm-investigation')),
              )
              .onPressed,
          isNull,
        );
        await tap(tester, find.byKey(const ValueKey('investigation-spy')));
        final investigator =
            covertSpies(c.state!, courtPerson(c.state!, id)!).first;
        await tap(tester, find.textContaining(investigator.name).last);
        await tap(
          tester,
          find.byKey(const ValueKey('investigation-funding-80')),
        );
        expect(find.textContaining('Tử vong nếu thất bại:'), findsOneWidget);
        expect(c.state!.toJson(), before.toJson());
        await capture(tester, 'investigation-${size.width.toInt()}');
        await tap(tester, find.text('Hủy').last);
        expect(c.state!.toJson(), before.toJson());
        await tap(tester, action('investigate'));
        await tap(tester, find.byKey(const ValueKey('investigation-spy')));
        await tap(tester, find.textContaining(investigator.name).last);
        await tap(
          tester,
          find.byKey(const ValueKey('investigation-funding-40')),
        );
        await tap(tester, find.byKey(const ValueKey('confirm-investigation')));
        expect(c.state!.treasury, before.treasury - 4000);
        expect(c.state!.points, before.points - 1);
        expect(
          c.state!.pending
              .singleWhere((p) => p.covertMission != null)
              .covertMission!
              .spyId,
          investigator.id,
        );
        expect(
          tester.widget<OutlinedButton>(action('investigate')).onPressed,
          isNull,
        );
        expect((await c.gateway.load()).active!.toJson(), c.state!.toJson());
      },
    );

    testWidgets(
      'demotion offers one/two ranks, cancellation is free, and evidence expiry locks discipline at $size',
      (tester) async {
        final (c, store, id) = await setup(tester, size, plot: 61);
        final before = c.state!.copy();
        expect(
          tester.widget<OutlinedButton>(action('demote-court')).onPressed,
          isNotNull,
        );
        expect(
          tester.widget<OutlinedButton>(action('convict')).onPressed,
          isNull,
        );
        await tap(tester, action('demote-court'));
        expect(find.text('Chọn mức giáng phẩm'), findsOneWidget);
        await tap(
          tester,
          find.byKey(const ValueKey('demotion-choice-demote-court:2')),
        );
        await capture(tester, 'demotion-${size.width.toInt()}');
        await tap(tester, find.byKey(const ValueKey('meeting-action-cancel')));
        expect(c.state!.toJson(), before.toJson());
        await tap(tester, action('demote-court'));
        await tap(
          tester,
          find.byKey(const ValueKey('demotion-choice-demote-court:2')),
        );
        await tap(tester, find.byKey(const ValueKey('meeting-action-confirm')));
        expect(courtPerson(c.state!, id)!.grade, 3);
        expect(courtOfficeFor(c.state!, id), isNull);
        expect(c.state!.stability, before.stability);
        expect(c.state!.authority, before.authority);
        expect(c.state!.points, before.points - 1);
        await store.update((a) => a.active!.completedWeeks = 4);
        await c.load();
        await tester.pumpAndSettle();
        expect(
          tester.widget<OutlinedButton>(action('demote-court')).onPressed,
          isNull,
        );
        expect(find.textContaining('Bằng chứng đã hết hạn'), findsWidgets);
      },
    );

    testWidgets(
      'conviction confirms imprisonment and removes the holder without political disruption at $size',
      (tester) async {
        final (c, _, id) = await setup(tester, size, plot: 76);
        final before = c.state!.copy();
        await tap(tester, action('convict'));
        expect(find.textContaining('Bỏ tù'), findsWidgets);
        await capture(tester, 'conviction-${size.width.toInt()}');
        await tap(tester, find.byKey(const ValueKey('meeting-action-confirm')));
        final prisoner = c.state!.court.firstWhere((p) => p.id == id);
        expect(prisoner.imprisoned, true);
        expect(prisoner.grade, 0);
        expect(prisoner.available, false);
        expect(c.state!.stability, before.stability);
        expect(c.state!.authority, before.authority);
        expect(courtOfficeFor(c.state!, id), isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
