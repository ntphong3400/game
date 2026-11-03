import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/harem_rules.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'harem_quests_test.dart' as fixtures;

Future<GameController> showQuests(
  WidgetTester tester,
  Size size,
  GameState state, {
  GlobalKey? boundary,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final store = MemoryGameStore();
  await store.update((a) => a.active = state);
  final controller = GameController(LocalGameGateway(store));
  await controller.load();
  addTearDown(controller.dispose);
  if (const bool.fromEnvironment('HAREM_QUEST_PREVIEWS')) {
    for (final entry in [
      ('Lora', 'assets/fonts/Lora.ttf'),
      ('BeVietnam', 'assets/fonts/BeVietnamPro-Regular.ttf'),
    ]) {
      await (FontLoader(entry.$1)..addFont(rootBundle.load(entry.$2))).load();
    }
  }
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundary,
      child: GameApp(controller: controller, initialRoute: 'harem-management'),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

Future<void> tapQuest(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [
    const Size(1440, 1000),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets(
      'relationship chapters show exact costs, cancellation and persisted payment at $size',
      (tester) async {
        final state = fixtures.fixture();
        state.haremQuests.add(
          HaremQuest(
            personId: 'owner',
            definitionId: 'PT01',
            assignedTurn: 1,
            faction: 'Võ tướng',
          ),
        );
        final boundary = GlobalKey();
        final controller = await showQuests(
          tester,
          size,
          state,
          boundary: boundary,
        );
        expect(find.byKey(const ValueKey('harem-quest-panel')), findsOneWidget);
        expect(find.text('Câu chuyện hậu cung'), findsWidgets);
        expect(find.byKey(const ValueKey('open-palace-study')), findsNothing);
        final before = controller.state!.toJson();
        final choice = find.byKey(
          const ValueKey('quest-choice-owner-personal-B'),
        );
        await tapQuest(tester, choice);
        expect(
          find.byKey(const ValueKey('harem-quest-confirmation')),
          findsOneWidget,
        );
        expect(find.textContaining('Võ tướng −2'), findsWidgets);
        await tapQuest(tester, find.text('Để lúc khác').last);
        expect(controller.state!.toJson(), before);
        if (const bool.fromEnvironment('HAREM_QUEST_PREVIEWS')) {
          await tester.runAsync(() async {
            final context = boundary.currentContext!;
            for (final asset in [
              'assets/images/imperial/panel.webp',
              'assets/images/imperial/parchment.webp',
            ]) {
              await precacheImage(AssetImage(asset), context);
            }
          });
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await render.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory('output/harem-quests').create(recursive: true);
            await File(
              'output/harem-quests/quests-${size.width.toInt()}x${size.height.toInt()}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tapQuest(tester, choice);
        await tapQuest(
          tester,
          find.byKey(const ValueKey('confirm-harem-quest')),
        );
        expect(controller.state!.treasury, state.treasury - 800);
        expect(controller.state!.points, state.points - 1);
        expect(
          controller.state!.factions['Võ tướng'],
          state.factions['Võ tướng']! - 2,
        );
        expect(haremQuestFor(controller.state!, 'owner')!.stage, 1);
        expect(
          (await controller.gateway.load()).active!.toJson(),
          controller.state!.toJson(),
        );
        expect(
          tester
              .widget<OutlinedButton>(
                find.byKey(const ValueKey('quest-choice-owner-personal-A')),
              )
              .onPressed,
          isNull,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'insufficient gold disables both ordinary choices without losing progress',
    (tester) async {
      final s = fixtures.fixture()..treasury = 0;
      s.haremQuests.add(
        HaremQuest(
          personId: 'owner',
          definitionId: 'PT01',
          assignedTurn: 1,
          faction: 'Võ tướng',
        ),
      );
      final c = await showQuests(tester, const Size(390, 844), s);
      for (final option in ['A', 'B']) {
        expect(
          tester
              .widget<OutlinedButton>(
                find.byKey(ValueKey('quest-choice-owner-personal-$option')),
              )
              .onPressed,
          isNull,
        );
      }
      expect(haremQuestFor(c.state!, 'owner')!.stage, 0);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'conflict displays a real target and blocks final chapter before verification',
    (tester) async {
      final s = fixtures.fixture(
        traits: const [Personality.resentful, Personality.cautious],
      );
      fixtures.addConflictTargets(s);
      s.haremQuests.add(
        HaremQuest(
          personId: 'owner',
          definitionId: 'PT17',
          assignedTurn: 1,
          faction: 'Võ tướng',
          targetId: 'official-target',
          officeId: 'conflict-office',
          stage: 2,
        ),
      );
      final c = await showQuests(tester, const Size(390, 844), s);
      expect(find.textContaining('Quan đương nhiệm'), findsWidgets);
      expect(find.text('Bổ nhiệm / điều chuyển'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const ValueKey('quest-choice-owner-personal-A')),
            )
            .onPressed,
        isNull,
      );
      await tapQuest(
        tester,
        find.byKey(const ValueKey('quest-refuse-owner-personal')),
      );
      await tapQuest(tester, find.byKey(const ValueKey('confirm-harem-quest')));
      expect(c.state!.court.first.affection, 72);
      expect(haremQuestFor(c.state!, 'owner')!.refusedUntil, 3);
      expect(tester.takeException(), isNull);
    },
  );
}
