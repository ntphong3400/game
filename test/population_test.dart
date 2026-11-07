import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/logic/petition_assignment_rules.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/population_rules.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/logic/reign_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

final engine = GameEngine(goldEnabled: false);
GameState fresh() {
  final s = engine.start('population', 'An', 42);
  s.petitions.clear();
  s.nextMajorWeek = s.nextChainWeek = 100000;
  s.factions.updateAll((k, v) => 60);
  for (final c in s.court) {
    c.loyalty = c.integrity = 90;
    c.ambition = 10;
  }
  return s;
}

GameCommand command(
  GameState s,
  String type, {
  String target = '',
  String option = '',
  String assignee = '',
}) => GameCommand(
  id: 'p-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: type,
  target: target,
  option: option,
  assigneeId: assignee,
);
GameState send(
  GameState s,
  String type, {
  String target = '',
  String option = '',
  String assignee = '',
}) => engine.execute(
  s,
  command(s, type, target: target, option: option, assignee: assignee),
);
void petition(GameState s, String id, {String? instance}) => s.petitions.add(
  Petition(
    id: instance ?? id,
    definitionId: id,
    openedWeek: s.week,
    deadline: s.week + 1,
  ),
);
GameState close(GameState s) {
  s.petitions.clear();
  s.affairsThisWeek = 1;
  s.workThisWeek = 1;
  return send(s, 'endWeek');
}

void main() {
  test(
    'new seasonal reign starts with a million workers, 50,000 troops and tạ',
    () {
      final s = fresh(), p = s.population!;
      expect(p.population, 1000000);
      expect(p.soldiers, 50000);
      expect(p.civilians, 950000);
      expect(s.grain, 4000000);
      expect(populationFoodConsumption(s), 922500);
      expect(p.readiness, closeTo(71, .001));
      expect(militaryStrength(s), greaterThan(30000));
      expect(foodDays(s), 390);
    },
  );
  test(
    'old seasonal and weekly saves never acquire a population on reload',
    () {
      for (final seasonal in [true, false]) {
        final old = GameEngine(
          seasonal: seasonal,
          populationEnabled: false,
        ).start('old', 'An', 4);
        final json = old.toJson()..remove('population');
        json['rulesVersion'] = 'mvp-0.20.0';
        json['contentVersion'] = 18;
        final loaded = GameState.fromJson(json);
        expect(loaded.population, isNull);
        expect(loaded.grain, 100);
        expect(loaded.copy().population, isNull);
      }
    },
  );
  test(
    'food rounds upward once, including tiny positive receipts and zero',
    () {
      expect(foodAmount(2323.12), 2324);
      expect(foodAmount(.01), 1);
      expect(foodAmount(0), 0);
      expect(foodAmount(-1), 0);
      expect(roundTroops(2323.12), 2330);
      expect(emergencyRecruitmentCount(23.2312, true), 2330);
      expect(emergencyRecruitmentCount(5, true), 500);
      expect(emergencyRecruitmentCount(90, false), 1000);
    },
  );
  test('a normal season nets 0.35% workers and records consumption', () {
    final s = close(fresh()), p = s.population!;
    expect(p.population, 1003500);
    expect(p.civilians + p.soldiers, p.population);
    expect(s.grain, 4000000 - 922500);
    expect(p.reports.single['changes']['Người mới tới tuổi lao động'], 7000);
    expect(p.reports.single['changes']['Rời lực lượng vì tuổi già'], -2500);
    expect(p.reports.single['changes']['Bệnh tật'], -1000);
  });
  test('three production policies allocate 80/20, 20/80 and 50/50', () {
    final s = fresh(), p = s.population!;
    p.policy = 'economy';
    expect(manufacturedEquipment(s), 2000);
    expect(economicLaborFactor(s), closeTo(1, .0001));
    p.policy = 'army';
    expect(manufacturedEquipment(s), 8000);
    expect(economicLaborFactor(s), closeTo(.25, .0001));
    p.policy = 'balanced';
    expect(manufacturedEquipment(s), 5000);
    expect(economicLaborFactor(s), closeTo(.625, .0001));
  });
  test('production changes commit next season, not the current settlement', () {
    var s = fresh();
    s = send(s, 'population', target: 'production', option: 'army');
    expect(s.population!.policy, 'economy');
    expect(s.population!.nextPolicy, 'army');
    expect(budgetIncome(s).first.amount, 80);
    s = close(s);
    expect(s.population!.policy, 'army');
    expect(
      s.population!.reports.last['changes']['Sản xuất quân khí (bộ)'],
      2000,
    );
    expect(
      budgetIncome(s).first.amount,
      21,
    ); // New workers also contribute next season.
  });
  test(
    'regular recruitment and demobilization conserve population and dilute training',
    () {
      var s = send(fresh(), 'population', target: 'recruit');
      expect(s.population!.soldiers, 50000);
      expect(s.population!.orders.single.count, 5000);
      s = close(s);
      final p = s.population!;
      expect(p.population, 1003500);
      expect(p.soldiers, 49825 + 5000);
      expect(p.training, lessThan(60));
      final population = p.population, army = p.soldiers;
      s = send(s, 'population', target: 'demobilize');
      expect(s.population!.population, population);
      expect(s.population!.soldiers, army - 5000);
    },
  );
  test(
    'early labor borrows future additions, excludes recruitment, waits four seasons',
    () {
      var s = fresh();
      final before = s.population!.recruitable;
      s = send(s, 'emergency', target: 'early_labor');
      expect(s.population!.population, 1010000);
      expect(s.population!.earlyDebt, 10000);
      expect(s.population!.earlyAvailable, 5);
      expect(s.people, 57);
      expect(s.stability, 59);
      expect(s.population!.recruitable, lessThanOrEqualTo(before));
      expect(
        () => send(s, 'emergency', target: 'early_labor'),
        throwsA(isA<GameRuleException>()),
      );
      s = close(s);
      expect(s.population!.earlyDebt, 10000);
      s = close(s);
      expect(s.population!.earlyDebt, 5000);
      s = close(s);
      expect(s.population!.earlyDebt, 0);
      expect(emergencyBlocked(s, 'early_labor'), isNotNull);
      s = close(s);
      expect(s.week, 5);
      expect(emergencyBlocked(s, 'early_labor'), isNull);
    },
  );
  test(
    'emergency recruitment matches public chance; failure costs the same',
    () {
      final outcomes = <bool>{};
      for (var rng = 1; rng < 30 && outcomes.length < 2; rng++) {
        final start = fresh()..rng = rng;
        final officer = start.court.firstWhere((c) => c.id == 'general');
        final chance = actionSuccessChance(start, 'train', officer);
        final success = ((rng * 48271) % 2147483647) % 100 < chance;
        outcomes.add(success);
        final result = send(
          start,
          'emergency',
          target: 'levy',
          option: officer.id,
        );
        expect(result.population!.population, 1000000);
        expect(
          result.population!.soldiers,
          50000 + emergencyRecruitmentCount(chance, success),
        );
        expect(result.treasury, start.treasury - 15);
        expect(result.grain, start.grain - 1500);
        expect(
          result.population!.civilians,
          1000000 - result.population!.soldiers,
        );
      }
      expect(outcomes, {true, false});
      expect(
        () => send(fresh(), 'emergency', target: 'levy'),
        throwsA(isA<GameRuleException>()),
      );
    },
  );
  test(
    'refugee petition charges food and opposing faction, arrivals do not work retroactively',
    () {
      var s = fresh();
      petition(s, 'population_refugees');
      final before = s.population!.productiveCivilians;
      s = send(s, 'petition', target: 'population_refugees', option: '0');
      expect(s.treasury, 470);
      expect(s.grain, 3990000);
      expect(s.factions['Văn thần'], 63);
      expect(s.factions['Võ tướng'], 55);
      expect(s.population!.population, 1000000);
      expect(s.population!.productiveCivilians, before);
      s = close(s);
      expect(s.population!.population, 1013500);
      expect(s.population!.productiveCivilians, s.population!.civilians);
    },
  );
  test(
    'settlers and returnees arrive only once after their advertised due dates',
    () {
      var s = send(fresh(), 'population', target: 'settle');
      expect(s.population!.orders.single.due, 2);
      s = close(s);
      expect(s.population!.orders.length, 1);
      s = close(s);
      expect(s.population!.orders, isEmpty);
      s.population!.displaced = 6000;
      s = send(s, 'population', target: 'return');
      expect(s.population!.displaced, 0);
      expect(s.population!.orders.single.count, 6000);
      expect(
        () => send(s, 'population', target: 'return'),
        throwsA(isA<GameRuleException>()),
      );
      s = close(s);
      expect(s.population!.orders, isEmpty);
      expect(
        s.population!.reports.last['changes']['Kêu gọi dân lưu tán trở về'],
        6000,
      );
    },
  );
  test(
    'contingents reserve troops, survive reload and cannot be double allocated',
    () {
      var s = fresh();
      s.population!.soldiers = 5000;
      petition(s, 'population_border_skirmish', instance: 'a');
      petition(s, 'population_border_skirmish', instance: 'b');
      s = send(s, 'petition', target: 'a', option: '0');
      expect(s.population!.busySoldiers, 3000);
      expect(s.population!.availableSoldiers, 2000);
      final saved = GameState.fromJson(
        object(jsonDecode(jsonEncode(s.toJson()))),
      );
      expect(
        saved.population!.deployments.single.toJson(),
        s.population!.deployments.single.toJson(),
      );
      expect(
        () => send(saved, 'petition', target: 'b', option: '0'),
        throwsA(isA<GameRuleException>()),
      );
      final d = saved.population!.deployments.single;
      expect(
        d.losses,
        inInclusiveRange(d.succeeded ? 30 : 1500, d.succeeded ? 600 : 2100),
      );
      final food = saved.grain;
      final need = remainingFoodConsumption(saved);
      s = close(saved);
      expect(s.population!.deployments, isEmpty);
      expect(
        s
            .population!
            .reports
            .last['changes']['Tử trận: Toán địch quấy phá đường biên'],
        -d.losses,
      );
      expect(s.grain, food - need);
      expect(s.population!.soldiers, greaterThan(2500));
    },
  );
  test('large battle losses apply only to 10,000 deployed soldiers', () {
    var s = fresh();
    petition(s, 'population_major_battle');
    s = send(s, 'petition', target: 'population_major_battle', option: '0');
    final d = s.population!.deployments.single;
    expect(d.troops, 10000);
    expect(
      d.losses,
      inInclusiveRange(d.succeeded ? 2000 : 5000, d.succeeded ? 5000 : 7000),
    );
    s = close(s);
    expect(s.population!.soldiers, greaterThan(42000));
  });
  test('a supply order prepays a ration once and never creates free food', () {
    var s = send(fresh(), 'population', target: 'supply_army');
    expect(s.grain, 3980000);
    expect(s.population!.foodCredit, 20000);
    s = close(s);
    expect(s.grain, 4000000 - 922500);
  });
  test('popular support affects morale while disease affects population', () {
    final a = fresh(), b = fresh();
    a.people = 80;
    b.people = 20;
    a.population!.diseaseLevel = b.population!.diseaseLevel = 2;
    final high = close(a), low = close(b);
    expect(high.population!.morale, greaterThan(low.population!.morale));
    expect(high.population!.reports.last['changes']['Bệnh tật'], -12000);
  });
  test(
    'gateway retries do not duplicate workers, payments or recruitment',
    () async {
      final gateway = LocalGameGateway(MemoryGameStore());
      var archive = await gateway.start(
        name: 'An',
        runId: 'once',
        seed: 5,
        previousRunId: null,
        previousRevision: null,
      );
      final cmd = command(archive.active!, 'emergency', target: 'early_labor');
      archive = await gateway.dispatch(cmd);
      final json = jsonEncode(archive.active!.toJson());
      archive = await gateway.dispatch(cmd);
      expect(jsonEncode(archive.active!.toJson()), json);
    },
  );
  test('new army has no legacy 100-point cap or legacy zero-point death', () {
    final s = fresh()..army = 0;
    final result = send(s, 'action', target: 'rest');
    expect(result.ended, false);
    expect(militaryStrength(result), greaterThan(100));
    result.population!.soldiers = 0;
    final ended = send(result, 'population', target: 'recruit');
    expect(ended.ended, true);
    expect(ended.population!.soldiers, 0);
  });
  test(
    'military petitions reject commanders with a different specialty atomically',
    () {
      final s = fresh();
      petition(s, 'population_major_battle');
      final officer = s.court.firstWhere((x) => x.id == 'general');
      officer.specialty = 'An ninh';
      final before = jsonEncode(s.toJson());
      expect(
        () => send(
          s,
          'petition',
          target: 'population_major_battle',
          option: '0',
          assignee: officer.id,
        ),
        throwsA(
          isA<GameRuleException>().having(
            (e) => e.message,
            'reason',
            contains('chuyên môn Quân sự'),
          ),
        ),
      );
      expect(jsonEncode(s.toJson()), before);
    },
  );
  test(
    'military event preview and committed roll use quality and commanders',
    () {
      final s = fresh();
      petition(s, 'population_major_battle');
      final e = eventForState(s, 'population_major_battle'),
          c = e.choices.first;
      final officer = s.court.firstWhere((x) => x.id == 'general');
      final chance = petitionChance(s, e, c, officer);
      expect(petitionChance(s, e, c), 30);
      expect(chance, inInclusiveRange(35, 90));
      final result = send(
        s,
        'petition',
        target: 'population_major_battle',
        option: '0',
        assignee: officer.id,
      );
      expect(result.population!.deployments.single.chance, chance);
      s.population!.training = 0;
      s.population!.equipment = 0;
      expect(petitionChance(s, e, c, officer), lessThan(chance));
      officer.ability = 100;
      officer.affection = officer.loyalty = 100;
      officer.discontent = officer.strain = 0;
      s.factions[officer.faction] = 100;
      s.population!.training = 100;
      s.population!.equipment = 100;
      expect(petitionChance(s, e, c, officer), 90);
    },
  );
  test(
    'all existing major events accept their native food and military-stage decisions',
    () {
      for (final definition in majorDefinitions) {
        var s = fresh();
        s.major = MajorMission(
          id: 'audit-${definition.id}',
          kind: definition.id,
          openedWeek: 1,
          deadline: 4,
          severity: 1,
          preparedness: 0,
          demanding: true,
          petitionDriven: true,
          dueWeek: 1,
          objectives: [
            for (final goal in definition.objectives)
              MissionObjective(key: goal.key),
          ],
        );
        s.heirId = 'prince';
        for (var stage = 0; stage < 4; stage++) {
          s.treasury = 100000;
          s.grain = foodCapacity(s);
          s.health = s.stability = s.authority = s.people = 100;
          engine.prepareStoryPetitions(s);
          final p = s.petitions.firstWhere(
            (p) => p.storyId == 'audit-${definition.id}',
          );
          final e = eventForState(s, p.definitionId);
          expect(
            e.choices.first.grainCost,
            greaterThanOrEqualTo(0),
            reason: definition.id,
          );
          s = send(s, 'petition', target: p.id, option: '0');
          expect(
            s.population!.population,
            s.population!.civilians + s.population!.soldiers,
          );
          s.petitions.removeWhere((p) => !p.isStory);
          s = send(s, 'endWeek');
          expect(s.ended, false, reason: '${definition.id}: ${s.endReason}');
        }
        expect(
          s.majorHistory.where((m) => m.id == 'audit-${definition.id}'),
          hasLength(1),
          reason: definition.id,
        );
        expect(s.population!.deployments, isEmpty);
      }
    },
  );
  test('public disease control reduces only the population epidemic', () {
    var s = fresh();
    s.population!.diseaseLevel = 2;
    s.illness = 15;
    s = send(s, 'population', target: 'public_health');
    expect(s.population!.diseaseLevel, 1);
    expect(s.illness, 15);
    expect(s.grain, 3995000);
    expect(
      () => send(s, 'population', target: 'public_health'),
      throwsA(isA<GameRuleException>()),
    );
  });
  test(
    'insufficient native food never spends money or alters the original save',
    () {
      final s = fresh()..grain = 6999;
      final snapshot = jsonEncode(s.toJson());
      expect(
        () => send(s, 'population', target: 'settle'),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), snapshot);
    },
  );

  test(
    'demobilizing cannot erase the wages and rations for service already performed',
    () {
      var s = fresh();
      final wages = budgetExpenses(s)['army']!.amount;
      final food = populationFoodConsumption(s);
      s = send(s, 'population', target: 'demobilize');
      expect(s.population!.soldiers, 45000);
      expect(budgetExpenses(s)['army']!.amount, wages);
      expect(populationFoodConsumption(s), food);
      s = close(s);
      expect(s.population!.serviceSoldiers, s.population!.soldiers);
      expect(budgetExpenses(s)['army']!.amount, lessThan(wages));
    },
  );
  test(
    'season reports use capped morale and the actual committed strength',
    () {
      final start = fresh();
      start.population!.morale = 100;
      final result = close(start);
      expect(result.population!.morale, 100);
      final report = result.outcomes.lastWhere(
        (o) => o.title == 'Dân cư và quân đội cuối mùa',
      );
      expect(report.changes['Sĩ khí'], isNull);
      expect(
        report.changes['Quân lực'],
        militaryStrength(result) - militaryStrength(start),
      );
    },
  );
}
