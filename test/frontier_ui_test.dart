import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/frontier_rules.dart';
import 'package:van_tue/game/logic/warfare_rules.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/frontier_hub.dart';
import 'package:van_tue/game/presentation/widgets/frontier_routes.dart';

Future<(GameController, MemoryGameStore)> setup(
  WidgetTester tester,
  Size size, {
  String route = 'citadel',
  bool war = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  if (const bool.fromEnvironment('FRONTIER_PREVIEWS')) {
    for (final (family, path) in [
      ('Lora', 'assets/fonts/Lora.ttf'),
      ('BeVietnam', 'assets/fonts/BeVietnamPro-Regular.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(path))).load();
    }
  }
  final store = MemoryGameStore();
  final gate = LocalGameGateway(store);
  await gate.start(
    name: 'Thiên Hòa',
    runId: 'front-ui',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  final controller = GameController(gate);
  await controller.load();
  if (war) {
    await controller.act(
      'war',
      target: 'south',
      option: jsonEncode({'action': 'declare'}),
    );
  }
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey('frontier-canvas'),
      child: GameApp(controller: controller, initialRoute: route),
    ),
  );
  await tester.pumpAndSettle();
  return (controller, store);
}

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('FRONTIER_PREVIEWS')) return;
  final context = tester.element(find.byType(GameApp));
  await tester.runAsync(() async {
    for (final asset in [
      ...frontierBackgroundAssets.values,
      'assets/images/imperial/parchment.webp',
      'assets/images/imperial/icons.webp',
      'assets/images/imperial/jade-texture.webp',
      'assets/images/imperial/panel.webp',
      'assets/images/imperial/ivory.webp',
      'assets/images/imperial/jade.webp',
      'assets/images/imperial/crimson.webp',
    ]) {
      await precacheImage(AssetImage(asset), context);
    }
  });
  await tester.pumpAndSettle();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('frontier-canvas')),
  );
  await tester.runAsync(() async {
    await Directory('output/frontier-preview').create(recursive: true);
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      'output/frontier-preview/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> click(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      180,
      scrollable:
          find
              .descendant(
                of: find.byType(ListView).first,
                matching: find.byType(Scrollable),
              )
              .first,
      maxScrolls: 30,
    );
  }
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  for (final country in ['south', 'north', 'west']) {
    testWidgets(
      'Giang Son opens $country and all three landmarks without mutating gameplay',
      (tester) async {
        final (c, _) = await setup(tester, const Size(1440, 900));
        final before = jsonEncode(c.state!.toJson());
        await tester.tap(
          find.byKey(const ValueKey('giang-son-region-frontier')),
        );
        await tester.pumpAndSettle();
        await click(tester, find.byKey(ValueKey('giang-son-$country-pass')));
        expect(find.byType(FrontierHub), findsOneWidget);
        final background = tester.widget<Image>(
          find.byKey(ValueKey('frontier-background-$country')),
        );
        expect(
          (background.image as AssetImage).assetName,
          frontierBackgroundAssets[country],
        );
        expect(frontierBackgroundAssets.values.toSet(), hasLength(3));
        await capture(tester, '$country-1440');
        for (final place in frontierPlaceNames.keys) {
          await click(tester, find.byKey(ValueKey('frontier-location-$place')));
          expect(
            find.byKey(ValueKey('frontier-panel-$country-$place')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('frontier-defense-forecast')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          if (country == 'south') await capture(tester, '$country-$place-1440');
          await tester.tap(find.byKey(const ValueKey('section-back')));
          await tester.pumpAndSettle();
        }
        expect(jsonEncode(c.state!.toJson()), before);
        await tester.tap(find.byKey(const ValueKey('section-back')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('giang-son-map-scroll')),
          findsOneWidget,
        );
      },
    );
  }
  for (final size in [
    const Size(390, 844),
    const Size(320, 568),
    const Size(844, 390),
  ]) {
    testWidgets('mobile pass pans and all workspaces fit $size', (
      tester,
    ) async {
      await setup(tester, size, route: 'frontier-south');
      await capture(tester, 'south-${size.width.toInt()}');
      for (final place in frontierPlaceNames.keys) {
        await click(tester, find.byKey(ValueKey('frontier-location-$place')));
        expect(tester.takeException(), isNull);
        await capture(tester, 'south-$place-${size.width.toInt()}');
        await tester.tap(find.byKey(const ValueKey('section-back')));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'transfer review, cancel, confirm and persisted before/after work on mobile',
    (tester) async {
      final (c, _) = await setup(
        tester,
        const Size(390, 844),
        route: 'frontier-south-camp',
      );
      final before = jsonEncode(c.state!.toJson());
      await click(tester, find.byKey(const ValueKey('transfer-review')));
      expect(find.text('Xác nhận điều quân'), findsOneWidget);
      await capture(tester, 'transfer-review-390');
      await tester.tap(find.text('Để sau'));
      await tester.pumpAndSettle();
      expect(jsonEncode(c.state!.toJson()), before);
      await click(tester, find.byKey(const ValueKey('transfer-review')));
      await tester.tap(find.byKey(const ValueKey('transfer-confirm')));
      await tester.pumpAndSettle();
      expect(c.state!.population!.stationed('south'), 12000);
      expect(c.state!.population!.stationed('capital'), 18000);
      expect(c.state!.population!.soldiers, 50000);
      expect(c.state!.points, jsonDecode(before)['points'] - 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'gate deploys only local soldiers and presents public combat preview',
    (tester) async {
      final (c, _) = await setup(
        tester,
        const Size(1440, 900),
        route: 'frontier-south-gate',
        war: true,
      );
      final m = c.state!.warfare!.missions.first;
      await click(tester, find.byKey(ValueKey('war-open-${m.id}')));
      final leader = find.byKey(const ValueKey('war-leader'));
      await click(tester, leader);
      await tester.tap(find.textContaining('năng lực').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('war-win-chance')), findsOneWidget);
      await capture(tester, 'deploy-1440');
      final confirm = find.byKey(const ValueKey('war-confirm-deploy'));
      await click(tester, confirm);
      expect(c.state!.population!.deployments, hasLength(1));
      final d = c.state!.population!.deployments.single;
      expect(d.sourceGarrison, 'south');
      expect(
        c.state!.population!.availableAt('south'),
        10000 - warTroops(m, .8),
      );
      expect(c.state!.population!.availableAt('north'), 10000);
      expect(
        FrontierDefense(c.state!, c.state!.warfare!.neighbors.last).troops,
        10000,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
