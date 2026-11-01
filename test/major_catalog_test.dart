import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/logic/reign_rules.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState fresh() {
    final s = engine.start('catalog66', 'An', 42);
    s.petitions.clear();
    s.nextChainWeek = s.nextMajorWeek = 10000;
    s.factions.updateAll((k, v) => 60);
    for (final c in s.court) {
      c.loyalty = 90;
      c.ambition = 10;
    }
    return s;
  }

  MajorMission mission(String kind, {int deadline = 1}) => MajorMission(
    id: '$kind-test',
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
  GameState send(
    GameState s,
    String type, {
    String target = '',
    String option = '',
  }) => engine.execute(
    s,
    GameCommand(
      id: 'cmd-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );
  void ledger(GameState s) {
    for (final w in s.financialWeeks) {
      expect(w.closingBalance, w.openingBalance + w.income - w.expense);
      expect(
        w.closingDebt,
        w.openingDebt + w.entries.fold<int>(0, (n, e) => n + e.debtChange),
      );
    }
  }

  GameState reveal(String kind, {int week = 53}) {
    final s = fresh()..completedWeeks = week - 2;
    s.majorHistory =
        majorDefinitions
            .where((d) => d.id != kind)
            .map((d) => mission(d.id)..resolvedWeek = 1)
            .toList();
    s.nextMajorWeek = week;
    final next = send(s, 'endWeek');
    expect(next.ended, false);
    expect(next.major!.kind, kind);
    return next;
  }

  test(
    'all sixty approved rows have unique codes, narratives, four goals and outcome text',
    () {
      final added = majorDefinitions.where((d) => d.code.isNotEmpty).toList();
      expect(added, hasLength(60));
      expect(majorDefinitions.map((d) => d.id).toSet(), hasLength(66));
      expect(added.map((d) => d.code).toSet(), {
        for (var i = 1; i <= 60; i++) 'DB-${i.toString().padLeft(2, '0')}',
      });
      expect(added.map((d) => d.title).toSet(), hasLength(60));
      expect(added.map((d) => d.body).toSet(), hasLength(60));
      for (final group in majorGroupNames.keys) {
        expect(added.where((d) => d.group == group), hasLength(10));
      }
      for (final d in added) {
        expect(d.successText, isNotEmpty);
        expect(d.failureText, isNotEmpty);
        expect(d.objectives.map((o) => o.title).toSet(), hasLength(4));
        expect(
          d.objectives.fold<int>(0, (sum, o) => sum + o.cost),
          lessThanOrEqualTo(120),
        );
        expect(
          d.objectives.fold<int>(0, (sum, o) => sum + o.grain),
          lessThanOrEqualTo(60),
        );
        for (final o in d.objectives) {
          expect(o.aftermath, isNotEmpty);
          expect(
            o.damage.keys.every(
              (k) => [
                'people',
                'stability',
                'army',
                'authority',
                'treasury',
                'grain',
                'war',
              ].contains(k),
            ),
            true,
          );
          expect(o.responses.every(crisisNames.containsKey), true);
        }
      }
    },
  );

  test(
    'each new zero-goal result can end a reign at medium critical stats and writes a single receipt',
    () {
      for (final d in majorDefinitions.where((d) => d.code.isNotEmpty)) {
        final s =
            fresh()
              ..major = mission(d.id)
              ..people = 40
              ..army = 40
              ..stability = 40
              ..authority = 40;
        expect(missionTerminalRisks(s, s.major!), isNotEmpty, reason: d.code);
        final next = send(s, 'endWeek');
        expect(next.ended, true, reason: d.code);
        expect(next.completedWeeks, 0, reason: d.code);
        expect(next.majorHistory.single.kind, d.id);
        expect(next.outcomes.single.status, 'failure');
        expect(next.outcomes.single.detail, contains(d.failureText));
        expect(next.copy().toJson(), next.toJson());
        expect(() => send(next, 'endWeek'), throwsA(isA<GameRuleException>()));
        ledger(next);
      }
    },
  );

  test(
    'resource loss beyond treasury becomes debt with the correct one-time major receipt',
    () {
      final s =
          fresh()
            ..treasury = 0
            ..major = mission('db-34');
      s.financialWeeks.clear();
      final next = send(s, 'endWeek');
      final report = next.outcomes.single;
      expect(next.debt, greaterThan(0));
      expect(report.changes['Nợ chi trả'], greaterThan(0));
      expect(report.changes['Ngân khố'], -1);
      expect(report.changes['Nợ chi trả'], 149);
      ledger(next);
    },
  );

  test(
    'condition gates cover season, war, debt, maturity and a real royal successor',
    () {
      final s = fresh();
      expect(majorEligible(s, majorDefinition('db-01')), false);
      s.completedWeeks = 7;
      expect(majorEligible(s, majorDefinition('db-01')), true);
      expect(majorEligible(s, majorDefinition('db-05')), false);
      s.war = 1;
      expect(majorEligible(s, majorDefinition('db-05')), true);
      expect(majorEligible(s, majorDefinition('db-18')), false);
      expect(majorEligible(s, majorDefinition('db-37')), false);
      s.debt = 1;
      expect(majorEligible(s, majorDefinition('db-37')), true);
      expect(majorEligible(s, majorDefinition('db-21')), false);
      s.completedWeeks = 13;
      expect(s.season, 'Hạ');
      expect(majorEligible(s, majorDefinition('db-21')), true);
      expect(majorEligible(s, majorDefinition('db-23')), false);
      s.completedWeeks = 52;
      s.war = 0;
      expect(majorEligible(s, majorDefinition('db-55')), true);
      expect(majorEligible(s, majorDefinition('db-18')), true);
      for (final c in heirCandidates(s)) {
        c.available = false;
      }
      expect(majorEligible(s, majorDefinition('db-55')), false);
      expect(majorEligible(s, majorDefinition('db-56')), false);
    },
  );

  test(
    'unseen eligible events outrank context and recent-group preference, without consuming random',
    () {
      final s = fresh()..completedWeeks = 60;
      s.majorHistory =
          majorDefinitions
              .where((d) => d.id != 'db-42')
              .map((d) => mission(d.id)..resolvedWeek = 1)
              .toList();
      final rng = s.rng;
      final result = majorDrawPool(s);
      expect(result.map((d) => d.id), ['db-42']);
      expect(s.rng, rng);
      final restored = s.copy();
      expect(majorDrawPool(restored).map((d) => d.id), ['db-42']);
    },
  );

  test(
    'recent groups and immediate event repeat are avoided when fresh alternatives exist',
    () {
      final s = fresh()..completedWeeks = 60;
      s.majorHistory = [
        mission('db-41')..resolvedWeek = 1,
        mission('db-01')..resolvedWeek = 2,
      ];
      s.lastMajorKind = 'db-01';
      final pool = majorDrawPool(s);
      expect(pool, isNotEmpty);
      expect(
        pool.any((d) => ['politics', 'military'].contains(d.group)),
        false,
      );
      expect(pool.any((d) => d.id == 'db-01'), false);
    },
  );

  test(
    'selection over a sixty-year timeline reaches all 66 and continues after the catalog is exhausted',
    () {
      final s = fresh()..debt = 100;
      for (var draw = 0; draw < 156; draw++) {
        s.completedWeeks = draw * 20;
        s.war = draw.isEven ? 1 : 0;
        final pool = majorDrawPool(s);
        expect(pool, isNotEmpty);
        final d = pool.first;
        expect(d.id, isNot(s.lastMajorKind));
        final eligible = majorDefinitions.where(
          (e) => majorEligible(s, e) && e.id != s.lastMajorKind,
        );
        final seen = s.majorHistory.map((m) => m.kind).toSet();
        if (eligible.any((e) => !seen.contains(e.id))) {
          expect(seen.contains(d.id), false);
        }
        s.majorHistory.add(mission(d.id)..resolvedWeek = s.week);
        s.lastMajorKind = d.id;
      }
      expect(s.majorHistory.map((m) => m.kind).toSet(), hasLength(66));
      expect(s.majorHistory, hasLength(156));
      expect(
        majorDrawPool(s.copy()).map((d) => d.id),
        majorDrawPool(s).map((d) => d.id),
      );
    },
  );

  test(
    'actual draw and objective contracts reproduce exactly after restore',
    () {
      final a =
          fresh()
            ..completedWeeks = 12
            ..nextMajorWeek = 14;
      final b = a.copy();
      final first = send(a, 'endWeek'), second = send(b, 'endWeek');
      expect(first.major, isNotNull);
      expect(first.toJson(), second.toJson());
      expect(first.major!.deadline, first.major!.openedWeek + 5);
      expect(first.major!.severity, 2);
      expect(first.major!.objectives, hasLength(4));
    },
  );

  test(
    'new economic opportunity pays finite recurring income through budget, with no reapplication',
    () {
      var s = fresh()..major = mission('db-12');
      for (final o in s.major!.objectives) {
        o.done = true;
      }
      s.affairsThisWeek = 1;
      s = send(s, 'endWeek');
      expect(s.realmMilestones['db-12'], 1);
      final benefit = s.obligations.single;
      expect(benefit.income, 5);
      expect(benefit.remaining, 8);
      expect(benefit.nextWeek, 2);
      expect(s.outcomes.single.changes['Uy quyền'], 6);
      expect(s.outcomes.single.changes.containsKey('Ngân khố'), false);
      final title = benefit.title;
      for (var i = 0; i < 8; i++) {
        s.petitions.clear();
        s.affairsThisWeek = 1;
        s.workThisWeek = 1;
        final projection = BudgetProjection(s);
        expect(
          projection.income.any((r) => r.title == title && r.amount == 5),
          true,
        );
        s = send(s.copy(), 'endWeek');
        expect(s.treasury, projection.closingBalance);
        final paid = s.financialWeeks.last.entries.where(
          (e) => e.title == title,
        );
        expect(paid, hasLength(1));
        expect(paid.single.amount, 5);
        ledger(s);
      }
      expect(s.obligations, isEmpty);
      expect(BudgetProjection(s).income.any((r) => r.title == title), false);
      s.petitions.clear();
      s.affairsThisWeek = 1;
      s = send(s, 'endWeek');
      expect(s.financialWeeks.last.entries.any((e) => e.title == title), false);
      expect(s.copy().realmMilestones['db-12'], 1);
    },
  );

  test(
    'partially signed assistance promise costs money but incomplete economic opportunity grants no income',
    () {
      var s = fresh()..major = mission('db-13');
      s.major!.objectives[2].done = true;
      s = send(s, 'endWeek');
      expect(
        s.obligations.any(
          (o) => o.kind == 'alliance' && o.amount == 4 && o.remaining == 6,
        ),
        true,
      );
      final incomplete = fresh()..major = mission('db-38');
      incomplete.major!.objectives[0].done = true;
      final failed = send(incomplete, 'endWeek');
      expect(failed.obligations.any((o) => o.income > 0), false);
      expect(failed.realmMilestones.containsKey('db-38'), false);
    },
  );

  test(
    'succession scenarios bind a living adult royal and keep care separate from king health',
    () {
      var s = reveal('db-55');
      final heir = s.court.firstWhere((c) => c.id == s.major!.subjectId);
      expect(heir.available, true);
      expect(heir.age, greaterThanOrEqualTo(18));
      expect(heir.faction, 'Hoàng tộc');
      expect(s.heirId, heir.id);
      expect(s.heirCondition, 'critical');
      expect(majorBody(s, s.major!), contains(heir.name));
      final before = s.health;
      for (final o in s.major!.objectives) {
        o.done = true;
      }
      s.affairsThisWeek = 1;
      s = send(s, 'endWeek');
      expect(s.heirCondition, 'stable');
      expect(s.health, before);
      expect(s.copy().heirId, heir.id);
      var certification = reveal('db-56');
      for (final o in certification.major!.objectives) {
        o.done = true;
      }
      certification.affairsThisWeek = 1;
      certification = send(certification, 'endWeek');
      expect(certification.successionCertified, true);
      expect(certification.copy().successionCertified, true);
    },
  );

  test(
    'a successor who dies naturally is not resurrected by a mission outcome',
    () {
      var s =
          fresh()
            ..completedWeeks = 51
            ..heirCondition = 'stable'
            ..successionCertified = true;
      final heir = heirCandidates(s).first;
      s.heirId = heir.id;
      for (final c in s.court) {
        c.age = 30;
      }
      heir.age = 100;
      s.rng = 100;
      s.affairsThisWeek = 1;
      s.workThisWeek = 1;
      s = send(s, 'endWeek');
      expect(s.court.firstWhere((c) => c.id == heir.id).available, false);
      expect(s.heirCondition, 'deceased');
      expect(s.successionCertified, false);
      s.major = mission('db-55', deadline: s.week)..subjectId = heir.id;
      for (final o in s.major!.objectives) {
        o.done = true;
      }
      s.affairsThisWeek = 1;
      s = send(s, 'endWeek');
      expect(s.heirCondition, 'deceased');
    },
  );

  test(
    'care goals are interrupted and cannot be reassigned after their subject dies',
    () {
      var s = reveal('db-55');
      final doctor = s.court.firstWhere(
        (c) => c.role == 'Ngự y' && c.available,
      );
      s = send(s, 'mission', target: 'goal1', option: doctor.id);
      s.court.firstWhere((c) => c.id == s.major!.subjectId).available = false;
      s.heirCondition = 'deceased';
      s = send(s, 'endWeek');
      expect(s.major!.objectives.first.working, false);
      expect(s.major!.objectives.first.done, false);
      expect(
        majorGoalUnavailable(
          s,
          s.major!,
          majorDefinition('db-55').objectives.first,
        ),
        isNotNull,
      );
      expect(
        () => send(s, 'mission', target: 'goal1', option: doctor.id),
        throwsA(isA<GameRuleException>()),
      );
      expect(s.heirCondition, 'deceased');
    },
  );

  test(
    'dismissing the designated successor invalidates certification without reporting a death',
    () {
      var s = reveal('db-55');
      final old = s.heirId;
      s.successionCertified = true;
      s = send(s, 'appoint', target: old, option: s.officialsPool.first.id);
      expect(s.heirCondition, 'withdrawn');
      expect(s.successionCertified, false);
      final reason =
          majorGoalUnavailable(
            s,
            s.major!,
            majorDefinition('db-55').objectives.first,
          )!;
      expect(reason, contains('không còn đủ điều kiện'));
      expect(reason.contains('qua đời'), false);
      expect(s.copy().heirCondition, 'withdrawn');
    },
  );

  test(
    'content-7 active save upgrades without resetting missions, random, revision or ledger',
    () {
      var s = fresh()..major = mission('flood', deadline: 6);
      s = send(s, 'mission', target: 'levee', option: 'works');
      final archive = GameArchive()..active = s;
      final raw = object(jsonDecode(jsonEncode(archive.toJson())));
      final old = object(raw['active'])..['contentVersion'] = 7;
      old.remove('realmMilestones');
      old.remove('heirId');
      old.remove('heirCondition');
      old.remove('successionCertified');
      object(old['major']).remove('subjectId');
      raw['active'] = old;
      final loaded = GameArchive.fromJson(raw);
      expect(loaded.active!.runId, s.runId);
      expect(loaded.active!.rng, s.rng);
      expect(loaded.active!.revision, s.revision);
      expect(
        loaded.active!.major!.objectives.first.toJson(),
        s.major!.objectives.first.toJson(),
      );
      expect(
        loaded.active!.financialWeeks.map((w) => w.toJson()),
        s.financialWeeks.map((w) => w.toJson()),
      );
      expect(loaded.archivedRuns, isEmpty);
      expect(loaded.active!.toJson()['contentVersion'], contentVersion);
      expect(old['contentVersion'], 7);
      expect(majorDrawPool(loaded.active!).any((d) => d.id == 'flood'), true);
    },
  );

  test(
    'gateway retry of final major week cannot grant reward or benefit twice',
    () async {
      final store = MemoryGameStore();
      // Use one shared store for dispatch and reload, just like the browser adapter.
      final g = LocalGameGateway(store, seasonal: false);
      await g.start(
        name: 'An',
        runId: 'benefit-once',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((a) {
        a.active!.major = mission('db-12');
        for (final o in a.active!.major!.objectives) {
          o.done = true;
        }
      });
      const command = GameCommand(
        id: 'settle',
        runId: 'benefit-once',
        expectedRevision: 0,
        type: 'endWeek',
      );
      final once = await g.dispatch(command);
      final retry = await LocalGameGateway(
        store,
        seasonal: false,
      ).dispatch(command);
      expect(retry.toJson(), once.toJson());
      expect(retry.active!.majorHistory, hasLength(1));
      expect(
        retry.active!.obligations.where((o) => o.income > 0),
        hasLength(1),
      );
    },
  );
}
