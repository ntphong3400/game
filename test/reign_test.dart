import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/logic/reign_rules.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState fresh() {
    final s = engine.start('reign-test', 'An', 42);
    s.petitions.clear();
    s.nextMajorWeek = s.nextChainWeek = 1000;
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
      id: '${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );
  MajorMission mission(String kind, {int deadline = 6}) => MajorMission(
    id: 'm-$kind',
    kind: kind,
    openedWeek: 1,
    deadline: deadline,
    severity: 1,
    preparedness: 0,
    objectives:
        majorDefinition(
          kind,
        ).objectives.map((o) => MissionObjective(key: o.key)).toList(),
  );
  void ledger(GameState s) {
    for (final w in s.financialWeeks) {
      expect(w.closingBalance, w.openingBalance + w.income - w.expense);
      expect(
        w.closingDebt,
        w.openingDebt + w.entries.fold<int>(0, (v, e) => v + e.debtChange),
      );
    }
  }

  test(
    'catalog has sixty-six distinct crises and twelve four-stage petition stories',
    () {
      expect(majorDefinitions.map((d) => d.id).toSet(), hasLength(66));
      for (final d in majorDefinitions) {
        expect(d.objectives.map((o) => o.key).toSet(), hasLength(4));
        expect(
          d.objectives.every(
            (o) => o.duration <= 2 && o.cost >= 0 && o.grain >= 0,
          ),
          true,
        );
      }
      expect(chainDefinitions, hasLength(12));
      expect(chainDefinitions.every((d) => d.stages.length == 4), true);
    },
  );

  test(
    'mission dispatch consumes resources once, reserves officer and waits for actual completion',
    () {
      final s = fresh()..major = mission('flood');
      var next = send(s, 'mission', target: 'levee', option: 'works');
      expect(next.major!.achieved, 0);
      expect(next.treasury, s.treasury - 30);
      expect(next.points, 2);
      expect(officerBusy(next, 'works'), true);
      expect(taskOfficers(next, 'repair').any((c) => c.id == 'works'), false);
      next = send(next, 'endWeek');
      expect(next.major!.achieved, 0);
      next.petitions.clear();
      next.affairsThisWeek = 1;
      next = send(next.copy(), 'endWeek');
      expect(next.major!.achieved, 1);
      expect(officerBusy(next, 'works'), false);
      ledger(next);
    },
  );

  test('invalid mission requests are atomic and do not consume random', () {
    for (final scenario in [
      'cash',
      'grain',
      'points',
      'consort',
      'busy',
      'late',
      'duplicate',
    ]) {
      final s = fresh()..major = mission('flood');
      var key = 'food', officer = 'treasurer';
      if (scenario == 'cash') s.treasury = 0;
      if (scenario == 'grain') s.grain = 0;
      if (scenario == 'points') s.points = 0;
      if (scenario == 'consort') officer = 'consort_lan';
      if (scenario == 'busy') {
        s.projects.add(
          WorkOrder(
            id: 'p',
            kind: 'farm',
            officerId: officer,
            startedWeek: 1,
            duration: 3,
          ),
        );
      }
      if (scenario == 'late') {
        s.major!.deadline = 1;
        key = 'levee';
        officer = 'works';
      }
      if (scenario == 'duplicate') {
        s.major!.objectives.firstWhere((o) => o.key == key).done = true;
      }
      final before = jsonEncode(s.toJson());
      expect(
        () => send(s, 'mission', target: key, option: officer),
        throwsA(isA<GameRuleException>()),
        reason: scenario,
      );
      expect(jsonEncode(s.toJson()), before, reason: scenario);
    }
  });

  test(
    'all objectives finish early and rewards, receipts, cooldown survive reload',
    () {
      final s = fresh()..major = mission('flood');
      for (final o in s.major!.objectives) {
        o.officerId = 'works';
        o.finishWeek = 1;
      }
      var next = send(s, 'endWeek');
      expect(next.major, isNull);
      expect(next.majorHistory.single.achieved, 4);
      expect(next.majorHistory.single.resolvedWeek, 1);
      expect(next.outcomes.single.status, 'success');
      expect(next.outcomes.single.changes['Uy quyền'], 5);
      expect(next.lastMajorGap, inInclusiveRange(4, 24));
      expect(next.nextMajorWeek, 1 + next.lastMajorGap + 1);
      final original = next.copy();
      next.affairsThisWeek = 1;
      next.petitions.clear();
      next = send(next.copy(), 'endWeek');
      expect(next.majorHistory, hasLength(1));
      expect(
        next.outcomes.where((o) => o.title == majorDefinition('flood').title),
        hasLength(1),
      );
      expect(original.toJson(), GameState.fromJson(original.toJson()).toJson());
      ledger(next);
    },
  );

  test(
    'deadline is inclusive: work finishing on deadline counts before settlement',
    () {
      final s = fresh()..major = mission('flood', deadline: 1);
      for (final o in s.major!.objectives.take(3)) {
        o.done = true;
      }
      final o =
          s.major!.objectives.last
            ..officerId = 'general'
            ..finishWeek = 1;
      expect(o.done, false);
      final next = send(s, 'endWeek');
      expect(next.majorHistory.single.achieved, 4);
      expect(next.outcomes.single.status, 'success');
    },
  );

  for (final count in [0, 1, 2, 3, 4]) {
    test(
      '$count goals settle with proportional outcome and no refunded/repeated cost',
      () {
        final s = fresh()..major = mission('flood', deadline: 1);
        for (final o in s.major!.objectives.take(count)) {
          o.done = true;
        }
        final expected = missionEffects(s.major!);
        final next = send(s, 'endWeek');
        final outcome = next.outcomes.firstWhere(
          (o) => o.title == majorDefinition('flood').title,
        );
        expect(next.majorHistory.single.result, missionResultLabel(count));
        final labels = {
          'people': 'Lòng dân',
          'authority': 'Uy quyền',
          'stability': 'Ổn định triều đình',
          'grain': 'Lương thực',
          'levee': 'Đê điều',
          'treasury': 'Ngân khố',
        };
        for (final e in expected.entries) {
          expect(outcome.changes[labels[e.key]], e.value);
        }
        expect(
          next.obligations.where((o) => o.kind == 'aftermath').length,
          count <= 1 ? 1 : 0,
        );
        ledger(next);
      },
    );
  }

  test(
    'major flood penalties have independent severe numeric expectations',
    () {
      for (final (achieved, damage) in [
        (0, -50),
        (1, -35),
        (2, -20),
        (3, -10),
      ]) {
        final m = mission('flood');
        // Keep evacuation unprotected at every level; finish other goals first.
        for (final o in m.objectives
            .where((o) => o.key != 'evacuate')
            .take(achieved)) {
          o.done = true;
        }
        expect(missionEffects(m)['people'], damage);
        final protected = MajorMission.fromJson(m.toJson());
        protected.objectives.firstWhere((o) => o.key == 'evacuate').done = true;
        expect(
          (missionEffects(protected)['people'] ?? 0),
          greaterThanOrEqualTo(0),
        );
      }
      final m = mission('flood');
      expect(missionEffects(m)['treasury'], -150);
      expect(missionEffects(m)['grain'], -100);
      m.preparedness = 2;
      expect(missionEffects(m)['people'], -40);
      m.severity = 2;
      expect(missionEffects(m)['people'], -48);
    },
  );

  for (final (kind, stat, endKind) in [
    ('flood', 'people', 'rebellion'),
    ('invasion', 'army', 'invasion'),
    ('rumor', 'stability', 'courtCollapse'),
  ]) {
    test(
      '$kind failure can end a reign with a low or medium critical stat and cannot replay damage',
      () {
        for (final value in [15, 40]) {
          final s = fresh()..major = mission(kind, deadline: 1);
          if (stat == 'people') s.people = value;
          if (stat == 'army') s.army = value;
          if (stat == 'stability') s.stability = value;
          expect(missionTerminalRisks(s, s.major!), isNotEmpty);
          final result = send(s, 'endWeek');
          expect(result.ended, true);
          expect(result.endKind, endKind);
          expect(result.completedWeeks, 0);
          expect(result.majorHistory.single.achieved, 0);
          expect(result.outcomes.single.status, 'failure');
          expect(result.copy().toJson(), result.toJson());
          expect(
            () => send(result, 'endWeek'),
            throwsA(isA<GameRuleException>()),
          );
          ledger(result);
        }
      },
    );
  }

  test(
    'major forecast and settlement end zero authority even with a stable court',
    () {
      final s =
          fresh()
            ..authority = 10
            ..stability = 100
            ..major = mission('rumor', deadline: 1);
      for (final objective in s.major!.objectives) {
        objective.done = objective.key != 'source';
      }
      expect(
        missionTerminalRisks(s, s.major!),
        contains('Uy quyền về 0, vua trở thành bù nhìn'),
      );
      final result = send(s, 'endWeek');
      expect(result.endKind, 'puppet');
      expect(result.stability, greaterThan(25));
      expect(result.completedWeeks, 0);
      expect(result.majorHistory.single.achieved, 3);
    },
  );

  test(
    'fully completing a major crisis preserves positive stats and gives rewards',
    () {
      final s =
          fresh()
            ..people = 40
            ..major = mission('flood', deadline: 1);
      for (final o in s.major!.objectives) {
        o.done = true;
      }
      expect(missionTerminalRisks(s, s.major!), isEmpty);
      final result = send(s, 'endWeek');
      expect(result.ended, false);
      expect(result.outcomes.single.changes['Lòng dân'], 4);
    },
  );

  test(
    'all subsets improve monotonically; protected objectives change damage type',
    () {
      for (final d in majorDefinitions) {
        for (var mask = 0; mask < 16; mask++) {
          final m = mission(d.id);
          for (var i = 0; i < 4; i++) {
            m.objectives[i].done = (mask & (1 << i)) != 0;
          }
          final before = missionEffects(m);
          for (var i = 0; i < 4; i++) {
            if (m.objectives[i].done) continue;
            final improved = MajorMission.fromJson(m.toJson());
            improved.objectives[i].done = true;
            final after = missionEffects(improved);
            for (final key in {...before.keys, ...after.keys}) {
              if (key == 'war') {
                expect(after[key] ?? 0, lessThanOrEqualTo(before[key] ?? 0));
              } else {
                expect(after[key] ?? 0, greaterThanOrEqualTo(before[key] ?? 0));
              }
            }
          }
        }
      }
      final evacuation = mission('flood')..objectives[1].done = true;
      final levee = mission('flood')..objectives[0].done = true;
      expect(missionEffects(evacuation).containsKey('people'), false);
      expect(missionEffects(levee).containsKey('people'), true);
    },
  );

  test(
    'preparedness mitigates damage and later stages increase it without changing active contracts',
    () {
      final a = mission('flood');
      final b = MajorMission.fromJson(a.toJson())..preparedness = 2;
      expect(
        missionEffects(b)['people']!,
        greaterThan(missionEffects(a)['people']!),
      );
      final c = MajorMission.fromJson(a.toJson())..severity = 3;
      expect(
        missionEffects(c)['people']!,
        lessThan(missionEffects(a)['people']!),
      );
      final s =
          fresh()
            ..completedWeeks = 25
            ..major = a;
      final frozen = s.major!.toJson();
      expect(s.copy().major!.toJson(), frozen);
    },
  );

  test(
    'one major at a time and exactly 4-24 full resting weeks before next',
    () {
      var s =
          fresh()
            ..major = mission('flood', deadline: 2)
            ..nextMajorWeek = 1;
      s.affairsThisWeek = 1;
      s = send(s, 'endWeek');
      expect(s.major!.id, 'm-flood');
      for (final o in s.major!.objectives) {
        o.done = true;
      }
      s = send(s, 'endWeek');
      final next = s.nextMajorWeek, gap = s.lastMajorGap;
      expect(gap, inInclusiveRange(4, 24));
      expect(next, s.majorHistory.single.resolvedWeek + gap + 1);
      while (s.week < next && !s.ended) {
        s.petitions.clear();
        s.affairsThisWeek = 1;
        s.workThisWeek = 1;
        s = send(s.copy(), 'endWeek');
        if (s.week < next) expect(s.major, isNull);
      }
      expect(s.ended, false);
      expect(s.major, isNotNull);
      expect(s.major!.kind, isNot('flood'));
      expect(s.major!.deadline, s.major!.openedWeek + 5);
    },
  );

  test(
    'mission interrupted on officer death may be reassigned; appointment transfers progress',
    () {
      var s = fresh()..major = mission('flood');
      s = send(s, 'mission', target: 'levee', option: 'works');
      final candidate = s.officialsPool.first;
      final due = s.major!.objectives.first.finishWeek;
      s = send(s, 'appoint', target: 'works', option: candidate.id);
      expect(s.major!.objectives.first.officerId, candidate.id);
      expect(s.major!.objectives.first.finishWeek, due);
      s.court.firstWhere((c) => c.id == candidate.id).available = false;
      s.completedWeeks = due - 1;
      s = send(s, 'endWeek');
      expect(s.major!.objectives.first.working, false);
      expect(s.major!.objectives.first.done, false);
    },
  );

  test(
    'death interrupts a mission before its scheduled finish so another official can take over',
    () {
      var s = fresh()..major = mission('flood');
      s = send(s, 'mission', target: 'levee', option: 'works');
      expect(s.major!.objectives.first.finishWeek, 2);
      s.court.firstWhere((c) => c.id == 'works').available = false;
      s = send(s, 'endWeek');
      expect(s.major!.objectives.first.working, false);
      final goal = majorDefinition('flood').objectives.first;
      s = send(
        s,
        'mission',
        target: 'levee',
        option: missionOfficers(s, goal).first.id,
      );
      expect(s.major!.objectives.first.working, true);
      expect(s.major!.achieved, 0);
    },
  );

  test(
    'crisis response is specific: audience does not erase hunger, food does',
    () {
      var s = fresh()..grain = 10;
      s = send(s, 'courtier', target: 'chancellor', option: 'audience');
      s = send(s, 'endWeek');
      expect(s.neglectedWeeks, 0);
      expect(s.crisisWeeks['hunger'], 1);
      // Guarantee one successful purchase, as the existing engine test roll helper does.
      s.rng = 100;
      s = send(s, 'action', target: 'buy_grain', option: 'treasurer');
      expect(s.responsesThisWeek['hunger'], 1);
      s.petitions.clear();
      s = send(s, 'endWeek');
      expect(s.crisisWeeks.containsKey('hunger'), false);
    },
  );

  test('official fatigue reduces chance and return; resting recovers it', () {
    var s = fresh();
    final c = s.court.firstWhere((c) => c.id == 'treasurer');
    final before = TaskAssessment('collect_arrears', c);
    c.strain = 80;
    final after = TaskAssessment('collect_arrears', c);
    expect(after.successChance, lessThan(before.successChance));
    expect(after.rewardPercent, lessThan(before.rewardPercent));
    s.affairsThisWeek = 1;
    s = send(s, 'endWeek');
    expect(s.court.firstWhere((x) => x.id == c.id).strain, 70);
  });

  test(
    'three successes create influence and a finite demand, unpaid demand hits the faction',
    () {
      var s = fresh();
      final c = s.court.firstWhere((c) => c.id == 'treasurer')..merit = 2;
      s.rng = 100;
      s = send(s, 'action', target: 'collect_arrears', option: c.id);
      expect(s.court.firstWhere((x) => x.id == c.id).merit, 3);
      expect(s.obligations.single.kind, 'demand');
      s.completedWeeks = 1;
      s.treasury = 0;
      s.petitions.clear();
      // Income can cover the basic budget but not the demand.
      s.people = 12;
      s.war = 2;
      s.affairsThisWeek = 1;
      final mood = s.factions[c.faction]!;
      s = send(s, 'endWeek');
      expect(s.factions[c.faction], lessThan(mood));
      ledger(s);
    },
  );

  test(
    'loan starts next week, budget and actual ledger agree; duplicate loan blocked',
    () {
      var s = send(fresh(), 'emergency', target: 'borrow');
      expect(s.treasury, 640);
      expect(s.obligations.single.remaining, 10);
      expect(
        BudgetProjection(s).expenses.any((i) => i.title == 'Vay thế gia'),
        false,
      );
      expect(
        () => send(s, 'emergency', target: 'borrow'),
        throwsA(isA<GameRuleException>()),
      );
      s.affairsThisWeek = 1;
      s = send(s, 'endWeek');
      final projection = BudgetProjection(s);
      s.petitions.clear();
      s.affairsThisWeek = 1;
      s = send(s, 'endWeek');
      expect(s.treasury, projection.closingBalance);
      expect(s.obligations.single.remaining, 9);
      expect(
        s.financialWeeks.last.entries
            .where((e) => e.title == 'Vay thế gia')
            .single
            .amount,
        -15,
      );
      ledger(s);
    },
  );

  test('emergency levies and peace leave exact finite consequences', () {
    var s = fresh()..war = 2;
    s = send(s, 'emergency', target: 'levy');
    s = send(s, 'emergency', target: 'peace');
    expect(s.war, 0);
    expect(s.obligations.map((o) => o.remaining), [6, 8]);
    expect(s.obligations.first.effects, {'grain': -2});
    expect(s.obligations.last.amount, 6);
    expect(s.responsesThisWeek['border'], 1);
  });

  test('arrears pool depletes on failed attempts too and persists', () {
    final s = fresh()..rng = 99 * 31 % 100;
    final next = send(
      s,
      'action',
      target: 'collect_arrears',
      option: 'treasurer',
    );
    expect(next.arrearsUses, 1);
    expect(arrearsBase(next.copy()), 39);
    next.arrearsUses = 100;
    expect(arrearsBase(next), 15);
  });

  test(
    'chain stages wait, preserve prior decisions, and apply branch-dependent ending',
    () {
      GameState play(int first) {
        var s =
            fresh()
              ..chains = [
                StoryArc(
                  settlementVersion: 0,
                  id: 'arc',
                  kind: 'embezzlement',
                  dueWeek: 1,
                ),
              ];
        s = send(s, 'chain', target: 'arc', option: '$first');
        expect(s.chains.single.stage, 1);
        expect(
          () => send(s, 'chain', target: 'arc', option: '0'),
          throwsA(isA<GameRuleException>()),
        );
        s.completedWeeks = 2;
        s.points = 3;
        s = send(s.copy(), 'chain', target: 'arc', option: '0');
        s.completedWeeks = 4;
        s.points = 3;
        s = send(s.copy(), 'chain', target: 'arc', option: '0');
        return s;
      }

      final public = play(0), ignored = play(2);
      expect(public.chains, isEmpty);
      expect(public.completedChains, ['embezzlement']);
      expect(public.outcomes.single.changes['Ngân khố'], 30);
      expect(ignored.outcomes.single.changes['Lòng dân'], 2);
    },
  );

  test('expired chain uses fallback and schedules next stage once', () {
    var s =
        fresh()
          ..chains = [
            StoryArc(
              settlementVersion: 0,
              id: 'arc',
              kind: 'granary',
              dueWeek: 1,
            ),
          ]
          ..completedWeeks = 2;
    s = send(s, 'endWeek');
    expect(s.chains.single.stage, 1);
    expect(s.chains.single.decisions, [2]);
    expect(s.chains.single.dueWeek, 5);
  });

  test('reign stages are forecast and recurring costs match projections', () {
    final s = fresh();
    for (final weeks in [0, 7, 52]) {
      s.completedWeeks = weeks;
      expect(
        reignStage(s),
        weeks == 0
            ? 0
            : weeks == 7
            ? 1
            : 2,
      );
      final costs = budgetExpenses(s);
      expect(costs['realm']?.amount ?? 0, reignStage(s) * 2);
    }
  });

  test(
    'difficulty begins in week eight, with advance warning in week four',
    () {
      var s = fresh()..completedWeeks = 6;
      expect(s.week, 7);
      expect(reignStage(s), 0);
      expect(budgetExpenses(s).containsKey('realm'), false);
      s.affairsThisWeek = 1;
      s = send(s, 'endWeek');
      expect(s.week, 8);
      expect(reignStage(s), 1);
      expect(budgetExpenses(s)['realm']!.amount, 2);
      expect(s.journal.any((e) => e.title == 'Giai đoạn Tranh quyền'), true);
      final restored = s.copy();
      expect(reignStage(restored), 1);
      restored.completedWeeks = 51;
      expect(reignStage(restored), 1);
      restored.completedWeeks = 52;
      expect(reignStage(restored), 2);
      var warning =
          fresh()
            ..completedWeeks = 2
            ..affairsThisWeek = 1;
      warning = send(warning, 'endWeek');
      expect(warning.week, 4);
      expect(
        warning.journal.any(
          (e) => e.title == 'Thế cục sắp đổi' && e.text.contains('tuần 8'),
        ),
        true,
      );
    },
  );

  test('terminal stats cannot be revived by major success rewards', () {
    final s =
        fresh()
          ..major = mission('flood')
          ..people = 0;
    for (final o in s.major!.objectives) {
      o.done = true;
    }
    final next = send(s, 'endWeek');
    expect(next.ended, true);
    expect(next.endKind, 'rebellion');
    expect(next.majorHistory, isEmpty);
  });

  test(
    'every major can be completed within six weeks with cooperative honest officers and successful rolls',
    () {
      for (final d in majorDefinitions) {
        var s = fresh()..major = mission(d.id);
        for (final c in s.court) {
          c.integrity = 100;
          c.affection = c.loyalty = 90;
          c.personalities
            ..clear()
            ..addAll([Personality.grateful, Personality.disciplined]);
        }
        for (var w = 0; w < 6 && s.major != null && !s.ended; w++) {
          final open =
              s.major!.objectives
                  .where((o) => !o.done && !o.working)
                  .firstOrNull;
          if (open != null) {
            final goal = d.objectives.firstWhere((g) => g.key == open.key);
            final c = missionOfficers(s, goal).first;
            s = send(s, 'mission', target: open.key, option: c.id);
          }
          while (s.points > 0) {
            s = send(s, 'action', target: 'rest');
          }
          s.rng = 100;
          s = send(s.copy(), 'endWeek');
        }
        expect(s.ended, false, reason: d.id);
        expect(s.major, isNull, reason: d.id);
        expect(s.majorHistory.single.achieved, 4, reason: d.id);
        expect(
          s.majorHistory.single.resolvedWeek,
          lessThanOrEqualTo(6),
          reason: d.id,
        );
        ledger(s);
      }
    },
  );

  test('finite obligations finish and do not silently discard unpaid debt', () {
    var s =
        fresh()
          ..completedWeeks = 1
          ..treasury = 0
          ..war = 4;
    s.obligations.add(
      Obligation(
        id: 'loan',
        kind: 'borrow',
        title: 'Vay thế gia',
        remaining: 1,
        nextWeek: 2,
        amount: 15,
      ),
    );
    final projection = BudgetProjection(s);
    s.affairsThisWeek = 1;
    s = send(s, 'endWeek');
    expect(s.obligations, isEmpty);
    expect(s.debt, projection.closingDebt);
    expect(s.debt, greaterThan(0));
    ledger(s);
  });

  test(
    'gateway retries mission orders once and reloads committed random/objectives/ledger',
    () async {
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store, seasonal: false);
      await gateway.start(
        name: 'An',
        runId: 'atomic-major',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((a) {
        a.active!.major = mission('flood');
      });
      final command = GameCommand(
        id: 'order',
        runId: 'atomic-major',
        expectedRevision: 0,
        type: 'mission',
        target: 'levee',
        option: 'works',
      );
      final once = await gateway.dispatch(command);
      final twice = await LocalGameGateway(
        store,
        seasonal: false,
      ).dispatch(command);
      expect(once.toJson(), twice.toJson());
      expect(twice.active!.major!.objectives.first.working, true);
      expect(twice.active!.history, hasLength(1));
      expect(twice.active!.financialWeeks.single.entries, hasLength(1));
      expect((await gateway.load()).toJson(), twice.toJson());
    },
  );
}
