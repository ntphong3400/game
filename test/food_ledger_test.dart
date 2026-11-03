import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/food_ledger_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'warfare_test.dart' as war;

final ledgerEngine = GameEngine();
GameState ledgerState() {
  final s = ledgerEngine.start('ledger-test', 'An', 42);
  s.petitions.clear();
  s.midSeasonDelivered = true;
  s.nextMajorWeek = s.nextChainWeek = 100000;
  s.lastManagementTurn = 100000;
  s.factions.updateAll((k, v) => 60);
  for (final c in s.court) {
    c.loyalty = c.integrity = c.affection = 100;
    c.strain = c.discontent = 0;
  }
  final c = s.court.firstWhere((c) => c.id == 'treasurer');
  c.ability = 100;
  c.specialty = 'Kinh tế';
  c.personalities
    ..clear()
    ..addAll([Personality.honest, Personality.dutiful]);
  s.rng = 1;
  return s;
}

GameState ledgerSend(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => ledgerEngine.execute(
  s,
  GameCommand(
    id: 'ledger-${s.revision}',
    runId: s.runId,
    expectedRevision: s.revision,
    type: type,
    target: target,
    option: option,
  ),
);
GameState ledgerClose(GameState s) {
  s.petitions.clear();
  s.workThisWeek = s.affairsThisWeek = s.restThisWeek = 1;
  return ledgerSend(s, 'endWeek');
}

void reconcilesFood(GameState s) {
  for (final w in s.foodWeeks) {
    expect(
      w.openingBalance + w.income - w.expense,
      w.closingBalance,
      reason: 'turn ${w.week}',
    );
    var stock = w.openingBalance;
    for (final e in w.entries) {
      stock += e.amount;
      expect(stock, e.balanceAfter, reason: '${w.week}: ${e.title}');
      expect(e.overflow, greaterThanOrEqualTo(0));
      expect(e.shortfall, greaterThanOrEqualTo(0));
    }
    expect(w.outstanding, greaterThanOrEqualTo(0));
    if (w.closed) expect(w.outstanding, 0);
  }
  expect(s.foodWeeks.last.closingBalance, s.grain);
}

void main() {
  test(
    'new run has an opening stock and read-only projections do not mutate state or RNG',
    () {
      final s = ledgerState();
      expect(s.foodWeeks.single.openingBalance, 4000000);
      expect(s.foodWeeks.single.entries, isEmpty);
      final json = jsonEncode(s.toJson());
      final p = FoodProjection(s);
      expect(p.harvestReceived, 0);
      expect(p.remainingNeed, 922500);
      expect(p.closingBalance, 3077500);
      expect(jsonEncode(s.toJson()), json);
    },
  );
  test(
    'purchase and sale record actual food once; pending cash does not become food income',
    () {
      var s = ledgerState();
      s = ledgerSend(s, 'action', target: 'buy_grain', option: 'treasurer');
      final w = s.foodWeeks.single;
      expect(w.income, s.grain - 4000000);
      expect(w.entries.single.category, 'purchase');
      expect(w.expense, 0);
      s = ledgerSend(s, 'action', target: 'sell_surplus', option: 'treasurer');
      expect(s.foodWeeks.single.expense, 100000);
      expect(s.pending.where((p) => p.effects.containsKey('gold')), isNotEmpty);
      reconcilesFood(s);
      expect(s.copy().foodWeeks.single.toJson(), s.foodWeeks.single.toJson());
    },
  );
  test(
    'relief and ordinary consumption balance without treating prepaid rations as income',
    () {
      var s = ledgerState();
      s.petitions.add(
        Petition(
          id: 'flood',
          definitionId: 'flood',
          openedWeek: s.week,
          deadline: s.week,
        ),
      );
      s = ledgerSend(s, 'petition', target: 'flood', option: '0');
      expect(s.foodWeeks.single.income, 0);
      expect(s.foodWeeks.single.expense, 285000);
      expect(s.foodWeeks.single.prepaid, 228000);
      expect(s.foodWeeks.single.entries.last.amount, 0);
      final projection = FoodProjection(s);
      expect(projection.prepaid, 228000);
      expect(projection.consumption, 694500);
      s = ledgerClose(s);
      final w = s.foodWeeks.first;
      expect(w.closed, true);
      expect(w.applied, 228000);
      expect(w.expense, 979500);
      expect(w.income, 0);
      expect(w.closingBalance, projection.closingBalance);
      expect(s.foodWeeks.last.openingBalance, w.closingBalance);
      expect(s.foodWeeks.last.prepaid, 0);
      reconcilesFood(s);
    },
  );
  test(
    'unused prepaid rations expire at season close without entering or leaving stock',
    () {
      var s = ledgerState()..foodWeeks.clear();
      s.population!.foodCredit = 1000000;
      s = ledgerClose(s);
      final w = s.foodWeeks.first;
      expect(w.openingPrepaid, 1000000);
      expect(w.applied, 922500);
      expect(w.expired, 77500);
      expect(w.income, 0);
      expect(w.expense, 0);
      expect(w.closingBalance, 4000000);
      expect(s.foodWeeks.last.prepaid, 0);
      reconcilesFood(s);
    },
  );
  test(
    'pending food gains and losses are posted once alongside seasonal consumption',
    () {
      var s = ledgerState();
      s.pending.addAll([
        Consequence(
          kind: 'eventOutcome',
          dueWeek: s.week,
          title: 'Lương đến hạn',
          effects: {'food': 12345},
        ),
        Consequence(
          kind: 'eventOutcome',
          dueWeek: s.week,
          title: 'Mất lương',
          effects: {'food': -2345},
        ),
      ]);
      s = ledgerClose(s);
      final w = s.foodWeeks.first;
      expect(w.income, 12345);
      expect(w.expense, 922500 + 2345);
      expect(
        w.entries.where((e) => e.title == 'Kết quả: Lương đến hạn'),
        hasLength(1),
      );
      expect(
        w.entries.where((e) => e.title == 'Kết quả: Mất lương'),
        hasLength(1),
      );
      reconcilesFood(s);
    },
  );
  test(
    'near-full purchase counts only accepted food and exposes overflow without a fake expense',
    () {
      var s =
          ledgerState()
            ..grain = 7999877
            ..foodWeeks.clear();
      s = ledgerSend(s, 'action', target: 'buy_grain', option: 'treasurer');
      final w = s.foodWeeks.single;
      expect(w.income, 123);
      expect(w.expense, 0);
      expect(w.overflow, greaterThan(200000));
      expect(w.entries.single.amount, 123);
      expect(w.closingBalance, 8000000);
      reconcilesFood(s);
    },
  );
  test(
    'full-store autumn harvest has zero receipt; seasonal consumption is the only stock expense',
    () {
      var s =
          ledgerState()
            ..completedWeeks = 2
            ..grain = 8000000
            ..foodWeeks.clear();
      s = ledgerClose(s);
      final w = s.foodWeeks.first;
      final harvest = w.entries.singleWhere((e) => e.category == 'harvest');
      expect(harvest.amount, 0);
      expect(harvest.overflow, greaterThan(3000000));
      expect(w.income, 0);
      expect(w.expense, 922500);
      expect(w.closingBalance, 7077500);
      reconcilesFood(s);
    },
  );
  test(
    'insufficient grain records actual withdrawal, request and shortfall without negative inventory',
    () {
      var s =
          ledgerState()
            ..grain = 100
            ..foodWeeks.clear();
      s = ledgerClose(s);
      final w = s.foodWeeks.first;
      expect(w.expense, 100);
      expect(w.shortfall, 922400);
      expect(w.closingBalance, 0);
      reconcilesFood(s);
    },
  );
  test(
    'the harvest forecast samples this season and wear before admitting food, without using RNG',
    () {
      var s =
          ledgerState()
            ..completedWeeks = 2
            ..grain = 4000000
            ..levee = 70
            ..foodWeeks.clear();
      final before = jsonEncode(s.toJson());
      final p = FoodProjection(s);
      expect(p.harvestDue, true);
      expect(p.grossHarvest, greaterThanOrEqualTo(p.lowHarvest));
      expect(p.grossHarvest, lessThanOrEqualTo(p.highHarvest));
      expect(jsonEncode(s.toJson()), before);
      s = ledgerClose(s);
      expect(
        s.lastHarvestAmount,
        inInclusiveRange(p.lowHarvest, p.highHarvest),
      );
      final w = s.foodWeeks.first;
      expect(
        w.entries.singleWhere((e) => e.category == 'harvest').requested,
        s.lastHarvestAmount,
      );
      reconcilesFood(s);
    },
  );
  test(
    'multi-season armies record stock charges and zero-stock ration offsets separately',
    () {
      var s = war.war();
      final m = war.addMission(s, 'siege');
      final officer = s.court.firstWhere((c) => c.id == 'general');
      s = war.order(s, m.id, {
        'action': 'deploy',
        'ratio': 2,
      }, leader: officer.id);
      expect(s.foodWeeks.single.expense, 25200);
      expect(s.foodWeeks.single.prepaid, 13500);
      s = war.close(s);
      expect(s.foodWeeks.first.applied, 13500);
      s = war.order(s, m.id, {'action': 'intervene'});
      expect(s.foodWeeks.last.expense, 25200);
      expect(s.foodWeeks.last.prepaid, 13500);
      s = war.close(s);
      expect(s.foodWeeks[1].applied, 13500);
      expect(s.foodWeeks[1].entries.where((e) => e.prepaid > 0), hasLength(1));
      reconcilesFood(s);
    },
  );
  test(
    'older saves begin a partial ledger at the next command and never reconstruct past entries',
    () {
      final s =
          ledgerState()
            ..completedWeeks = 1
            ..revision = 5;
      final json = s.toJson()..remove('foodWeeks');
      final loaded = GameState.fromJson(json);
      final before = jsonEncode(loaded.toJson());
      expect(loaded.foodWeeks, isEmpty);
      FoodProjection(loaded);
      expect(jsonEncode(loaded.toJson()), before);
      final result = ledgerSend(loaded, 'action', target: 'rest');
      expect(result.foodWeeks, hasLength(1));
      expect(result.foodWeeks.single.week, 2);
      expect(result.foodWeeks.single.partial, true);
      expect(result.foodWeeks.single.entries, isEmpty);
      expect(result.foodWeeks.single.openingBalance, s.grain);
      expect(result.rng, loaded.rng);
    },
  );
  test(
    'automatic flood damage in the new season is posted, not lost outside the ledger',
    () {
      GameState? flooded;
      for (var seed = 1; seed <= 100; seed++) {
        final s =
            ledgerState()
              ..levee = 20
              ..rng = seed;
        final result = ledgerClose(s);
        if (result.foodWeeks.last.entries.any(
          (e) => e.category == 'disaster',
        )) {
          flooded = result;
          break;
        }
      }
      expect(flooded, isNotNull);
      expect(
        flooded!.foodWeeks.last.entries.any((e) => e.category == 'adjustment'),
        false,
      );
      reconcilesFood(flooded);
    },
  );
}
