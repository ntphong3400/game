import 'package:flutter/material.dart';
import 'support/navigation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'palace_test.dart' show freshPalace;

void main() {
  testWidgets(
    'herbal discount appears in treatment UI and matches actual debit and ledger',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      await store.update((a) {
        a.active = freshPalace()..treasury = 15;
        a.active!.palaceEffects.add(
          PalaceEffect(
            kind: 'herbs',
            personId: 'wife-0',
            startsTurn: 1,
            endsTurn: 6,
            amount: 10,
            uses: 3,
          ),
        );
      });
      final controller = GameController(LocalGameGateway(store));
      await controller.load();
      await tester.pumpWidget(
        GameApp(initialRoute: 'court', controller: controller),
      );
      await tester.pumpAndSettle();
      await openSection(tester, 'health');
      await tester.pumpAndSettle();
      final price = find.textContaining(
        'Chi 15 tiền (gốc 25, dược liệu giảm 10)',
      );
      await tester.ensureVisible(price);
      expect(price, findsOneWidget);
      final treatment = find.byKey(const ValueKey('action-treat'));
      await tester.ensureVisible(treatment);
      expect(tester.widget<IconButton>(treatment).onPressed, isNotNull);
      await tester.tap(treatment);
      await tester.pumpAndSettle();
      expect(controller.state!.treasury, 0);
      expect(controller.state!.points, 11);
      expect(controller.state!.palaceEffects.single.uses, 2);
      expect(controller.state!.financialWeeks.last.entries.last.amount, -15);
      expect(controller.state!.journal.first.text, contains('Đã chi 15 tiền'));
      expect(tester.takeException(), isNull);
    },
  );
}
