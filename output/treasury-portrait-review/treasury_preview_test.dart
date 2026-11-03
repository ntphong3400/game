// Render the real treasury UI with bundled art/fonts and an isolated sample save.
// flutter test tools/treasury_visual_test.dart
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
    const Size(390, 844),
  ]) {
    testWidgets('render treasury ledger and dossiers at $size', (tester) async {
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
      final gateway = LocalGameGateway(store);
      await gateway.start(
        name: 'Thiên Hòa',
        runId: 'treasury-render',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((archive) {
        final s = archive.active!;
        s.completedWeeks = 4;
        s.treasury = 100;
        s.debt = 30;
        s.grain = 85;
        s.levee = 72;
        s.tax = 1;
        s.financialWeeks.clear();
        s.financialWeeks.add(
          FinanceWeek(
            week: s.week,
            openingBalance: 150,
            openingDebt: 30,
            closingBalance: 100,
            closingDebt: 30,
            entries: [
              FinanceEntry(
                title: 'Truy thu thuế tồn',
                detail: 'Tiền đã chuyển vào ngân khố.',
                category: 'action',
                amount: 35,
                requiredAmount: 0,
                debtChange: 0,
                balanceAfter: 185,
                debtAfter: 30,
              ),
              FinanceEntry(
                title: 'Cấp vốn thương mại',
                detail: 'Vốn ứng trước.',
                category: 'action',
                amount: -40,
                requiredAmount: 40,
                debtChange: 0,
                balanceAfter: 145,
                debtAfter: 30,
              ),
              FinanceEntry(
                title: 'Bổ sung kho lương',
                detail: 'Chi thu mua lương thực.',
                category: 'action',
                amount: -45,
                requiredAmount: 45,
                debtChange: 0,
                balanceAfter: 100,
                debtAfter: 30,
              ),
            ],
          ),
        );
        s.projects = [
          WorkOrder(
            id: 'trade',
            kind: 'commerce',
            officerId: 'treasurer',
            startedWeek: s.week,
            duration: 5,
            progress: 0,
          ),
        ];
        s.pending = [
          Consequence(
            kind: 'event',
            title: 'Khoản thu công văn chờ chuyển',
            dueWeek: s.week + 1,
          ),
        ];
      });
      final controller = GameController(gateway);
      await controller.load();
      addTearDown(controller.dispose);
      final before = controller.state!.toJson();
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: GameApp(controller: controller, initialRoute: 'treasury'),
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
            'output/treasury-portrait-review/treasury-${size.width.toInt()}-$suffix.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        expect(tester.takeException(), isNull);
      }

      await capture('ledger');
      final row = find.byKey(const ValueKey('finance-row-regular'));
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pumpAndSettle();
      if (size.width == 1440) await capture('ledger-detail');
      for (var i = 1; i <= 4; i++) {
        await tester.ensureVisible(find.byKey(ValueKey('treasury-open-$i')));
        await tester.tap(find.byKey(ValueKey('treasury-open-$i')));
        await tester.pumpAndSettle();
        await capture(['', 'tax', 'revenue', 'stock', 'progress'][i]);
        await tester.tap(find.byKey(const ValueKey('section-back')));
        await tester.pumpAndSettle();
      }
      expect(controller.state!.toJson(), before);
    });
  }
}
