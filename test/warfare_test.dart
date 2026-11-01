import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/warfare_rules.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/logic/game_gateway.dart';

final engine = GameEngine();
GameState fresh([int seed = 42]) {
  final s = engine.start('war-$seed', 'An', seed);
  s.petitions.clear();
  s.nextMajorWeek = s.nextChainWeek = 100000;
  s.factions.updateAll((k, v) => 70);
  for (final c in s.court) {
    c.affection = 90;
    c.loyalty = c.integrity = 100;
    c.strain = 0;
  }
  return s;
}

GameCommand cmd(
  GameState s,
  String target,
  Map<String, dynamic> data, {
  String leader = '',
}) => GameCommand(
  id: 'w-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: 'war',
  target: target,
  option: jsonEncode(data),
  assigneeId: leader,
);
GameState order(
  GameState s,
  String target,
  Map<String, dynamic> data, {
  String leader = '',
}) => engine.execute(s, cmd(s, target, data, leader: leader));
GameState close(GameState s) {
  s.petitions.clear();
  s.workThisWeek = s.affairsThisWeek = 1;
  s.health = s.authority = s.stability = s.people = 90;
  return engine.execute(
    s,
    GameCommand(
      id: 'end-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: 'endWeek',
    ),
  );
}

GameState war() => order(fresh(), 'north', {'action': 'declare'});
WarMission addMission(GameState s, String kind, {int enemy = 5000}) {
  final w = s.warfare!;
  final m = WarMission(
    id: 'custom-${++w.sequence}',
    countryId: 'north',
    kind: kind,
    title: warMissionNames[kind]!,
    enemyTroops: enemy,
    opened: s.week,
    deadline: s.week + 3,
  );
  w.missions.add(m);
  return m;
}

void reconcile(GameState s) {
  for (final f in s.financialWeeks) {
    expect(f.closingBalance, f.openingBalance + f.income - f.expense);
    expect(f.closingDebt, f.openingDebt + f.newDebt - f.debtReduction);
  }
}

void main() {
  test(
    'three neighbors start at zero advantage and random 10,10,0 relations',
    () {
      final s = fresh();
      expect(s.warfare!.neighbors.map((n) => n.advantage), [0, 0, 0]);
      final relations = s.warfare!.neighbors.map((n) => n.relation).toList();
      expect([...relations]..sort(), [0, 10, 10]);
      expect(s.copy().warfare!.neighbors.map((n) => n.advantage), [0, 0, 0]);
      expect(s.copy().warfare!.neighbors.map((n) => n.relation), relations);
      expect(
        GameEngine(populationEnabled: false).start('old', 'An', 1).warfare,
        isNull,
      );
      final old =
          s.toJson()
            ..remove('warfare')
            ..['rulesVersion'] = 'mvp-0.21.1';
      expect(GameState.fromJson(old).warfare!.neighbors, hasLength(3));
      expect(GameState.fromJson(old).treasury, 50000);
    },
  );
  test(
    'one war has many missions, but cannot declare against another neighbor',
    () {
      final s = war();
      expect(s.warfare!.active!.advantage, 0);
      expect(s.warfare!.missions, hasLength(2));
      expect(
        () => order(s, 'west', {'action': 'declare'}),
        throwsA(isA<GameRuleException>()),
      );
    },
  );
  test(
    'different seeds vary which country starts neutral without rerolling',
    () {
      final neutralCountries = <String>{};
      for (var seed = 1; seed <= 30; seed++) {
        final s = fresh(seed);
        final w = s.warfare!;
        expect(w.neighbors.map((n) => n.advantage), [0, 0, 0]);
        expect(w.neighbors.where((n) => n.relation == 10), hasLength(2));
        neutralCountries.add(
          w.neighbors.singleWhere((n) => n.relation == 0).id,
        );
        expect(jsonEncode(s.copy().warfare!.toJson()), jsonEncode(w.toJson()));
        expect(s.copy().rng, s.rng);
      }
      expect(neutralCountries, {'north', 'west', 'south'});
    },
  );
  test(
    'old setup is corrected once while preserving diplomacy and deployed army',
    () {
      var s = war();
      final mission = s.warfare!.missions.first;
      s = order(s, mission.id, {
        'action': 'deploy',
        'ratio': 1,
      }, leader: warOfficers(s).first.id);
      s.warfare!.neighbors.first.advantage += 15;
      s.warfare!.neighbors[1].relation += 12;
      final opening = WarfareState(seed: s.seed);
      final raw = s.toJson();
      final warfare = raw['warfare'] as Map<String, dynamic>;
      warfare.remove('initialSetupVersion');
      for (final entry in warfare['neighbors'] as List) {
        final n = entry as Map<String, dynamic>;
        if (n['id'] == 'north' || n['id'] == 'west') {
          n['advantage'] = (n['advantage'] as int) + 10;
        }
        n['relation'] =
            (n['relation'] as int) -
            opening.neighbors.firstWhere((c) => c.id == n['id']).relation;
      }
      final source = jsonEncode(raw);
      final restored = GameState.fromJson(raw);
      expect(jsonEncode(restored.toJson()), jsonEncode(s.toJson()));
      expect(jsonEncode(raw), source);
      expect(
        jsonEncode(restored.copy().toJson()),
        jsonEncode(restored.toJson()),
      );
    },
  );
  test('normal and siege ratios round up to tens and enforce minimum 200%', () {
    final s = war();
    final m = addMission(s, 'siege');
    final c = warOfficers(s).first;
    expect(warTroopRatios(m), [2, 2.5, 3]);
    expect(warTroops(m, 2), 10000);
    expect(warDeployBlocked(s, m, 1.25, c, null), isNotNull);
    expect(
      () => order(s, m.id, {'action': 'deploy', 'ratio': 1.25}, leader: c.id),
      throwsA(isA<GameRuleException>()),
    );
    final odd = addMission(s, 'defend', enemy: 2323);
    expect(warTroops(odd, .8), 1860);
  });
  test(
    'affection changes final odds independently from capability and includes deputy',
    () {
      final s = war();
      final m = s.warfare!.missions.first;
      final c = warOfficers(s).first;
      c.ability = 90;
      c.affection = 90;
      final high = WarPreview(s, m, 5000, c, null);
      c.affection = 0;
      final low = WarPreview(s, m, 5000, c, null);
      expect(low.tacticalChance, high.tacticalChance);
      expect(low.withdrawal, 40);
      expect(low.winChance, closeTo(high.winChance * .6, .00001));
      final deputy = warOfficers(s).firstWhere((d) => d.id != c.id);
      deputy.affection = 100;
      expect(warAffection(c, deputy), 30);
    },
  );
  test(
    'fortification, defense, force size and naval commander affect battle preview',
    () {
      final s = war();
      final c = warOfficers(s).first;
      final defense = addMission(s, 'defend');
      final field = addMission(s, 'battle');
      final siege = addMission(s, 'siege');
      expect(
        WarPreview(s, defense, 5000, c, null).tacticalChance,
        greaterThan(WarPreview(s, field, 5000, c, null).tacticalChance),
      );
      expect(
        WarPreview(s, field, 6250, c, null).tacticalChance,
        greaterThan(WarPreview(s, field, 4000, c, null).tacticalChance),
      );
      final weak = WarPreview(s, siege, 10000, c, null).tacticalChance;
      s.warfare!.active!.fortification = 100;
      expect(
        WarPreview(s, siege, 10000, c, null).tacticalChance,
        lessThanOrEqualTo(weak),
      );
      c.role = 'Đô đốc';
      c.specialty = 'Ngoại giao';
      expect(
        warOfficerAbility(c, naval: true),
        greaterThan(warOfficerAbility(c)),
      );
    },
  );
  test(
    'new casualty formulas permit 100% defeat, reduce victories 50-75%, and retain losses',
    () {
      expect(battleCasualtyBase(troops: 10000, enemy: 10000, command: 75), 40);
      expect(
        battleLosses(10000, 40, won: false, retreated: false, reduction: 0),
        4000,
      );
      expect(
        battleLosses(10000, 40, won: true, retreated: false, reduction: 60),
        1600,
      );
      expect(
        battleLosses(10000, 40, won: false, retreated: true, reduction: 10),
        400,
      );
      expect(
        battleLosses(10000, 100, won: false, retreated: false, reduction: 0),
        10000,
      );
      expect(
        battleLosses(10000, 100, won: true, retreated: false, reduction: 50),
        5000,
      );
      expect(
        battleLosses(123, 1, won: true, retreated: false, reduction: 75),
        1,
      );
    },
  );
  test(
    'reserves troops and both officers, charges exact quote, cannot reuse or overcommit',
    () {
      var s = war();
      final m = s.warfare!.missions.first;
      final officers = warOfficers(s);
      final leader = officers[0], deputy = officers[1];
      final quote = WarPreview(s, m, 6250, leader, deputy);
      final before = s.treasury;
      s = order(s, m.id, {
        'action': 'deploy',
        'ratio': 1.25,
        'deputy': deputy.id,
      }, leader: leader.id);
      expect(s.population!.soldiers, 50000);
      expect(s.population!.availableSoldiers, 43750);
      expect(s.treasury, before - quote.cost);
      expect(s.population!.foodCredit, warFoodCredit(6250));
      expect(officerBusy(s, leader.id), true);
      expect(officerBusy(s, deputy.id), true);
      final m2 = s.warfare!.missions[1];
      expect(
        () => order(s, m2.id, {
          'action': 'deploy',
          'ratio': 1,
        }, leader: deputy.id),
        throwsA(isA<GameRuleException>()),
      );
      final huge = addMission(s, 'battle', enemy: 100000);
      expect(
        warDeployBlocked(s, huge, .8, warOfficers(s).first, null),
        contains('Thiếu'),
      );
      reconcile(s);
    },
  );
  test(
    'simultaneous deployments only lose their own soldiers and settle once after reload',
    () {
      var s = war();
      for (final id in s.warfare!.missions.take(2).map((m) => m.id).toList()) {
        final c = warOfficers(s).first;
        s = order(s, id, {'action': 'deploy', 'ratio': 1}, leader: c.id);
      }
      final saved = jsonEncode(s.toJson());
      expect(jsonEncode(s.copy().toJson()), saved);
      final losses = s.population!.deployments.fold<int>(
        0,
        (n, d) => n + d.losses,
      );
      var baseline = s.copy();
      baseline.population!.deployments = [
        for (final d in baseline.population!.deployments)
          ArmyDeployment.fromJson(d.toJson()..['losses'] = 0),
      ];
      baseline = close(baseline);
      s = close(s.copy());
      expect(s.population!.deployments, isEmpty);
      expect(s.population!.soldiers, baseline.population!.soldiers - losses);
      expect(
        s.warfare!.reports.where((r) => r.containsKey('missionId')),
        hasLength(2),
      );
      s = close(s);
      expect(
        s.warfare!.reports.where((r) => r.containsKey('missionId')),
        hasLength(2),
      );
      expect(
        s.population!.changes.keys.where((k) => k.startsWith('Tử trận')),
        isEmpty,
      );
    },
  );
  test(
    'low-affection commander can withdraw with low casualties and lose the objective',
    () {
      GameState? deployed;
      for (var seed = 1; seed < 100; seed++) {
        var s = order(fresh(seed), 'north', {'action': 'declare'});
        final m = s.warfare!.missions.first;
        final c = warOfficers(s).first;
        c.affection = 0;
        c.ability = 100;
        s = order(s, m.id, {'action': 'deploy', 'ratio': 1}, leader: c.id);
        if (s.population!.deployments.single.retreated) {
          deployed = s;
          break;
        }
      }
      expect(deployed, isNotNull);
      final d = deployed!.population!.deployments.single;
      expect(d.succeeded, false);
      expect(d.reduction, inInclusiveRange(10, 25));
      expect(
        d.losses,
        lessThanOrEqualTo((d.troops * d.baseCasualty / 100 * .25).ceil()),
      );
      final result = close(deployed);
      expect(result.warfare!.reports.first['result'], 'retreated');
      expect(
        result.warfare!.reports.first['detail'],
        contains('tự ý rút quân'),
      );
    },
  );
  test(
    'multi-season army stays unavailable and supply intervention has a real cost',
    () {
      var s = war();
      final m = addMission(s, 'siege');
      final leader = warOfficers(s).first;
      s = order(s, m.id, {'action': 'deploy', 'ratio': 2}, leader: leader.id);
      s = close(s);
      expect(s.population!.busySoldiers, 10000);
      expect(officerBusy(s, leader.id), true);
      final active = s.warfare!.missions.firstWhere((x) => x.id == m.id);
      expect(active.intervention, true);
      final before = s.treasury;
      s = order(s, m.id, {'action': 'intervene'});
      expect(s.treasury, before - 1000);
      expect(
        () => order(s, m.id, {'action': 'intervene'}),
        throwsA(isA<GameRuleException>()),
      );
      s = close(s);
      expect(s.population!.busySoldiers, 0);
      expect(officerBusy(s, leader.id), false);
      expect(
        s.warfare!.reports.where((r) => r['missionId'] == m.id),
        hasLength(1),
      );
      reconcile(s);
    },
  );
  test(
    'peace recalls armies without duplicate combat and preserves return schedule',
    () {
      var s = war();
      final m = addMission(s, 'siege');
      final c = warOfficers(s).first;
      s = order(s, m.id, {'action': 'deploy', 'ratio': 2}, leader: c.id);
      final due = s.population!.deployments.single.due;
      s = order(s, 'north', {
        'action': 'negotiate',
        'tier': 'light',
        'surrender': true,
      });
      expect(s.war, 0);
      expect(s.population!.busySoldiers, 10000);
      expect(s.population!.deployments.single.losses, 0);
      expect(s.population!.deployments.single.due, due);
      s = close(s);
      expect(s.population!.busySoldiers, 10000);
      s = close(s);
      expect(s.population!.busySoldiers, 0);
      expect(s.warfare!.reports.first['losses'], 0);
      expect(
        s.population!.changes.keys.where((k) => k.startsWith('Tử trận')),
        isEmpty,
      );
      expect(s.warfare!.reports.first['result'], 'recalled');
    },
  );
  test(
    'receiving tribute first settles after four seasons and repeats annually, never each season',
    () {
      var s = fresh();
      final n = s.warfare!.neighbors.first;
      n.status = 'treaty';
      n.treaty = TributeTreaty(
        tier: 'light',
        receiving: true,
        annualGold: 5000,
        signed: s.week,
        installments: 2,
      );
      for (var i = 0; i < 4; i++) {
        s = close(s);
      }
      expect(s.warfare!.neighbors.first.treaty!.paidInstallments, 0);
      expect(tributeReceipts(s).single.amount, 5000);
      final projection = BudgetProjection(s);
      s = close(s);
      expect(s.warfare!.neighbors.first.treaty!.paidInstallments, 1);
      expect(
        s.financialWeeks.last.entries
            .where((e) => e.title == 'Triều cống từ Hàn Kỳ')
            .single
            .amount,
        5000,
      );
      expect(s.financialWeeks.last.closingBalance, projection.closingBalance);
      s = close(s);
      expect(s.warfare!.neighbors.first.treaty!.paidInstallments, 1);
      reconcile(s);
    },
  );
  test('outgoing tribute uses gold tiers and occurs only in due budget', () {
    var s = war();
    s.warfare!.active!.advantage = -80;
    expect(
      () => order(s, 'north', {
        'action': 'negotiate',
        'tier': 'light',
        'surrender': true,
      }),
      throwsA(isA<GameRuleException>()),
    );
    s = order(s, 'north', {
      'action': 'negotiate',
      'tier': 'heavy',
      'surrender': true,
    });
    final t = s.warfare!.neighbors.first.treaty!;
    expect(t.annualGold, 17000);
    expect(t.installments, 3);
    expect(t.nextDue, t.signed + 4);
    s.completedWeeks = t.nextDue - 1;
    final projection = BudgetProjection(s);
    s = close(s);
    final week = s.financialWeeks.last;
    expect(
      week.entries.where((e) => e.category == 'tribute').single.amount,
      -17000,
    );
    expect(week.closingBalance, projection.closingBalance);
    reconcile(s);
  });
  test(
    'unpaid tribute is recorded once, can extend or repay, not duplicated into ordinary debt',
    () {
      var s = fresh();
      final n = s.warfare!.neighbors.first;
      n.status = 'treaty';
      n.treaty = TributeTreaty(
        tier: 'heavy',
        receiving: false,
        annualGold: 17000,
        signed: s.week - 4,
        installments: 3,
      );
      s.treasury = 0;
      s.financialWeeks.clear();
      s = close(s);
      final t = s.warfare!.neighbors.first.treaty!;
      expect(t.arrears, greaterThan(0));
      expect(s.debt, lessThan(t.arrears));
      final missing = t.arrears;
      final paid = t.annualGold - missing;
      expect(
        s.financialWeeks.first.entries
            .where((e) => e.category == 'tribute')
            .single
            .amount,
        -paid,
      );
      s = order(s, 'north', {'action': 'extend'});
      expect(s.warfare!.neighbors.first.treaty!.graceUntil, s.week + 1);
      s.treasury = 50000;
      s.financialWeeks.clear();
      s = order(s, 'north', {'action': 'pay'});
      expect(s.treasury, 50000 - missing);
      expect(s.warfare!.neighbors.first.treaty!.arrears, 0);
      expect(
        () => order(s, 'north', {'action': 'pay'}),
        throwsA(isA<GameRuleException>()),
      );
      reconcile(s);
    },
  );
  test(
    'missing a tribute grace period breaks treaty and warns before restarting war',
    () {
      var s = fresh();
      final n = s.warfare!.neighbors.first;
      n.status = 'treaty';
      n.treaty =
          TributeTreaty(
              tier: 'light',
              receiving: false,
              annualGold: 5000,
              signed: s.week,
              installments: 2,
            )
            ..arrears = 3000
            ..graceUntil = s.week;
      s = close(s);
      expect(s.warfare!.neighbors.first.treaty!.broken, true);
      expect(s.warfare!.active, isNull);
      s = close(s);
      expect(s.warfare!.active!.id, 'north');
      expect(s.warfare!.active!.treaty!.arrears, 3000);
    },
  );
  test(
    'completed treaty ends income and protects peace for four more seasons',
    () {
      var s = fresh();
      final n = s.warfare!.neighbors.first;
      n.status = 'treaty';
      n.treaty = TributeTreaty(
        tier: 'light',
        receiving: true,
        annualGold: 5000,
        signed: s.week - 8,
        installments: 2,
      )..paidInstallments = 1;
      final settled = s.week;
      s = close(s);
      final done = s.warfare!.neighbors.first;
      expect(done.status, 'peace');
      expect(done.cooldownUntil, settled + 4);
      expect(tributeReceipts(s), isEmpty);
      expect(
        () => order(s, 'north', {'action': 'declare'}),
        throwsA(isA<GameRuleException>()),
      );
    },
  );
  test(
    'capital threat is explicit and loss only follows ignoring or losing the final defense',
    () {
      var s = war();
      s.warfare!.missions.clear();
      s.warfare!.active!.advantage = -75;
      s = close(s);
      expect(s.ended, false);
      final capital = s.warfare!.missions.firstWhere(
        (m) => m.kind == 'capital',
      );
      expect(capital.deadline, greaterThanOrEqualTo(s.week));
      s = order(s, capital.id, {'action': 'decline'});
      expect(s.ended, true);
      expect(s.endKind, 'invasion');
    },
  );
  test(
    'all troops may be busy without immediate defeat and insufficient selections are blocked',
    () {
      var s = war();
      s.warfare!.missions.clear();
      final m = addMission(s, 'battle', enemy: 50000);
      s.population!.garrisons = {
        'capital': 0,
        'north': 50000,
        'west': 0,
        'south': 0,
      };
      s.warfare!.active!.enemyTroops = 50000;
      final c = warOfficers(s).first;
      s.treasury = 100000;
      s.financialWeeks.clear();
      s = order(s, m.id, {'action': 'deploy', 'ratio': 1}, leader: c.id);
      expect(s.population!.availableSoldiers, 0);
      expect(s.ended, false);
      final second = addMission(s, 'defend');
      expect(
        warDeployBlocked(s, second, .8, warOfficers(s).first, null),
        contains('Thiếu'),
      );
    },
  );
  test(
    'military petition opens a selectable mission without charging fixed troops or fees',
    () {
      var s = fresh();
      final e = eventForState(s, 'population_border_skirmish');
      expect(e.choices.first.troops, 0);
      expect(e.choices.first.effects['warMission'], 3000);
      s.petitions.add(
        Petition(
          id: 'source',
          definitionId: e.id,
          openedWeek: s.week,
          deadline: s.week,
        ),
      );
      final before = s.treasury;
      final points = s.points;
      s = engine.execute(
        s,
        GameCommand(
          id: 'source-open',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'petition',
          target: 'source',
          option: '0',
        ),
      );
      expect(s.treasury, before);
      expect(s.points, points);
      expect(s.population!.deployments, isEmpty);
      expect(s.warfare!.missions.any((m) => m.title == e.title), true);
    },
  );
  test(
    'gateway retry cannot duplicate an army, payment, or change a frozen result',
    () async {
      final store = MemoryGameStore();
      final gate = LocalGameGateway(store);
      var a = await gate.start(
        name: 'An',
        runId: 'war-retry',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      a = await gate.dispatch(cmd(a.active!, 'north', {'action': 'declare'}));
      final s = a.active!;
      final m = s.warfare!.missions.first;
      final c = warOfficers(s).first;
      final command = cmd(s, m.id, {
        'action': 'deploy',
        'ratio': 1,
      }, leader: c.id);
      a = await gate.dispatch(command);
      final snapshot = jsonEncode(a.active!.toJson());
      a = await gate.dispatch(command);
      expect(jsonEncode(a.active!.toJson()), snapshot);
      expect(a.active!.population!.deployments, hasLength(1));
    },
  );
  test(
    'victory has nonzero casualties with a saved 50-75 percent reduction',
    () {
      ArmyDeployment? victory;
      for (var seed = 1; seed < 50; seed++) {
        var s = order(fresh(seed), 'north', {'action': 'declare'});
        final m = s.warfare!.missions.first;
        final c = warOfficers(s).first;
        s = order(s, m.id, {'action': 'deploy', 'ratio': 1.25}, leader: c.id);
        final d = s.population!.deployments.single;
        if (d.succeeded) {
          victory = d;
          break;
        }
      }
      expect(victory, isNotNull);
      final d = victory!;
      expect(d.losses, greaterThan(0));
      expect(d.reduction, inInclusiveRange(50, 75));
      expect(
        d.losses,
        battleLosses(
          d.troops,
          d.baseCasualty,
          won: true,
          retreated: false,
          reduction: d.reduction,
        ),
      );
    },
  );
  test(
    'postures trade success odds against casualties instead of a dominant attack option',
    () {
      final s = war();
      final m = s.warfare!.missions.first;
      final c = warOfficers(s).first;
      final cautious = WarPreview(s, m, 5000, c, null, tactic: 'defend');
      final aggressive = WarPreview(s, m, 5000, c, null, tactic: 'attack');
      expect(aggressive.tacticalChance, greaterThan(cautious.tacticalChance));
      expect(aggressive.defeatLoss, greaterThan(cautious.defeatLoss));
    },
  );
  test(
    'broken treaty debt survives replacement peace and can be paid once',
    () {
      var s = war();
      final n = s.warfare!.active!;
      n.treaty =
          TributeTreaty(
              tier: 'heavy',
              receiving: false,
              annualGold: 17000,
              signed: 1,
              installments: 3,
            )
            ..arrears = 3000
            ..broken = true;
      s = order(s, 'north', {
        'action': 'negotiate',
        'tier': 'light',
        'surrender': true,
      });
      expect(s.warfare!.neighbors.first.oldPayable, 3000);
      final before = s.treasury;
      s = order(s, 'north', {'action': 'oldPay'});
      expect(s.treasury, before - 3000);
      expect(s.warfare!.neighbors.first.oldPayable, 0);
      expect(
        () => order(s, 'north', {'action': 'oldPay'}),
        throwsA(isA<GameRuleException>()),
      );
    },
  );
  test(
    'an annihilated field army opens a capital warning and still permits surrender',
    () {
      var s = war();
      s.warfare!.missions.clear();
      s.warfare!.active!.advantage = -60;
      final m = addMission(s, 'defend', enemy: 50000);
      s.population!.garrisons = {
        'capital': 0,
        'north': 50000,
        'west': 0,
        'south': 0,
      };
      s.warfare!.active!.enemyTroops = 50000;
      final c = warOfficers(s).first;
      s.treasury = 100000;
      s.financialWeeks.clear();
      s = order(s, m.id, {'action': 'deploy', 'ratio': 1}, leader: c.id);
      final d = s.population!.deployments.single;
      s.population!.deployments = [
        ArmyDeployment.fromJson(
          d.toJson()
            ..['losses'] = 50000
            ..['succeeded'] = false
            ..['retreated'] = false,
        ),
      ];
      s = close(s);
      expect(s.population!.soldiers, 0);
      expect(s.ended, false);
      expect(
        s.warfare!.missions.any(
          (m) => m.kind == 'capital' && m.status == 'open',
        ),
        true,
      );
      s = order(s, 'north', {
        'action': 'negotiate',
        'tier': 'heavy',
        'surrender': true,
      });
      expect(s.ended, false);
      expect(s.war, 0);
    },
  );
  test(
    'military major waits for its selectable army mission and records its actual outcome',
    () {
      var s = fresh();
      final definition = majorDefinition('invasion');
      s.major = MajorMission(
        id: 'military-story',
        kind: definition.id,
        openedWeek: 1,
        deadline: 8,
        severity: 1,
        preparedness: 0,
        petitionDriven: true,
        dueWeek: 1,
        objectives: [
          for (final goal in definition.objectives)
            MissionObjective(key: goal.key),
        ],
      );
      final stage = definition.objectives.indexWhere(
        (g) => g.specialty == 'Quân sự',
      );
      s.major!.stage = stage;
      engine.prepareStoryPetitions(s);
      final p = s.petitions.firstWhere((p) => p.storyId == 'military-story');
      final e = eventForState(s, p.definitionId);
      final index = e.choices.indexWhere(
        (c) => c.effects.containsKey('warMission'),
      );
      expect(index, greaterThanOrEqualTo(0));
      s = engine.execute(
        s,
        GameCommand(
          id: 'major-open',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'petition',
          target: p.id,
          option: '$index',
        ),
      );
      final mission = s.warfare!.missions.firstWhere(
        (m) => m.majorId == 'military-story',
      );
      expect(s.major!.objectives[stage].done, false);
      final c = warOfficers(s).first;
      s = order(s, mission.id, {
        'action': 'deploy',
        'ratio': 1.25,
      }, leader: c.id);
      for (var turn = 0; turn < mission.duration; turn++) {
        for (final m in s.warfare!.missions.where(
          (m) => m.majorId.isEmpty && m.status == 'open',
        )) {
          m.status = 'cancelled';
        }
        final current = s.warfare!.missions.firstWhere(
          (m) => m.id == mission.id,
        );
        if (current.intervention) {
          s = order(s, mission.id, {'action': 'intervene'});
        }
        s = close(s);
      }
      expect(
        s.warfare!.reports.where((r) => r['missionId'] == mission.id),
        hasLength(1),
      );
      final report = s.warfare!.reports.firstWhere(
        (r) => r['missionId'] == mission.id,
      );
      final major =
          s.major ?? s.majorHistory.firstWhere((m) => m.id == 'military-story');
      expect(major.objectives[stage].done, report['result'] == 'success');
    },
  );

  test(
    'last annual term expires on schedule even when counterpart still owes tribute',
    () {
      var s = fresh();
      final n = s.warfare!.neighbors.first;
      n.status = 'treaty';
      n.treaty =
          TributeTreaty(
              tier: 'light',
              receiving: true,
              annualGold: 5000,
              signed: s.week - 8,
              installments: 2,
            )
            ..paidInstallments = 2
            ..arrears = 1200
            ..graceUntil = s.week + 1;
      s = close(s);
      final ended = s.warfare!.neighbors.first;
      expect(ended.status, 'peace');
      expect(ended.treaty!.arrears, 1200);
      expect(tributeReceipts(s), isEmpty);
      s = order(s, 'north', {'action': 'forgive'});
      expect(s.warfare!.neighbors.first.treaty!.arrears, 0);
    },
  );
}
