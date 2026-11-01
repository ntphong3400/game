import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/event_stories.dart';
import 'package:van_tue/game/data/expanded_events.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState send(
    GameState s,
    String type, {
    String target = '',
    String option = '',
  }) => engine.execute(
    s,
    GameCommand(
      id: 'event-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );
  void stabilize(GameState s) {
    s.treasury = 10000;
    s.grain = 180;
    s.people = s.stability = s.authority = s.army = s.health = 85;
    s.levee = 85;
    s.fatigue = s.stress = s.illness = s.war = s.siege = s.debt = 0;
    s.neglectedWeeks = 0;
    s.affairsThisWeek = 1;
    s.workThisWeek = 1;
    s.restThisWeek = 1;
    s.factions.updateAll((k, v) => 60);
    for (final c in s.court) {
      c.loyalty = 90;
      c.ambition = 10;
      c.plot = 0;
      c.affection = c.baseAffection = 60;
    }
  }

  GameState fresh([int seed = 42]) {
    final s = engine.start('catalog', 'An', seed);
    stabilize(s);
    s.financialWeeks.clear();
    s.petitions.clear();
    return s;
  }

  void add(GameState s, EventDefinition e, {int? deadline}) {
    s.petitions.add(
      Petition(
        id: 'test',
        definitionId: e.id,
        openedWeek: s.week,
        deadline: deadline ?? s.week + 1,
        targetId: e.id == 'consort_recommendation' ? 'consort_lan' : '',
      ),
    );
  }

  test(
    'catalog is exactly tenfold: 45 originals plus 405 authored stories',
    () {
      expect(baseEvents, hasLength(45));
      expect(events, hasLength(450));
      expect(expandedEvents, hasLength(405));
      expect(eventStories, hasLength(15));
      for (final pack in eventStories.entries) {
        expect(pack.value.trim().split('\n'), hasLength(27), reason: pack.key);
      }
      expect(events.map((e) => e.id).toSet(), hasLength(450));
      expect(events.map((e) => e.title).toSet(), hasLength(450));
      expect(events.map((e) => e.body).toSet(), hasLength(450));
      final effectKeys = {
        'treasury',
        'people',
        'authority',
        'army',
        'health',
        'stability',
        'grain',
        'levee',
        'stress',
        'fatigue',
        'illness',
        'war',
        'debt',
        'revel',
        'rest',
        'work',
        'peace',
        'taxNormal',
        'plotReduce',
        'repair',
        'revealCandidates',
        'recruitConsort',
        'rejectConsort',
      };
      final conditions = {
        'any',
        'spring',
        'rain',
        'winter',
        'flood',
        'hungry',
        'poor',
        'rich',
        'court',
        'ill',
        'peace',
        'war',
        'debt',
        'harem',
        'stressed',
        'weakArmy',
        'tax',
        'plot',
        'lowPeople',
        'weakAuthority',
        'recruitment',
        'weakLevee',
        'hasConsort',
        'factionSplit',
      };
      final knownFactions = fresh().factions.keys;
      for (final e in events) {
        expect(conditions, contains(e.condition), reason: e.id);
        expect(e.title.trim(), isNotEmpty);
        expect(e.body.trim(), isNotEmpty);
        expect(e.choices.length, inInclusiveRange(2, 4));
        expect(
          e.choices.map((c) => c.label).toSet(),
          hasLength(e.choices.length),
          reason: e.id,
        );
        expect(
          e.choices.last.cost +
              e.choices.last.grainCost +
              e.choices.last.points,
          e.id == 'consort_recommendation' ? 1 : 0,
          reason: e.id,
        );
        for (final c in e.choices) {
          expect(c.successChance, inInclusiveRange(1, 100));
          expect(c.cost, greaterThanOrEqualTo(0));
          expect(c.grainCost, greaterThanOrEqualTo(0));
          if (c.laterEffects.isNotEmpty) {
            expect(c.delay, greaterThan(0));
            expect(c.hint, contains('Sau ${c.delay} tuần'));
            if (c.successChance < 100) {
              expect(c.laterFailureEffects, isNotEmpty);
              expect(c.hint, contains('${c.successChance}%'));
            }
          }
          for (final key in {
            ...c.effects.keys,
            ...c.laterEffects.keys,
            ...c.laterFailureEffects.keys,
          }) {
            if (key.startsWith('faction:')) {
              expect(knownFactions, contains(key.substring(8)));
            } else if (key.startsWith('affection:')) {
              expect(knownFactions, contains(key.substring(10)));
            } else {
              expect(effectKeys, contains(key), reason: '${e.id}/$key');
            }
          }
        }
      }
    },
  );

  test('every choice executes through engine and survives save/load', () {
    for (final e in events) {
      for (var i = 0; i < e.choices.length; i++) {
        final s = fresh();
        add(s, e);
        final next = send(s, 'petition', target: 'test', option: '$i');
        expect(next.petitions, isEmpty, reason: '${e.id}/$i');
        expect(next.ended, false, reason: '${e.id}/$i');
        expect(next.copy().toJson(), next.toJson(), reason: '${e.id}/$i');
        final report = next.financialWeeks.single;
        expect(
          report.openingBalance + report.income - report.expense,
          next.treasury,
          reason: '${e.id}/$i cash',
        );
        expect(
          report.openingDebt + report.newDebt - report.debtReduction,
          next.debt,
          reason: '${e.id}/$i debt',
        );
        final c = e.choices[i];
        if (c.laterEffects.isNotEmpty) {
          final result = next.pending.singleWhere(
            (p) => p.kind == 'eventOutcome',
          );
          expect(result.title, e.title);
          expect(result.dueWeek, s.week + c.delay - 1);
          expect(
            result.effects,
            anyOf(equals(c.laterEffects), equals(c.laterFailureEffects)),
          );
        }
      }
    }
  });

  test('all 450 timeouts apply defaults once without spending resources', () {
    for (final e in events) {
      final s = fresh();
      add(s, e, deadline: s.week);
      final result = send(s, 'endWeek');
      expect(result.ended, false, reason: e.id);
      expect(result.petitions.any((p) => p.id == 'test'), false);
      final timeout = result.journal.where(
        (n) => n.title == 'Tấu chương quá hạn',
      );
      expect(timeout, hasLength(1), reason: e.id);
      expect(timeout.single.text, contains(e.title));
      result.petitions.clear();
      final later = send(result, 'endWeek');
      expect(
        later.journal.where((n) => n.title == 'Tấu chương quá hạn'),
        hasLength(1),
        reason: e.id,
      );
    }
  });

  test(
    'expanded payments are validated atomically, including grain exchange',
    () {
      for (final e in expandedEvents) {
        for (var i = 0; i < e.choices.length; i++) {
          final c = e.choices[i];
          for (final resource in ['money', 'grain', 'points']) {
            if (resource == 'money' && c.cost == 0 ||
                resource == 'grain' && c.grainCost == 0 ||
                resource == 'points' && c.points == 0) {
              continue;
            }
            final s = fresh();
            add(s, e);
            if (resource == 'money') s.treasury = 0;
            if (resource == 'grain') s.grain = 0;
            if (resource == 'points') s.points = 0;
            final before = jsonEncode(s.toJson());
            expect(
              () => send(s, 'petition', target: 'test', option: '$i'),
              throwsA(isA<GameRuleException>()),
              reason: '${e.id}/$i/$resource',
            );
            expect(jsonEncode(s.toJson()), before);
          }
        }
      }
      expect(eventById('commerce_03').choices[1].grainCost, 18);
      expect(eventById('finance_03').choices[0].cost, 10);
    },
  );

  test(
    'delayed successes and failures resolve once on time, never reroll on reload',
    () {
      final e = eventById('finance_02');
      for (final roll in [0, 99]) {
        final s = fresh();
        s.rng = roll == 0 ? 100 : roll * 31 % 100;
        add(s, e);
        var a = send(s, 'petition', target: 'test', option: '0');
        var b = a.copy();
        expect(
          a.pending.single.effects,
          roll == 0
              ? e.choices[0].laterEffects
              : e.choices[0].laterFailureEffects,
        );
        expect(
          a.pending.single.detail,
          contains(roll == 0 ? 'thành công' : 'thất bại'),
        );
        expect(a.journal.any((n) => n.title == 'Kết quả: ${e.title}'), false);
        a = send(a, 'endWeek');
        b = send(b, 'endWeek').copy();
        expect(b.toJson(), a.toJson());
        expect(a.pending.where((p) => p.kind == 'eventOutcome'), hasLength(1));
        final before = a.treasury;
        // The two-week result is due at the end of week 2.
        a = send(a, 'endWeek');
        b = send(b, 'endWeek').copy();
        expect(b.toJson(), a.toJson());
        expect(a.pending.where((p) => p.kind == 'eventOutcome'), isEmpty);
        expect(
          a.journal.where((n) => n.title == 'Kết quả: ${e.title}'),
          hasLength(1),
        );
        expect(
          a.treasury - before - a.lastIncome + a.lastExpense,
          (roll == 0
              ? e.choices[0].laterEffects
              : e.choices[0].laterFailureEffects)['treasury'],
        );
        a.petitions.clear();
        a = send(a, 'endWeek');
        expect(
          a.journal.where((n) => n.title == 'Kết quả: ${e.title}'),
          hasLength(1),
        );
      }
    },
  );

  test(
    'event choices affect named factions and only active members affection',
    () {
      final s = fresh();
      final e = eventById('factions_01');
      add(s, e);
      final result = send(s, 'petition', target: 'test', option: '1');
      expect(result.factions['Võ tướng'], 65);
      expect(result.factions['Văn thần'], 55);
      final p = fresh();
      add(p, eventById('palace_01'));
      final active =
          p.court
              .where(
                (c) =>
                    c.faction == 'Hoàng tộc' &&
                    (!c.isConsort || c.inHarem) &&
                    c.available,
              )
              .map((c) => c.id)
              .toSet();
      final changed = send(p, 'petition', target: 'test', option: '1');
      for (final c in changed.court) {
        expect(c.affection, active.contains(c.id) ? 58 : 60, reason: c.id);
      }
    },
  );

  test(
    'deferred losses beyond the treasury become debt instead of disappearing',
    () {
      final s = fresh();
      s.pending.add(
        Consequence(
          kind: 'eventOutcome',
          dueWeek: 1,
          title: 'Khoản lỗ',
          detail: 'Đầu tư thất bại.',
          effects: {'treasury': -20000},
        ),
      );
      final result = send(s, 'endWeek');
      expect(result.treasury, 0);
      expect(result.debt, greaterThan(9000));
    },
  );

  test(
    'new situation conditions gate harem, weak levees and faction disputes',
    () {
      final s = fresh()..completedWeeks = 9;
      expect(engine.eligible(s, eventById('palace_02')), false);
      s.court.firstWhere((c) => c.id == 'consort_lan').inHarem = true;
      expect(engine.eligible(s, eventById('palace_02')), true);
      expect(engine.eligible(s, eventById('disasters_22')), false);
      s.levee = 30;
      expect(engine.eligible(s, eventById('disasters_22')), true);
      expect(engine.eligible(s, eventById('factions_22')), false);
      s.factions['Hoàng tộc'] = 10;
      expect(engine.eligible(s, eventById('factions_22')), true);
    },
  );

  test(
    'normal event selection exhausts unseen eligible stories before repeating',
    () {
      var s = fresh();
      final normal = <String>{};
      for (var w = 0; w < 180; w++) {
        // Isolate the ordinary scheduler, not a playable survival strategy.
        // Major crises now can kill even this 85-stat fixture; their long-run
        // rotation and terminal effects are covered in major_catalog_test.
        stabilize(s);
        s.major = null;
        s.nextMajorWeek = s.nextChainWeek = 10000;
        s.chains.clear();
        s.petitions.clear();
        s = send(s, 'endWeek');
        expect(s.ended, false);
        for (final p in s.petitions) {
          final e = eventById(p.definitionId);
          if (eventTrigger(e).isNotEmpty || e.id == 'consort_recommendation') {
            continue;
          }
          expect(
            normal.add(e.id),
            true,
            reason: '${e.id} repeated at week ${s.week}',
          );
          expect(s.eventSeen[e.id], 1);
        }
        s = s.copy();
      }
      expect(normal.length, greaterThan(120));
      expect(s.eventSeen.length, greaterThan(normal.length));
      expect(s.eventFamilyWeeks, isNotEmpty);
      expect(s.recentEventCategories.length, lessThanOrEqualTo(3));
    },
  );

  test('scheduler prefers a spaced family when unseen alternatives exist', () {
    var checked = false;
    for (var seed = 1; seed < 20 && !checked; seed++) {
      final s = fresh(seed)..completedWeeks = 8;
      for (final e in events) {
        s.eventSeen[e.id] = 1;
      }
      s.eventSeen['community_01'] = s.eventSeen['finance_01'] = 0;
      s.eventFamilyWeeks['community'] = s.week + 1;
      s.recentEventCategories = ['Dân sinh'];
      final result = send(s, 'endWeek');
      if (result.petitions.isEmpty) continue;
      expect(result.petitions.first.definitionId, 'finance_01');
      checked = true;
    }
    expect(checked, true);
  });

  test(
    'urgent flavors share cooldown and rotate without hiding unresolved hunger',
    () {
      var s = fresh()..grain = 0;
      s = send(s, 'endWeek');
      final hunger = s.petitions.singleWhere(
        (p) => eventTrigger(eventById(p.definitionId)) == 'hunger',
      );
      final first = hunger.definitionId;
      expect(s.cooldowns['hunger'], s.week + eventById('hunger').cooldown);
      for (final e in events.where((e) => eventTrigger(e) == 'hunger')) {
        expect(engine.eligible(s, e), false);
      }
      final due = s.cooldowns['hunger']!;
      s.petitions.clear();
      while (s.week < due) {
        stabilize(s);
        s.grain = 0;
        s.petitions.clear();
        s = send(s, 'endWeek');
        expect(s.ended, false);
        if (s.week < due) {
          expect(
            s.petitions.any(
              (p) => eventTrigger(eventById(p.definitionId)) == 'hunger',
            ),
            false,
          );
        }
      }
      expect(
        s.petitions.where(
          (p) => eventTrigger(eventById(p.definitionId)) == 'hunger',
        ),
        hasLength(1),
      );
      expect(
        s.petitions
            .firstWhere(
              (p) => eventTrigger(eventById(p.definitionId)) == 'hunger',
            )
            .definitionId,
        isNot(first),
      );
      expect(s.eventSeen[first], 1);
    },
  );
}
