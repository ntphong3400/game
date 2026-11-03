// Capture the real shared ledgers with bundled fonts and art.
// flutter test tools/food_ledger_visual_test.dart
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
import '../test/food_ledger_ui_test.dart' show foodLedgerUiState;

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    for (final route in ['local-granary', if (size.width == 1440) 'treasury']) {
      testWidgets('capture $route at $size', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await (FontLoader('Lora')
          ..addFont(rootBundle.load('assets/fonts/Lora.ttf'))).load();
        await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
        await (FontLoader('BeVietnam')
              ..addFont(
                rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'),
              )
              ..addFont(
                rootBundle.load('assets/fonts/BeVietnamPro-SemiBold.ttf'),
              ))
            .load();
        final store = MemoryGameStore();
        await store.update((a) => a.active = foodLedgerUiState());
        final controller = GameController(LocalGameGateway(store));
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.toJson();
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: GameApp(controller: controller, initialRoute: route),
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
          await tester.pump();
          final boundary =
              boundaryKey.currentContext!.findRenderObject()
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final directory = Directory('output/food-ledger')
              ..createSync(recursive: true);
            await File(
              '${directory.path}/$route-${size.width.toInt()}-$suffix.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
          expect(tester.takeException(), isNull);
        }

        await capture('ledger');
        if (route == 'local-granary') {
          final row = find.byKey(const ValueKey('food-row-regular'));
          await tester.ensureVisible(row);
          await tester.tap(row);
          await tester.pumpAndSettle();
          await capture('consumption');
          final offsets = find.byKey(const ValueKey('food-prepaid'));
          await tester.ensureVisible(offsets);
          await tester.pumpAndSettle();
          await capture('offsets');
        }
        expect(controller.state!.toJson(), before);
      });
    }
  }
}
