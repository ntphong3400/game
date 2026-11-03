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
import 'package:van_tue/game/presentation/game_app.dart';

Future<GameController> start(
  WidgetTester tester,
  Size size,
  String route,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final gateway = LocalGameGateway(MemoryGameStore());
  await gateway.start(
    name: 'Thiên Hòa',
    runId: 'population-ui',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  final controller = GameController(gateway);
  await controller.load();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey('population-canvas'),
      child: GameApp(controller: controller, initialRoute: route),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
    const Size(844, 390),
  ]) {
    for (final route in ['population', 'military']) {
      testWidgets(
        '$route information scrolls without overflow or writes at $size',
        (tester) async {
          if (const bool.fromEnvironment('POPULATION_PREVIEWS')) {
            await (FontLoader('MaterialIcons')..addFont(
              rootBundle.load('fonts/MaterialIcons-Regular.otf'),
            )).load();
            await (FontLoader('Lora')
              ..addFont(rootBundle.load('assets/fonts/Lora.ttf'))).load();
            await (FontLoader('BeVietnam')..addFont(
              rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'),
            )).load();
          }
          final controller = await start(tester, size, route);
          expect(tester.takeException(), isNull);
          final before = jsonEncode(controller.state!.toJson());
          final panel = find.byKey(ValueKey('$route-panel'));
          expect(panel, findsOneWidget);
          if (route == 'population') {
            expect(find.text('1.000.000 người'), findsOneWidget);
          } else {
            expect(find.text('50.000 người'), findsNWidgets(2));
          }
          if (const bool.fromEnvironment('POPULATION_PREVIEWS')) {
            final context = tester.element(find.byType(GameApp));
            await tester.runAsync(() async {
              for (final asset in [
                'assets/images/imperial/icons.webp',
                'assets/images/imperial/jade.webp',
                'assets/images/imperial/jade-texture.webp',
                'assets/images/imperial/panel.webp',
              ]) {
                await precacheImage(AssetImage(asset), context);
              }
            });
            await tester.pumpAndSettle();
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('population-canvas')),
            );
            await tester.runAsync(() async {
              final image = await boundary.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await File(
                'docs/population-$route-${size.width.toInt()}.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.drag(panel, const Offset(0, -1200));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(jsonEncode(controller.state!.toJson()), before);
        },
      );
    }
  }
  testWidgets(
    'production policy can be chosen and persists as next-season choice',
    (tester) async {
      final controller = await start(tester, const Size(1440, 900), 'treasury');
      await tester.tap(find.byKey(const ValueKey('treasury-open-1')));
      await tester.pumpAndSettle();
      final balanced = find.byKey(const ValueKey('production-balanced'));
      await tester.ensureVisible(balanced);
      await tester.tap(balanced);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(controller.state!.population!.policy, 'economy');
      expect(controller.state!.population!.nextPolicy, 'balanced');
      expect(
        (await controller.gateway.load()).active!.population!.nextPolicy,
        'balanced',
      );
    },
  );
  testWidgets(
    'emergency recruitment requires an officer and shows matching reward',
    (tester) async {
      final controller = await start(tester, const Size(1440, 900), 'kingdom');
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('kingdom-open-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('emergency-levy')));
      await tester.pumpAndSettle();
      final confirm = find.byKey(const ValueKey('confirm-emergency'));
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
      await tester.tap(find.byKey(const ValueKey('levy-officer')));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Lê Trọng Uy').last);
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(controller.state!.population!.soldiers, greaterThan(50000));
      expect(controller.state!.population!.population, 1000000);
      expect(controller.state!.treasury, 48500);
    },
  );
  testWidgets(
    'population action confirms its actual food and one pending order',
    (tester) async {
      final controller = await start(tester, const Size(390, 844), 'kingdom');
      final action = find.byKey(const ValueKey('action-settle'));
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.textContaining('8.750 tạ'), findsWidgets);
      await tester.tap(find.text('Ban lệnh').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(controller.state!.population!.orders.single.count, 5000);
      expect(controller.state!.grain, 3991250);
    },
  );
}
