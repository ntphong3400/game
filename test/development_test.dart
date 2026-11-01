import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine();
  GameState fresh() {
    final s = engine.start('development', 'An', 42);
    s.petitions.clear();
    s.nextMajorWeek = s.nextChainWeek = 10000;
    s.treasury = 5000;
    s.financialWeeks.clear();
    s.people = 60;
    s.factions.updateAll((k, v) => 60);
    for (final c in s.court) {
      c.loyalty = 90;
      c.ambition = 10;
    }
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
      id: 'dev-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );
  GameState close(GameState s, {int roll = 0}) {
    s.petitions.clear();
    s.affairsThisWeek = s.workThisWeek = s.restThisWeek = 1;
    s.rng = roll == 0 ? 100 : roll * 31 % 100;
    return send(s, 'endWeek');
  }

  Courtier qualified(GameState s, String task, {int ability = 95}) {
    final c = s.court.firstWhere((c) => c.id == 'works');
    c.specialty = developmentSpecialties[task]!;
    c.ability = ability;
    c.integrity = 95;
    c.investigated = true;
    return c;
  }

  void level(GameState s, String task, int value) {
    switch (task) {
      case 'upgrade_economy':
        s.economyLevel = value;
      case 'upgrade_farm':
        s.agricultureLevel = value;
      case 'upgrade_levee':
        s.leveeLevel = value;
    }
  }

  test('agreed levee anchors, interpolation and upper cap', () {
    for (final (condition, percent) in [
      (0, 30),
      (30, 60),
      (60, 100),
      (80, 110),
      (95, 120),
      (100, 120),
    ]) {
      expect(leveeYieldPercent(condition), percent);
    }
    expect(leveeYieldPercent(45), 80);
    expect(leveeYieldPercent(70), 105);
    expect(leveeYieldPercent(-10), 30);
    expect(leveeYieldPercent(120), 120);
  });

  for (final task in developmentTasks) {
    for (var target = 2; target <= 5; target++) {
      test(
        '$task level $target enforces ability, specialty and cost atomically',
        () {
          final s = fresh();
          level(s, task, target - 1);
          final min = [0, 0, 60, 70, 80, 90][target];
          final c = qualified(s, task, ability: min - 1);
          final before = jsonEncode(s.toJson());
          expect(
            () => send(s, 'action', target: task, option: c.id),
            throwsA(isA<GameRuleException>()),
          );
          expect(jsonEncode(s.toJson()), before);
          c.ability = min;
          c.specialty = 'Y thuật';
          expect(
            () => send(s, 'action', target: task, option: c.id),
            throwsA(isA<GameRuleException>()),
          );
          c.specialty = developmentSpecialties[task]!;
          final cost = developmentCost(s, task);
          final result = send(s, 'action', target: task, option: c.id);
          expect(result.treasury, s.treasury - cost);
          expect(result.points, s.points - 1);
          expect(developmentLevel(result, task), target - 1);
          final p = result.projects.single;
          expect(p.targetLevel, target);
          expect(p.duration, target - 1);
          expect(p.progress, 0);
          expect(p.successChance, inInclusiveRange(10, 95));
          expect(officerBusy(result, c.id), true);
          expect(
            () => send(result, 'action', target: task, option: c.id),
            throwsA(isA<GameRuleException>()),
          );
        },
      );
    }

    test(
      '$task can actually succeed or fail; reload preserves the outcome',
      () {
        for (final roll in [0, 99]) {
          var s = fresh();
          final officer = qualified(s, task);
          s = send(s, 'action', target: task, option: officer.id);
          final saved = s.copy();
          final result = close(s, roll: roll);
          final replay = close(saved, roll: roll);
          expect(replay.toJson(), result.toJson());
          expect(developmentLevel(result, task), roll == 0 ? 2 : 1);
          expect(result.projects, isEmpty);
          expect(officerBusy(result, officer.id), false);
          expect(
            result.financialWeeks.first.entries.where(
              (e) => e.title == developmentNames[task] && e.amount < 0,
            ),
            hasLength(1),
          );
          expect(
            result.outcomes.last.status,
            roll == 0 ? 'success' : 'failure',
          );
        }
      },
    );

    test(
      '$task rolls only after all construction seasons and max is enforced',
      () {
        var s = fresh();
        level(s, task, 2);
        final c = qualified(s, task);
        s = send(s, 'action', target: task, option: c.id);
        s = close(s);
        expect(developmentLevel(s, task), 2);
        expect(s.projects.single.progress, 1);
        final chance = s.projects.single.successChance;
        s = s.copy();
        expect(s.projects.single.successChance, chance);
        s = close(s);
        expect(developmentLevel(s, task), 3);
        expect(s.projects, isEmpty);
        level(s, task, 5);
        expect(
          () => send(s, 'action', target: task, option: c.id),
          throwsA(isA<GameRuleException>()),
        );
      },
    );
  }

  test(
    'invalid, unavailable, busy officers and insufficient resources are rejected',
    () {
      final s = fresh();
      final c = qualified(s, 'upgrade_economy');
      for (final id in [
        '',
        'missing',
        s.court.firstWhere((c) => c.isConsort).id,
      ]) {
        expect(
          () => send(s, 'action', target: 'upgrade_economy', option: id),
          throwsA(isA<GameRuleException>()),
        );
      }
      c.available = false;
      expect(
        () => send(s, 'action', target: 'upgrade_economy', option: c.id),
        throwsA(isA<GameRuleException>()),
      );
      c.available = true;
      s.projects.add(
        WorkOrder(
          id: 'busy',
          kind: 'commerce',
          officerId: c.id,
          startedWeek: s.week,
          duration: 5,
        ),
      );
      expect(
        () => send(s, 'action', target: 'upgrade_economy', option: c.id),
        throwsA(isA<GameRuleException>()),
      );
      s.projects.clear();
      s.treasury = 79;
      final before = jsonEncode(s.toJson());
      expect(
        () => send(s, 'action', target: 'upgrade_economy', option: c.id),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
      s.treasury = 100;
      s.points = 0;
      expect(
        () => send(s, 'action', target: 'upgrade_economy', option: c.id),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test(
    'lost officer pauses progress; qualified replacement resumes without new capital',
    () {
      var s = fresh()..economyLevel = 2;
      final officer = qualified(s, 'upgrade_economy');
      s = send(s, 'action', target: 'upgrade_economy', option: officer.id);
      s = close(s);
      s.court.firstWhere((c) => c.id == officer.id).available = false;
      s = close(s);
      expect(s.projects.single.progress, 1);
      expect(s.projects.single.paused, true);
      s = s.copy();
      final replacement = s.court.firstWhere((c) => c.id == 'treasurer');
      replacement.ability = 90;
      replacement.specialty = 'Kinh tế';
      final money = s.treasury;
      s = send(s, 'action', target: 'upgrade_economy', option: replacement.id);
      expect(s.treasury, money);
      expect(s.projects.single.progress, 1);
      expect(s.projects.single.paused, false);
      // Complete in winter so harvest RNG does not precede the success roll.
      s.completedWeeks = 3;
      s = close(s);
      expect(s.economyLevel, 3);
    },
  );

  test('economy bonus is a single annual total, with no tax-rate change', () {
    var s = fresh()..economyLevel = 3;
    expect(annualTaxGross(s), 305); // 260 + 45, not +20+45.
    expect(BudgetProjection(s).totalIncome, 80);
    s.completedWeeks = 2;
    final forecast = BudgetProjection(s);
    expect(forecast.totalIncome, 385);
    s = close(s);
    expect(s.tax, 1);
    expect(s.lastTaxRevenue, 305);
    expect(s.treasury, forecast.closingBalance);
    s = close(s);
    expect(s.lastIncome, 80);
    for (final w in s.financialWeeks) {
      expect(w.closingBalance, w.openingBalance + w.income - w.expense);
    }
  });

  test(
    'summer/spring samples survive reload; autumn repair cannot erase earlier losses',
    () {
      var s = fresh()..levee = 33;
      s = close(s); // Spring closes at 30.
      expect(s.springLeveePercent, 60);
      expect(s.lastHarvestYear, 0);
      s.levee = 68;
      s = close(s.copy()); // Summer closes at 60.
      expect(s.summerLeveePercent, 100);
      expect(s.lastHarvestYear, 0);
      s.levee = 84;
      final before = s.grain;
      s = close(s.copy()); // Autumn closes at 80.
      expect(s.lastHarvestLeveePercent, closeTo(95, .00001));
      expect(
        s.lastHarvestAmount,
        (60 * .95 * s.lastHarvestWeather / 100).round(),
      );
      expect(s.grain, before + s.lastHarvestAmount - 12);
      final previousHarvest = s.lastHarvestAmount;
      s = close(s); // Winter: no harvest, condition carries into spring.
      expect(s.lastHarvestYear, 1);
      expect(s.lastHarvestAmount, previousHarvest);
      final winterCondition = s.levee;
      s = close(s);
      expect(s.cropYear, 2);
      expect(s.cropBaselineLevee, winterCondition);
      expect(s.summerLeveePercent, isNull);
    },
  );

  test(
    'higher levee levels reduce real wear and preserve fractional remainder',
    () {
      for (final level in [1, 5]) {
        var s =
            fresh()
              ..levee = 100
              ..leveeLevel = level;
        for (var i = 0; i < 4; i++) {
          s = close(s.copy());
        }
        expect(s.levee, level == 1 ? 82 : 93);
        expect(s.leveeWearRemainder, level == 1 ? 0 : 20);
      }
    },
  );

  test('new levee level does not heal or reduce wear before completion', () {
    var s = fresh();
    final c = qualified(s, 'upgrade_levee');
    s = send(s, 'action', target: 'upgrade_levee', option: c.id);
    s = close(s);
    expect(s.leveeLevel, 2);
    expect(s.levee, 62); // Old level's 3 wear; no healing.
  });

  test(
    'agriculture levels change actual annual yields, not harvest cadence',
    () {
      for (var level = 1; level <= 5; level++) {
        var s =
            fresh()
              ..completedWeeks = 2
              ..agricultureLevel = level;
        s = close(s);
        expect(
          s.lastHarvestAmount,
          ([0, 60, 80, 100, 120, 140][level] *
                  s.lastHarvestLeveePercent *
                  s.lastHarvestWeather /
                  10000)
              .round(),
        );
        expect(s.lastHarvestYear, 1);
        final last = s.lastHarvestAmount;
        s = close(s);
        expect(s.lastHarvestAmount, last);
        expect(s.lastHarvestYear, 1);
      }
    },
  );

  test(
    'food consumption reflects peace and war without requiring an action',
    () {
      for (final war in [0, 1]) {
        final s = fresh()..war = war;
        final next = close(s);
        expect(next.grain, s.grain - (war == 0 ? 12 : 20));
        expect(next.lastHarvestYear, 0);
      }
    },
  );

  test(
    'maintenance restores condition once per season, charges even on failure',
    () {
      for (final roll in [0, 99]) {
        final s = fresh()..levee = 70;
        final c = qualified(s, 'upgrade_levee');
        s.rng = roll == 0 ? 100 : roll * 31 % 100;
        final result = send(
          s,
          'action',
          target: 'maintain_levee',
          option: c.id,
        );
        expect(result.treasury, s.treasury - 20);
        expect(result.leveeLevel, 1);
        expect(result.levee, roll == 0 ? greaterThan(70) : 68);
        expect(
          () => send(result, 'action', target: 'maintain_levee', option: c.id),
          throwsA(isA<GameRuleException>()),
        );
      }
    },
  );

  test(
    'office replacement cannot bypass development qualification or reset progress',
    () {
      var s = fresh()..leveeLevel = 2;
      final c = qualified(s, 'upgrade_levee');
      s = send(s, 'action', target: 'upgrade_levee', option: c.id);
      s = close(s);
      final replacement = s.officialsPool.first;
      replacement.ability = 20;
      replacement.specialty = 'Y thuật';
      s = send(s, 'appoint', target: c.id, option: replacement.id);
      final p = s.projects.single;
      expect(p.paused, true);
      expect(p.progress, 1);
      expect(p.officerId, c.id);
      expect(
        () =>
            send(s, 'action', target: 'upgrade_levee', option: replacement.id),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test('new economy level completed in autumn earns its bonus next year', () {
    var s = fresh()..completedWeeks = 2;
    final c = qualified(s, 'upgrade_economy');
    s = send(s, 'action', target: 'upgrade_economy', option: c.id);
    // Harvest uses one RNG draw before development. Search deterministic seeds
    // for a successful completion without changing the production probability.
    GameState? success;
    for (var seed = 1; seed <= 100; seed++) {
      final trial = s.copy()..rng = seed;
      trial.affairsThisWeek = trial.workThisWeek = trial.restThisWeek = 1;
      final next = send(trial, 'endWeek');
      if (next.economyLevel == 2) {
        success = next;
        break;
      }
    }
    expect(success, isNotNull);
    expect(success!.lastTaxRevenue, 260);
    expect(annualTaxGross(success), 280);
  });

  test('old saves default to level 1 without changing cash, grain or RNG', () {
    final s =
        fresh()
          ..completedWeeks = 1
          ..levee = 43;
    final json = s.toJson();
    for (final key in [
      'economyLevel',
      'agricultureLevel',
      'leveeLevel',
      'leveeWearRemainder',
      'cropYear',
      'cropBaselineLevee',
      'springLeveePercent',
      'summerLeveePercent',
      'lastHarvestYear',
      'lastHarvestAmount',
      'lastHarvestWeather',
      'lastHarvestLeveePercent',
    ]) {
      json.remove(key);
    }
    final loaded = GameState.fromJson(json);
    expect(loaded.economyLevel, 1);
    expect(loaded.agricultureLevel, 1);
    expect(loaded.leveeLevel, 1);
    expect(loaded.cropBaselineLevee, 43);
    expect(loaded.treasury, s.treasury);
    expect(loaded.grain, s.grain);
    expect(loaded.rng, s.rng);
    expect(loaded.copy().toJson(), loaded.toJson());
  });
}
