// flutter test tools/petition_assignee_visual_test.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [
    const Size(1440, 1000),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets('render assignee picker at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await (FontLoader('Lora')
        ..addFont(rootBundle.load('assets/fonts/Lora.ttf'))).load();
      await (FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      await (FontLoader('BeVietnam')
            ..addFont(rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'))
            ..addFont(
              rootBundle.load('assets/fonts/BeVietnamPro-SemiBold.ttf'),
            ))
          .load();
      final store = MemoryGameStore();
      final live = LocalGameGateway(store);
      await live.start(
        name: 'Thiên Hòa',
        runId: 'picker-preview',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((archive) {
        final s = archive.active!;
        s.petitions = [
          Petition(
            id: 'preview',
            definitionId: 'levee_warning',
            openedWeek: s.week,
            deadline: s.week + 1,
          ),
        ];
        s.treasury = 100000;
        for (final p in s.court) {
          p.specialty = 'Quân sự';
        }
        final people =
            s.court.where((p) => !p.isConsort && p.available).take(3).toList();
        for (var i = 0; i < people.length; i++) {
          final p = people[i];
          p.specialty = 'Công trình';
          p.name = ['Hồ Đức Lâm', 'Đào Công Thành', 'Trịnh Bảo Nghi'][i];
          p.role = ['Tri phủ', 'Công bộ', 'Phó tá'][i];
          p.ability = [94, 91, 41][i];
          p.strain = [10, 0, 20][i];
          p.affection = 50;
          p.discontent = 0;
          s.factions[p.faction] = 50;
          p.personalities
            ..clear()
            ..addAll([Personality.grateful, Personality.honest]);
          p.lastInvestigation = null;
        }
      });
      final controller = GameController(live);
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
      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tap(find.byKey(const ValueKey('read-petition-preview')));
      await tap(find.byKey(const ValueKey('petition-choice-0')));
      await tap(find.byKey(const ValueKey('petition-assignee')));
      final context = tester.element(find.byType(GameApp));
      await tester.runAsync(() async {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        for (final path in manifest.listAssets().where(
          (p) =>
              p.endsWith('.webp') &&
              (p.contains('/imperial/') || p.contains('/portraits/')),
        )) {
          if (context.mounted) await precacheImage(AssetImage(path), context);
        }
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final output = File(
          'output/petition-assignee-preview-${size.width.toInt()}.png',
        );
        output.parent.createSync(recursive: true);
        await output.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    });
  }
}
