import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/logic/reign_rules.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine();
  GameState fresh() {
    final s = engine.start('season', 'An', 42);
    s.petitions.clear();
    s.nextMajorWeek = s.nextChainWeek = 10000;
    s.factions.updateAll((k, v) => 60);
    for (final c in s.court) {
      c.loyalty = c.integrity = 90;
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
      id: 'season-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );
  MajorMission mission(GameState s) => MajorMission(
    id: 'm',
    kind: 'flood',
    openedWeek: s.week,
    deadline: s.week + 1,
    severity: 1,
    preparedness: 0,
    objectives:
        majorDefinition(
          'flood',
        ).objectives.map((d) => MissionObjective(key: d.key)).toList(),
  );
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
    'production defaults use four seasons/year, twelve actions and correct 82-year duration',
    () {
      final s = engine.start('calendar', 'An', 42);
      expect(s.seasonal, true);
      expect(s.points, 12);
      expect(s.age, 18);
      expect(s.season, 'Xuân');
      expect(s.year, 1);
      for (var n = 0; n < 4; n++) {
        s.completedWeeks = n;
        expect(s.season, seasonNames[n]);
        expect(s.age, 18);
      }
      s.completedWeeks = 4;
      expect(s.age, 19);
      expect(s.year, 2);
      expect(s.season, 'Xuân');
      s.completedWeeks = 328;
      expect(s.age, 100);
      expect(s.duration, '82 năm 0 mùa');
      expect(s.toJson()['timeUnit'], 'season');
      expect(s.copy().toJson(), s.toJson());
    },
  );

  test('petition counts vary across seeds and stay fixed after reload', () {
    final targets = <int>{};
    for (var seed = 1; seed <= 60; seed++) {
      final s = engine.start('random-$seed', 'An', seed);
      targets.add(s.seasonPetitionTarget);
      expect(s.seasonPetitionTarget, inInclusiveRange(4, 6));
      expect(s.petitions, hasLength(s.seasonPetitionTarget));
      final restored = s.copy();
      expect(restored.rng, s.rng);
      expect(restored.seasonPetitionTarget, s.seasonPetitionTarget);
      var result = restored;
      for (var i = 0; i < 6; i++) {
        result = send(result, 'action', target: 'rest');
      }
      expect(result.petitions, hasLength(s.seasonPetitionTarget));
      expect(
        result.petitions.map((p) => p.id).toSet(),
        hasLength(s.seasonPetitionTarget),
      );
    }
    expect(targets, {4, 5, 6});
  });

  test('0.11 saves gain four actions once and retain petitions and RNG', () {
    for (final remaining in [0, 3, 8]) {
      final original =
          engine.start('upgrade-$remaining', 'An', 42)
            ..points = remaining
            ..seasonActionsSpent = 8 - remaining
            ..seasonPetitionTarget = 6;
      final raw =
          original.toJson()
            ..['rulesVersion'] = 'mvp-0.11.1'
            ..['contentVersion'] = 12;
      final restored = GameState.fromJson(raw);
      expect(restored.points, remaining + 4);
      expect(restored.seasonActionsSpent, original.seasonActionsSpent);
      expect(restored.seasonPetitionTarget, 6);
      expect(restored.rng, original.rng);
      expect(
        restored.petitions.map((p) => p.toJson()).toList(),
        raw['petitions'],
      );
      expect(restored.copy().toJson(), restored.toJson());
      raw['rulesVersion'] = 'mvp-0.10.1';
      raw['contentVersion'] = 11;
      expect(GameState.fromJson(raw).points, remaining + 2);
      raw['rulesVersion'] = 'mvp-0.11.1';
      raw['contentVersion'] = 12;
      raw['endReason'] = 'Finished';
      expect(GameState.fromJson(raw).points, remaining);
      raw['endReason'] = null;
      raw['timeUnit'] = 'week';
      expect(GameState.fromJson(raw).points, remaining);
    }
  });

  test(
    'loading a partial season reveals only its missing half, once',
    () async {
      for (final alreadyDelivered in [false, true]) {
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store);
        final original = engine.start('partial', 'An', 42);
        final target = original.seasonPetitionTarget;
        final initial = (target + 1) ~/ 2;
        final resolvedId = original.petitions.first.id;
        original.petitions =
            original.petitions
                .skip(1)
                .take((alreadyDelivered ? target : initial) - 1)
                .toList();
        original.midSeasonDelivered = alreadyDelivered;
        original.points = 11;
        original.seasonActionsSpent = 1;
        final raw = original.toJson()..['rulesVersion'] = 'mvp-0.12.0';
        final old = GameState.fromJson(raw);
        expect(old.points, 11);
        await store.update((a) => a.active = old);
        final results = await Future.wait([gateway.load(), gateway.load()]);
        for (final a in results) {
          final s = a.active!;
          expect(s.petitions, hasLength(target - 1));
          expect(s.petitions.any((p) => p.id == resolvedId), false);
          expect(s.midSeasonDelivered, true);
          expect(s.points, 11);
          expect(s.seasonActionsSpent, 1);
          expect(s.treasury, original.treasury);
          expect(s.revision, original.revision + (alreadyDelivered ? 0 : 1));
        }
        final saved = (await store.read()).active!;
        expect((await gateway.load()).active!.toJson(), saved.toJson());
        expect((await gateway.load()).active!.rng, saved.rng);
      }
    },
  );

  test(
    'old weekly saves preserve age, RNG, points, debts and active deadlines',
    () {
      final old =
          GameEngine(seasonal: false).start('old', 'An', 42)
            ..completedWeeks = 104
            ..debt = 75
            ..points = 2;
      final raw =
          old.toJson()
            ..['rulesVersion'] = 'mvp-0.9.0'
            ..['contentVersion'] = 9;
      raw.remove('timeUnit');
      raw.remove('scoreRules');
      final restored = GameState.fromJson(raw);
      expect(restored.seasonal, false);
      expect(restored.age, 20);
      expect(restored.rng, old.rng);
      expect(restored.points, 2);
      expect(restored.debt, 75);
      expect(restored.nextMajorWeek, old.nextMajorWeek);
      expect(restored.scoreRules, 'mvp-0.9.0');
      expect(restored.copy().toJson(), restored.toJson());
    },
  );

  test(
    'all 4–6 petitions arrive at opening and actions never deliver an extra batch',
    () {
      var s = engine.start('petitions', 'An', 42);
      final target = s.seasonPetitionTarget;
      expect(target, inInclusiveRange(4, 6));
      expect(s.petitions.length, target);
      final original = s.petitions.first;
      s = send(s, 'petition', target: original.id, option: '2');
      expect(s.points, 11);
      expect(s.seasonActionsSpent, 1);
      for (var i = 0; i < 4; i++) {
        s = send(s, 'action', target: 'rest');
      }
      expect(s.midSeasonDelivered, true);
      s = send(s.copy(), 'action', target: 'rest');
      expect(s.midSeasonDelivered, true);
      expect(s.petitions.length + 1, target);
      final count = s.petitions.length;
      s = send(s.copy(), 'action', target: 'rest');
      expect(s.petitions.length, count);
      expect(s.journal.where((n) => n.title == 'Tin đến giữa mùa'), isEmpty);
    },
  );

  test(
    'closing a season preserves unresolved petitions and opens the full next batch',
    () {
      final s = engine.start('early', 'An', 42);
      final count = s.seasonPetitionTarget;
      final result = send(s, 'endWeek');
      expect(result.seasonPetitionTarget, inInclusiveRange(4, 6));
      expect(
        result.petitions.where((p) => p.openedWeek == 1),
        hasLength(count),
      );
      expect(
        result.petitions.where((p) => p.openedWeek == 2),
        hasLength(result.seasonPetitionTarget),
      );
      expect(result.season, 'Hạ');
      expect(result.points, 12);
      expect(result.seasonActionsSpent, 0);
      expect(result.midSeasonDelivered, true);
      reconcile(result);
    },
  );

  test(
    'a 0.15.1 season retains its drawn petitions and uses 4–6 only from the next season',
    () async {
      final s =
          fresh()
            ..seasonPetitionTarget = 9
            ..midSeasonDelivered = true;
      final definitions =
          events
              .where((e) => e.condition == 'any' && eventTrigger(e).isEmpty)
              .take(9)
              .toList();
      s.petitions = [
        for (var i = 0; i < definitions.length; i++)
          Petition(
            id: 'old-$i',
            definitionId: definitions[i].id,
            openedWeek: 1,
            deadline: 2,
          ),
      ];
      final raw =
          s.toJson()
            ..['rulesVersion'] = 'mvp-0.15.1'
            ..remove('scoreRules');
      final restored = GameState.fromJson(raw);
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store);
      await store.update((a) => a.active = restored);
      final loaded = (await gateway.load()).active!;
      expect(loaded.seasonPetitionTarget, 9);
      expect(
        loaded.petitions.map((p) => p.toJson()).toList(),
        raw['petitions'],
      );
      expect(loaded.rng, s.rng);
      expect(loaded.points, s.points);
      expect(loaded.scoreRules, 'mvp-0.15.1');
      final result = send(loaded, 'endWeek');
      expect(result.seasonPetitionTarget, inInclusiveRange(4, 6));
      expect(result.petitions.where((p) => p.openedWeek == 1), hasLength(9));
      expect(
        result.petitions.where((p) => p.openedWeek == 2),
        hasLength(result.seasonPetitionTarget),
      );
      expect(result.copy().toJson(), result.toJson());
    },
  );

  test(
    'difficulty follows explicit seasonal milestones and uses the same budget forecast',
    () {
      final s = fresh();
      for (final (turns, stage, cost) in [
        (0, 0, 0),
        (1, 1, 8),
        (3, 1, 8),
        (4, 2, 16),
        (19, 2, 16),
        (20, 3, 24),
        (59, 3, 24),
        (60, 4, 32),
        (119, 4, 32),
        (120, 5, 40),
      ]) {
        s.completedWeeks = turns;
        expect(reignStage(s), stage);
        expect(budgetExpenses(s)['realm']?.amount ?? 0, cost);
        expect(reignStageHint(s), contains('mùa'));
      }
      s.completedWeeks = 3;
      s.affairsThisWeek = 1;
      final forecast = BudgetProjection(s), result = send(s, 'endWeek');
      expect(result.treasury, forecast.closingBalance);
      expect(result.debt, forecast.closingDebt);
      expect(
        result.journal.any((n) => n.title == 'Giai đoạn Tranh quyền'),
        true,
      );
      reconcile(result);
    },
  );

  test('each difficulty milestone is announced one season in advance', () {
    for (final before in [3, 19, 59, 119]) {
      final s =
          fresh()
            ..completedWeeks = before - 1
            ..affairsThisWeek = 1
            ..rng = 100;
      final result = send(s, 'endWeek');
      expect(
        result.journal.any(
          (n) => n.title == 'Thế cục sắp đổi' && n.text.contains('1 mùa'),
        ),
        true,
      );
    }
  });

  test(
    'seasonal event weights, eligibility and mission durations fit the annual calendar',
    () {
      final s = fresh();
      final drought = majorDefinition('db-21');
      final springWeight = majorWeight(s, drought);
      s.completedWeeks = 1;
      expect(majorWeight(s, drought), greaterThan(springWeight));
      expect(majorSeasonHint('Hạ'), contains('vỡ đê'));
      expect(majorPreferredSeasons(majorDefinition('db-23')), {'Xuân'});
      expect(majorDuration(s, majorDefinition('flood')), 4);
      expect(majorDuration(s, majorDefinition('invasion')), 4);
      for (final d in majorDefinitions) {
        expect(majorPreferredSeasons(d), isNotEmpty);
        expect(majorDuration(s, d), d.objectives.length);
      }
    },
  );

  test(
    'major starts use the live season/stage and preserve a complete 3–5 season rest',
    () {
      var s =
          fresh()
            ..nextMajorWeek = 2
            ..affairsThisWeek = 1;
      s = send(s, 'endWeek');
      expect(s.major, isNotNull);
      expect(s.major!.openedWeek, 2);
      expect(s.major!.severity, 2);
      expect(
        s.major!.deadline - s.major!.openedWeek + 1,
        majorDuration(s, majorDefinition(s.major!.kind)),
      );
      for (final o in s.major!.objectives) {
        o.done = true;
        o.delivered = 100;
      }
      s.petitions.clear();
      s.affairsThisWeek = 1;
      s = send(s, 'endWeek').copy();
      expect(s.lastMajorGap, inInclusiveRange(3, 5));
      final next = s.nextMajorWeek;
      while (s.week < next) {
        expect(s.major, isNull);
        s.petitions.clear();
        s.affairsThisWeek = 1;
        s = send(s, 'endWeek').copy();
      }
      expect(s.major, isNotNull);
      expect(s.major!.openedWeek, next);
      s.completedWeeks = 60;
      expect(majorGap(s, 0), 3);
      expect(majorGap(s, 20), 5);
    },
  );

  test(
    'multi-season work reserves its official and records a goal only at actual completion',
    () {
      var s = fresh();
      s.major = mission(s);
      s = send(s, 'mission', target: 'levee', option: 'works');
      expect(s.major!.objectives.first.finishWeek, 2);
      s = send(s, 'endWeek');
      expect(s.major!.achieved, 0);
      s.petitions.clear();
      s.affairsThisWeek = 1;
      s.rng = 100;
      s = send(s, 'endWeek');
      expect(s.majorHistory.single.objectives.first.done, true);
      reconcile(s);
    },
  );

  test(
    'loan repayments retain total 150 and settle over three later seasons',
    () {
      var s = send(fresh(), 'emergency', target: 'borrow');
      expect(s.obligations.single.amount, 50);
      expect(s.obligations.single.remaining, 3);
      for (var i = 0; i < 4; i++) {
        s.petitions.clear();
        s.affairsThisWeek = 1;
        s = send(s, 'endWeek').copy();
      }
      expect(s.obligations.where((o) => o.kind == 'borrow'), isEmpty);
      final paid = s.financialWeeks
          .expand((w) => w.entries)
          .where((e) => e.title == 'Vay thế gia' && e.amount < 0)
          .fold<int>(0, (n, e) => n - e.amount);
      expect(paid, 150);
      reconcile(s);
    },
  );

  test(
    'annual harvest occurs in autumn once and officers age after four seasons',
    () {
      var s = fresh();
      final age = s.court.first.age;
      for (var i = 0; i < 4; i++) {
        s.petitions.clear();
        s.affairsThisWeek = 1;
        s = send(s, 'endWeek');
      }
      expect(s.age, 19);
      expect(s.court.first.age, age + 1);
      expect(s.journal.where((n) => n.title == 'Mùa gặt'), hasLength(1));
    },
  );

  test(
    'gateway retries cannot duplicate seasonal petitions, time or seasonal scores',
    () async {
      final gateway = LocalGameGateway(MemoryGameStore());
      var archive = await gateway.start(
        name: 'An',
        runId: 'retry-season',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      for (var i = 0; i < 7; i++) {
        final s = archive.active!;
        final c = GameCommand(
          id: 'mid-$i',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'action',
          target: 'rest',
        );
        archive = await gateway.dispatch(c);
        final before = jsonEncode(archive.toJson());
        archive = await gateway.dispatch(c);
        expect(jsonEncode(archive.toJson()), before);
      }
      expect(archive.active!.midSeasonDelivered, true);
      expect(archive.active!.points, 5);
      expect((await gateway.load()).active!.toJson(), archive.active!.toJson());
      final weekly = ScoreEntry('w', 'A', 52),
          seasonal = ScoreEntry('s', 'B', 4, seasonal: true);
      final ranking = rankedScores([weekly, seasonal]);
      expect(ranking.map((r) => r.rank), [1, 1]);
      expect(
        reignTime(seasonal.weeks, seasonal: seasonal.seasonal),
        '1 năm 0 mùa',
      );
    },
  );
}
