import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/logic/petition_assignment_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine();
  GameState fresh() {
    final s = engine.start('economy', 'An', 42);
    s.petitions.clear();
    s.midSeasonDelivered = true;
    s.nextMajorWeek = s.nextChainWeek = 10000;
    s.treasury = 5000;
    s.people = s.authority = s.stability = s.army = s.health = 90;
    s.factions.updateAll((k, v) => 70);
    for (final c in s.court) {
      c.affection = c.loyalty = c.integrity = 100;
      c.discontent = c.plot = 0;
    }
    return s;
  }

  GameState close(GameState s) {
    s.petitions.clear();
    s.affairsThisWeek = s.workThisWeek = s.restThisWeek = 1;
    s.midSeasonDelivered = true;
    return engine.execute(
      s,
      GameCommand(
        id: 'close-${s.revision}',
        runId: s.runId,
        expectedRevision: s.revision,
        type: 'endWeek',
      ),
    );
  }

  final cases = {
    'finance_02': (cost: 20, revenue: 70, ticks: 2, failure: {'stability': -1}),
    'finance_03': (cost: 10, revenue: 45, ticks: 3, failure: {'people': -1}),
    'commerce_01': (cost: 30, revenue: 85, ticks: 3, failure: <String, int>{}),
    'engineering_03': (
      cost: 20,
      revenue: 60,
      ticks: 2,
      failure: {'authority': -1},
    ),
    'diplomacy_02': (
      cost: 25,
      revenue: 70,
      ticks: 3,
      failure: {'authority': -1},
    ),
    'bureaucracy_03': (
      cost: 25,
      revenue: 75,
      ticks: 2,
      failure: {'authority': -1},
    ),
    'culture_03': (cost: 25, revenue: 70, ticks: 3, failure: {'authority': -1}),
  };

  test(
    'catalog applies the approved economics to all 36 investments and 27 recoveries',
    () {
      final s = fresh();
      var investments = 0, recoveries = 0, boosted = 0, loans = 0;
      for (final raw in events) {
        final current = eventForState(s, raw.id);
        for (var i = 0; i < raw.choices.length; i++) {
          final old = raw.choices[i], c = current.choices[i];
          if (old.economy != null) {
            old.economy!.isRecovery ? recoveries++ : investments++;
            expect(c.laterEffects['treasury'], old.economy!.seasonalRevenue);
            expect(c.laterFailureEffects.containsKey('treasury'), false);
            for (final key in ['people', 'authority', 'stability']) {
              if ((old.laterFailureEffects[key] ?? 0) < 0) {
                expect(c.laterFailureEffects[key], -1);
              }
            }
            expect(petitionDelay(s, c), old.economy!.isRecovery ? 2 : 3);
            expect(petitionBaseChance(c), 30);
          }
          if ((old.effects['treasury'] ?? 0) > 0) {
            if ((old.effects['debt'] ?? 0) > 0) {
              loans++;
              expect(c.effects['treasury'], 22);
              expect(c.effects['debt'], 40);
            } else {
              boosted++;
              expect(
                c.effects['treasury'],
                greaterThan((old.effects['treasury']! * .75).floor()),
              );
              for (final entry in old.effects.entries.where(
                (e) => e.key != 'treasury' && e.value < 0,
              )) {
                expect(c.effects[entry.key], entry.value);
              }
            }
          }
        }
      }
      expect(investments, 36);
      expect(recoveries, 27);
      expect(boosted, 141);
      expect(loans, 9);
      expect(
        eventForState(s, 'corrupt_gift').choices.first.effects['treasury'],
        55,
      );
      expect(eventForState(s, 'silk_route').choices[1].effects['treasury'], 20);
      expect(
        eventForState(s, 'foreign_tribute').choices[1].effects['treasury'],
        25,
      );
      final diplomatic = eventForState(s, 'diplomacy_01').choices.first;
      expect(diplomatic.cost, 35);
      expect(diplomatic.laterEffects['treasury'], 11);
      expect(diplomatic.laterFailureEffects, {'war': 1, 'authority': -3});
      expect(petitionDelay(s, diplomatic), 5);
      final weekly = s.copy()..seasonal = false;
      for (final id in cases.keys) {
        expect(identical(eventForState(weekly, id), eventById(id)), true);
      }
    },
  );

  for (final entry in cases.entries) {
    for (final success in [true, false]) {
      test(
        '${entry.key} settles ${success ? 'success' : 'failure'} once at the approved date',
        () {
          final s = fresh()..rng = success ? 100 : 1;
          s.petitions.add(
            Petition(
              id: 'p',
              definitionId: entry.key,
              openedWeek: s.week,
              deadline: s.week + 1,
            ),
          );
          final e = eventForState(s, entry.key), c = e.choices.first;
          final expected = entry.value;
          expect(c.cost, expected.cost);
          expect(c.laterEffects['treasury'], expected.revenue);
          expect(c.laterFailureEffects, expected.failure);
          var result = engine.execute(
            s,
            GameCommand(
              id: 'choose',
              runId: s.runId,
              expectedRevision: s.revision,
              type: 'petition',
              target: 'p',
              option: '0',
            ),
          );
          final due = s.week + expected.ticks - 1;
          expect(result.treasury, s.treasury - expected.cost);
          expect(result.points, s.points - 1);
          expect(result.pending.single.dueWeek, due);
          expect(result.pending.single.assignment!.succeeded, success);
          result = GameState.fromJson(
            object(jsonDecode(jsonEncode(result.toJson()))),
          );
          while (result.week < due) {
            result = close(result);
            expect(result.outcomes, isEmpty);
            expect(result.pending, hasLength(1));
          }
          result = close(result);
          expect(result.pending, isEmpty);
          expect(
            result.outcomes.single.status,
            success ? 'success' : 'failure',
          );
          expect(
            result.outcomes.single.changes['Ngân khố'] ?? 0,
            success ? expected.revenue : 0,
          );
          final income =
              result.financialWeeks
                  .expand((w) => w.entries)
                  .where((v) => v.category == 'outcome' && v.title == e.title)
                  .toList();
          expect(income, hasLength(success ? 1 : 0));
          if (success) expect(income.single.amount, expected.revenue);
          final previous = result.outcomes.single.toJson();
          result = close(result);
          expect(result.outcomes, hasLength(1));
          expect(result.outcomes.single.toJson(), previous);
        },
      );
    }
  }

  test(
    'old committed rewards, losses and audit ranges survive the upgrade',
    () {
      final s = fresh();
      s.pending.addAll([
        Consequence(
          kind: 'audit',
          dueWeek: 2,
          title: 'Old audit',
          assignment: const PetitionAssignment(
            eventId: 'tax_abuse',
            assigneeId: '',
            assigneeName: '',
            specialty: 'Dân chính',
            chance: 35,
            succeeded: true,
            failureEffects: {},
          ),
        ),
        Consequence(
          kind: 'eventOutcome',
          dueWeek: 5,
          title: 'Old reward',
          effects: {'treasury': 33},
        ),
        Consequence(
          kind: 'eventOutcome',
          dueWeek: 5,
          title: 'Old failure',
          effects: {},
          assignment: const PetitionAssignment(
            eventId: 'finance_02',
            assigneeId: '',
            assigneeName: '',
            specialty: 'Kinh tế',
            chance: 50,
            succeeded: false,
            failureEffects: {'treasury': -8, 'stability': -2},
          ),
        ),
      ]);
      final saved =
          object(jsonDecode(jsonEncode(s.toJson())))
            ..['rulesVersion'] = 'mvp-0.17.3'
            ..['contentVersion'] = 16
            ..['scoreRules'] = 'mvp-0.17.3';
      for (final p in saved['pending'] as List) {
        final a = p['assignment'] as Map?;
        a?.remove('auditRecoveryMinimum');
        a?.remove('auditRecoveryMaximum');
      }
      var restored = GameState.fromJson(saved);
      expect(restored.scoreRules, 'mvp-0.17.3');
      expect(restored.pending.map((p) => p.dueWeek), [2, 5, 5]);
      while (restored.week <= 5) {
        restored = close(restored);
      }
      expect(
        restored.outcomes
            .singleWhere((o) => o.title == 'Old audit')
            .changes['Ngân khố'],
        inInclusiveRange(25, 45),
      );
      expect(
        restored.outcomes
            .singleWhere((o) => o.title == 'Old reward')
            .changes['Ngân khố'],
        33,
      );
      final failure = restored.outcomes.singleWhere(
        (o) => o.title == 'Old failure',
      );
      expect(failure.changes['Ngân khố'], -8);
      expect(failure.changes[stabilityLabel], -2);
    },
  );

  test(
    'new audits snapshot their reward range, fee and next-season deadline',
    () {
      for (final id in ['tax_abuse', 'treasury_review']) {
        var s = fresh()..rng = 100;
        s.petitions.add(
          Petition(
            id: 'p',
            definitionId: id,
            openedWeek: s.week,
            deadline: s.week + 1,
          ),
        );
        final choice = eventForState(s, id).choices.first;
        expect(choice.cost, 20);
        final result = engine.execute(
          s,
          GameCommand(
            id: 'choose',
            runId: s.runId,
            expectedRevision: s.revision,
            type: 'petition',
            target: 'p',
            option: '0',
          ),
        );
        expect(result.treasury, s.treasury - 20);
        s = GameState.fromJson(object(jsonDecode(jsonEncode(result.toJson()))));
        expect(s.pending.single.assignment!.auditRecoveryMinimum, 60);
        expect(s.pending.single.assignment!.auditRecoveryMaximum, 90);
        expect(s.pending.single.dueWeek, 2);
        s = close(s);
        expect(s.outcomes, isEmpty);
        s = close(s);
        expect(s.outcomes.single.changes['Ngân khố'], inInclusiveRange(60, 90));
      }
    },
  );
}
