import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState fresh({int cash = 520, int debt = 0}) {
    final s = engine.start('finance', 'An', 42);
    s.treasury = cash;
    s.debt = debt;
    s.petitions.clear();
    s.financialWeeks.clear();
    s.affairsThisWeek = 1;
    return s;
  }

  GameState send(
    GameState s,
    String type, {
    String target = '',
    String option = '',
  }) => engine.execute(
    s,
    GameCommand(
      id: 'cash-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );
  void roll(GameState s, int n) {
    s.rng = n == 0 ? 100 : n * 31 % 100;
  }

  void balanced(GameState s) {
    FinanceWeek? previous;
    for (final report in s.financialWeeks) {
      if (previous != null) {
        expect(report.openingBalance, previous.closingBalance);
        expect(report.openingDebt, previous.closingDebt);
      }
      var cash = report.openingBalance;
      var debt = report.openingDebt;
      for (final e in report.entries) {
        cash += e.amount;
        debt += e.debtChange;
        expect(e.balanceAfter, cash, reason: e.title);
        expect(e.debtAfter, debt, reason: e.title);
        expect(cash, greaterThanOrEqualTo(0));
        expect(debt, greaterThanOrEqualTo(0));
        if (e.requiredAmount > 0) {
          expect(-e.amount, inInclusiveRange(0, e.requiredAmount));
        }
      }
      expect(cash, report.closingBalance);
      expect(debt, report.closingDebt);
      expect(report.openingBalance + report.income - report.expense, cash);
      expect(report.openingDebt + report.newDebt - report.debtReduction, debt);
      previous = report;
    }
    expect(previous!.closingBalance, s.treasury);
    expect(previous.closingDebt, s.debt);
    expect(s.copy().toJson(), s.toJson());
  }

  test('new game opens a complete ledger without changing money or random', () {
    final s = engine.start('new', 'An', 42);
    final report = s.financialWeeks.single;
    expect(report.week, 1);
    expect(report.openingBalance, 520);
    expect(report.entries, isEmpty);
    expect(report.partial, false);
    balanced(s);
  });

  test(
    'tax, war, harem and repayment formulas match actual weekly settlements',
    () {
      final s =
          fresh(cash: 100, debt: 30)
            ..tax = 2
            ..war = 2
            ..people = 65;
      for (final c in s.court.where((c) => c.isConsort).take(2)) {
        c.inHarem = true;
      }
      final snapshot = jsonEncode(s.toJson());
      final projection = BudgetProjection(s);
      expect(jsonEncode(s.toJson()), snapshot);
      expect(projection.income.map((i) => i.amount), [13, 16, 5]);
      expect(projection.expenses.map((i) => i.amount), [18, 5, 12]);
      expect(projection.totalIncome, 34);
      expect(projection.requiredExpense, 35);
      expect(projection.repayment, 10);
      expect(projection.closingBalance, 89);
      expect(projection.closingDebt, 20);
      final result = send(s, 'endWeek');
      final report = result.financialWeeks.single;
      expect(report.closed, true);
      expect(report.income, 34);
      expect(report.expense, 45);
      expect(report.closingBalance, projection.closingBalance);
      expect(report.closingDebt, projection.closingDebt);
      expect(
        report.entries
            .firstWhere((e) => e.title == 'Thu thêm theo lòng dân')
            .detail,
        contains('65 ÷ 12'),
      );
      expect(
        report.entries
            .firstWhere((e) => e.title == 'Triều đình và hậu cung')
            .detail,
        contains('2 phi tần/hoàng hậu'),
      );
      expect(report.entries.last.debtChange, -10);
      balanced(result);
    },
  );

  test(
    'unpaid expenses are debt, not fake spending, and priority changes who gets paid',
    () {
      for (final priority in ['army', 'people']) {
        final s =
            fresh(cash: 0)
              ..tax = 0
              ..people = 1
              ..war = 8
              ..priority = priority;
        final projection = BudgetProjection(s);
        expect(projection.totalIncome, 13);
        expect(projection.requiredExpense, 49);
        expect(projection.shortfall, 36);
        final result = send(s, 'endWeek');
        final report = result.financialWeeks.single;
        expect(report.income, 13);
        expect(report.expense, 13);
        expect(report.newDebt, 36);
        expect(report.closingBalance, 0);
        expect(report.closingDebt, 36);
        final army = report.entries.firstWhere(
          (e) => e.title == 'Duy trì quân đội',
        );
        final people = report.entries.firstWhere(
          (e) => e.title == 'Dân sinh thường lệ',
        );
        expect(army.requiredAmount, 36);
        expect(army.amount, priority == 'army' ? -13 : -8);
        expect(people.amount, priority == 'army' ? 0 : -5);
        expect(report.closed, true);
        balanced(result);
      }
    },
  );

  test(
    'actions, event income and appointments are included in gross cash totals',
    () {
      var s = fresh();
      s.court.firstWhere((c) => c.id == 'treasurer').ability = 80;
      roll(s, 0);
      s = send(s, 'action', target: 'collect_arrears', option: 'treasurer');
      roll(s, 0);
      s = send(s, 'action', target: 'buy_grain', option: 'treasurer');
      final candidate =
          s.officialsPool.first
            ..ability = 80
            ..influence = 40;
      s = send(s, 'appoint', target: 'governor', option: candidate.id);
      s.petitions.add(
        Petition(
          id: 'trade',
          definitionId: 'silk_route',
          openedWeek: 1,
          deadline: 2,
        ),
      );
      s = send(s, 'petition', target: 'trade', option: '1');
      final report = s.financialWeeks.single;
      expect(report.entries.map((e) => e.amount), [55, -45, -23, 20]);
      expect(report.income, 75);
      expect(report.expense, 68);
      expect(s.treasury, 527);
      expect(report.entries[0].detail, contains('hiệu quả 123%'));
      expect(report.entries[2].title, contains('Bổ nhiệm'));
      expect(report.entries.last.title, eventById('silk_route').title);
      balanced(s);
    },
  );

  test('lost capital, failed work and unfunded losses reconcile with debt', () {
    var s =
        fresh(cash: 40)
          ..tax = 0
          ..people = 60;
    s = send(s, 'action', target: 'commerce', option: 'treasurer');
    s.projects.single.progress = 3;
    roll(s, 99);
    s = send(s, 'endWeek');
    final report = s.financialWeeks.single;
    expect(report.entries.first.amount, -40);
    final loss = report.entries.firstWhere(
      (e) => e.title.contains('Thất bại nặng'),
    );
    expect(loss.requiredAmount, 20);
    expect(loss.amount, 0);
    expect(loss.debtChange, 20);
    expect(loss.category, 'project');
    expect(report.income, 18);
    expect(report.expense, 58);
    expect(report.closingDebt, 27);
    balanced(s);
  });

  test(
    'overdue event losses keep their cause even when the treasury is empty',
    () {
      final s = fresh(cash: 0);
      s.petitions.add(
        Petition(
          id: 'late',
          definitionId: 'finance_02',
          openedWeek: 1,
          deadline: 1,
        ),
      );
      final result = send(s, 'endWeek');
      final report = result.financialWeeks.single;
      expect(report.entries.first.title, startsWith('Quá hạn:'));
      expect(report.entries.first.requiredAmount, 12);
      expect(report.entries.first.amount, 0);
      expect(report.entries.first.debtChange, 12);
      balanced(result);
    },
  );

  test(
    'both deferred branches record only when due and opening balances carry forward',
    () {
      for (final n in [0, 99]) {
        var s = fresh();
        roll(s, n);
        s.petitions.add(
          Petition(
            id: 'audit',
            definitionId: 'finance_02',
            openedWeek: 1,
            deadline: 2,
          ),
        );
        s = send(s, 'petition', target: 'audit', option: '0');
        expect(s.financialWeeks.single.entries.map((e) => e.amount), [-20]);
        for (var i = 0; i < 2; i++) {
          s.petitions.clear();
          s.affairsThisWeek = 1;
          s = send(s.copy(), 'endWeek');
        }
        final outcomes = s.financialWeeks
            .expand((w) => w.entries)
            .where((e) => e.category == 'outcome');
        expect(outcomes, hasLength(1));
        expect(outcomes.single.amount, n == 0 ? 45 : -8);
        expect(
          outcomes.single.detail,
          contains(n == 0 ? 'thành công' : 'thất bại'),
        );
        final last = s.financialWeeks.last;
        expect(last.week, 2);
        balanced(s);
        s.petitions.clear();
        s.affairsThisWeek = 1;
        s = send(s, 'endWeek');
        expect(
          s.financialWeeks
              .expand((w) => w.entries)
              .where((e) => e.category == 'outcome'),
          hasLength(1),
        );
        balanced(s);
      }
    },
  );

  test(
    'legacy trade and audit payouts explain their base and variable components',
    () {
      for (final kind in ['trade', 'audit']) {
        final s = fresh();
        roll(s, 0);
        s.pending.add(Consequence(kind: kind, dueWeek: 1));
        final result = send(s, 'endWeek');
        final entry = result.financialWeeks.single.entries.singleWhere(
          (e) => e.category == 'outcome',
        );
        expect(
          entry.amount,
          inInclusiveRange(
            kind == 'trade' ? 65 : 35,
            kind == 'trade' ? 95 : 70,
          ),
        );
        expect(entry.detail, contains('= ${entry.amount}'));
        balanced(result);
      }
    },
  );

  test(
    'palace and personal expenses are separate from recurring palace upkeep',
    () {
      var s = fresh();
      s = send(s, 'courtier', target: 'consort_lan', option: 'invite');
      s = send(s, 'courtier', target: 'consort_lan', option: 'queen');
      s = send(s, 'courtier', target: 'chancellor', option: 'reward');
      expect(s.financialWeeks.single.entries.map((e) => e.amount), [
        -35,
        -60,
        -20,
      ]);
      s = send(s, 'endWeek');
      expect(
        s.financialWeeks.single.entries
            .firstWhere((e) => e.title == 'Triều đình và hậu cung')
            .amount,
        -10,
      );
      balanced(s);
    },
  );

  test('loan obligations and debt relief do not masquerade as cash income', () {
    final s = fresh(cash: 50, debt: 20);
    s.pending.add(
      Consequence(
        kind: 'eventOutcome',
        dueWeek: 1,
        title: 'Khoản vay',
        detail: 'Điều chỉnh nghĩa vụ.',
        effects: {'treasury': 30, 'debt': 40},
      ),
    );
    final result = send(s, 'endWeek');
    final outcomes =
        result.financialWeeks.single.entries
            .where((e) => e.category == 'outcome')
            .toList();
    expect(outcomes, hasLength(2));
    expect(outcomes.first.amount, 30);
    expect(outcomes.last.amount, 0);
    expect(outcomes.last.debtChange, 40);
    balanced(result);
    final relief = fresh(cash: 50, debt: 20);
    relief.pending.add(
      Consequence(
        kind: 'eventOutcome',
        dueWeek: 1,
        title: 'Miễn nợ',
        detail: 'Chủ nợ giảm nghĩa vụ.',
        effects: {'debt': -50},
      ),
    );
    final forgiven = send(relief, 'endWeek');
    final report = forgiven.financialWeeks.single;
    expect(
      report.debtReduction,
      20,
    ); // 10 paid, 10 forgiven; never a cash gain.
    expect(report.closingDebt, 0);
    expect(
      report.entries.singleWhere((e) => e.category == 'outcome').amount,
      0,
    );
    expect(
      report.entries.singleWhere((e) => e.category == 'outcome').debtChange,
      -10,
    );
    balanced(forgiven);
  });

  test(
    'invalid actions do not add entries and retries never double-book',
    () async {
      final s = fresh(cash: 0);
      final before = jsonEncode(s.toJson());
      expect(
        () => send(s, 'action', target: 'repair', option: 'governor'),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
      final gateway = LocalGameGateway(MemoryGameStore(), seasonal: false);
      final original = await gateway.start(
        name: 'An',
        runId: 'cash-once',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      final command = GameCommand(
        id: 'cost',
        runId: original.active!.runId,
        expectedRevision: 0,
        type: 'action',
        target: 'revel',
      );
      final first = await gateway.dispatch(command);
      final retry = await gateway.dispatch(command);
      expect(first.toJson(), retry.toJson());
      expect(retry.active!.financialWeeks.single.entries, hasLength(1));
      balanced(retry.active!);
    },
  );

  test(
    'current saves missing ledger start a clearly partial ledger without inventing historical transactions',
    () {
      final old =
          engine.start('old', 'An', 42).toJson()
            ..remove('financialWeeks')
            ..['rulesVersion'] = rulesVersion
            ..['completedWeeks'] = 10
            ..['revision'] = 8
            ..['treasury'] = 123;
      final raw =
          (GameArchive()..active = engine.start('old', 'An', 42)).toJson()
            ..['active'] = old;
      final loaded = GameArchive.fromJson(raw).active!;
      expect(loaded.financialWeeks, isEmpty);
      expect(loaded.treasury, 123);
      final next = send(loaded, 'action', target: 'revel');
      final report = next.financialWeeks.single;
      expect(report.week, 11);
      expect(report.openingBalance, 123);
      expect(report.partial, true);
      expect(report.entries.single.amount, -18);
      balanced(next);
    },
  );
}
