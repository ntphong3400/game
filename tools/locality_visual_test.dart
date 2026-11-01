// Render the real locality page with bundled fonts and artwork.
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
import 'package:van_tue/game/presentation/widgets/locality_hub.dart';
import 'package:van_tue/game/presentation/widgets/locality_routes.dart';

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(1024, 768),
    const Size(844, 390),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets('render locality at $size', (tester) async {
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
        runId: 'locality-preview',
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
      await tester.ensureVisible(find.byKey(const ValueKey('giang-son-farms')));
      await tester.tap(find.byKey(const ValueKey('giang-son-farms')));
      await tester.pumpAndSettle();
      expect(find.byType(LocalityHub), findsOneWidget);
      final context = tester.element(find.byType(GameApp));
      await tester.runAsync(() async {
        for (final asset in [
          'assets/images/dia-phuong-watercolor.webp',
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
      final boundary =
          boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'output/dia-phuong-implementation/locality-${size.width.toInt()}x${size.height.toInt()}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      if (size.width == 1440 || size.width == 320) {
        for (final place in LocalityPlace.values) {
          final landmark = find.byKey(
            ValueKey('locality-location-${place.name}'),
          );
          await Scrollable.ensureVisible(
            tester.element(landmark),
            alignment: .5,
          );
          await tester.pumpAndSettle();
          await tester.tap(landmark);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              'output/dia-phuong-implementation/${place.name}-${size.width.toInt()}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
          await tester.tap(find.byKey(const ValueKey('locality-detail-back')));
          await tester.pumpAndSettle();
        }
      }
      debugDisableShadows = previousShadows;
      expect(tester.takeException(), isNull);
    });
  }
}
