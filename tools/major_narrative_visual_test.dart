// flutter test tools/chain_narrative_visual_test.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import '../test/major_narrative_ui_test.dart' show majorNarrativeState;
import '../test/support/legacy_gateway.dart';

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets('preview major narrative at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final font
          in {
            'Lora': 'assets/fonts/Lora.ttf',
            'BeVietnam': 'assets/fonts/BeVietnamPro-Regular.ttf',
            'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
          }.entries) {
        await (FontLoader(font.key)
          ..addFont(rootBundle.load(font.value))).load();
      }
      final s = majorNarrativeState(2);
      final p = s.petitions.single;
      final store = MemoryGameStore();
      await store.update((a) => a.active = s);
      final controller = GameController(LocalGameGateway(store));
      await controller.load();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: GameApp(initialRoute: 'court', controller: controller),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(GameApp));
      await tester.runAsync(() async {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        for (final path in manifest.listAssets().where(
          (p) => p.endsWith('.webp') && p.contains('/imperial/'),
        )) {
          if (context.mounted) await precacheImage(AssetImage(path), context);
        }
      });
      final open = find.byKey(ValueKey('read-petition-${p.id}'));
      await tester.ensureVisible(open);
      await tester.tap(open);
      await tester.pumpAndSettle();
      final before = controller.state!.toJson();
      Future<void> capture(String state) async {
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final boundary =
              boundaryKey.currentContext!.findRenderObject()
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final output = File(
            'output/major-narrative-${size.width.toInt()}-$state.png',
          );
          output.parent.createSync(recursive: true);
          await output.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('reading');
      final option = find.byKey(const ValueKey('petition-choice-1'));
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('petition-choice-detail-1')),
        findsNothing,
      );
      expect(find.textContaining('không đổi chỉ số ngay'), findsNothing);
      final details = find.byKey(const ValueKey('petition-details-1'));
      await tester.ensureVisible(details);
      await capture('choice');
      expect(controller.state!.toJson(), before);
    });
  }
}
