import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/logic/personality_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine();
  GameState fresh() {
    final s = engine.start('annual-tax', 'An', 42);
    s.petitions.clear();
    s.nextMajorWeek = s.nextChainWeek = 10000;
    s.people = 60;
    s.factions.updateAll((k, v) => 60);
    for (final c in s.court) {
      c.loyalty = 90;
      c.ambition = 10;
    }
    return s;
  }

  GameState send(GameState s, String type, {String option = ''}) =>
      engine.execute(
        s,
        GameCommand(
          id: 'tax-${s.revision}',
          runId: s.runId,
          expectedRevision: s.revision,
          type: type,
          option: option,
        ),
      );
  GameState close(GameState s) {
    s.petitions.clear();
    s.affairsThisWeek = 1;
    s.workThisWeek = 1;
    s.restThisWeek = 1;
    s.rng = 100;
    return send(s, 'endWeek').copy();
  }

  void reconcile(GameState s) {
    for (final w in s.financialWeeks) {
      expect(w.closingBalance, w.openingBalance + w.income - w.expense);
      expect(
        w.closingDebt,
        w.openingDebt + w.entries.fold<int>(0, (n, e) => n + e.debtChange),
      );
    }
  }

  test(
    'spring/summer/winter have no tax or hidden support-based tax income',
    () {
      final s = fresh()..tax = 2;
      for (final turn in [0, 1, 3, 4, 5, 7]) {
        s.completedWeeks = turn;
        expect(budgetIncome(s).map((e) => e.title), [
          'Thu cơ bản của vương quốc',
        ]);
        expect(BudgetProjection(s).totalIncome, 80);
      }
      s.completedWeeks = 2;
      expect(BudgetProjection(s).totalIncome, 520); // 80 + (90 + 20) * 4.
      expect(
        budgetIncome(s).where((e) => e.title.startsWith('Thuế vụ Thu')),
        hasLength(1),
      );
    },
  );

  test(
    'spring medium then summer high collects high once after autumn harvest',
    () {
      var s = fresh();
      expect(s.tax, 1);
      expect(s.effectiveTax, 1);
      s = close(s);
      expect(s.season, 'Hạ');
      expect(s.people, 60);
      expect(s.lastIncome, 80);
      final money = s.treasury;
      s = send(s, 'tax', option: '2');
      expect(s.tax, 2);
      expect(s.effectiveTax, 1);
      expect(s.people, 60);
      expect(s.treasury, money);
      s = close(s);
      expect(s.season, 'Thu');
      expect(s.people, 60);
      expect(s.lastIncome, 80);
      final forecast = BudgetProjection(s), before = s.treasury;
      s = close(s);
      expect(s.season, 'Đông');
      expect(s.lastTaxYear, 1);
      expect(s.lastTaxRate, 2);
      expect(s.lastTaxRevenue, 440);
      expect(s.effectiveTax, 2);
      expect(s.people, 52);
      expect(s.treasury, forecast.closingBalance);
      expect(s.treasury - before, forecast.totalIncome - forecast.paidExpense);
      final taxEntry = s.financialWeeks
          .expand((w) => w.entries)
          .singleWhere((e) => e.title == 'Thuế vụ Thu năm 1 · mức cao');
      expect(taxEntry.amount, 440);
      final levyIndex = s.journal.indexWhere(
        (n) => n.title == 'Chốt thuế vụ Thu năm 1',
      );
      final harvestIndex = s.journal.indexWhere((n) => n.title == 'Mùa gặt');
      expect(
        levyIndex,
        lessThan(harvestIndex),
      ); // Reverse chronological journal.
      reconcile(s);
    },
  );

  test(
    'winter edits are pending until next autumn and do not refund or recollect the previous year',
    () {
      var s =
          fresh()
            ..completedWeeks = 2
            ..tax = 2;
      s = close(s);
      final priorRevenue = s.lastTaxRevenue, priorPeople = s.people;
      s = send(s, 'tax', option: '0');
      expect(s.nextTaxYear, 2);
      expect(s.nextTaxTurn, 7);
      expect(s.tax, 0);
      expect(s.effectiveTax, 2);
      for (var i = 0; i < 3; i++) {
        s = close(s);
        expect(s.lastTaxRevenue, priorRevenue);
        expect(s.lastTaxYear, 1);
        expect(s.people, priorPeople);
        expect(s.lastIncome, 80);
      }
      expect(s.season, 'Thu');
      expect(s.year, 2);
      s = close(s);
      expect(s.lastTaxYear, 2);
      expect(s.lastTaxRate, 0);
      expect(s.lastTaxRevenue, 68); // 52 ~/ 3 * 4.
      expect(s.people, priorPeople + 4);
      expect(s.effectiveTax, 0);
      reconcile(s);
    },
  );

  test(
    'the latest choice made during autumn is the rate locked for that year',
    () {
      var s = fresh()..completedWeeks = 2;
      s = send(s, 'tax', option: '2');
      s = send(s.copy(), 'tax', option: '0');
      expect(s.lastTaxYear, 0);
      expect(s.effectiveTax, 1);
      s = close(s);
      expect(s.lastTaxRate, 0);
      expect(s.lastTaxRevenue, 80);
      expect(s.people, 64);
    },
  );

  test(
    'a settled annual marker blocks a second tax charge and repeated opinion effects',
    () {
      final s =
          fresh()
            ..completedWeeks = 2
            ..tax = 2
            ..lastTaxYear = 1
            ..lastTaxRate = 1
            ..lastTaxRevenue = 260;
      expect(s.autumnTaxDue, false);
      expect(BudgetProjection(s).totalIncome, 80);
      final next = close(s);
      expect(next.lastTaxRevenue, 260);
      expect(next.lastTaxRate, 1);
      expect(next.people, 60);
      expect(next.lastIncome, 80);
    },
  );

  test(
    'high-tax complaints and personality reactions use the applied rate, not the pending choice',
    () {
      final s =
          fresh()
            ..completedWeeks = 20
            ..tax = 2;
      final event = events.firstWhere((e) => e.condition == 'tax');
      expect(engine.eligible(s, event), false);
      expect(PersonalityAssessment(s.court.first, s).tax, 1);
      s.lastTaxRate = 2;
      expect(engine.eligible(s, event), true);
      expect(PersonalityAssessment(s.court.first, s).tax, 2);
    },
  );

  test(
    'pre-update spring collections are credited once without changing old money or RNG on load',
    () {
      final s =
          fresh()
            ..completedWeeks = 1
            ..tax = 2
            ..people = 58;
      final w = s.financialWeeks.first;
      for (final (title, amount) in [
        ('Thuế cao', 90),
        ('Thu thêm theo lòng dân', 20),
      ]) {
        s.treasury += amount;
        w.entries.add(
          FinanceEntry(
            title: title,
            detail: 'old',
            category: 'budget',
            amount: amount,
            requiredAmount: 0,
            debtChange: 0,
            balanceAfter: s.treasury,
            debtAfter: 0,
          ),
        );
      }
      w.closingBalance = s.treasury;
      w.closed = true;
      final old =
          s.toJson()
            ..['rulesVersion'] = 'mvp-0.10.0'
            ..['contentVersion'] = 10;
      for (final key in [
        'lastTaxYear',
        'lastTaxRate',
        'lastTaxRevenue',
        'taxCreditYear',
        'taxCredit',
        'taxSupportCredit',
      ]) {
        old.remove(key);
      }
      var restored = GameState.fromJson(old);
      expect(restored.treasury, s.treasury);
      expect(restored.rng, s.rng);
      expect(restored.taxCredit, 110);
      expect(restored.taxSupportCredit, -2);
      expect(restored.financialWeeks.first.toJson(), w.toJson());
      expect(restored.copy().toJson(), restored.toJson());
      restored = close(restored);
      expect(annualTaxRevenue(restored), 326); // (90 + 19)*4 minus 110 prepaid.
      restored = close(restored);
      expect(restored.lastTaxRevenue, 326);
      expect(restored.people, 52);
      expect(restored.taxCredit, 0);
      expect(restored.taxSupportCredit, 0);
      reconcile(restored);
    },
  );

  test(
    'legacy winter saves wait until the following autumn without retroactive income',
    () {
      final s = fresh()..completedWeeks = 3;
      final old =
          s.toJson()
            ..['rulesVersion'] = 'mvp-0.10.0'
            ..['contentVersion'] = 10;
      for (final key in [
        'lastTaxYear',
        'lastTaxRate',
        'lastTaxRevenue',
        'taxCreditYear',
        'taxCredit',
        'taxSupportCredit',
      ]) {
        old.remove(key);
      }
      final restored = GameState.fromJson(old);
      expect(restored.lastTaxYear, 1);
      expect(restored.nextTaxYear, 2);
      expect(restored.treasury, s.treasury);
      expect(BudgetProjection(restored).totalIncome, 80);
    },
  );

  test(
    'gateway retries and reload preserve the pending/applied split and settle once',
    () async {
      final store = MemoryGameStore();
      final prepared = LocalGameGateway(store);
      await prepared.start(
        name: 'An',
        runId: 'annual-tax',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((a) {
        a.active =
            fresh()
              ..completedWeeks = 2
              ..tax = 2
              ..affairsThisWeek = 1
              ..rng = 100;
      });
      final command = GameCommand(
        id: 'settle-autumn',
        runId: 'annual-tax',
        expectedRevision: 0,
        type: 'endWeek',
      );
      final settled = await prepared.dispatch(command);
      final expected = jsonEncode(settled.toJson());
      expect(jsonEncode((await prepared.dispatch(command)).toJson()), expected);
      expect(jsonEncode((await prepared.load()).toJson()), expected);
      expect(settled.active!.lastTaxRevenue, 440);
      final pending = await prepared.dispatch(
        GameCommand(
          id: 'winter-rate',
          runId: 'annual-tax',
          expectedRevision: settled.active!.revision,
          type: 'tax',
          option: '0',
        ),
      );
      final loaded = (await prepared.load()).active!;
      expect(loaded.tax, 0);
      expect(loaded.lastTaxRate, 2);
      expect(loaded.lastTaxYear, 1);
      expect(loaded.toJson(), pending.active!.toJson());
    },
  );
}
