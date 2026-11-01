// Render the real Flutter widgets with bundled fonts, without browser access.
// flutter test tools/kingdom_visual_test.dart
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
import 'package:van_tue/game/models/game_state.dart';

void main() {
  for (final (size, populated) in [
    for (final size in [
      const Size(1672, 1000),
      const Size(1440, 900),
      const Size(390, 844),
    ])
      for (final populated in [false, true]) (size, populated),
  ]) {
    testWidgets(
      'render focused national affairs at $size, populated=$populated',
      (tester) async {
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
              ..addFont(
                rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'),
              )
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
        if (populated) {
          await store.update((archive) {
            final s = archive.active!;
            s.projects = [
              WorkOrder(
                id: 'farm',
                kind: 'farm',
                officerId: 'treasurer',
                startedWeek: 1,
                duration: 3,
                progress: 1,
              ),
            ];
            s.pending = [
              Consequence(
                kind: 'envoy',
                title: 'Sứ đoàn phương Bắc',
                dueWeek: 2,
              ),
            ];
            s.obligations = [
              Obligation(
                id: 'borrow',
                kind: 'borrow',
                title: 'Hoàn trả khoản vay thế gia',
                nextWeek: 2,
                remaining: 3,
                amount: 50,
              ),
              Obligation(
                id: 'income',
                kind: 'income',
                title: 'Nguồn thu thương lộ',
                nextWeek: 2,
                remaining: 2,
                income: 8,
              ),
            ];
            s.outcomes = [
              const OutcomeReport(
                id: 'report',
                week: 1,
                title: 'Cứu tế vùng ven sông',
                status: 'success',
                detail:
                    'Lương thực đã đến tay dân chúng. Lòng dân được củng cố.',
                changes: {'Lòng dân': 5},
              ),
            ];
          });
        }
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: GameApp(controller: controller, initialRoute: 'kingdom'),
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
            await File(
              'docs/kingdom-focused-${size.width.toInt()}-${populated ? 'active-' : ''}$suffix.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
          expect(tester.takeException(), isNull);
        }

        await capture('orders');
        if (size.width == 1672 && populated) {
          final rail = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('kingdom-dossier-rail')),
          );
          await tester.runAsync(() async {
            final image = await rail.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              'docs/kingdom-dossiers-panel.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
          final card = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('kingdom-document-govern')),
          );
          await tester.runAsync(() async {
            final image = await card.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              'docs/kingdom-watercolor-card.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        for (final (section, suffix) in [
          if (populated) (1, 'progress'),
          (2, 'obligations'),
          (3, 'emergency'),
          (4, 'results'),
        ]) {
          await tester.tap(find.byKey(ValueKey('kingdom-open-$section')));
          await tester.pumpAndSettle();
          if (size.width < 700 || populated) await capture(suffix);
          await tester.tap(find.byKey(const ValueKey('close-kingdom-detail')));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
