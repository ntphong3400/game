// Reproducible screenshots of Giang Sơn using real widgets, fonts and assets.
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

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(1280, 720),
    const Size(1024, 768),
    const Size(844, 390),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets('render Giang Sơn at $size', (tester) async {
      final previousShadows = debugDisableShadows;
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = previousShadows);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final (family, path) in [
        ('Lora', 'assets/fonts/Lora.ttf'),
        ('BeVietnam', 'assets/fonts/BeVietnamPro-Regular.ttf'),
        ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
      ]) {
        await (FontLoader(family)..addFont(rootBundle.load(path))).load();
      }
      final gateway = LocalGameGateway(MemoryGameStore());
      await gateway.start(
        name: 'Thiên Hòa',
        runId: 'map-preview',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      final controller = GameController(gateway);
      await controller.load();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: GameApp(controller: controller),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(GameApp));
      await tester.runAsync(() async {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        for (final asset in manifest.listAssets().where(
          (s) => s.endsWith('.webp'),
        )) {
          await precacheImage(AssetImage(asset), context);
        }
      });
      await tester.pumpAndSettle();
      Future<void> capture(String suffix) async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'docs/giang-son-${size.width.toInt()}-$suffix.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        expect(tester.takeException(), isNull);
      }

      await capture('preview');
      if (size.width == 1440 || size.width == 1024 || size.width == 390) {
        await tester.tap(find.byKey(const ValueKey('giang-son-palace')));
        await tester.pumpAndSettle();
        await capture('palace');
        if (size.width >= 720) {
          await tester.tap(find.byKey(const ValueKey('citadel-location-court')));
          await tester.pumpAndSettle();
          await capture('court');
        }
      }
      debugDisableShadows = previousShadows;
    });
  }
}
