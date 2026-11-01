import 'support/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets(
      'tax selection stays pending until autumn and UI separates annual tax from seasonal cash at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final game = LocalGameGateway(store);
        await game.start(
          name: 'An',
          runId: 'tax-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((a) {
          final s = a.active!;
          s.completedWeeks = 1;
          s.people = 60;
          s.petitions.clear();
          s.nextMajorWeek = s.nextChainWeek = 10000;
        });
        final controller = GameController(game);
        await controller.load();
        await tester.pumpWidget(
          GameApp(initialRoute: 'court', controller: controller),
        );
        await tester.pumpAndSettle();
        await openSection(tester, 'treasury');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('treasury-open-1')));
        await tester.pumpAndSettle();
        final choice = find.widgetWithText(ChoiceChip, 'Thuế cao');
        await tester.ensureVisible(choice);
        final money = controller.state!.treasury;
        await tester.tap(choice);
        await tester.pumpAndSettle();
        expect(controller.state!.tax, 2);
        expect(controller.state!.effectiveTax, 1);
        expect(controller.state!.treasury, money);
        final policy =
            tester
                .widget<Text>(find.byKey(const ValueKey('tax-policy-timing')))
                .data!;
        expect(policy, contains('Mức đã chọn: cao'));
        expect(policy, contains('mùa Thu · năm 1'));
        final estimate = find.byKey(const ValueKey('treasury-tax-estimate'));
        await tester.ensureVisible(estimate);
        expect(
          tester.widget<Text>(estimate).data,
          contains('Không có thuế trong dự toán mùa này'),
        );
        expect(tester.takeException(), isNull);
        for (var i = 0; i < 2; i++) {
          await store.update((a) {
            a.active!.petitions.clear();
            a.active!.affairsThisWeek = 1;
            a.active!.restThisWeek = 1;
          });
          await controller.act('endWeek');
          await tester.pumpAndSettle();
          if (i == 0) {
            expect(controller.state!.season, 'Thu');
            expect(controller.state!.lastTaxYear, 0);
            expect(
              tester.widget<Text>(estimate).data,
              contains('Khoản này có trong dự toán cuối mùa Thu'),
            );
          }
        }
        final applied =
            tester
                .widget<Text>(find.byKey(const ValueKey('tax-policy-timing')))
                .data!;
        expect(applied, contains('Đã thu năm 1: mức cao'));
        expect(applied, contains('mùa Thu · năm 2'));
        expect(controller.state!.effectiveTax, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
