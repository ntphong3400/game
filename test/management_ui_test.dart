import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/management_rules.dart';
import 'package:van_tue/game/presentation/game_app.dart';

Future<GameController> setup(
  WidgetTester tester,
  Size size,
  String route,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final store = MemoryGameStore();
  final gateway = LocalGameGateway(store);
  await gateway.start(
    name: 'Thiên Hòa',
    runId: 'management-ui',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  await store.update((archive) {
    final s = archive.active!;
    final next = s.officialsPool.first;
    next.courtGroup = route.startsWith('frontier') ? 'Võ ban' : 'Văn ban';
    next.grade = 6;
    next.ability = 100;
    next.affection = 60;
  });
  final controller = GameController(gateway);
  await controller.load();
  addTearDown(controller.dispose);
  if (const bool.fromEnvironment('MANAGEMENT_PREVIEWS')) {
    for (final (family, path) in [
      ('Lora', 'assets/fonts/Lora.ttf'),
      ('BeVietnam', 'assets/fonts/BeVietnamPro-Regular.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(path))).load();
    }
  }
  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey('management-canvas'),
      child: GameApp(controller: controller, initialRoute: route),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('MANAGEMENT_PREVIEWS')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('management-canvas')),
  );
  await tester.runAsync(() async {
    await Directory('output/management-preview').create(recursive: true);
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      'output/management-preview/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  for (final size in [const Size(1440, 900), const Size(320, 568)]) {
    testWidgets(
      'frontier shows management first and replacement confirms exact costs at $size',
      (tester) async {
        final c = await setup(tester, size, 'frontier-north-camp');
        const post = ManagementPost('camp', 'north');
        final before = c.state!.copy();
        final oldId = managementHolder(before, post)!.id;
        final next = before.officialsPool.first;
        expect(
          find.byKey(ValueKey('management-card-${post.id}')),
          findsOneWidget,
        );
        expect(find.text('Thay đổi người quản lý'), findsOneWidget);
        await capture(tester, 'camp-${size.width.toInt()}');
        await tap(tester, find.byKey(ValueKey('change-manager-${post.id}')));
        await tap(
          tester,
          find.byKey(ValueKey('manager-candidate-${post.id}-${next.id}')),
        );
        expect(
          find.textContaining('Chi 1.000 ngân lượng và 1 hành động.'),
          findsOneWidget,
        );
        expect(c.state!.toJson(), before.toJson());
        await tap(tester, find.text('Hủy').last);
        expect(c.state!.toJson(), before.toJson());
        await tap(tester, find.byKey(ValueKey('change-manager-${post.id}')));
        await tap(
          tester,
          find.byKey(ValueKey('manager-candidate-${post.id}-${next.id}')),
        );
        await tap(tester, find.byKey(ValueKey('confirm-manager-${post.id}')));
        expect(managementHolder(c.state!, post)!.id, next.id);
        expect(c.state!.treasury, before.treasury - 1000);
        expect(c.state!.points, before.points - 1);
        expect(
          c.state!.court.firstWhere((p) => p.id == oldId).role,
          'Chờ bổ nhiệm',
        );
        expect((await c.gateway.load()).active!.toJson(), c.state!.toJson());
      },
    );

    testWidgets(
      'Phủ nha defaults to officials, preserves operating tab and appoints prefect at $size',
      (tester) async {
        final c = await setup(tester, size, 'local-administration');
        const post = ManagementPost('prefect', 'bac-son');
        final before = c.state!.copy();
        final next = before.officialsPool.first;
        expect(
          find.byKey(ValueKey('management-card-${post.id}')),
          findsOneWidget,
        );
        expect(find.text('Quan lại địa phương'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('locality-administration-ledger')),
          findsNothing,
        );
        await capture(tester, 'locality-${size.width.toInt()}');
        await tap(tester, find.byKey(const ValueKey('locality-tab-1')));
        expect(
          find.byKey(const ValueKey('locality-administration-ledger')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('management-card-${post.id}')),
          findsNothing,
        );
        await tap(tester, find.byKey(const ValueKey('locality-tab-0')));
        expect(c.state!.toJson(), before.toJson());
        await tap(tester, find.byKey(ValueKey('change-manager-${post.id}')));
        await tap(
          tester,
          find.byKey(ValueKey('manager-candidate-${post.id}-${next.id}')),
        );
        await tap(tester, find.byKey(ValueKey('confirm-manager-${post.id}')));
        expect(managementHolder(c.state!, post)!.id, next.id);
        expect(
          c.state!.court.firstWhere((p) => p.id == next.id).role,
          'Tri phủ',
        );
        expect(c.state!.treasury, before.treasury - 1000);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
