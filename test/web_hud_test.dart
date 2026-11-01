import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/web_game_hud.dart';

Future<GameController> start(
  WidgetTester tester,
  Size size, {
  bool legacy = false,
  String route = 'citadel',
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final gateway = LocalGameGateway(
    MemoryGameStore(),
    engine: GameEngine(populationEnabled: !legacy),
  );
  await gateway.start(
    name: 'Thiên Hòa',
    runId: 'web-hud',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  final controller = GameController(gateway);
  await controller.load();
  addTearDown(controller.dispose);
  await tester.pumpWidget(GameApp(controller: controller, initialRoute: route));
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  for (final width in [1440.0, 1280.0, 1024.0, 844.0]) {
    for (final route in ['citadel', 'court']) {
      testWidgets('contextual HUD counters at $width on $route', (
        tester,
      ) async {
        final controller = await start(tester, Size(width, 720), route: route);
        final before = controller.state!.toJson();
        expect(find.byType(WebGameHud), findsOneWidget);
        expect(find.byTooltip('Mở danh mục'), findsNothing);
        final hud = find.byType(WebGameHud);
        for (final label in [
          'Ngân khố',
          if (route == 'citadel') 'Số dân',
          if (route == 'citadel') 'Lương thực (tạ)',
          if (route == 'citadel') 'Quân lực',
          'Lòng dân',
          'Uy quyền',
          if (route == 'citadel') 'Sức khỏe',
          'Ổn định',
        ]) {
          expect(
            find.descendant(of: hud, matching: find.text(label)),
            findsOneWidget,
          );
        }
        if (route == 'citadel') {
          expect(
            find.descendant(of: hud, matching: find.text('1.000.000')),
            findsOneWidget,
          );
        }
        if (route == 'citadel') {
          expect(
            find.descendant(of: hud, matching: find.text('4.000.000')),
            findsOneWidget,
          );
        }
        expect(find.byKey(const ValueKey('web-hud-one-row')), findsOneWidget);
        expect(find.byKey(const ValueKey('web-hud-two-rows')), findsNothing);
        expect(tester.getSize(hud).height, lessThanOrEqualTo(65));
        final last = find.byKey(const ValueKey('web-hud-stat-stability'));
        await tester.ensureVisible(last);
        await tester.pumpAndSettle();
        expect(last.hitTestable(), findsOneWidget);
        expect(controller.state!.toJson(), before);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'population and food counters navigate without changing the save and refresh after load',
    (tester) async {
      final controller = await start(tester, const Size(1440, 900));
      final before = controller.state!.toJson();
      await tester.tap(find.byKey(const ValueKey('web-hud-stat-population')));
      await tester.pumpAndSettle();
      expect(find.text('Dân số và phân bổ lao động'), findsOneWidget);
      await tester.tap(find.byTooltip('Về Giang Sơn'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('web-hud-stat-food')));
      await tester.pumpAndSettle();
      expect(find.text('Việc tăng thu'), findsOneWidget);
      expect(controller.state!.toJson(), before);
      expect((await controller.gateway.load()).active!.toJson(), before);
      await (controller.gateway as LocalGameGateway).store.update((archive) {
        archive.active!.population!.population = 1234567;
        archive.active!.grain = 2345678;
      });
      await controller.load();
      await tester.pumpAndSettle();
      final hud = find.byType(WebGameHud);
      expect(
        find.byKey(const ValueKey('web-hud-stat-population')),
        findsNothing,
      );
      expect(
        find.descendant(of: hud, matching: find.text('2.345.678')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('section-back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('capital-back')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(WebGameHud),
          matching: find.text('1.234.567'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'legacy saves show unavailable population and retain their food unit',
    (tester) async {
      await start(tester, const Size(1280, 720), legacy: true);
      final hud = find.byType(WebGameHud);
      expect(
        find.descendant(of: hud, matching: find.text('—')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hud, matching: find.text('Lương thực (thóc)')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('web-hud-stat-population')));
      await tester.pumpAndSettle();
      expect(find.text('Điện nghị sự'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'phone viewport keeps all eight Giang Son counters without a menu',
    (tester) async {
      await start(tester, const Size(390, 844));
      expect(find.byType(WebGameHud), findsOneWidget);
      expect(find.text('Số dân'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('web-hud-stat-stability')),
        findsOneWidget,
      );
      expect(find.byTooltip('Mở danh mục'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
