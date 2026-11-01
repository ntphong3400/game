import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/finance_panel.dart';

Future<void> selectWeek(WidgetTester tester, String label) async {
  final selector = find.byKey(const ValueKey('finance-week-selector'));
  await tester.ensureVisible(selector);
  await tester.tap(selector);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets(
      'ledger compares current cash and forecast, historical periods exclude forecast at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store, seasonal: false);
        await gateway.start(
          name: 'An',
          runId: 'finance-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        Future<void> send(String type, {String target = ''}) async {
          final s = (await gateway.load()).active!;
          await gateway.dispatch(
            GameCommand(
              id: 'ui-${s.revision}',
              runId: s.runId,
              expectedRevision: s.revision,
              type: type,
              target: target,
            ),
          );
        }

        await send('action', target: 'revel');
        for (var i = 0; i < 2; i++) {
          await store.update((a) {
            a.active!.affairsThisWeek = 1;
            a.active!.petitions.clear();
          });
          await send('endWeek');
        }
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.toJson();
        await tester.pumpWidget(
          GameApp(initialRoute: 'treasury', controller: controller),
        );
        await tester.pumpAndSettle();
        expect(find.text('Sổ ngân khố'), findsOneWidget);
        final forecast = BudgetProjection(controller.state!);
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey('finance-closing-estimate')),
              )
              .data,
          '${forecast.closingBalance}',
        );
        await selectWeek(tester, 'tuần 2 · đã chốt');
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('finance-total-income')))
              .data,
          '+26',
        );
        expect(
          find.byKey(const ValueKey('finance-closing-estimate')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('finance-projection')), findsNothing);
        await selectWeek(tester, 'tuần 1 · đã chốt');
        expect(
          find.textContaining('520 + thu 26 − chi 43 = cuối tuần 503'),
          findsOneWidget,
        );
        final other = find.byKey(const ValueKey('finance-row-other'));
        await tester.ensureVisible(other);
        await tester.tap(other);
        await tester.pumpAndSettle();
        expect(find.text('Thưởng nhạc, yến tiệc'), findsOneWidget);
        await selectWeek(tester, 'tuần 3 · đang ghi');
        final income = find.byKey(const ValueKey('finance-row-income'));
        await tester.ensureVisible(income);
        await tester.tap(income);
        await tester.pumpAndSettle();
        expect(find.textContaining('Mức thuế 1 × 8 = 8'), findsOneWidget);
        expect(find.textContaining('chưa ghi vào ngân khố'), findsOneWidget);
        expect(controller.state!.toJson(), before);
        expect((await gateway.load()).active!.toJson(), before);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'unpaid obligations and debt-only adjustments remain available in the chronological ledger',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final engine = GameEngine(seasonal: false);
      final s = engine.start('poor', 'An', 42);
      s.treasury = 0;
      s.people = 40;
      s.tax = 0;
      s.war = 8;
      s.affairsThisWeek = 1;
      s.petitions.clear();
      s.financialWeeks.clear();
      final result = engine.execute(
        s,
        GameCommand(
          id: 'poor-end',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'endWeek',
        ),
      );
      final report = result.financialWeeks.single;
      expect(report.expense, 16);
      expect(report.newDebt, 33);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FinancePanel(state: result),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await selectWeek(tester, 'tuần 1 · đã chốt');
      final detail = find.byKey(const ValueKey('finance-entries-1'));
      await tester.ensureVisible(detail);
      await tester.tap(detail);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Cần trả 36 · đã chi 16 · chưa trả 20'),
        findsOneWidget,
      );
      expect(find.text('Chưa trả'), findsWidgets);
      expect(find.textContaining('Nợ phát sinh: +33'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'posted expense groups and repayment reconcile without counting debt twice',
    (tester) async {
      final s = GameEngine().start('groups', 'An', 42);
      s.debt = 20;
      s.treasury = 95;
      s.financialWeeks.clear();
      final report = FinanceWeek(
        week: s.week,
        openingBalance: 150,
        openingDebt: 30,
        closingBalance: 95,
        closingDebt: 20,
        entries: [
          FinanceEntry(
            title: 'Thu thực nhận',
            detail: '',
            category: 'event',
            amount: 35,
            requiredAmount: 0,
            debtChange: 0,
            balanceAfter: 185,
            debtAfter: 30,
          ),
          FinanceEntry(
            title: 'Chi quyết định',
            detail: '',
            category: 'event',
            amount: -40,
            requiredAmount: 40,
            debtChange: 0,
            balanceAfter: 145,
            debtAfter: 30,
          ),
          FinanceEntry(
            title: 'Chi nền',
            detail: '',
            category: 'budget',
            amount: -40,
            requiredAmount: 40,
            debtChange: 0,
            balanceAfter: 105,
            debtAfter: 30,
          ),
          FinanceEntry(
            title: 'Trả nợ thực tế',
            detail: '',
            category: 'debt',
            amount: -10,
            requiredAmount: 10,
            debtChange: -10,
            balanceAfter: 95,
            debtAfter: 20,
          ),
        ],
      );
      s.financialWeeks.add(report);
      final before = s.toJson();
      final forecast = BudgetProjection(s);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: FinancePanel(state: s)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final (id, amount) in [
        ('income', '+35'),
        ('other', '−40'),
        ('regular', '−40'),
        ('repayment', '−10'),
      ]) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey('finance-row-$id')),
            matching: find.text(amount),
          ),
          findsWidgets,
        );
      }
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('finance-actual-net')))
            .data,
        '−55',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('finance-future-regular')))
            .data,
        '−${forecast.paidExpense - forecast.repayment}',
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('finance-closing-estimate')),
            )
            .data,
        '${forecast.closingBalance}',
      );
      expect(s.toJson(), before);
    },
  );
}
