import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/web_game_hud.dart';

Future<GameController> mount(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final gateway = LocalGameGateway(MemoryGameStore());
  await gateway.start(
    name: 'An',
    runId: 'context-hud',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  final controller = GameController(gateway);
  await controller.load();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    GameApp(controller: controller, initialRoute: 'citadel'),
  );
  await tester.pumpAndSettle();
  return controller;
}

GoRouter routerOf(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(GameShell)));

Future<void> tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets('only relevant counters and no left menu at $size', (
      tester,
    ) async {
      final controller = await mount(tester, size);
      final before = controller.state!.toJson();
      final router = routerOf(tester);
      const counters = [
        'treasury',
        'population',
        'food',
        'military',
        'people',
        'authority',
        'health',
        'stability',
      ];
      const screens = {
        '/citadel': counters,
        '/capital': ['treasury', 'authority', 'stability'],
        '/court': ['treasury', 'people', 'authority', 'stability'],
        '/treasury': ['treasury', 'food'],
        '/people': ['treasury', 'authority', 'stability'],
        '/harem': ['treasury', 'food', 'stability'],
        '/health': ['treasury', 'health'],
        '/journal': <String>[],
        '/scores': <String>[],
        '/population': ['population', 'food', 'people'],
        '/military': ['treasury', 'food', 'military'],
        '/locality': ['treasury', 'population', 'food', 'people'],
        '/locality/agriculture': ['treasury', 'food'],
        '/locality/village': ['population', 'food', 'people'],
        '/frontier/north': ['treasury', 'food', 'military'],
        '/country/north': ['treasury', 'military', 'authority'],
      };
      for (final entry in screens.entries) {
        router.go(entry.key);
        await tester.pumpAndSettle();
        for (final counter in counters) {
          expect(
            find.byKey(ValueKey('web-hud-stat-$counter')),
            entry.value.contains(counter) ? findsOneWidget : findsNothing,
            reason: '${entry.key}: $counter',
          );
        }
        expect(find.byType(Drawer), findsNothing);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byTooltip('Mở danh mục'), findsNothing);
        expect(tester.takeException(), isNull, reason: entry.key);
      }
      expect(controller.state!.toJson(), before);
    });

    testWidgets('map entrances and back buttons preserve navigation at $size', (
      tester,
    ) async {
      final controller = await mount(tester, size);
      final before = controller.state!.toJson();
      final router = routerOf(tester);
      await tap(tester, 'giang-son-palace');
      await tap(tester, 'citadel-location-court');
      await tap(tester, 'court-affairs');
      expect(router.routeInformationProvider.value.uri.path, '/kingdom');
      await tap(tester, 'section-back');
      expect(router.routeInformationProvider.value.uri.path, '/court');
      await tap(tester, 'section-back');
      expect(router.routeInformationProvider.value.uri.path, '/capital');
      await tap(tester, 'citadel-location-harem');
      expect(find.byKey(const ValueKey('section-back')), findsNothing);
      await tap(tester, 'harem-back-to-capital');
      expect(router.routeInformationProvider.value.uri.path, '/capital');
      await tap(tester, 'capital-back');
      await tap(tester, 'web-hud-stat-military');
      expect(router.routeInformationProvider.value.uri.path, '/military');
      await tap(tester, 'section-back');
      expect(router.routeInformationProvider.value.uri.path, '/citadel');
      expect(controller.state!.toJson(), before);
      expect(tester.takeException(), isNull);
    });

    testWidgets('court and harem meetings have no national HUD at $size', (
      tester,
    ) async {
      final controller = await mount(tester, size);
      final before = controller.state!.toJson();
      final router = routerOf(tester);
      for (final id in ['war-minister', 'consort_lan']) {
        final person = controller.state!.court.firstWhere((p) => p.id == id);
        final section = person.isConsort ? 'harem' : 'people';
        router.go('/$section/meet/${person.publicId}');
        await tester.pumpAndSettle();
        expect(find.byType(WebGameHud), findsNothing);
        expect(find.byType(Drawer), findsNothing);
        expect(
          find.byKey(const ValueKey('meeting-action-audience')),
          findsOneWidget,
        );
        expect(find.textContaining('1 hành động'), findsWidgets);
        await tap(tester, 'meeting-back');
        expect(router.routeInformationProvider.value.uri.path, '/$section');
        expect(find.byKey(const ValueKey('section-back')), findsNothing);
      }
      expect(controller.state!.toJson(), before);
      expect(tester.takeException(), isNull);
    });
  }
}
