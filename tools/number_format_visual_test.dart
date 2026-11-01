import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import '../test/number_format_ui_test.dart' show numberFixture;

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets('number formatting preview at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final font in [
        ('Lora', 'assets/fonts/Lora.ttf'),
        ('BeVietnam', 'assets/fonts/BeVietnamPro-Regular.ttf'),
        ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
      ]) {
        await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
      }
      final (controller, store) = await numberFixture();
      addTearDown(controller.dispose);
      final before = (await store.read()).toJson();
      final boundary = GlobalKey();
      Future<void> capture(String name) async {
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await render.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final directory = Directory('output/number-format');
          directory.createSync(recursive: true);
          await File(
            '${directory.path}/${size.width.toInt()}-$name.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      for (final route in ['treasury', 'population', 'journal']) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: GameApp(controller: controller, initialRoute: route),
          ),
        );
        await capture(route);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: GameApp(controller: controller, initialRoute: 'treasury'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('treasury-open-3')));
      await tester.pumpAndSettle();
      final buy = find.byKey(const ValueKey('action-buy_grain'));
      await tester.ensureVisible(buy);
      await tester.tap(buy);
      await tester.pumpAndSettle();
      final worker = find.byKey(const ValueKey('assign-buy_grain-treasurer'));
      await tester.ensureVisible(worker);
      await tester.tap(worker);
      await capture('purchase');
      expect((await store.read()).toJson(), before);
    });
  }
}
