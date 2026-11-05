import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/widgets/citadel_hub.dart';

Future<GameController> mount(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  bool motion = false,
  bool busy = false,
  double textScale = 1,
  GlobalKey<NavigatorState>? navigatorKey,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: !motion);
  final gateway = LocalGameGateway(MemoryGameStore());
  await gateway.start(
    name: 'Thiên Hòa',
    runId: 'panorama',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  final controller = GameController(gateway);
  await controller.load();
  addTearDown(controller.dispose);
  if (const bool.fromEnvironment('GIANG_SON_PREVIEWS')) {
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
      key: const ValueKey('panorama-preview'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
        home: Scaffold(
          body: CitadelHub(
            state: controller.state!,
            busy: busy,
            onNavigate: (_) {},
            onEndTurn: () {},
            onOvertime: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return controller;
}

ScrollController camera(WidgetTester tester) =>
    tester
        .widget<SingleChildScrollView>(
          find.byKey(const ValueKey('giang-son-map-scroll')),
        )
        .controller!;

Future<void> frames(WidgetTester tester, [int count = 45]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('GIANG_SON_PREVIEWS')) return;
  final context = tester.element(find.byType(CitadelHub));
  await tester.runAsync(() async {
    for (final asset in [
      'assets/images/giang-son-map.webp',
      'assets/images/imperial/jade-texture.webp',
    ]) {
      await precacheImage(AssetImage(asset), context);
    }
  });
  await tester.pumpAndSettle();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('panorama-preview')),
  );
  await tester.runAsync(() async {
    await Directory('output/giang-son-preview').create(recursive: true);
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      'output/giang-son-preview/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  testWidgets(
    'tour starts automatically, manual drag holds it, last action restarts five-second idle delay',
    (tester) async {
      final c = await mount(tester, motion: true);
      final before = c.state!.toJson();
      final scroll = camera(tester);
      final start = scroll.offset;
      await frames(tester);
      expect(scroll.offset, greaterThan(start));
      final scene = find.byKey(const ValueKey('giang-son-map-scroll'));
      final gesture = await tester.startGesture(tester.getCenter(scene));
      await gesture.moveBy(const Offset(-70, 0));
      await tester.pump();
      final held = scroll.offset;
      // Holding a finger longer than five seconds must never restart the tour.
      await tester.pump(const Duration(seconds: 7));
      expect(scroll.offset, held);
      await gesture.up();
      await tester.pump();
      final released = scroll.offset;
      await tester.pump(const Duration(seconds: 4));
      expect(scroll.offset, released);
      await tester.tapAt(tester.getCenter(scene));
      await tester.pump(const Duration(seconds: 4));
      expect(scroll.offset, released);
      await tester.pump(const Duration(seconds: 1));
      await frames(tester);
      expect(scroll.offset, greaterThan(released));
      expect(
        scroll.offset - released,
        lessThan(10),
        reason: 'Resume in place, without snapping back',
      );
      expect(c.state!.toJson(), before);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('wheel input also pauses and resumes after inactivity', (
    tester,
  ) async {
    await mount(tester, motion: true);
    await frames(tester);
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(
          find.byKey(const ValueKey('giang-son-map-scroll')),
        ),
        scrollDelta: const Offset(40, 0),
      ),
    );
    await tester.pump();
    final stopped = camera(tester).offset;
    await tester.pump(const Duration(seconds: 4));
    expect(camera(tester).offset, stopped);
    await tester.pump(const Duration(seconds: 1));
    await frames(tester);
    expect(camera(tester).offset, greaterThan(stopped));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tour pauses behind a dialog and resumes after it closes', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    await mount(tester, motion: true, navigatorKey: navigator);
    await frames(tester);
    final dialog = showDialog<void>(
      context: navigator.currentContext!,
      builder: (_) => const AlertDialog(title: Text('Tạm dừng')),
    );
    await frames(tester);
    final stopped = camera(tester).offset;
    await frames(tester);
    expect(camera(tester).offset, stopped);
    navigator.currentState!.pop();
    await dialog;
    await frames(tester);
    expect(camera(tester).offset, greaterThan(stopped));
    await tester.pumpWidget(const SizedBox());
  });

  for (final busy in [true, false]) {
    testWidgets('tour respects ${busy ? 'saving' : 'reduced motion'}', (
      tester,
    ) async {
      await mount(tester, motion: busy, busy: busy);
      final start = camera(tester).offset;
      await frames(tester);
      expect(camera(tester).offset, start);
      await tester.pumpWidget(const SizedBox());
    });
  }

  for (final size in [
    const Size(1440, 900),
    const Size(1024, 768),
    const Size(844, 390),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets('large painting and floating end-season fit $size', (
      tester,
    ) async {
      await mount(tester, size: size);
      await tester.pumpAndSettle();
      final map = find.byKey(const ValueKey('giang-son-map-scroll'));
      final tabs = find.byKey(const ValueKey('giang-son-regions'));
      final end = find.byKey(const ValueKey('citadel-end-turn'));
      expect(tester.getBottomRight(map).dy, tester.getTopLeft(tabs).dy);
      expect(tester.getBottomRight(end).dx, closeTo(size.width - 16, .1));
      expect(
        tester.getBottomRight(end).dy,
        closeTo(tester.getTopLeft(tabs).dy - 12, .1),
      );
      expect(tester.getSize(map).height, greaterThan(size.height * .5));
      expect(find.text('Lãnh thổ của bệ hạ'), findsNothing);
      expect(find.text('Dạo cảnh'), findsNothing);
      expect(find.textContaining('Còn '), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('giang-son-map')),
          matching: find.byType(ButtonStyleButton),
        ),
        findsNothing,
      );
      await capture(tester, '${size.width.toInt()}-interior');
      await tester.tap(find.byKey(const ValueKey('giang-son-region-frontier')));
      await tester.pumpAndSettle();
      expect(find.text('Bắc ải'), findsOneWidget);
      expect(find.text('Kinh thành'), findsNothing);
      await capture(tester, '${size.width.toInt()}-frontier');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('mobile supports larger text without overflowing controls', (
    tester,
  ) async {
    await mount(tester, size: const Size(320, 568), textScale: 2);
    await tester.pumpAndSettle();
    for (final id in ['interior', 'frontier', 'neighbors']) {
      await tester.tap(find.byKey(ValueKey('giang-son-region-$id')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
