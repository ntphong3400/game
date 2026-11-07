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
import '../test/chain_settlement_test.dart' show settlementState;
import '../test/chain_settlement_ui_test.dart' show openSettlement;
import '../test/support/legacy_gateway.dart';

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets('preview final refugee petition at $size', (tester) async {
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
      final s =
          settlementState('refugees')
            ..seasonal = true
            ..goldStandard = true
            ..treasury = 50000;
      final arc = s.chains.single;
      arc.stage = arc.completedSteps = 3;
      arc.settlementVersion = 2;
      arc.currencyScale = 100;
      arc.cashSpent = 4000;
      arc.investedValue = 11000;
      arc.decisions = [2, 2, 1];
      arc.decisionLabels = [
        'Giao các chủ điền tự tổ chức tiếp nhận, uy quyền −3 (mùa Hạ · năm 1)',
        'Huy động dân sở tại mở đường và chỉnh đất, lòng dân −5 (mùa Thu · năm 1)',
        'Cấp 4.000 lượng vàng để hoàn thành phần việc (mùa Đông · năm 1)',
      ];
      final p = s.petitions.single;
      p.definitionId = 'chain:refugees:3';
      p.storyStage = 3;
      p.deadline = s.week + 1;
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
      await openSettlement(tester, controller);
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
            'output/chain-narrative-${size.width.toInt()}-$state.png',
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
        tester
            .widget<Text>(find.byKey(const ValueKey('petition-impact-cost')))
            .data,
        '−5.000',
      );
      expect(find.textContaining('Dự kiến hoàn thành'), findsNothing);
      final details = find.byKey(const ValueKey('petition-details-1'));
      await tester.ensureVisible(details);
      await capture('choice');
      final stop = find.byKey(const ValueKey('petition-choice-0'));
      await tester.ensureVisible(stop);
      await tester.tap(stop);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('petition-details-0')),
      );
      expect(
        find.byKey(const ValueKey('petition-impact-points')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('petition-choice-detail-0')),
        findsNothing,
      );
      await capture('stop');
      expect(controller.state!.toJson(), before);
    });
  }
}
