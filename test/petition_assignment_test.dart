import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/petition_assignment_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine();
  GameState fresh({String event = 'community_03'}) {
    final s = engine.start('assignment', 'An', 42);
    s.treasury = 10000;
    s.grain = 180;
    s.people = s.authority = s.stability = s.army = s.health = 80;
    s.debt = s.war = s.fatigue = s.stress = s.illness = 0;
    s.factions.updateAll((key, value) => 70);
    s.nextMajorWeek = s.nextChainWeek = 10000;
    for (final c in s.court) {
      c.affection = c.baseAffection = 80;
      c.loyalty = c.integrity = 100;
      c.discontent = c.strain = c.plot = 0;
      c.ability = 100;
      c.personalities
        ..clear()
        ..addAll([Personality.grateful, Personality.diplomatic]);
    }
    final definition = eventForState(s, event);
    s.court.first.specialty = petitionSpecialty(
      definition,
      definition.choices[event == 'border_riders' ? 1 : 0],
    );
    s.petitions = [
      Petition(id: 'p', definitionId: event, openedWeek: 1, deadline: 2),
    ];
    s.midSeasonDelivered = true;
    s.rng = 1; // roll 71: fails unassigned 30%, succeeds assigned 90%.
    return s;
  }

  GameCommand decision(
    GameState s, {
    String person = '',
    String option = '0',
    String id = 'choose',
  }) => GameCommand(
    id: id,
    runId: s.runId,
    expectedRevision: s.revision,
    type: 'petition',
    target: 'p',
    option: option,
    assigneeId: person,
  );
  GameState close(GameState s) {
    s.petitions.clear();
    s.affairsThisWeek = s.workThisWeek = 1;
    s.midSeasonDelivered = true;
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

  GameState settle(GameState s) {
    final due = s.pending.first.dueWeek;
    while (s.week <= due && !s.ended) {
      s = close(s);
    }
    return s;
  }

  test(
    'every assignable choice lists only available people with the exact specialty',
    () {
      final s = fresh();
      final matching = s.court.first;
      final related = s.court[1];
      final unrelated = s.court[2];
      final specialties = [
        'Dân chính',
        'Kinh tế',
        'Công trình',
        'Quân sự',
        'An ninh',
        'Ngoại giao',
        'Y thuật',
        'Cung đình',
      ];
      for (final raw in events) {
        final e = eventForState(s, raw.id);
        for (final c in e.choices.where((c) => petitionCanAssign(s, c))) {
          final specialty = petitionSpecialty(e, c);
          matching.specialty = specialty;
          related.specialty = specialties.firstWhere(
            (value) => specialtyFit(value, specialty) == 65,
          );
          unrelated.specialty = specialties.firstWhere(
            (value) => specialtyFit(value, specialty) == 20,
          );
          final candidates = petitionAssignees(s, e, c);
          expect(candidates, contains(matching), reason: '${e.id}: ${c.label}');
          expect(candidates, isNot(contains(related)));
          expect(candidates, isNot(contains(unrelated)));
          expect(candidates.every((p) => p.specialty == specialty), isTrue);
          matching.strain = 0;
          matching.available = false;
          expect(petitionAssignees(s, e, c), isNot(contains(matching)));
          matching.available = true;
        }
      }
    },
  );

  test(
    'repair rejects related and unrelated specialists without changing state',
    () {
      for (final specialty in ['Kinh tế', 'Quân sự']) {
        final s = fresh(event: 'levee_warning');
        s.court.first.specialty = specialty;
        final before = jsonEncode(s.toJson());
        expect(
          () => engine.execute(s, decision(s, person: s.court.first.id)),
          throwsA(
            isA<GameRuleException>().having(
              (e) => e.message,
              'reason',
              contains('chuyên môn Công trình'),
            ),
          ),
        );
        expect(jsonEncode(s.toJson()), before);
      }
    },
  );

  test('no matching specialists still allows an unassigned petition', () {
    final s = fresh(event: 'levee_warning');
    for (final person in s.court) {
      person.specialty = 'Quân sự';
    }
    final e = eventForState(s, 'levee_warning');
    expect(petitionAssignees(s, e, e.choices.first), isEmpty);
    final result = engine.execute(s, decision(s));
    expect(result.pending.single.assignment!.assigneeId, isEmpty);
  });

  test(
    'all 148 risky choices share the 30% default and attainable 90% cap',
    () {
      final s = fresh();
      var count = 0;
      for (final raw in events) {
        final e = eventForState(s, raw.id);
        for (final c in e.choices) {
          if (!petitionCanAssign(s, c)) continue;
          count++;
          expect(petitionBaseChance(c), 30);
          expect(petitionChance(s, e, c), 30);
          final person = s.court.first;
          person.specialty = petitionSpecialty(e, c);
          expect(petitionChance(s, e, c, person), 90);
        }
      }
      expect(count, 148);
    },
  );

  test(
    'ability and fatigue match the preview with neutral relations and traits',
    () {
      final s = fresh(event: 'levee_warning');
      final e = eventForState(s, 'levee_warning');
      final c = e.choices.first;
      final p = s.court.first;
      p.affection = 50;
      p.personalities
        ..clear()
        ..addAll([Personality.grateful, Personality.honest]);
      s.factions[p.faction] = 50;
      const rows = {
        0: [35, 35, 35, 35, 35, 35],
        20: [42, 37, 35, 35, 35, 35],
        41: [55, 50, 45, 40, 35, 35],
        60: [66, 61, 56, 52, 47, 42],
        80: [78, 73, 68, 64, 59, 54],
        100: [90, 85, 80, 76, 71, 66],
      };
      for (final row in rows.entries) {
        p.ability = row.key;
        for (var column = 0; column < row.value.length; column++) {
          p.strain = column * 20;
          expect(
            petitionChance(s, e, c, p),
            row.value[column],
            reason: 'ability ${p.ability}, fatigue ${p.strain}',
          );
        }
      }
      p.ability = 100;
      for (final (fatigue, chance) in [(9, 90), (10, 88), (19, 88), (20, 85)]) {
        p.strain = fatigue;
        expect(petitionChance(s, e, c, p), chance);
      }
    },
  );

  test('assignment adds 20 fatigue and busy officers recover 5 per season', () {
    final s = fresh(event: 'commerce_01');
    final assigned = engine.execute(s, decision(s, person: 'chancellor'));
    expect(assigned.court.first.strain, 20);
    final committedChance = assigned.pending.single.assignment!.chance;
    final afterSeason = close(assigned);
    expect(officerBusy(afterSeason, 'chancellor'), isTrue);
    expect(afterSeason.court.first.strain, 15);
    expect(afterSeason.pending.single.assignment!.chance, committedChance);
  });

  test('fatigue caps at 100 and idle recovery floors at zero', () {
    final s = fresh(event: 'commerce_01');
    s.court.first.strain = 95;
    final assigned = engine.execute(s, decision(s, person: 'chancellor'));
    expect(assigned.court.first.strain, 100);
    final idle = fresh();
    idle.court.first.strain = 9;
    expect(close(idle).court.first.strain, 0);
  });

  test(
    'the same roll fails without a person and succeeds with a skilled courtier',
    () {
      final unassigned = fresh(), assigned = fresh();
      final e = eventForState(assigned, 'community_03'),
          c = eventForState(assigned, 'community_03').choices.first;
      final preview = petitionChance(assigned, e, c, assigned.court.first);
      final a = engine.execute(unassigned, decision(unassigned));
      final b = engine.execute(
        assigned,
        decision(assigned, person: 'chancellor'),
      );
      expect(a.pending.single.assignment!.assigneeId, isEmpty);
      expect(a.pending.single.assignment!.chance, 30);
      expect(a.pending.single.assignment!.succeeded, false);
      expect(b.pending.single.assignment!.chance, preview);
      expect(preview, 90);
      expect(b.pending.single.assignment!.succeeded, true);
      expect(b.points, a.points);
      expect(b.treasury, a.treasury);
      expect(officerBusy(b, 'chancellor'), true);
      final result = settle(b.copy());
      expect(result.outcomes.single.status, 'success');
      expect(result.outcomes.single.detail, contains('Trần Văn Chính'));
      expect(officerBusy(result, 'chancellor'), false);
      expect(settle(a).outcomes.single.status, 'failure');
    },
  );

  test(
    'an admitted adult consort can handle the same work without extra AP',
    () {
      final s = fresh();
      final person = s.court.firstWhere((c) => c.id == 'consort_lan');
      person.inHarem = true;
      person.specialty = 'Dân chính';
      final result = engine.execute(s, decision(s, person: person.id));
      expect(result.points, 11);
      expect(result.pending.single.assignment!.assigneeId, person.id);
      expect(officerBusy(result, person.id), isTrue);
      expect(
        settle(result).outcomes.single.status,
        result.pending.single.assignment!.succeeded ? 'success' : 'failure',
      );
    },
  );

  test(
    'specialty, ability, fatigue and known relations influence the offered chance',
    () {
      final s = fresh(), e = eventForState(fresh(), 'community_03');
      final c = e.choices.first;
      final p = s.court.first;
      final strong = petitionChance(s, e, c, p);
      p.specialty = 'Quân sự';
      p.ability = 20;
      p.strain = 90;
      p.affection = 5;
      p.discontent = 100;
      p.investigated = true;
      p.loyalty = 5;
      final weak = petitionChance(s, e, c, p);
      expect(weak, lessThan(strong));
      expect(weak, greaterThan(petitionChance(s, e, c)));
      p.investigated = false;
      p.loyalty = 0;
      final unknown = petitionChance(s, e, c, p);
      p.loyalty = 100;
      expect(petitionChance(s, e, c, p), unknown);
    },
  );

  test(
    'busy, underage, departed, unadmitted and unknown people are rejected atomically',
    () {
      for (final mode in [
        'busy',
        'underage',
        'departed',
        'candidate',
        'missing',
      ]) {
        final s = fresh();
        var id = 'chancellor';
        final c = s.court.first;
        if (mode == 'busy') {
          s.projects.add(
            WorkOrder(
              id: 'job',
              kind: 'farm',
              officerId: c.id,
              startedWeek: 1,
              duration: 2,
            ),
          );
        }
        if (mode == 'underage') c.age = 17;
        if (mode == 'departed') c.available = false;
        if (mode == 'candidate') id = 'consort_lan';
        if (mode == 'missing') id = 'not-a-person';
        final before = jsonEncode(s.toJson());
        expect(
          () => engine.execute(s, decision(s, person: id)),
          throwsA(isA<GameRuleException>()),
        );
        expect(jsonEncode(s.toJson()), before);
      }
      final s = fresh();
      expect(
        () => engine.execute(s, decision(s, person: 'chancellor', option: '1')),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test(
    'an assigned person cannot be reused for a second petition or other work',
    () {
      final s = fresh(event: 'commerce_01');
      var a = engine.execute(s, decision(s, person: 'chancellor'));
      a.petitions = [
        Petition(
          id: 'p',
          definitionId: 'community_03',
          openedWeek: 1,
          deadline: 2,
        ),
      ];
      expect(
        () =>
            engine.execute(a, decision(a, person: 'chancellor', id: 'second')),
        throwsA(isA<GameRuleException>()),
      );
      expect(
        () => engine.execute(
          a,
          GameCommand(
            id: 'work',
            runId: a.runId,
            expectedRevision: a.revision,
            type: 'action',
            target: 'repair',
            option: 'chancellor',
          ),
        ),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test(
    'death or dismissal interrupts the named assignment without automatic replacement',
    () {
      final s = fresh(event: 'commerce_01');
      var a = engine.execute(s, decision(s, person: 'chancellor'));
      a.court.first.available = false;
      final result = settle(a.copy());
      expect(result.outcomes.single.status, 'interrupted');
      expect(result.outcomes.single.detail, contains('Trần Văn Chính'));
      expect(result.pending, isEmpty);
    },
  );

  for (final event in [
    'levee_warning',
    'tax_abuse',
    'border_riders',
    'court_rumor',
    'treasury_review',
  ]) {
    test('$event no longer auto-picks a person when left unassigned', () {
      final s = fresh(event: event);
      s.rng = 1;
      final option = event == 'border_riders' ? '1' : '0';
      final result = engine.execute(s, decision(s, option: option));
      expect(result.pending.single.assignment!.assigneeId, isEmpty);
      expect(result.pending.single.assignment!.chance, 30);
      expect(result.pending.single.assignment!.succeeded, false);
      expect(result.projects, isEmpty);
      expect(settle(result).outcomes.single.status, 'failure');
    });
    test(
      '$event resolves through its assigned courtier and reports the right reward',
      () {
        final s = fresh(event: event)..rng = 100;
        s.war = 2;
        s.court.firstWhere((c) => c.id == 'prince').plot = 50;
        final option = event == 'border_riders' ? '1' : '0';
        final result = settle(
          engine.execute(s, decision(s, person: 'chancellor', option: option)),
        );
        final report = result.outcomes.single;
        expect(report.status, 'success');
        expect(report.detail, contains('Trần Văn Chính'));
        if (event == 'levee_warning') {
          expect(report.changes['Đê điều'], greaterThan(0));
        }
        if (event == 'tax_abuse' || event == 'treasury_review') {
          expect(report.changes['Ngân khố'], inInclusiveRange(60, 90));
        }
        if (event == 'border_riders') {
          expect(report.changes['Áp lực chiến tranh'], lessThan(0));
        }
        if (event == 'court_rumor') {
          expect(
            result.court.firstWhere((c) => c.id == 'prince').plot,
            lessThan(44),
          );
        }
      },
    );
  }

  test(
    'insufficient payment does not roll or reserve the requested person',
    () {
      final s = fresh()..treasury = 0;
      final before = jsonEncode(s.toJson());
      expect(
        () => engine.execute(s, decision(s, person: 'chancellor')),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
      expect(officerBusy(s, 'chancellor'), false);
    },
  );

  test('a consort assigned a long petition cannot start palace study', () {
    final s = fresh(event: 'commerce_01');
    s.court.firstWhere((c) => c.id == 'consort_lan').inHarem = true;
    s.court.firstWhere((c) => c.id == 'consort_lan').ability = 80;
    s.court.firstWhere((c) => c.id == 'consort_lan').specialty = 'Kinh tế';
    final a = engine.execute(s, decision(s, person: 'consort_lan'));
    expect(
      () => engine.execute(
        a,
        GameCommand(
          id: 'study',
          runId: a.runId,
          expectedRevision: a.revision,
          type: 'palace',
          target: 'consort_lan',
          option: 'study',
        ),
      ),
      throwsA(
        isA<GameRuleException>().having(
          (e) => e.message,
          'reason',
          contains('đã được thay'),
        ),
      ),
    );
  });

  test(
    'reload and idempotent gateway retries preserve staff, chance and the one-time result',
    () async {
      final store = MemoryGameStore();
      // Use one shared store for committed dispatches and reloads.
      final committed = LocalGameGateway(store);
      final s = fresh(event: 'commerce_01');
      await store.update((a) => a.active = s);
      final cmd = decision(s, person: 'chancellor');
      final first = await committed.dispatch(cmd),
          again = await committed.dispatch(cmd);
      expect(again.toJson(), first.toJson());
      final pending = first.active!.pending.single.toJson();
      expect((await committed.load()).active!.pending.single.toJson(), pending);
      await expectLater(
        committed.dispatch(decision(s, person: 'doctor')),
        throwsA(isA<GameRuleException>()),
      );
      final result = settle(first.active!.copy());
      expect(result.outcomes, hasLength(1));
      final later = close(result.copy());
      expect(later.outcomes, hasLength(1));
      expect(later.outcomes.single.toJson(), result.outcomes.single.toJson());
    },
  );

  test(
    'previously committed chances above the new cap survive reload and settlement',
    () {
      final s = fresh(event: 'commerce_01');
      final assigned = engine.execute(s, decision(s, person: 'chancellor'));
      final raw = assigned.toJson();
      (raw['pending'] as List).single['assignment']['chance'] = 95;
      final restored = GameState.fromJson(raw);
      expect(restored.pending.single.assignment!.chance, 95);
      final result = settle(restored);
      expect(result.outcomes.single.status, 'success');
      expect(result.outcomes.single.detail, contains('95%'));
    },
  );

  test(
    'legacy pending outcomes and command signatures retain their old contract',
    () {
      final s = fresh();
      s.petitions.clear();
      s.pending.add(
        Consequence(
          kind: 'eventOutcome',
          dueWeek: 1,
          title: 'Old',
          detail: 'thành công',
          effects: {'treasury': 17},
        ),
      );
      final raw =
          s.toJson()
            ..['rulesVersion'] = 'mvp-0.15.2'
            ..remove('scoreRules');
      final restored = GameState.fromJson(raw);
      expect(restored.pending.single.assignment, isNull);
      expect(restored.scoreRules, 'mvp-0.15.2');
      expect(close(restored).outcomes.single.changes['Ngân khố'], 17);
      expect(decision(s).toJson().containsKey('assigneeId'), false);
    },
  );
}
