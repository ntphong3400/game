// Render the real Flutter widgets with bundled fonts, without browser access.
// flutter test tools/court_visual_test.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [
    const Size(1672, 940),
    const Size(1280, 720),
    const Size(390, 844),
  ]) {
    testWidgets('render memorial desk at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await (FontLoader('Lora')
        ..addFont(rootBundle.load('assets/fonts/Lora.ttf'))).load();
      await (FontLoader('Charm')
        ..addFont(rootBundle.load('assets/fonts/Charm-Regular.ttf'))).load();
      await (FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      await (FontLoader('BeVietnam')
            ..addFont(rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'))
            ..addFont(
              rootBundle.load('assets/fonts/BeVietnamPro-SemiBold.ttf'),
            ))
          .load();
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store);
      await gateway.start(
        name: 'Thiên Hòa',
        runId: 'art-render',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((a) {
        final s = a.active!;
        s.affairsThisWeek = 1;
        s.petitions = [
          for (final title in [
            'Ruộng trũng nuôi cá',
            'Vết nứt bên dòng Đại Hà',
            'Đường buôn dọc bờ hồ',
          ])
            Petition(
              id: title,
              definitionId: events.firstWhere((e) => e.title == title).id,
              openedWeek: s.week,
              deadline: s.week,
            ),
        ];
      });
      final controller = GameController(gateway);
      await controller.load();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: GameApp(controller: controller, initialRoute: 'court'),
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
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'docs/court-watercolor-${size.width.toInt()}-$suffix.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        expect(tester.takeException(), isNull);
      }

      await capture('reading');
      if (size.width == 1672) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('petition-card-Ruộng trũng nuôi cá')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'docs/court-memorial-paper.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      if (size.width < 700) {
        final open = find.byKey(
          const ValueKey('read-petition-Ruộng trũng nuôi cá'),
        );
        await tester.ensureVisible(open);
        await tester.tap(open);
        await tester.pumpAndSettle();
      }
      final choice = find.byKey(const ValueKey('petition-choice-1'));
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      // Preserve the top of the reading surface where the illustration is visible.
      if (size.width >= 700) {
        final title = find.byKey(const ValueKey('court-reading'));
        Scrollable.ensureVisible(tester.element(title), alignment: 0);
        await tester.pump();
        await tester.pumpAndSettle();
      }
      await capture('selected');
      if (size.width >= 700) {
        final confirm = find.byKey(const ValueKey('confirm-petition'));
        await tester.ensureVisible(confirm);
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('approval-seal')), findsOneWidget);
        await capture('approved');
      }
    });
  }
}
