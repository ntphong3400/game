import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/currency_rules.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/population_rules.dart';
import 'package:van_tue/game/logic/chain_settlement_rules.dart';
import 'package:van_tue/game/logic/palace_rules.dart';
import 'package:van_tue/game/logic/reign_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

final engine = GameEngine();
GameState fresh() {
  final s = engine.start('gold', 'An', 42);
  s.petitions.clear();
  s.nextMajorWeek = s.nextChainWeek = 100000;
  s.factions.updateAll((k, v) => 60);
  for (final c in s.court) {
    c.loyalty = c.integrity = 100;
    c.ambition = 10;
  }
  return s;
}

GameCommand command(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => GameCommand(
  id: 'gold-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: type,
  target: target,
  option: option,
);
GameState send(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => engine.execute(s, command(s, type, target: target, option: option));
GameState close(GameState s) {
  s.petitions.clear();
  s.affairsThisWeek = s.workThisWeek = 1;
  return send(s, 'endWeek');
}

void addPetition(GameState s, String id) => s.petitions.add(
  Petition(id: id, definitionId: id, openedWeek: s.week, deadline: s.week + 1),
);
void reconcile(GameState s) {
  for (final w in s.financialWeeks) {
    expect(w.closingBalance, w.openingBalance + w.income - w.expense);
    expect(w.closingDebt, w.openingDebt + w.newDebt - w.debtReduction);
  }
}

void main() {
  test('new game starts with 50,000 gold and the same population and food', () {
    final s = fresh();
    expect(s.goldStandard, true);
    expect(s.treasury, 50000);
    expect(s.financialWeeks.single.openingBalance, 50000);
    expect(s.population!.population, 1000000);
    expect(s.grain, 4000000);
    expect(moneyUnit(s), 'lượng vàng');
    expect(actionCost(s, actions.firstWhere((a) => a.id == 'buy_grain')), 4500);
    expect(foodAmount(100 * 200000 / 4500), 4445);
  });
  test('shared quotes and eligibility use native gold', () {
    final s = fresh();
    expect(actionCost(s, actions.firstWhere((a) => a.id == 'train')), 3500);
    expect(
      actionCost(s, actions.firstWhere((a) => a.id == 'upgrade_economy')),
      8000,
    );
    expect(investigationCost(s), 2000);
    final candidate = s.officialsPool.first;
    expect(
      appointmentCost(candidate, 'Tri phủ', s),
      appointmentCost(candidate, 'Tri phủ') * 100,
    );
    expect(palaceDutyCost(s, palaceDuty('charity')!), 2000);
    s.treasury = 8000;
    expect(PersonalityAssessment(s.court.first, s).scarce, false);
    s.treasury = 7999;
    expect(PersonalityAssessment(s.court.first, s).scarce, true);
    s.treasury = 3999;
    expect(populationActionBlocked(s, 'settle'), isNotNull);
    expect(
      () => send(s, 'population', target: 'settle'),
      throwsA(isA<GameRuleException>()),
    );
  });
  test('budget rounds after converting to gold and scales military upkeep', () {
    final s = fresh();
    expect(budgetIncome(s).first.amount, 8000);
    expect(budgetExpenses(s)['army']!.amount, 4500);
    expect(budgetExpenses(s)['people']!.amount, 2000);
    s.population!.productiveCivilians = 950001;
    expect(budgetIncome(s).first.amount, 8001);
    s.population!.productiveCivilians = 950000;
    s.population!.policy = 'army';
    expect(budgetIncome(s).first.amount, 2000);
    s.population!.policy = 'balanced';
    expect(budgetIncome(s).first.amount, 5000);
  });
  test(
    'settlement and character actions spend the price shown exactly once',
    () {
      var s = send(fresh(), 'population', target: 'settle');
      expect(s.treasury, 46000);
      expect(s.grain, 3993000);
      s = send(s, 'courtier', target: 'general', option: 'reward');
      expect(s.treasury, 44000);
      reconcile(s);
    },
  );
  test('gold emergency loan and its future repayments preserve the ledger', () {
    var s = send(fresh(), 'emergency', target: 'borrow');
    expect(s.treasury, 62000);
    expect(s.obligations.single.amount, 5000);
    expect(s.obligations.single.remaining, 3);
    expect(emergencyHint(s, 'borrow'), contains('5.000 lượng vàng/mùa'));
    expect(emergencyHint(s, 'borrow'), contains('15.000 lượng vàng'));
    s = close(s);
    reconcile(s);
    expect(s.obligations.single.remaining, 3);
    final before = s.treasury;
    final forecast = BudgetProjection(s);
    s = close(s);
    expect(s.treasury, forecast.closingBalance);
    expect(s.financialWeeks.last.openingBalance, before);
    reconcile(s);
  });
  test(
    'debt repayment and poverty boundaries use gold, not old raw numbers',
    () {
      final s = fresh();
      expect(debtPayment(5000, 5000, scale: moneyScale(s)), 1000);
      expect(debtPayment(5000, 2000, scale: moneyScale(s)), 0);
      final poor = events.firstWhere((e) => e.condition == 'poor');
      s.treasury = 11999;
      expect(engine.eligible(s, poor), true);
      s.treasury = 12000;
      expect(engine.eligible(s, poor), false);
    },
  );
  test('petitions project native gold only once and apply it only once', () {
    var s = fresh();
    addPetition(s, 'population_refugees');
    final e = eventForState(s, 'population_refugees');
    expect(e.choices.first.cost, 5000);
    expect(e.choices.first.hint, contains('5.000 lượng vàng'));
    expect(currencyEvent(s, e).choices.first.cost, 5000);
    s = send(s, 'petition', target: 'population_refugees', option: '0');
    expect(s.treasury, 45000);
    expect(s.grain, 3990000);
    reconcile(s);
  });
  test(
    'pending monetary effects use a native key and survive a save/reload',
    () {
      var s = fresh();
      final e = eventsForState(s)
          .map((e) => eventForState(s, e.id))
          .firstWhere(
            (e) => e.choices.any(
              (c) => (c.laterEffects['gold'] ?? 0) > 0 && c.economy != null,
            ),
          );
      final index = e.choices.indexWhere(
        (c) => (c.laterEffects['gold'] ?? 0) > 0 && c.economy != null,
      );
      addPetition(s, e.id);
      s = send(s, 'petition', target: e.id, option: '$index');
      expect(s.pending, isNotEmpty);
      final due = s.pending
          .map((p) => p.dueWeek)
          .reduce((a, b) => a > b ? a : b);
      final effects = Map<String, int>.from(s.pending.last.effects);
      final restored = GameState.fromJson(
        object(jsonDecode(jsonEncode(s.toJson()))),
      );
      expect(restored.pending.last.effects, effects);
      s = restored;
      while (s.week <= due) {
        s = close(s);
      }
      expect(s.pending.where((p) => p.title == e.title), isEmpty);
      reconcile(s);
      final changes = s.outcomes.where((r) => r.title == e.title).toList();
      expect(changes, hasLength(1));
    },
  );
  test(
    'economic chains settle native invested capital without a second multiplication',
    () {
      var s = fresh();
      s.chains.add(
        StoryArc(id: 'gold-chain', kind: 'embezzlement', dueWeek: 1),
      );
      engine.prepareStoryPetitions(s);
      for (var stage = 0; stage < 2; stage++) {
        final p = s.petitions.firstWhere((p) => p.storyId == 'gold-chain');
        final quote = eventForState(s, p.definitionId).choices[1].cost;
        final before = s.treasury;
        s = send(s, 'petition', target: p.id, option: '1');
        expect(before - s.treasury, quote);
        if (stage == 0) s = close(s);
      }
      final arc = s.chains.single;
      expect(arc.currencyScale, 100);
      expect(arc.cashSpent, 7000);
      expect(arc.investedValue, 7000);
      expect(chainSettlementEffects(arc), {'gold': 3500});
      s = close(s);
      final stop = s.petitions.firstWhere((p) => p.storyId == 'gold-chain');
      final before = s.treasury;
      s = send(s, 'petition', target: stop.id, option: '0');
      expect(s.treasury, before + 3500);
      expect(s.chains, isEmpty);
      reconcile(s);
    },
  );
  test(
    'old quantitative save scales balance, debt, entries and obligations once',
    () {
      final oldEngine = GameEngine(goldEnabled: false);
      var old = oldEngine.start('old-gold', 'An', 7);
      old = oldEngine.execute(old, command(old, 'emergency', target: 'borrow'));
      old.deltas = {'treasury': -20, 'people': 3};
      final raw =
          old.toJson()
            ..remove('goldStandard')
            ..['rulesVersion'] = 'mvp-0.21.0';
      final original = jsonEncode(raw);
      final converted = GameState.fromJson(raw);
      expect(converted.goldStandard, true);
      expect(converted.deltas, {'treasury': -2000, 'people': 3});
      expect(converted.treasury, old.treasury * 100);
      expect(
        converted.obligations.single.amount,
        old.obligations.single.amount * 100,
      );
      expect(converted.financialWeeks.single.entries.single.amount, 12000);
      expect(converted.financialWeeks.single.openingBalance, 52000);
      expect(jsonEncode(raw), original);
      expect(converted.copy().treasury, converted.treasury);
      expect(
        converted.copy().obligations.single.amount,
        converted.obligations.single.amount,
      );
      reconcile(converted);
    },
  );
  test('legacy pre-population saves retain their original money contract', () {
    final old = GameEngine(populationEnabled: false).start('legacy', 'An', 1);
    final raw = old.toJson()..remove('goldStandard');
    final loaded = GameState.fromJson(raw);
    expect(loaded.goldStandard, false);
    expect(loaded.treasury, 520);
  });
  test(
    'authored money descriptions scale without touching food or native gold twice',
    () {
      final s = fresh();
      expect(
        authoredMoneyText(s, 'Chi 45 tiền, 200.000 tạ, 1 hành động'),
        'Chi 4.500 lượng vàng, 200.000 tạ, 1 hành động',
      );
      final once = authoredMoneyText(s, 'Ngân khố +60 · thu hồi 60–90 tiền');
      expect(authoredMoneyText(s, once), once);
      expect(money(s, .001), 1);
      expect(money(s, 0), 0);
    },
  );
  test(
    'gold gateway retry does not grant gold or spend a charge twice',
    () async {
      final gateway = LocalGameGateway(MemoryGameStore());
      var a = await gateway.start(
        name: 'An',
        runId: 'gold-once',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      final cmd = command(a.active!, 'population', target: 'settle');
      a = await gateway.dispatch(cmd);
      final snapshot = jsonEncode(a.active!.toJson());
      a = await gateway.dispatch(cmd);
      expect(jsonEncode(a.active!.toJson()), snapshot);
      expect(a.active!.treasury, 46000);
    },
  );
  test(
    'palace price reductions and study costs use gold without multiplying buffs twice',
    () {
      final s = fresh();
      s.palaceEffects.add(
        PalaceEffect(
          kind: 'herbs',
          personId: 'doctor',
          startsTurn: 1,
          endsTurn: 3,
          amount: 8,
          uses: 1,
        ),
      );
      expect(palaceTreatmentDiscount(s), 800);
      expect(actionCost(s, actions.firstWhere((a) => a.id == 'treat')), 1700);
      final result = send(s, 'action', target: 'treat');
      expect(result.treasury, 48300);
      reconcile(result);
    },
  );
}
