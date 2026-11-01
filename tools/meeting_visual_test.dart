// Render the real Ngoc Lan meeting page with bundled fonts and artwork.
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
    const Size(1024, 768),
    const Size(844, 390),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets('render Ngoc Lan meeting at $size', (tester) async {
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
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store);
      await gateway.start(
        name: 'Thiên Hòa',
        runId: 'meeting-preview',
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
          child: GameApp(controller: controller, initialRoute: 'harem'),
        ),
      );
      await tester.pumpAndSettle();
      final meet = find.byKey(const ValueKey('meet-person-consort_lan'));
      await tester.ensureVisible(meet);
      await tester.tap(meet);
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(GameApp));
      await tester.runAsync(() async {
        for (final asset in [
          'assets/images/harem-interior.webp',
          'assets/images/meetings/ngoc-lan-fullbody-v1.png',
          'assets/images/imperial/parchment.webp',
          'assets/images/imperial/icons.webp',
          'assets/images/imperial/jade-texture.webp',
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
          'output/meeting-ngoc-lan/meeting-${size.width.toInt()}x${size.height.toInt()}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      Future<void> captureContributions(String rank) async {
        final header = find.text('Đóng góp hậu cung');
        for (final expanded in [false, true]) {
          await tester.ensureVisible(header);
          if (expanded) await tester.tap(header);
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              'output/meeting-ngoc-lan/contributions-${expanded ? 'details-' : ''}$rank-${size.width.toInt()}x${size.height.toInt()}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.ensureVisible(header);
        await tester.tap(header);
        await tester.pumpAndSettle();
      }

      await captureContributions('candidate');
      final before = controller.state!.toJson();
      for (final id in [
        'audience',
        'reward',
        'investigate',
        'invite',
        'expel',
      ]) {
        final action = find.byKey(ValueKey('meeting-action-$id'));
        await tester.ensureVisible(action);
        await tester.tap(action);
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'output/meeting-ngoc-lan/confirm-$id-${size.width.toInt()}x${size.height.toInt()}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.tap(find.byKey(const ValueKey('meeting-action-cancel')));
        await tester.pumpAndSettle();
        expect(controller.state!.toJson(), before);
        expect(tester.takeException(), isNull);
      }
      for (final rank in ['consort', 'queen']) {
        await store.update((a) {
          final c = a.active!.court.firstWhere((c) => c.id == 'consort_lan');
          c.inHarem = true;
          c.queen = rank == 'queen';
        });
        await controller.load();
        await tester.pumpAndSettle();
        await captureContributions(rank);
        final snapshot = controller.state!.toJson();
        final action = find.byKey(const ValueKey('meeting-action-demote'));
        await tester.ensureVisible(action);
        await tester.tap(action);
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'output/meeting-ngoc-lan/confirm-demote-$rank-${size.width.toInt()}x${size.height.toInt()}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.tap(find.byKey(const ValueKey('meeting-action-cancel')));
        await tester.pumpAndSettle();
        expect(controller.state!.toJson(), snapshot);
        expect(tester.takeException(), isNull);
      }
      await store.update((a) {
        final c = a.active!.court.firstWhere((c) => c.id == 'consort_lan');
        c.plot = 43;
        c.discontent = 67;
      });
      await controller.load();
      await tester.pumpAndSettle();
      final investigate = find.byKey(
        const ValueKey('meeting-action-investigate'),
      );
      await tester.ensureVisible(investigate);
      await tester.tap(investigate);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('meeting-action-confirm')));
      await tester.pumpAndSettle();
      expect(
        controller.state!.court
            .firstWhere((c) => c.id == 'consort_lan')
            .lastInvestigation,
        isNull,
      );
      for (var i = 0; i < 2; i++) {
        expect(await controller.act('endWeek'), true);
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(find.byKey(const ValueKey('meeting-plot')));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'output/meeting-ngoc-lan/investigated-${size.width.toInt()}x${size.height.toInt()}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      debugDisableShadows = previousShadows;
      expect(tester.takeException(), isNull);
    });
  }
}
