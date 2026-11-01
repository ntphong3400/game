import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets(
      'gold starting balance and food quote match the committed payment at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final actualGateway = LocalGameGateway(store);
        await actualGateway.start(
          name: 'An',
          runId: 'gold-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((a) {
          final s = a.active!;
          s.rng = 1;
          final c = s.court.firstWhere((c) => c.id == 'treasurer');
          c.ability = c.integrity = c.loyalty = c.affection = 100;
          c.discontent = c.strain = 0;
          c.specialty = 'Kinh tế';
          c.personalities
            ..clear()
            ..addAll([Personality.honest, Personality.dutiful]);
          c.personalityContacts = 6;
        });
        final controller = GameController(actualGateway);
        await controller.load();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          GameApp(controller: controller, initialRoute: 'treasury'),
        );
        await tester.pumpAndSettle();
        expect(find.text('50.000'), findsWidgets);
        expect(controller.state!.treasury, 50000);
        await tester.tap(find.byKey(const ValueKey('treasury-open-3')));
        await tester.pumpAndSettle();
        final buy = find.byKey(const ValueKey('action-buy_grain'));
        await tester.ensureVisible(buy);
        await tester.tap(buy);
        await tester.pumpAndSettle();
        final assignee = find.byKey(
          const ValueKey('assign-buy_grain-treasurer'),
        );
        await tester.ensureVisible(assignee);
        await tester.tap(assignee);
        await tester.pumpAndSettle();
        expect(find.textContaining('4.500 lượng vàng'), findsWidgets);
        final confirm = find.text('Xác nhận giao việc');
        await tester.ensureVisible(confirm);
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(controller.state!.treasury, 45500);
        expect(controller.state!.grain, greaterThan(4000000));
        expect((await actualGateway.load()).active!.treasury, 45500);
        expect(
          controller.state!.financialWeeks.single.entries.first.amount,
          -4500,
        );
      },
    );
  }
}
