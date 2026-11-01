import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/frontier_rules.dart';
import 'package:van_tue/game/logic/warfare_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

final engine = GameEngine();
GameState fresh([int seed = 42]) {
  final s = engine.start('front-$seed', 'Thiên Hòa', seed);
  s.petitions.clear();
  s.nextMajorWeek = s.nextChainWeek = 100000;
  s.factions.updateAll((k, v) => 80);
  for (final c in s.court) {
    c.affection = c.loyalty = c.integrity = 100;
    c.strain = 0;
  }
  return s;
}

GameCommand command(
  GameState s,
  String type, {
  String target = '',
  String option = '',
  String leader = '',
}) => GameCommand(
  id: '$type-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: type,
  target: target,
  option: option,
  assigneeId: leader,
);
GameState transfer(GameState s, String from, String to, int count) =>
    engine.execute(
      s,
      command(
        s,
        'transfer',
        target: to,
        option: jsonEncode({'from': from, 'count': count}),
      ),
    );
GameState warOrder(
  GameState s,
  String target,
  Map<String, dynamic> data, {
  String leader = '',
}) => engine.execute(
  s,
  command(s, 'war', target: target, option: jsonEncode(data), leader: leader),
);
GameState close(GameState s) {
  s.petitions.clear();
  s.health = s.authority = s.stability = s.people = 90;
  s.workThisWeek = s.affairsThisWeek = 1;
  s.treasury = 500000;
  s.grain = 7000000;
  s.financialWeeks.clear();
  return engine.execute(s, command(s, 'endWeek'));
}

void conserved(GameState s) {
  final p = s.population!;
  expect(p.garrisons.values.fold<int>(0, (a, b) => a + b), p.soldiers);
  expect(
    p.garrisons.keys.fold<int>(0, (a, id) => a + p.availableAt(id)),
    p.availableSoldiers,
  );
  for (final id in garrisonNames.keys) {
    expect(p.stationed(id), greaterThanOrEqualTo(p.away(id)));
  }
}

void main() {
  test(
    'initial four garrisons and three real enemy pools are safe in peace',
    () {
      final s = fresh();
      expect(s.population!.garrisons, {
        'capital': 20000,
        'north': 10000,
        'west': 10000,
        'south': 10000,
      });
      for (final n in s.warfare!.neighbors) {
        expect(n.enemyTroops, 12500);
        expect(n.enemyQuality, 65);
        expect(FrontierDefense(s, n).penalty, 0);
        expect(n.lastReinforcementYear, 0);
      }
      conserved(s);
    },
  );
  for (final count in transferSizes) {
    test(
      'transfer $count costs one action, arrives immediately and preserves population and quality',
      () {
        final before = fresh();
        final s = transfer(before, 'capital', 'south', count);
        expect(s.population!.stationed('capital'), 20000 - count);
        expect(s.population!.stationed('south'), 10000 + count);
        expect(s.population!.soldiers, before.population!.soldiers);
        expect(s.population!.population, before.population!.population);
        expect(s.population!.readiness, before.population!.readiness);
        expect(s.treasury, before.treasury);
        expect(s.grain, before.grain);
        expect(s.points, before.points - 1);
        conserved(s);
        expect(before.population!.stationed('capital'), 20000);
      },
    );
  }
  test('reverse and cross-front transfers use the same army', () {
    var s = transfer(fresh(), 'west', 'south', 5000);
    s = transfer(s, 'south', 'capital', 10000);
    expect(s.population!.stationed('west'), 5000);
    expect(s.population!.stationed('south'), 5000);
    expect(s.population!.stationed('capital'), 30000);
    conserved(s);
  });
  test('invalid, fractional and unavailable transfer requests are atomic', () {
    final s = fresh();
    final before = jsonEncode(s.toJson());
    for (final args in [
      ('capital', 'capital', 2000),
      ('unknown', 'south', 2000),
      ('capital', 'south', 3000),
      ('west', 'south', 20000),
    ]) {
      expect(
        () => transfer(s, args.$1, args.$2, args.$3),
        throwsA(isA<GameRuleException>()),
      );
    }
    expect(
      () => engine.execute(
        s,
        command(
          s,
          'transfer',
          target: 'south',
          option: '{"from":"capital","count":2000.5}',
        ),
      ),
      throwsA(isA<GameRuleException>()),
    );
    expect(jsonEncode(s.toJson()), before);
    s.points = 0;
    expect(transferBlocked(s, 'capital', 'south', 2000), contains('hành động'));
  });
  test(
    'capital and source-front warnings are soft and forecast the withdrawn force',
    () {
      var s = transfer(fresh(), 'capital', 'south', 2000);
      expect(transferWarning(s, 'capital', 10000), contains('10.000'));
      final n = s.warfare!.neighbors.first;
      n.status = 'war';
      s.war = 1;
      expect(transferWarning(s, 'north', 5000), contains('giảm'));
      s = transfer(s, 'north', 'south', 5000);
      expect(s.population!.stationed('north'), 5000);
      conserved(s);
    },
  );
  test(
    'deployed soldiers cannot transfer and global reserves cannot substitute local troops',
    () {
      var s = warOrder(fresh(), 'north', {'action': 'declare'});
      final m = s.warfare!.missions.first;
      s = warOrder(s, m.id, {
        'action': 'deploy',
        'ratio': 1,
      }, leader: warOfficers(s).first.id);
      expect(s.population!.away('north'), 5000);
      expect(
        transferBlocked(s, 'north', 'south', 10000),
        contains('quân rảnh'),
      );
      s = transfer(s, 'north', 'south', 5000);
      final scout = s.warfare!.missions.firstWhere((m) => m.kind == 'scout');
      expect(s.population!.availableSoldiers, greaterThan(30000));
      expect(
        warDeployBlocked(s, scout, 1, warOfficers(s).first, null),
        contains('Thiếu'),
      );
      conserved(s);
    },
  );
  test(
    'defenders count toward their own pass while scouts and recalled armies do not',
    () {
      var s = warOrder(fresh(), 'north', {'action': 'declare'});
      final m = s.warfare!.missions.first;
      final n = s.warfare!.neighbors.first;
      final before = FrontierDefense(s, n).troops;
      s = warOrder(s, m.id, {
        'action': 'deploy',
        'ratio': 1,
      }, leader: warOfficers(s).first.id);
      expect(FrontierDefense(s, s.warfare!.neighbors.first).troops, before);
      expect(FrontierDefense(s, s.warfare!.neighbors[1]).troops, 10000);
      s = warOrder(s, m.id, {'action': 'withdraw'});
      expect(FrontierDefense(s, s.warfare!.neighbors.first).troops, 5000);
      conserved(s);
    },
  );
  test(
    'return and casualties stay at source, without duplicating the enemy pool',
    () {
      var s = warOrder(fresh(), 'south', {'action': 'declare'});
      final m = s.warfare!.missions.first;
      s = warOrder(s, m.id, {
        'action': 'deploy',
        'ratio': 1,
      }, leader: warOfficers(s).first.id);
      final d = s.population!.deployments.single;
      final forced =
          d.toJson()
            ..['succeeded'] = true
            ..['losses'] = 200
            ..['retreated'] = false;
      s.population!.deployments = [ArmyDeployment.fromJson(forced)];
      final enemyBefore = s.warfare!.neighbors.last.enemyTroops;
      s = close(s);
      final report = s.warfare!.reports.firstWhere(
        (r) => r['missionId'] == m.id,
      );
      expect(report['sourceGarrison'], 'south');
      expect(report['returned'], 4800);
      expect(s.population!.away('south'), 0);
      expect(s.population!.stationed('south'), lessThanOrEqualTo(9800));
      expect(s.warfare!.neighbors.last.enemyTroops, enemyBefore - 1250);
      expect(report['enemyLosses'], 1250);
      conserved(s);
      expect(s.copy().warfare!.neighbors.last.enemyTroops, enemyBefore - 1250);
    },
  );
  test('scouting never creates fictitious enemy casualties', () {
    var s = warOrder(fresh(), 'south', {'action': 'declare'});
    final m = s.warfare!.missions.firstWhere((m) => m.kind == 'scout');
    s = warOrder(s, m.id, {
      'action': 'deploy',
      'ratio': 1,
    }, leader: warOfficers(s).first.id);
    s.population!.deployments = [
      ArmyDeployment.fromJson(
        s.population!.deployments.single.toJson()
          ..['succeeded'] = true
          ..['retreated'] = false,
      ),
    ];
    s = close(s);
    final report = s.warfare!.reports.firstWhere((r) => r['missionId'] == m.id);
    expect(report['enemyLosses'], 0);
    expect(s.warfare!.neighbors.last.enemyTroops, 12500);
  });
  test(
    'recruitment arrives in capital and natural losses conserve all garrisons',
    () {
      var s = fresh();
      s = engine.execute(s, command(s, 'population', target: 'recruit'));
      s = close(s);
      expect(s.population!.stationed('capital'), greaterThan(24000));
      expect(s.population!.stationed('north'), lessThan(10000));
      expect(s.population!.training, lessThan(60));
      conserved(s);
    },
  );
  test('all defense thresholds and no passive advantage gain', () {
    for (final v in [
      (1.20, 0),
      (1.0, 0),
      (.999, 1),
      (.9, 1),
      (.899, 2),
      (.75, 2),
      (.749, 3),
      (.6, 3),
      (.599, 4),
      (.4, 4),
      (.399, 6),
      (0.0, 6),
    ]) {
      expect(defensePenalty(v.$1), v.$2, reason: 'R=${v.$1}');
    }
    final s = fresh();
    final n = s.warfare!.neighbors.last;
    final base = FrontierDefense(s, n);
    n.status = 'war';
    final war = FrontierDefense(s, n);
    expect(war.pressure / base.pressure, closeTo(1.15 / .8, .00001));
    n.relation = 30;
    expect(FrontierDefense(s, n).pressure / war.pressure, closeTo(.9, .00001));
    n.relation = -30;
    expect(FrontierDefense(s, n).pressure / war.pressure, closeTo(1.1, .00001));
  });
  test('season settlement applies simultaneous visible penalties once', () {
    var s = fresh();
    s.population!.garrisons = {
      'capital': 50000,
      'north': 0,
      'west': 0,
      'south': 0,
    };
    for (final n in s.warfare!.neighbors) {
      n.advantage = 20;
    }
    final forecasts = {
      for (final n in s.warfare!.neighbors) n.id: FrontierDefense(s, n).penalty,
    };
    s = close(s);
    for (final n in s.warfare!.neighbors) {
      expect(n.advantage, 20 - forecasts[n.id]!);
    }
    expect(s.warfare!.lastDefenseWeek, 1);
    expect(
      s.warfare!.reports.where((r) => r['result'] == 'defense'),
      hasLength(3),
    );
    expect(s.copy().warfare!.neighbors.map((n) => n.advantage), [14, 14, 14]);
  });
  test('low advantage in peace does not open a capital defeat mission', () {
    var s = fresh();
    for (final n in s.warfare!.neighbors) {
      n.advantage = -69;
    }
    s.population!.garrisons = {
      'capital': 50000,
      'north': 0,
      'west': 0,
      'south': 0,
    };
    s = close(s);
    expect(s.ended, false);
    expect(s.warfare!.missions.where((m) => m.kind == 'capital'), isEmpty);
  });
  test(
    'treaty, protection and one preparation season suppress defense attrition',
    () {
      final s = fresh();
      final n = s.warfare!.neighbors.first;
      s.population!.garrisons = {
        'capital': 50000,
        'north': 0,
        'west': 0,
        'south': 0,
      };
      n.status = 'treaty';
      expect(FrontierDefense(s, n).penalty, 0);
      n.status = 'peace';
      n.cooldownUntil = s.week + 1;
      n.defenseGraceThrough = n.cooldownUntil;
      expect(FrontierDefense(s, n).penalty, 0);
      s.completedWeeks++;
      expect(FrontierDefense(s, n).penalty, 0);
      s.completedWeeks++;
      expect(FrontierDefense(s, n).penalty, 6);
    },
  );
  test('annual reinforcement anchors, first draw, persistence and cap', () {
    expect(reinforcementRange(1), (low: 1000, high: 2000));
    expect(reinforcementRange(5), (low: 1800, high: 3200));
    expect(reinforcementRange(10), (low: 2800, high: 4700));
    expect(reinforcementRange(11), (low: 3000, high: 5000));
    expect(reinforcementRange(16), (low: 4000, high: 5000));
    expect(reinforcementRange(99), (low: 4000, high: 5000));
    var s = fresh();
    for (var i = 0; i < 3; i++) {
      s = close(s);
    }
    expect(s.warfare!.neighbors.map((n) => n.enemyTroops), [
      12500,
      12500,
      12500,
    ]);
    s.warfare!.neighbors.first.enemyTroops = 39500;
    s = close(s);
    expect(s.year, 2);
    final n = s.warfare!.neighbors.first;
    expect(n.enemyTroops, 40000);
    expect(n.lastReinforcement, 500);
    for (final n in s.warfare!.neighbors) {
      expect(n.lastReinforcementYear, 1);
      expect(n.lastReinforcementRoll, inInclusiveRange(1000, 2000));
      expect(n.lastReinforcementRoll % 100, 0);
    }
    final pools = s.warfare!.neighbors.map((n) => n.enemyTroops).toList();
    s = s.copy();
    s = close(s);
    expect(s.warfare!.neighbors.map((n) => n.enemyTroops), pools);
    conserved(s);
  });
  test('countries draw independently without rerolling on save/load', () {
    final draws = <String>{};
    for (var seed = 1; seed <= 12; seed++) {
      var s = fresh(seed)..completedWeeks = 3;
      s = close(s);
      draws.add(s.warfare!.neighbors.map((n) => n.lastReinforcement).join(','));
      final restored = s.copy();
      expect(restored.rng, s.rng);
      expect(
        jsonEncode(restored.warfare!.toJson()),
        jsonEncode(s.warfare!.toJson()),
      );
    }
    expect(draws.length, greaterThan(1));
    expect(draws.any((line) => line.split(',').toSet().length > 1), true);
  });
  test(
    'generated missions share enemy resource and one large objective at a time',
    () {
      var s = warOrder(fresh(), 'south', {'action': 'declare'});
      expect(s.warfare!.missions.map((m) => m.enemyTroops), [5000, 1300]);
      for (var i = 0; i < 10; i++) {
        s = close(s);
        final n = s.warfare!.neighbors.last;
        expect(reservedEnemy(s, n.id), lessThanOrEqualTo(n.enemyTroops));
        expect(
          s.warfare!.missions
              .where(
                (m) =>
                    m.countryId == n.id &&
                    liveMission(m) &&
                    largeFrontierMission(m.kind),
              )
              .length,
          lessThanOrEqualTo(1),
        );
        if (s.ended) break;
      }
    },
  );
  test(
    'old save allocation preserves totals, frozen armies and RNG exactly once',
    () {
      var s = warOrder(fresh(), 'west', {'action': 'declare'});
      final m = s.warfare!.missions.first;
      s = warOrder(s, m.id, {
        'action': 'deploy',
        'ratio': 1,
      }, leader: warOfficers(s).first.id);
      final raw = s.toJson();
      final pop = raw['population'] as Map<String, dynamic>;
      pop.remove('garrisons');
      for (final d in pop['deployments'] as List) {
        (d as Map).remove('sourceGarrison');
      }
      final war = raw['warfare'] as Map<String, dynamic>;
      war.remove('frontierVersion');
      for (final n in war['neighbors'] as List) {
        (n as Map).remove('enemyTroops');
      }
      final before = jsonEncode(raw), migrated = GameState.fromJson(raw);
      expect(jsonEncode(raw), before);
      expect(migrated.rng, s.rng);
      expect(migrated.population!.soldiers, s.population!.soldiers);
      expect(
        migrated.population!.deployments.single.losses,
        s.population!.deployments.single.losses,
      );
      expect(migrated.population!.deployments.single.sourceGarrison, 'west');
      conserved(migrated);
      expect(
        jsonEncode(migrated.copy().toJson()),
        jsonEncode(migrated.toJson()),
      );
    },
  );
  test(
    'scouting leaves the pass and enemy defeat costs only its committed troops',
    () {
      var s = warOrder(fresh(), 'south', {'action': 'declare'});
      final scout = s.warfare!.missions.firstWhere((m) => m.kind == 'scout');
      s = warOrder(s, scout.id, {
        'action': 'deploy',
        'ratio': 1,
      }, leader: warOfficers(s).first.id);
      expect(FrontierDefense(s, s.warfare!.neighbors.last).troops, 8700);
      final defender = s.warfare!.missions.firstWhere(
        (m) => m.kind == 'defend',
      );
      s = warOrder(s, defender.id, {
        'action': 'deploy',
        'ratio': 1,
      }, leader: warOfficers(s).first.id);
      final index = s.population!.deployments.indexWhere(
        (d) => d.missionId == defender.id,
      );
      s.population!.deployments[index] = ArmyDeployment.fromJson(
        s.population!.deployments[index].toJson()
          ..['succeeded'] = false
          ..['retreated'] = false,
      );
      s = close(s);
      final report = s.warfare!.reports.firstWhere(
        (r) => r['missionId'] == defender.id,
      );
      expect(report['enemyLosses'], 500);
      expect(s.warfare!.neighbors.last.enemyTroops, 12000);
      conserved(s);
    },
  );
  test('withdrawal returns soldiers to source without enemy combat losses', () {
    var s = warOrder(fresh(), 'west', {'action': 'declare'});
    final m = s.warfare!.missions.first;
    s = warOrder(s, m.id, {
      'action': 'deploy',
      'ratio': 1,
    }, leader: warOfficers(s).first.id);
    s = warOrder(s, m.id, {'action': 'withdraw'});
    s = close(s);
    expect(s.warfare!.neighbors[1].enemyTroops, 12500);
    expect(s.population!.away('west'), 0);
    expect(
      s.warfare!.reports.firstWhere(
        (r) => r['missionId'] == m.id,
      )['enemyLosses'],
      0,
    );
    conserved(s);
  });
  test(
    'twenty years conserve armies, respect the enemy cap and retain annual records',
    () {
      var s = fresh();
      for (var season = 0; season < 80; season++) {
        if (season % 8 == 0 && s.population!.recruitable >= 5000) {
          s = engine.execute(s, command(s, 'population', target: 'recruit'));
        }
        s = close(s);
        expect(s.ended, false, reason: 'season $season');
        conserved(s);
        for (final n in s.warfare!.neighbors) {
          expect(n.enemyTroops, inInclusiveRange(12500, 40000));
          expect(n.enemyQuality, 65);
          expect(n.lastReinforcementYear, (season + 1) ~/ 4);
        }
      }
      expect(s.warfare!.neighbors.map((n) => n.enemyTroops), [
        40000,
        40000,
        40000,
      ]);
      expect(
        s.warfare!.reports.where((r) => r['result'] == 'reinforcement'),
        hasLength(60),
      );
    },
  );
  test('gateway receipt prevents duplicate transfer and annual draw', () async {
    final store = MemoryGameStore();
    final gate = LocalGameGateway(store);
    var archive = await gate.start(
      name: 'An',
      runId: 'receipt-frontier',
      seed: 42,
      previousRunId: null,
      previousRevision: null,
    );
    var s = archive.active!;
    final move = command(
      s,
      'transfer',
      target: 'south',
      option: '{"from":"capital","count":2000}',
    );
    archive = await gate.dispatch(move);
    s = archive.active!;
    final after = jsonEncode(s.toJson());
    archive = await gate.dispatch(move);
    expect(jsonEncode(archive.active!.toJson()), after);
    await store.update((a) {
      a.active!.completedWeeks = 3;
      a.active!.petitions.clear();
      a.active!.affairsThisWeek = 1;
    });
    s = (await gate.load()).active!;
    final end = command(s, 'endWeek');
    archive = await gate.dispatch(end);
    final drawn = jsonEncode(archive.active!.toJson());
    archive = await gate.dispatch(end);
    expect(jsonEncode(archive.active!.toJson()), drawn);
  });
}
