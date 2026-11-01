// Capture actual Flutter meeting pages with bundled fonts and complete artwork.
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
import 'package:van_tue/game/presentation/meeting_scenes.dart';

void main() {
  for (final id in [
    'consort_mai',
    'consort_yen',
    'general',
    'doctor',
    'prince',
  ]) {
    for (final size in [const Size(1440, 900), const Size(390, 844)]) {
      testWidgets('render $id meeting at $size', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final shadows = debugDisableShadows;
        debugDisableShadows = false;
        addTearDown(() => debugDisableShadows = shadows);
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
          runId: 'full-cast-preview',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update(
          (archive) => archive.active!.court.removeWhere((c) => c.id != id),
        );
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final person = controller.state!.court.single;
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: GameApp(
              controller: controller,
              initialRoute: person.isConsort ? 'harem' : 'people',
            ),
          ),
        );
        await tester.pumpAndSettle();
        final meet = find.byKey(ValueKey('meet-person-$id'));
        await tester.ensureVisible(meet);
        await tester.tap(meet);
        await tester.pumpAndSettle();
        final scene = meetingSceneFor(person);
        final context = tester.element(find.byType(GameApp));
        await tester.runAsync(() async {
          for (final asset in [
            scene.backgroundAsset,
            scene.characterAsset,
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
          final file = File(
            'output/meeting-generation/screenshots/$id-${size.width.toInt()}x${size.height.toInt()}.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        debugDisableShadows = shadows;
        expect(tester.takeException(), isNull);
      });
    }
  }
}
