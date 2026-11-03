import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/food_ledger_rules.dart';
import 'package:van_tue/game/logic/population_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/locality_routes.dart';
import 'package:van_tue/game/presentation/widgets/resource_ledger_panel.dart';
import 'food_ledger_test.dart' show ledgerState, ledgerSend, ledgerClose;

GameState foodLedgerUiState() {
  var s = ledgerState();
  s = ledgerSend(s, 'population', target: 'supply_army');
  s = ledgerClose(s);
  s.rng = 1;
  s = ledgerSend(s, 'action', target: 'buy_grain', option: 'treasurer');
  s = ledgerSend(s, 'population', target: 'supply_army');
  s.petitions.clear();
  s.midSeasonDelivered = true;
  return s;
}

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(844, 390),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets(
      'granary shares the ledger, switches seasons read-only and retains scoped actions at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final s = foodLedgerUiState();
        await store.update((a) => a.active = s);
        final gateway = LocalGameGateway(store);
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.toJson();
        final p = FoodProjection(controller.state!);
        await tester.pumpWidget(
          GameApp(
            controller: controller,
            initialRoute: LocalityPlace.granary.route,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ResourceLedgerPanel), findsOneWidget);
        expect(find.text('Sổ kho lương'), findsOneWidget);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('food-closing-estimate')))
              .data,
          whole(p.closingBalance),
        );
        Future<void> tap(Finder finder) async {
          await tester.ensureVisible(finder);
          await tester.pumpAndSettle();
          await tester.tap(finder);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        Future<void> select(int turn, String status) async {
          await tap(find.byKey(const ValueKey('food-week-selector')));
          await tap(find.text('${s.date(turn)} · $status').last);
        }

        await select(1, 'đã chốt');
        expect(
          find.byKey(const ValueKey('food-closing-estimate')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('food-projection')), findsNothing);
        final first = s.foodWeeks.first;
        expect(
          find.textContaining(
            'nhập/tăng ${whole(first.income)} − xuất/giảm ${whole(first.expense)}',
          ),
          findsWidgets,
        );
        await tap(find.byKey(const ValueKey('food-entries-1')));
        expect(find.textContaining('Đã đối trừ 20.000'), findsWidgets);
        await select(2, 'đang ghi');
        expect(
          find.byKey(const ValueKey('food-prepaid-estimate')),
          findsOneWidget,
        );
        expect(controller.state!.toJson(), before);
        expect((await gateway.load()).active!.toJson(), before);
        for (final id in ['buy_grain', 'relief', 'sell_surplus']) {
          expect(find.byKey(ValueKey('action-$id')), findsOneWidget);
        }
        expect(
          find.byKey(const ValueKey('action-collect_arrears')),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'buying from Kho Luong posts once after confirmation and refreshes the shared ledger',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      await store.update((a) => a.active = ledgerState());
      final controller = GameController(LocalGameGateway(store));
      await controller.load();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        GameApp(
          controller: controller,
          initialRoute: LocalityPlace.granary.route,
        ),
      );
      await tester.pumpAndSettle();
      final before = controller.state!.toJson();
      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tap(find.byKey(const ValueKey('action-buy_grain')));
      await tap(find.byKey(const ValueKey('assign-buy_grain-treasurer')));
      await tap(find.text('Cân nhắc lại'));
      expect(controller.state!.toJson(), before);
      await tap(find.byKey(const ValueKey('action-buy_grain')));
      await tap(find.byKey(const ValueKey('assign-buy_grain-treasurer')));
      await tap(find.text('Xác nhận giao việc'));
      final s = controller.state!;
      expect(s.revision, 1);
      expect(s.foodWeeks.single.entries, hasLength(1));
      expect(s.foodWeeks.single.income, s.grain - 4000000);
      final amount = find.byKey(const ValueKey('food-total-income'));
      await tester.ensureVisible(amount);
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(amount).data,
        '+${whole(s.foodWeeks.single.income)}',
      );
      expect((await store.read()).active!.toJson(), s.toJson());
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'viewing a save without food history does not manufacture an opening balance',
    (tester) async {
      final s =
          ledgerState()
            ..revision = 5
            ..foodWeeks.clear();
      final store = MemoryGameStore();
      await store.update((a) => a.active = s);
      final gateway = LocalGameGateway(store),
          controller = GameController(LocalGameGateway(store));
      await controller.load();
      addTearDown(controller.dispose);
      final before = controller.state!.toJson();
      await tester.pumpWidget(
        GameApp(
          controller: controller,
          initialRoute: LocalityPlace.granary.route,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('các khoản quá khứ không được dựng lại'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('food-opening-balance')))
            .data,
        '—',
      );
      expect(controller.state!.toJson(), before);
      expect((await gateway.load()).active!.foodWeeks, isEmpty);
    },
  );
}
