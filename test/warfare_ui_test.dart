import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/warfare_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';

Future<(GameController, MemoryGameStore)> setup(
  WidgetTester tester,
  Size size, {
  bool siege = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  if (const bool.fromEnvironment('WAR_PREVIEWS')) {
    await (FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await (FontLoader('Lora')
      ..addFont(rootBundle.load('assets/fonts/Lora.ttf'))).load();
    await (FontLoader('BeVietnam')..addFont(
      rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'),
    )).load();
  }
  final store = MemoryGameStore();
  final gate = LocalGameGateway(store);
  await gate.start(
    name: 'An',
    runId: 'war-ui',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  await store.update((a) {
    final s = a.active!;
    s.war = 1;
    final n = s.warfare!.neighbors.first;
    n.status = 'war';
    s.warfare!.missions.add(
      WarMission(
        id: 'ui-mission',
        countryId: n.id,
        kind: siege ? 'siege' : 'defend',
        title: siege ? 'Công thành' : 'Giữ cửa ải',
        enemyTroops: 5000,
        opened: s.week,
        deadline: s.week + 2,
      ),
    );
    final c = s.court.firstWhere((c) => c.role == 'Đại tướng');
    c.ability = 90;
    c.affection = 5;
    c.strain = 0;
  });
  final controller = GameController(gate);
  await controller.load();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey('war-canvas'),
      child: GameApp(controller: controller, initialRoute: 'military'),
    ),
  );
  await tester.pumpAndSettle();
  return (controller, store);
}

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets(
      'army preview includes affection and pays exact deployment at $size',
      (tester) async {
        final (controller, store) = await setup(tester, size);
        final before = jsonEncode(controller.state!.toJson());
        final open = find.byKey(const ValueKey('war-open-ui-mission'));
        await tester.ensureVisible(open);
        await tester.tap(open);
        await tester.pumpAndSettle();
        expect(
          find.text('Chọn số quân và tướng để dự tính cơ hội thắng.'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const ValueKey('war-confirm-deploy')),
              )
              .onPressed,
          isNull,
        );
        final ratio = find.byKey(const ValueKey('war-ratio-1.25'));
        await tester.ensureVisible(ratio);
        await tester.tap(ratio);
        await tester.pumpAndSettle();
        final picker = find.byKey(const ValueKey('war-leader'));
        await tester.ensureVisible(picker);
        await tester.tap(picker);
        await tester.pumpAndSettle();
        final general = controller.state!.court.firstWhere(
          (c) => c.role == 'Đại tướng',
        );
        await tester.tap(find.textContaining(general.name).last);
        await tester.pumpAndSettle();
        final s = controller.state!;
        final quote = WarPreview(
          s,
          s.warfare!.missions.single,
          6250,
          general,
          null,
        );
        expect(
          find.text('Cơ hội thắng: ${quote.winChance.toStringAsFixed(1)}%'),
          findsOneWidget,
        );
        expect(
          find.textContaining('nguy cơ tự ý rút quân: 40%'),
          findsOneWidget,
        );
        expect(jsonEncode(controller.state!.toJson()), before);
        if (const bool.fromEnvironment('WAR_PREVIEWS')) {
          final context = tester.element(find.byType(GameApp));
          await tester.runAsync(() async {
            for (final asset in ['icons', 'jade', 'jade-texture', 'panel']) {
              final path = 'assets/images/imperial/$asset.webp';
              await precacheImage(AssetImage(path), context);
            }
          });
          await tester.pumpAndSettle();
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('war-canvas')),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              'docs/warfare-preview-${size.width.toInt()}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        final confirm = find.byKey(const ValueKey('war-confirm-deploy'));
        await tester.ensureVisible(confirm);
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(controller.state!.population!.busySoldiers, 6250);
        expect(controller.state!.treasury, 50000 - quote.cost);
        expect(controller.state!.population!.availableSoldiers, 43750);
        expect(
          (await LocalGameGateway(store).load())
              .active!
              .population!
              .deployments,
          hasLength(1),
        );
      },
    );
  }
  testWidgets(
    'siege picker only offers 200,250,300 and cancel has no side effect',
    (tester) async {
      final (controller, _) = await setup(
        tester,
        const Size(390, 844),
        siege: true,
      );
      final before = jsonEncode(controller.state!.toJson());
      final open = find.byKey(const ValueKey('war-open-ui-mission'));
      await tester.ensureVisible(open);
      await tester.tap(open);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('war-ratio-2.0')), findsOneWidget);
      expect(find.byKey(const ValueKey('war-ratio-2.5')), findsOneWidget);
      expect(find.byKey(const ValueKey('war-ratio-3.0')), findsOneWidget);
      expect(find.byKey(const ValueKey('war-ratio-1.25')), findsNothing);
      await tester.tap(find.text('Để sau').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(jsonEncode(controller.state!.toJson()), before);
    },
  );
  testWidgets(
    'peace confirmation displays yearly tribute and commits a timed treaty',
    (tester) async {
      final (controller, _) = await setup(tester, const Size(390, 844));
      final peace = find.text('Cầu hòa, nộp triều cống');
      await tester.ensureVisible(peace);
      await tester.tap(peace);
      await tester.pumpAndSettle();
      expect(find.textContaining('5.000 lượng vàng/năm'), findsWidgets);
      await tester.tap(find.text('Xác nhận'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final s = controller.state!;
      expect(s.warfare!.neighbors.first.treaty!.annualGold, 5000);
      expect(s.warfare!.neighbors.first.treaty!.nextDue, s.week + 4);
      expect(s.war, 0);
    },
  );
}
