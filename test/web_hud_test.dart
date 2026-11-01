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
  for (final size in [
    const Size(1440, 900),
    const Size(1024, 768),
    const Size(844, 390),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    for (final route in ['citadel', 'capital', 'court']) {
      testWidgets('top bar shows season and actions at $size on $route', (
        tester,
      ) async {
        final controller = await start(tester, size, route: route);
        final before = controller.state!.toJson();
        final hud = find.byType(WebGameHud);
        expect(hud, findsOneWidget);
        final title = find.byKey(const ValueKey('hud-page-title'));
        expect(
          tester.widget<Text>(title).data,
          {
            'citadel': 'Giang Sơn',
            'capital': 'Kinh Thành',
            'court': 'Triều chính',
          }[route],
        );
        expect(tester.getCenter(title).dx, closeTo(size.width / 2, 1));
        expect(find.byKey(const ValueKey('room-calendar')), findsOneWidget);
        expect(
          find.descendant(of: hud, matching: find.byType(TextButton)),
          route == 'citadel' ? findsNothing : findsOneWidget,
        );
        expect(find.byKey(const ValueKey('web-hud-stat-scroll')), findsNothing);
        final remaining = find.byKey(const ValueKey('hud-actions-remaining'));
        expect(find.descendant(of: hud, matching: remaining), findsOneWidget);
        expect(
          tester.widget<Text>(remaining).data,
          '${controller.state!.points} hành động còn lại',
        );
        expect(
          find.text('${controller.state!.points} hành động còn lại'),
          findsOneWidget,
        );
        for (final label in [
          'Ngân khố',
          'Số dân',
          'Lương thực (tạ)',
          'Quân lực',
          'Lòng dân',
          'Uy quyền',
          'Sức khỏe',
          'Ổn định',
          controller.state!.playerName,
        ]) {
          expect(
            find.descendant(of: hud, matching: find.text(label)),
            findsNothing,
          );
        }
        if (route != 'citadel') {
          final back = find.byKey(const ValueKey('section-back'));
          expect(
            find.descendant(
              of: back,
              matching: find.text(
                route == 'capital' ? 'Giang Sơn' : 'Kinh Thành',
              ),
            ),
            findsOneWidget,
          );
          await tester.tap(back);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<Text>(find.byKey(const ValueKey('hud-page-title')))
                .data,
            route == 'capital' ? 'Giang Sơn' : 'Kinh Thành',
          );
        }
        expect(controller.state!.toJson(), before);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('loading the save refreshes the calendar and remaining actions', (
    tester,
  ) async {
    final controller = await start(tester, const Size(390, 844));
    await (controller.gateway as LocalGameGateway).store.update((archive) {
      archive.active!.completedWeeks += 1;
      archive.active!.treasury = 1234567;
      archive.active!.points = 5;
    });
    await controller.load();
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('room-calendar'))).data,
      'Mùa ${controller.state!.season}',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('hud-actions-remaining')))
          .data,
      '5 hành động còn lại',
    );
    expect(find.byKey(const ValueKey('web-hud-stat-treasury')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('legacy save uses the same top bar without population metrics', (
    tester,
  ) async {
    await start(tester, const Size(320, 568), legacy: true, route: 'capital');
    expect(find.byKey(const ValueKey('room-calendar')), findsOneWidget);
    expect(find.byKey(const ValueKey('web-hud-stat-population')), findsNothing);
    expect(find.byKey(const ValueKey('capital-back')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('section-back')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('hud-page-title'))).data,
      'Giang Sơn',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('long names fit a narrow top bar with large text', (
    tester,
  ) async {
    final controller = await start(tester, const Size(320, 568));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: WebGameHud(
                state: controller.state!,
                section: 'people-government',
                onNavigate: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bộ máy triều đình'), findsOneWidget);
    expect(find.text('Triều thần'), findsOneWidget);
    expect(
      tester.getCenter(find.byKey(const ValueKey('hud-page-title'))).dx,
      closeTo(160, 1),
    );
    expect(tester.takeException(), isNull);
  });
}
