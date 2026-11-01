import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/logic/palace_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

GameState freshPalace() {
  final s = GameEngine().start('palace', 'An', 42);
  s.court = List.generate(
    4,
    (i) => Courtier(
      id: 'wife-$i',
      name: 'Nàng $i',
      role: 'Tiểu thư',
      faction: 'Văn thần',
      trait: '',
      age: 25,
      ability: 70,
      loyalty: 90,
      integrity: 95,
      ambition: 10,
      influence: 20,
      affection: 60,
      baseAffection: 60,
      personalities: [Personality.disciplined, Personality.honest],
      inHarem: true,
    ),
  );
  s.petitions.clear();
  s.nextMajorWeek = s.nextChainWeek = 10000;
  s.treasury = 1000;
  s.stability = 60;
  s.people = s.authority = s.health = s.army = 80;
  s.affairsThisWeek = 1;
  s.factions.updateAll((k, v) => 60);
  return s;
}

GameCommand palaceCommand(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => GameCommand(
  id: 'p-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: type,
  target: target,
  option: option,
);
GameState palaceSend(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => GameEngine().execute(
  s,
  palaceCommand(s, type, target: target, option: option),
);
GameState closePalace(GameState s) {
  // Isolate palace settlement from unrelated petitions/neglect over long tests.
  s.petitions.clear();
  s.affairsThisWeek = s.restThisWeek = 1;
  s.health = s.army = s.authority = 80;
  s.grain = 150;
  return palaceSend(s, 'endWeek');
}

GameState resolvedDuty(String kind, {String status = 'success'}) {
  for (var seed = 1; seed < 200; seed++) {
    var s = freshPalace()..rng = seed;
    s.completedWeeks = 2; // Thu permits ceremony.
    if (status == 'partial') {
      s.court.first.integrity = 0;
      s.court.first.personalities
        ..clear()
        ..addAll([Personality.greedy, Personality.disciplined]);
    }
    s = palaceSend(
      s,
      'palace',
      target: 'wife-0',
      option: kind == 'kinship' ? 'kinship:Thế gia' : kind,
    );
    while (s.palaceWorks.isNotEmpty) {
      s = closePalace(s).copy();
    }
    if (s.outcomes.last.status == status) return s;
  }
  throw StateError('No deterministic $status result for $kind');
}

void main() {
  test(
    'palace care cannot revive a king whose health reaches zero during settlement',
    () {
      final s = freshPalace();
      s.health = 1;
      s.illness = 100;
      s.restThisWeek = 0;
      s.palaceEffects.add(
        PalaceEffect(
          kind: 'kitchen',
          personId: 'wife-0',
          startsTurn: 1,
          endsTurn: 3,
          amount: 2,
        ),
      );
      final result = palaceSend(s, 'endWeek');
      expect(result.ended, true);
      expect(result.health, 0);
      expect(
        result.journal.any((n) => n.title == 'Ngự thiện điều dưỡng'),
        false,
      );
    },
  );

  test(
    'all 12 duties retain the agreed costs, grain and seasonal durations',
    () {
      expect(palaceDuties.map((d) => (d.cost, d.grain, d.duration)), [
        (15, 0, 2),
        (20, 0, 2),
        (8, 0, 1),
        (15, 5, 2),
        (25, 0, 3),
        (10, 0, 1),
        (30, 5, 2),
        (20, 0, 1),
        (10, 0, 2),
        (15, 0, 2),
        (20, 25, 2),
        (40, 0, 3),
      ]);
      expect(palaceDuties.map((d) => d.id).toSet(), hasLength(12));
    },
  );

  test(
    'study costs one AP and 20 once, takes two closes, and persists XP and achievements',
    () {
      var s = freshPalace();
      s.court.first.ability = 58;
      s = palaceSend(s, 'palace', target: 'wife-0', option: 'study');
      expect(s.points, 11);
      expect(s.seasonActionsSpent, 1);
      expect(s.treasury, 980);
      expect(s.affairsThisWeek, 1);
      expect(
        s.financialWeeks.last.entries
            .where((e) => e.category == 'palace')
            .single
            .amount,
        -20,
      );
      expect(s.palaceWorks.single.dueTurn, 2);
      s = closePalace(s).copy();
      expect(s.palaceWorks.single.progress, 1);
      expect(s.court.first.ability, 58);
      s = closePalace(s).copy();
      expect(s.palaceWorks, isEmpty);
      expect(s.court.first.ability, 60);
      expect(s.court.first.palaceExperience, 0);
      expect(s.court.first.palaceCoursesCompleted, 1);
      expect(s.outcomes.single.changes['Năng lực Nàng 0'], 2);
      expect(
        s.financialWeeks
            .expand((w) => w.entries)
            .where((e) => e.category == 'palace'),
        hasLength(1),
      );
      s = closePalace(s);
      expect(s.court.first.palaceCoursesCompleted, 1);
    },
  );

  test('study slows at high ability and clamps at 100 without leftover XP', () {
    for (final (ability, xp, expected, remainder) in [
      (60, 0, 61, 0),
      (80, 0, 80, 10),
      (90, 0, 90, 10),
      (99, 55, 100, 0),
    ]) {
      var s = freshPalace();
      s.court.first
        ..ability = ability
        ..palaceExperience = xp;
      s = palaceSend(s, 'palace', target: 'wife-0', option: 'study');
      s = closePalace(closePalace(s));
      expect(s.court.first.ability, expected);
      expect(s.court.first.palaceExperience, remainder);
    }
    expect(
      dutyExperience(
        palaceDuty('wardrobe')!,
        freshPalace().court.first..ability = 80,
      ),
      0,
    );
    expect(
      dutyExperience(
        palaceDuty('school')!,
        freshPalace().court.first..ability = 80,
      ),
      24,
    );
  });

  test(
    'busy people cannot study/work twice; study does not occupy the two duty slots',
    () {
      var s = palaceSend(
        freshPalace(),
        'palace',
        target: 'wife-0',
        option: 'study',
      );
      final before = jsonEncode(s.toJson());
      expect(
        () => palaceSend(s, 'palace', target: 'wife-0', option: 'wardrobe'),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
      s = palaceSend(s, 'palace', target: 'wife-1', option: 'inventory');
      s = palaceSend(s, 'palace', target: 'wife-2', option: 'charity');
      expect(s.palaceWorks, hasLength(3));
      expect(
        () => palaceSend(s, 'palace', target: 'wife-3', option: 'quiet'),
        throwsA(isA<GameRuleException>()),
      );
      s = palaceSend(s, 'palace', target: 'wife-3', option: 'study');
      expect(s.palaceWorks, hasLength(4));
      // Existing relationship interactions stay available while studying.
      s = palaceSend(s, 'courtier', target: 'wife-0', option: 'audience');
      expect(s.palaceWorks, hasLength(4));
    },
  );

  test(
    'invalid people, requirements, resources and choices are rejected atomically',
    () {
      final variants = <void Function(GameState)>[
        (s) => s.points = 0,
        (s) => s.treasury = 19,
        (s) => s.grain = 24,
        (s) => s.court.first.inHarem = false,
        (s) => s.court.first.age = 17,
        (s) => s.court.first.role = 'Hộ bộ',
        (s) => s.court.first.available = false,
        (s) => s.court.first.ability = 20,
        (s) => s.seasonal = false,
      ];
      for (final change in variants) {
        final s = freshPalace();
        change(s);
        final before = jsonEncode(s.toJson());
        expect(
          () => palaceSend(s, 'palace', target: 'wife-0', option: 'charity'),
          throwsA(isA<GameRuleException>()),
        );
        expect(jsonEncode(s.toJson()), before);
      }
      for (final option in [
        'missing',
        'study:fake',
        'inventory:fake',
        'kinship',
        'kinship:fake',
        'kinship:Văn thần:fake',
      ]) {
        expect(
          () => palaceSend(
            freshPalace(),
            'palace',
            target: 'wife-0',
            option: option,
          ),
          throwsA(isA<GameRuleException>()),
        );
      }
      final maxed = freshPalace()..court.first.ability = 100;
      expect(
        () => palaceSend(maxed, 'palace', target: 'wife-0', option: 'study'),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test(
    'seasonal/context restrictions and duplicate-duty checks are enforced by engine',
    () {
      var s = freshPalace();
      expect(
        () => palaceSend(s, 'palace', target: 'wife-0', option: 'ceremony'),
        throwsA(isA<GameRuleException>()),
      );
      for (final c in s.court) {
        c.affection = 80;
      }
      expect(
        () => palaceSend(s, 'palace', target: 'wife-0', option: 'harmony'),
        throwsA(isA<GameRuleException>()),
      );
      s.stability = 80;
      expect(
        () => palaceSend(s, 'palace', target: 'wife-0', option: 'staff'),
        throwsA(isA<GameRuleException>()),
      );
      s.court.first.plot = 30;
      s = palaceSend(s, 'palace', target: 'wife-0', option: 'staff');
      expect(
        () => palaceSend(s, 'palace', target: 'wife-1', option: 'staff'),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  for (final duty in palaceDuties) {
    test(
      '${duty.id} settles successfully once and grants real benefits and XP',
      () {
        var s = resolvedDuty(duty.id);
        expect(s.palaceWorks, isEmpty);
        expect(s.court.first.palaceDutiesCompleted, 1);
        expect(
          s.court.first.palaceExperience + (s.court.first.ability - 70) * 20,
          duty.xp,
        );
        expect(s.outcomes, hasLength(1));
        final buff =
            s.palaceEffects.where((e) => e.kind == duty.id).firstOrNull;
        if ([
          'inventory',
          'wardrobe',
          'procurement',
          'kitchen',
          'herbs',
          'staff',
        ].contains(duty.id)) {
          expect(buff, isNotNull);
          expect(buff!.startsTurn, s.week);
          expect(buff.active(s.week), true);
        } else {
          expect(s.outcomes.single.changes, isNotEmpty);
        }
        s = closePalace(s);
        expect(s.court.first.palaceDutiesCompleted, 1);
        expect(s.outcomes, hasLength(1));
      },
    );
  }

  test(
    'failure and corrupt partial results spend no extra money, reduce XP, and report losses',
    () {
      final failed = resolvedDuty('ceremony', status: 'failure');
      expect(failed.outcomes.single.changes['Uy quyền'], -1);
      expect(failed.court.first.palaceDutiesCompleted, 0);
      expect(failed.court.first.palaceExperience, 4);
      final partial = resolvedDuty('inventory', status: 'partial');
      expect(partial.palaceEffects.single.amount, 4);
      expect(partial.court.first.palaceExperience, 5);
      expect(partial.outcomes.single.detail, contains('một phần'));
    },
  );

  test(
    'departure interrupts both work and study without rewarding or refunding',
    () {
      for (final kind in ['study', 'inventory']) {
        var s = palaceSend(
          freshPalace(),
          'palace',
          target: 'wife-0',
          option: kind,
        );
        s.court.first.available = false;
        s = closePalace(s);
        expect(s.palaceWorks, isEmpty);
        expect(s.outcomes.single.status, 'interrupted');
        expect(s.court.first.ability, 70);
        expect(
          s.court.first.palaceCoursesCompleted +
              s.court.first.palaceDutiesCompleted,
          0,
        );
      }
    },
  );

  test(
    'upkeep saving matches forecast and ledger, caps at actual harem cost and expires',
    () {
      var s = resolvedDuty('inventory');
      final normal = s.copy()..palaceEffects.clear();
      expect(
        budgetExpenses(normal)['court']!.amount -
            budgetExpenses(s)['court']!.amount,
        8,
      );
      s.palaceEffects.add(
        PalaceEffect(
          kind: 'wardrobe',
          personId: 'wife-1',
          startsTurn: s.week,
          endsTurn: s.week + 2,
          amount: 4,
        ),
      );
      expect(palaceUpkeepSaving(s), 8);
      s.court.removeRange(1, 4);
      expect(palaceUpkeepSaving(s), 6);
      for (var i = 0; i < 3; i++) {
        final expected = budgetExpenses(s)['court']!.amount;
        s = closePalace(s);
        final report = s.financialWeeks.where((w) => w.closed).last;
        expect(
          report.entries
              .singleWhere((e) => e.title == 'Triều đình và hậu cung')
              .requiredAmount,
          expected,
        );
      }
      expect(palaceUpkeepSaving(s), 0);
      expect(s.palaceEffects, isEmpty);
    },
  );

  test(
    'procurement discount applies only to duties, consumes five uses and never stacks',
    () {
      var s = resolvedDuty('procurement');
      final cost = palaceDutyCost(s, palaceDuty('wardrobe')!);
      expect(cost, 3);
      final originalMoney = s.treasury;
      s = palaceSend(s, 'palace', target: 'wife-1', option: 'study');
      expect(s.treasury, originalMoney - 20);
      expect(palaceEffect(s, 'procurement')!.uses, 5);
      s = palaceSend(s, 'palace', target: 'wife-2', option: 'wardrobe');
      expect(s.treasury, originalMoney - 23);
      expect(palaceEffect(s, 'procurement')!.uses, 4);
      expect(s.financialWeeks.last.entries.last.amount, -3);
      final e = palaceEffect(s, 'procurement')!;
      e.uses = 0;
      expect(palaceDutyCost(s, palaceDuty('inventory')!), 15);
      e.uses = 4;
      s.completedWeeks = e.endsTurn;
      expect(palaceDutyCost(s, palaceDuty('inventory')!), 15);
    },
  );

  test('herbs discounts actual treatment, uses are persisted and expire', () {
    var s = resolvedDuty('herbs');
    final treat = actions.firstWhere((a) => a.id == 'treat');
    expect(actionCost(s, treat), treat.cost - 10);
    final start = s.treasury;
    for (var i = 0; i < 3; i++) {
      s = palaceSend(s, 'action', target: 'treat').copy();
    }
    expect(s.treasury, start - (treat.cost - 10) * 3);
    expect(actionCost(s, treat), treat.cost);
    expect(palaceEffect(s, 'herbs')!.uses, 0);
  });

  test('hidden traits affect actual results but do not leak into previews', () {
    final s = freshPalace();
    final c = s.court.first;
    c.personalities
      ..clear()
      ..addAll([Personality.disciplined, Personality.negligent]);
    final d = palaceDuty('inventory')!;
    final preview = palaceSuccessChance(s, c, d, preview: true);
    expect(preview - palaceSuccessChance(s, c, d), 12);
    expect(c.knownPersonalityText, isNot(contains('Tắc trách')));
  });

  test(
    '0.13 saves default new fields without changing AP, RNG, revision, score group or finances',
    () {
      final s = freshPalace();
      final old =
          s.toJson()
            ..['rulesVersion'] = 'mvp-0.13.0'
            ..['contentVersion'] = 14;
      old.remove('palaceWorks');
      old.remove('palaceEffects');
      for (final c in old['court'] as List) {
        (c as Map).remove('palaceExperience');
        c.remove('palaceDutiesCompleted');
        c.remove('palaceCoursesCompleted');
      }
      final loaded = GameState.fromJson(old);
      expect(loaded.palaceWorks, isEmpty);
      expect(loaded.court.first.palaceExperience, 0);
      expect(loaded.points, s.points);
      expect(loaded.rng, s.rng);
      expect(loaded.revision, s.revision);
      expect(loaded.scoreRules, s.scoreRules);
      expect(
        loaded.financialWeeks.map((w) => w.toJson()),
        s.financialWeeks.map((w) => w.toJson()),
      );
      expect(loaded.copy().toJson(), loaded.toJson());
    },
  );

  test(
    'gateway reload, retry and stale commands cannot charge or grant twice',
    () async {
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store);
      await store.update((a) => a.active = freshPalace());
      final cmd = palaceCommand(
        (await gateway.load()).active!,
        'palace',
        target: 'wife-0',
        option: 'study',
      );
      final started = await gateway.dispatch(cmd);
      expect((await gateway.dispatch(cmd)).toJson(), started.toJson());
      expect((await gateway.load()).active!.palaceWorks.single.progress, 0);
      expect(
        () => gateway.dispatch(
          GameCommand(
            id: 'stale',
            runId: cmd.runId,
            expectedRevision: 0,
            type: 'palace',
            target: 'wife-1',
            option: 'study',
          ),
        ),
        throwsA(isA<GameRuleException>()),
      );
      for (var i = 0; i < 2; i++) {
        await store.update((a) {
          a.active!.petitions.clear();
          a.active!.affairsThisWeek = 1;
        });
        final next = palaceCommand((await gateway.load()).active!, 'endWeek');
        final result = await gateway.dispatch(next);
        expect((await gateway.dispatch(next)).toJson(), result.toJson());
      }
      final completed = (await gateway.load()).active!;
      expect(completed.court.first.palaceCoursesCompleted, 1);
      expect(completed.outcomes, hasLength(1));
    },
  );
}
