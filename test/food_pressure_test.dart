import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/population_rules.dart';
import 'package:van_tue/game/logic/food_pressure_rules.dart';
import 'package:van_tue/game/logic/warfare_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

final engine = GameEngine();
GameState fresh() {
  final s = engine.start('food-test', 'An', 42);
  s.petitions.clear();
  s.nextMajorWeek = s.nextChainWeek = 100000;
  s.people = s.authority = s.stability = s.health = 90;
  s.levee = 100;
  s.lastManagementTurn = 100000;
  s.factions.updateAll((k, v) => 60);
  for (final c in s.court) {
    c.loyalty = c.integrity = c.affection = 100;
    c.strain = c.discontent = 0;
  }
  return s;
}

GameState send(
  GameState s,
  String type, {
  String target = '',
  String option = '',
  String assignee = '',
}) => engine.execute(
  s,
  GameCommand(
    id: 'food-${s.revision}',
    runId: s.runId,
    expectedRevision: s.revision,
    type: type,
    target: target,
    option: option,
    assigneeId: assignee,
  ),
);
GameState close(GameState s) {
  s.petitions.clear();
  s.workThisWeek = s.affairsThisWeek = s.restThisWeek = 1;
  return send(s, 'endWeek');
}

GameState disaster(int choice) {
  var s = fresh();
  final d = majorDefinition('flood');
  s.major = MajorMission(
    id: 'flood-test',
    kind: d.id,
    openedWeek: 1,
    deadline: 4,
    dueWeek: 1,
    severity: 1,
    preparedness: 0,
    demanding: true,
    petitionDriven: true,
    objectives: d.objectives.map((g) => MissionObjective(key: g.key)).toList(),
  );
  engine.prepareStoryPetitions(s);
  final p = s.petitions.singleWhere((p) => p.storyKind == 'major');
  s = send(s, 'petition', target: p.id, option: '$choice');
  return s;
}

void main() {
  test(
    'ordinary disaster choices disclose and apply the same continuing pressure',
    () {
      var s = fresh();
      s.petitions.add(
        Petition(
          id: 'rain',
          definitionId: 'rain_forecast',
          openedWeek: s.week,
          deadline: s.week,
        ),
      );
      expect(
        eventForState(s, 'rain_forecast').choices.last.hint,
        contains('25% mùa này và mùa sau'),
      );
      s = send(s, 'petition', target: 'rain', option: '2');
      expect(s.foodDisruptions.single.percent, 25);
      expect(s.foodDisruptions.single.until, s.week + 1);
      expect(s.grain, 4000000);
    },
  );
  test(
    'food economy v2 keeps national consumption and removes all automatic welfare billing',
    () {
      final s = fresh();
      expect(s.foodPressureEnabled, true);
      expect(populationFoodConsumption(s), 922500);
      expect(budgetExpenses(s).containsKey('people'), false);
      s.priority = 'people';
      expect(budgetPaymentOrder(s).contains('people'), false);
      final before = BudgetProjection(s);
      final result = close(s);
      expect(result.grain, 4000000 - 922500);
      expect(result.treasury, before.closingBalance);
      expect(
        result.financialWeeks.first.entries.where(
          (e) => e.title == 'Dân sinh thường lệ',
        ),
        isEmpty,
      );
      expect(
        () => send(result, 'priority', option: 'army'),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test(
    'native, authored, and major food prices grow exactly 25%; penalties and rewards remain unchanged',
    () {
      final s = fresh(), old = fresh()..balanceVersion = 1;
      for (final raw in eventsForState(s)) {
        final current = eventForState(s, raw.id),
            previous = eventForState(old, raw.id);
        for (var i = 0; i < current.choices.length; i++) {
          final a = current.choices[i], b = previous.choices[i];
          expect(
            a.grainCost,
            (b.grainCost * 1.25).ceil(),
            reason: '${raw.id} choice $i',
          );
          expect(a.laterFailureEffects, b.laterFailureEffects);
          expect(a.laterEffects, b.laterEffects);
        }
        expect(
          foodCostEvent(s, current).choices.first.grainCost,
          current.choices.first.grainCost,
        );
      }
      expect(
        eventForState(s, 'population_refugees').choices.first.grainCost,
        12500,
      );
      expect(populationActionFood('refugees', s), 12500);
      expect(populationActionHint(s, 'refugees'), contains('12.500 tạ'));
      expect(
        eventForState(s, 'population_refugees').choices.first.hint,
        contains('12.500 tạ'),
      );
      expect(eventForState(s, 'flood').choices.first.grainCost, 285000);
      expect(
        eventForState(s, 'rain_forecast').choices[1].effects['food'],
        -37500,
      );
      expect(
        eventForState(s, 'flood').choices.last.effects['food'],
        eventForState(old, 'flood').choices.last.effects['food'],
      );
    },
  );

  test(
    'all five yields are calibrated while existing balance versions retain their values',
    () {
      final s = fresh();
      for (var level = 1; level <= 5; level++) {
        s.agricultureLevel = level;
        expect(
          agricultureBaseYield(s),
          [4100000, 4400000, 4700000, 5000000, 5300000][level - 1],
        );
      }
      s.balanceVersion = 1;
      expect(agricultureBaseYield(s), 10500000);
      expect(budgetExpenses(s)['people']!.amount, 2000);
      expect(s.copy().balanceVersion, 1);
      expect(s.copy().foodDisruptions, isEmpty);
    },
  );

  test(
    'paid flood relief credits only prepaid meals and leaves the 25% logistics cost real',
    () {
      var s = fresh();
      s.petitions.add(
        Petition(
          id: 'relief',
          definitionId: 'flood',
          openedWeek: s.week,
          deadline: s.week,
        ),
      );
      s = send(s, 'petition', target: 'relief', option: '0');
      expect(s.grain, 4000000 - 285000);
      expect(s.population!.foodCredit, 228000);
      s = close(s);
      expect(s.grain, 4000000 - 922500 - 57000);
      expect(s.population!.foodCredit, 0);
    },
  );

  test(
    'partial and neglected disasters affect one/two seasons, full response avoids a new shock',
    () {
      expect(disaster(0).foodDisruptions, isEmpty);
      final partial = disaster(1);
      expect(partial.foodDisruptions.single.percent, 12);
      expect(partial.foodDisruptions.single.until, partial.week);
      final neglected = disaster(2);
      expect(neglected.foodDisruptions.single.percent, 25);
      expect(neglected.foodDisruptions.single.until, neglected.week + 1);
      expect(
        neglected.copy().foodDisruptions.single.toJson(),
        neglected.foodDisruptions.single.toJson(),
      );
      expect(farmLaborFactor(neglected), closeTo(.75, .000001));
    },
  );

  test(
    'continuing relief is optional, repeat-safe and expires without an automatic food payment',
    () {
      var s = close(disaster(2));
      engine.prepareStoryPetitions(s);
      final petitions =
          s.petitions
              .where((p) => isFoodRecoveryEvent(p.definitionId))
              .toList();
      expect(petitions, hasLength(1));
      engine.prepareStoryPetitions(s);
      expect(
        s.petitions.where((p) => isFoodRecoveryEvent(p.definitionId)),
        hasLength(1),
      );
      final p = petitions.single;
      final quote = eventForState(s, p.definitionId);
      final beforeFood = s.grain, beforeCredit = s.population!.foodCredit;
      final base = recoveryRations(s, s.foodDisruptions.single);
      final paid = send(s.copy(), 'petition', target: p.id, option: '0');
      expect(paid.grain, beforeFood - quote.choices.first.grainCost);
      expect(paid.population!.foodCredit, beforeCredit + base);
      expect(foodProductionLoss(paid), 0);
      expect(paid.copy().foodDisruptions.single.percent, 0);
      expect(
        () => send(paid, 'petition', target: p.id, option: '0'),
        throwsA(isA<GameRuleException>()),
      );
      s.major = null;
      final noAid = close(s.copy());
      expect(noAid.grain, beforeFood - remainingFoodConsumption(s));
      expect(noAid.foodDisruptions.single.active(noAid.week), false);
    },
  );

  test(
    'combined warfare, civilian mobilization and overlapping disasters respect the 35% cap',
    () {
      final s = fresh();
      final n =
          s.warfare!.neighbors.first
            ..status = 'war'
            ..warStarted = s.week;
      expect(warProductionLoss(s), 10);
      s.completedWeeks += 2;
      expect(warProductionLoss(s), 20);
      n.advantage = -50;
      s.population!.campaignWorkers = 100000;
      for (var i = 0; i < 3; i++) {
        s.foodDisruptions.add(
          FoodDisruption(
            id: 'd$i',
            title: 'Thiên tai',
            percent: 30,
            start: 1,
            until: 10,
          ),
        );
      }
      expect(foodProductionLoss(s), 35);
      expect(farmLaborFactor(s), closeTo(.65, .000001));
    },
  );

  test(
    'autumn harvest uses the sampled seasonal impact and cannot rewrite earlier seasons',
    () {
      final s = fresh()..completedWeeks = 2;
      s.population!.yearlyFarmLabor = 2;
      s.population!.yearlyLaborSamples = 2;
      s.foodDisruptions.add(
        FoodDisruption(
          id: 'loss',
          title: 'Thiên tai',
          percent: 25,
          start: 3,
          until: 3,
        ),
      );
      final result = close(s);
      final expected = foodAmount(
        4100000 *
            result.lastHarvestLeveePercent /
            100 *
            result.lastHarvestWeather /
            100 *
            (2 + .75) /
            3,
      );
      expect(result.lastHarvestAmount, expected);
      expect(result.copy().lastHarvestAmount, expected);
      expect(result.population!.yearlyLaborSamples, 0);
    },
  );

  test(
    '90-day supply quotes and prepaid ration credits are versioned and persisted',
    () {
      final s = fresh();
      final m = WarMission(
        id: 'war',
        countryId: 'north',
        kind: 'siege',
        title: 'Công thành',
        enemyTroops: 5000,
        opened: 1,
        deadline: 3,
      );
      expect(warMissionFood(10000, s), 21600);
      expect(warMissionFood(10000, s, m), 25200);
      expect(warFoodCredit(10000, s), 13500);
      s.balanceVersion = 1;
      expect(
        warMissionFood(10000, s, m),
        foodAmount(10000 * 30 * 2 / 100 * 1.1),
      );
      expect(warFoodCredit(10000, s), 4500);
    },
  );

  test(
    'multi-season armies pay and receive ration credit once per season; recall cannot erase work already done',
    () {
      var s = fresh();
      s = send(
        s,
        'war',
        target: 'north',
        option: jsonEncode({'action': 'declare'}),
      );
      final m = WarMission(
        id: 'supplies',
        countryId: 'north',
        kind: 'siege',
        title: 'Công thành',
        enemyTroops: 5000,
        opened: s.week,
        deadline: s.week + 3,
      );
      s.warfare!.missions.add(m);
      final c = warOfficers(s).first;
      final food = s.grain;
      s = send(
        s,
        'war',
        target: m.id,
        option: jsonEncode({'action': 'deploy', 'ratio': 2}),
        assignee: c.id,
      );
      expect(s.grain, food - 25200);
      expect(s.population!.foodCredit, 13500);
      expect(s.population!.campaignWorkers, 10000);
      s = close(s);
      expect(s.population!.campaignWorkers, 10000);
      expect(s.population!.foodCredit, 0);
      final before = s.grain;
      s = send(
        s,
        'war',
        target: m.id,
        option: jsonEncode({'action': 'intervene'}),
      );
      expect(s.grain, before - 25200);
      expect(s.population!.foodCredit, 13500);
      expect(
        () => send(
          s,
          'war',
          target: m.id,
          option: jsonEncode({'action': 'intervene'}),
        ),
        throwsA(isA<GameRuleException>()),
      );
      s = send(
        s,
        'war',
        target: m.id,
        option: jsonEncode({'action': 'withdraw'}),
      );
      expect(s.copy().population!.campaignWorkers, 10000);
    },
  );
}
