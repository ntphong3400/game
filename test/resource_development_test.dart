import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/population_content.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/logic/currency_rules.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/population_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

final engine = GameEngine();

GameState fresh() {
  final s = engine.start('resource-development', 'An', 42);
  s.petitions.clear();
  s.nextMajorWeek = s.nextChainWeek = 100000;
  s.factions.updateAll((key, value) => 60);
  final c = s.court.firstWhere((c) => c.id == 'treasurer');
  c.ability = c.integrity = c.loyalty = c.affection = 100;
  c.discontent = c.strain = 0;
  c.specialty = 'Kinh tế';
  c.personalities
    ..clear()
    ..addAll([Personality.honest, Personality.dutiful]);
  c.personalityContacts = 6;
  s.rng = 1;
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
    id: 'resource-${s.revision}',
    runId: s.runId,
    expectedRevision: s.revision,
    type: type,
    target: target,
    option: option,
  ),
);

GameState close(GameState s) {
  s.petitions.clear();
  s.affairsThisWeek = s.workThisWeek = s.restThisWeek = 1;
  return send(s, 'endWeek');
}

void main() {
  test(
    'a successful purchase delivers the full officer-adjusted native amount',
    () {
      final s = fresh();
      final c = s.court.firstWhere((c) => c.id == 'treasurer');
      final amount =
          (200000 * TaskAssessment('buy_grain', c, s).rewardPercent / 100)
              .round();
      final result = send(s, 'action', target: 'buy_grain', option: c.id);
      expect(amount, greaterThan(200000));
      expect(result.grain - s.grain, amount);
      expect(result.treasury, s.treasury - 4500);
      expect(result.points, s.points - 1);
      expect(result.copy().grain, result.grain);
      expect(result.financialWeeks.single.entries.single.amount, -4500);
    },
  );

  test(
    'purchases stop at capacity, report overflow and reject a full warehouse',
    () {
      final s = fresh()..agricultureLevel = 2;
      s.grain = foodCapacity(s) - 123;
      final result = send(
        s,
        'action',
        target: 'buy_grain',
        option: 'treasurer',
      );
      expect(result.grain, 10000000);
      expect(result.treasury, s.treasury - 4500);
      expect(
        result.journal.any(
          (e) => e.title == 'Kho lương đầy' && e.text.contains('vượt sức chứa'),
        ),
        true,
      );
      expect(
        () => send(result, 'action', target: 'buy_grain', option: 'treasurer'),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test(
    'each agriculture level retains its enlarged stock through actions and reload',
    () {
      for (var level = 1; level <= 5; level++) {
        final s = fresh()..agricultureLevel = level;
        s.grain = foodCapacity(s);
        final loaded = GameState.fromJson(jsonDecode(jsonEncode(s.toJson())));
        expect(
          foodCapacity(loaded),
          [8000000, 10000000, 12000000, 14000000, 16000000][level - 1],
        );
        final result = send(loaded, 'action', target: 'rest');
        expect(result.grain, s.grain);
        expect(result.agricultureLevel, level);
      }
    },
  );

  test(
    'successful agriculture construction expands capacity without creating food',
    () {
      var s = fresh();
      final originalFood = s.grain;
      final consumption = populationFoodConsumption(s);
      s = send(s, 'action', target: 'upgrade_farm', option: 'treasurer');
      expect(foodCapacity(s), 8000000);
      s.projects.single.successChance = 100;
      s = close(s);
      expect(s.agricultureLevel, 2);
      expect(foodCapacity(s), 10000000);
      expect(s.grain, originalFood - consumption);
    },
  );

  test(
    'a high-level harvest fills the expanded warehouse and logs discarded food',
    () {
      final s =
          fresh()
            ..agricultureLevel = 5
            ..completedWeeks = 2
            ..levee = 100
            ..grain = 15000000;
      final result = close(s);
      expect(result.lastHarvestAmount, greaterThan(4000000));
      expect(result.grain, greaterThan(15000000));
      expect(result.grain, lessThanOrEqualTo(16000000));
      expect(result.journal.any((e) => e.title == 'Kho lương đầy'), true);
    },
  );

  test(
    'economy bonuses increase annual tax at every level and quotes use native units',
    () {
      final s = fresh();
      for (var level = 1; level <= 5; level++) {
        s.economyLevel = level;
        final bonus = [0, 40, 95, 170, 270][level - 1];
        expect(annualTaxGross(s), (264 + bonus) * 100);
        expect(
          developmentBenefit(s, 'upgrade_economy', level),
          contains('${whole(bonus * 100)} lượng vàng/năm'),
        );
      }
      s.economyLevel = 1;
      expect(developmentCost(s, 'upgrade_economy'), 8000);
      final description = developmentDescription(s, 'upgrade_economy');
      expect(authoredMoneyText(s, description), description);
      expect(
        developmentBenefit(s, 'upgrade_farm', 2),
        contains('4.400.000 tạ/năm'),
      );
      expect(
        developmentBenefit(s, 'upgrade_farm', 2),
        contains('10.000.000 tạ'),
      );
      expect(harvestPlan(s), contains('thực nhập'));
      expect(harvestPlan(s), contains('vượt kho'));
      expect(taskFailureHint('sell_surplus', s), contains('100.000 tạ'));
      expect(taskFailureHint('sell_surplus', s), contains('800 lượng vàng'));
      expect(taskFailureHint('commerce', s), contains('4.000 lượng vàng'));
    },
  );

  test(
    'levee construction is 35% cheaper and disaster preview equals applied damage',
    () {
      for (var level = 1; level <= 5; level++) {
        var s = fresh()..leveeLevel = level;
        if (level < 5) {
          expect(
            developmentCost(s, 'upgrade_levee'),
            [6500, 11700, 18200, 26000][level - 1],
          );
        }
        final definition = majorDefinition('flood');
        s.major = MajorMission(
          id: 'test-flood',
          kind: 'flood',
          openedWeek: 1,
          deadline: 4,
          dueWeek: 1,
          severity: 1,
          preparedness: 0,
          demanding: true,
          petitionDriven: true,
          objectives:
              definition.objectives
                  .map((g) => MissionObjective(key: g.key))
                  .toList(),
        );
        engine.prepareStoryPetitions(s);
        final p = s.petitions.singleWhere((p) => p.storyKind == 'major');
        final damage =
            eventForState(s, p.definitionId).choices[2].effects['levee']!;
        expect(damage, -(36 * (100 - (level - 1) * 10) / 100).ceil());
        final before = s.levee;
        s = send(s, 'petition', target: p.id, option: '2');
        expect(s.levee, before + damage);
        expect(s.major!.damageTaken['levee'], damage);
        final reloaded = s.copy();
        expect(reloaded.levee, s.levee);
        expect(reloaded.major!.damageTaken, s.major!.damageTaken);
      }
    },
  );

  test(
    'ordinary losses and repairs are unchanged; delayed disaster protection is applied once',
    () {
      final s = fresh()..leveeLevel = 5;
      expect(
        eventForState(s, 'levee_warning').choices.last.effects['levee'],
        -5,
      );
      expect(protectLeveeFromDisaster(s, {'levee': 12})['levee'], 12);
      final event = populationEvent(
        s,
        const EventDefinition(
          'test-disaster',
          'Thiên tai thử nghiệm',
          '',
          'Thiên tai',
          [
            EventChoice('Chờ', '', {}, laterEffects: {'levee': -20}, delay: 1),
          ],
        ),
      );
      expect(event.choices.single.laterEffects['levee'], -12);
      expect(
        populationEvent(s, event).choices.single.laterEffects['levee'],
        -12,
      );
      s.pending.add(
        Consequence(
          kind: 'eventOutcome',
          dueWeek: s.week,
          title: 'Thiên tai thử nghiệm',
          detail: 'Đã chốt',
          effects: event.choices.single.laterEffects,
        ),
      );
      s.leveeLevel = 2;
      final result = close(s.copy());
      final report = result.outcomes.singleWhere(
        (o) => o.title == 'Thiên tai thử nghiệm',
      );
      expect(report.changes['Đê điều'], -12);
      expect(
        result.pending.where((p) => p.title == 'Thiên tai thử nghiệm'),
        isEmpty,
      );
    },
  );

  test('historical saves keep their economy, levee prices and food scale', () {
    final legacy =
        GameEngine(populationEnabled: false).start('legacy', 'An', 42)
          ..economyLevel = 3
          ..leveeLevel = 2;
    expect(economyAnnualBonus(legacy), 45);
    expect(developmentCost(legacy, 'upgrade_levee'), 180);
    expect(foodCapacity(legacy), 200);
    expect(protectLeveeFromDisaster(legacy, {'levee': -20})['levee'], -20);
  });
}
