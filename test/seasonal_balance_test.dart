import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/reign_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine();
  GameState fresh() {
    final s = engine.start('rebalance', 'An', 42);
    s.petitions.clear();
    s.nextMajorWeek = s.nextChainWeek = 10000;
    s.people = s.army = s.stability = s.authority = s.health = 90;
    s.factions.updateAll((k, v) => 70);
    for (final c in s.court) {
      c.loyalty = c.integrity = c.affection = 100;
      c.ambition = 10;
      c.plot = 0;
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
      id: 'balance-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );

  GameState close(GameState s) {
    s.petitions.clear();
    s.midSeasonDelivered = true;
    s.affairsThisWeek = 1;
    s.rng =
        100; // First execution roll succeeds; no corruption at integrity 100.
    return send(s, 'endWeek').copy();
  }

  void addPetition(GameState s, String id) => s.petitions.add(
    Petition(
      id: id,
      definitionId: id,
      openedWeek: s.week,
      deadline: s.week + 1,
    ),
  );

  MajorMission mission(GameState s, {bool demanding = true}) => MajorMission(
    id: 'hard-flood',
    kind: 'flood',
    openedWeek: s.week,
    deadline: s.week + 2,
    severity: 3,
    preparedness: 0,
    demanding: demanding,
    objectives:
        majorDefinition(
          'flood',
        ).objectives.map((d) => MissionObjective(key: d.key)).toList(),
  );

  test(
    'rest and paid recreation apply distinct recovery only at season close',
    () {
      final s =
          fresh()
            ..fatigue = 70
            ..stress = 100;
      final baseline = close(s.copy());
      for (final action in ['rest', 'revel']) {
        final before = s.copy();
        final pending = send(before, 'action', target: action);
        expect(pending.fatigue, 70);
        expect(pending.stress, 100);
        expect(pending.points, before.points - 1);
        expect(
          pending.treasury,
          before.treasury - (action == 'revel' ? 18 : 0),
        );
        expect(pending.journal.first.text, contains('khi khép mùa'));
        final result = close(pending);
        expect(result.fatigue, baseline.fatigue - 16);
        expect(result.stress, baseline.stress - (action == 'rest' ? 8 : 16));
        expect(result.restThisWeek, 0);
        expect(result.revelThisWeek, 0);
      }
    },
  );

  test(
    'treatment instantly restores fatigue with the current doctor effect',
    () {
      for (final scenario in [
        (ability: 86, specialty: 'Y thuật', available: true, recovery: 16),
        (ability: 100, specialty: 'Y thuật', available: true, recovery: 18),
        (ability: 86, specialty: 'Cung đình', available: true, recovery: 10),
        (ability: 86, specialty: 'Quân sự', available: true, recovery: 3),
        (ability: 86, specialty: 'Y thuật', available: false, recovery: 5),
      ]) {
        final s =
            fresh()
              ..health = 60
              ..illness = 40
              ..fatigue = 70
              ..stress = 55
              ..workThisWeek = 6;
        final doctor = s.court.firstWhere((c) => c.id == 'doctor');
        doctor.ability = scenario.ability;
        doctor.specialty = scenario.specialty;
        doctor.available = scenario.available;
        final result = send(s, 'action', target: 'treat');
        expect(result.health, 62);
        expect(result.illness, 40 - scenario.recovery);
        expect(result.fatigue, 58);
        expect(result.stress, 55);
        expect(result.workThisWeek, 6);
        expect(result.restThisWeek, 0);
        expect(result.points, s.points - 1);
        expect(result.treasury, s.treasury - 25);
        expect(
          result.journal.first.text,
          contains('mức bệnh −${scenario.recovery}'),
        );
        expect(result.journal.first.text, contains('mệt mỏi −12'));
        expect(result.journal.first.text, contains('Hiệu quả áp dụng ngay'));
        final baseline = close(s.copy());
        final closed = close(result);
        expect(closed.fatigue, baseline.fatigue - 12);
        expect(closed.stress, baseline.stress);
        expect(closed.healthReport, isNot(contains('làm việc quá độ')));
      }
    },
  );

  test(
    'treatment caps recovery and records actual gains across save and reload',
    () {
      final s =
          fresh()
            ..health = 99
            ..illness = 3
            ..fatigue = 5;
      final result = send(s, 'action', target: 'treat');
      expect(result.health, 100);
      expect(result.illness, 0);
      expect(result.fatigue, 0);
      expect(result.journal.first.text, contains('sức khỏe +1'));
      expect(result.journal.first.text, contains('mức bệnh −3'));
      expect(result.journal.first.text, contains('mệt mỏi −5'));
      final restored = GameState.fromJson(
        object(jsonDecode(jsonEncode(result.toJson()))),
      );
      expect(restored.toJson(), result.toJson());
    },
  );

  test(
    'each recreation adds eight fatigue and four stress relative to the previous use',
    () {
      var s =
          fresh()
            ..fatigue = 70
            ..stress = 100;
      final baseline = close(s.copy());
      final results = <GameState>[];
      for (var i = 0; i < 6; i++) {
        s = send(s, 'action', target: 'revel');
        results.add(close(s.copy()));
      }
      final fatigueChanges = [-16, -8, 0, 8, 16, 24];
      final stressChanges = [-16, -12, -8, -4, 0, 4];
      var previous = baseline;
      for (var i = 0; i < results.length; i++) {
        expect(results[i].fatigue - previous.fatigue, fatigueChanges[i]);
        expect(results[i].stress - previous.stress, stressChanges[i]);
        previous = results[i];
      }
      expect(results[1].health, lessThan(results[0].health));
      expect(results[2].health, lessThan(results[1].health));
      expect(results[1].healthReport, contains('hưởng lạc quá mức'));
      expect(s.treasury, fresh().treasury - 108);
    },
  );

  test(
    'recreation still rewards moderation and penalizes accumulated indulgence',
    () {
      var s =
          fresh()
            ..health = 60
            ..fatigue = 30
            ..stress = 40;
      final moderate = close(send(s, 'action', target: 'revel'));
      expect(moderate.health, 62);
      s.indulgence = 6;
      s = close(send(s, 'action', target: 'revel'));
      expect(s.health, lessThan(60));
      expect(s.healthReport, contains('hưởng lạc quá mức'));
    },
  );

  test(
    'old saves preserve pending recreation and score group across upgrade',
    () {
      var s =
          fresh()
            ..fatigue = 70
            ..stress = 100;
      s = send(s, 'action', target: 'revel');
      for (final version in ['mvp-0.17.0', 'mvp-0.17.1', 'mvp-0.17.2']) {
        final saved =
            object(jsonDecode(jsonEncode(s.toJson())))
              ..['rulesVersion'] = version
              ..['scoreRules'] = version;
        final restored = GameState.fromJson(saved);
        expect(restored.scoreRules, version);
        expect(restored.revelThisWeek, 1);
        final result = close(send(restored, 'action', target: 'revel'));
        final uninterrupted = close(send(s, 'action', target: 'revel'));
        expect(result.fatigue, uninterrupted.fatigue);
        expect(result.stress, uninterrupted.stress);
        expect(result.indulgence, uninterrupted.indulgence);
        expect(result.fatigue, 34);
        expect(result.stress, 70);
      }
    },
  );

  test(
    'combined recovery clamps at zero and first recreation renews next season',
    () {
      var s =
          fresh()
            ..fatigue = 5
            ..stress = 5;
      s = send(s, 'action', target: 'rest');
      s = send(s, 'action', target: 'revel');
      s = close(s);
      expect(s.fatigue, 0);
      expect(s.stress, 0);
      s.fatigue = 70;
      s.stress = 100;
      s = close(send(s, 'action', target: 'revel'));
      expect(s.fatigue, 42);
      expect(s.stress, 82);
    },
  );

  test(
    'commerce waits through three intervening seasons and returns next spring',
    () {
      var s = fresh();
      final officer = s.court.firstWhere((c) => c.id == 'trade_officer');
      officer.ability = 100;
      s = send(s, 'action', target: 'commerce', option: officer.id);
      expect(s.treasury, 480);
      expect(s.projects.single.duration, 5);
      expect(
        revenueRewardPreview('commerce', officer, s),
        contains('mùa Xuân · năm 2'),
      );
      for (var i = 0; i < 4; i++) {
        s = close(s);
        expect(s.projects, hasLength(1));
        expect(s.outcomes.where((o) => o.title == 'Đoàn thương mại'), isEmpty);
        expect(officerBusy(s, officer.id), true);
        expect(
          () => send(s, 'action', target: 'commerce', option: 'treasurer'),
          throwsA(isA<GameRuleException>()),
        );
      }
      expect(s.date(s.week), 'mùa Xuân · năm 2');
      s = close(s);
      expect(s.projects, isEmpty);
      final revenue =
          s.financialWeeks
              .expand((w) => w.entries)
              .where((e) => e.title == 'Đoàn thương mại trở về')
              .single;
      expect(revenue.amount, greaterThan(40));
      expect(
        s.outcomes.singleWhere((o) => o.title == 'Đoàn thương mại').week,
        5,
      );
      expect(officerBusy(s, officer.id), false);
      final total = s.treasury;
      expect(s.copy().treasury, total);
    },
  );

  test('all seasons use the same two-season petition investment offset', () {
    for (var season = 0; season < 4; season++) {
      final s = fresh()..completedWeeks = season;
      final choice = eventForState(s, 'silk_route').choices.first;
      expect(s.week + petitionDelay(s, choice) - 1, s.week + 2);
      expect(choice.hint, contains(s.date(s.week + 2)));
      final result = send(
        (s..petitions.clear())
          ..petitions.add(
            Petition(
              id: 'silk',
              definitionId: 'silk_route',
              openedWeek: s.week,
              deadline: s.week + 1,
            ),
          ),
        'petition',
        target: 'silk',
        option: '0',
      );
      expect(result.pending.single.dueWeek, s.week + 2);
    }
  });

  test(
    'risky petition investments retain risk and defer both success and failure',
    () {
      final rawEvent = events.firstWhere(
        (e) => e.choices.any(
          (c) => (c.laterEffects['treasury'] ?? 0) > 0 && c.successChance < 100,
        ),
      );
      final index = rawEvent.choices.indexWhere(
        (c) => (c.laterEffects['treasury'] ?? 0) > 0 && c.successChance < 100,
      );
      for (final rng in [100, 69]) {
        final s = fresh()..rng = rng;
        addPetition(s, rawEvent.id);
        final c = eventForState(s, rawEvent.id).choices[index];
        expect(c.laterEffects['treasury'], 70);
        final result = send(
          s,
          'petition',
          target: rawEvent.id,
          option: '$index',
        );
        expect(result.pending.single.dueWeek, 2);
        expect(result.treasury, s.treasury - c.cost);
        expect(
          result.copy().pending.single.toJson(),
          result.pending.single.toJson(),
        );
      }
    },
  );

  test(
    'arrears transfer next season, sales transfer at closing, no immediate cash',
    () {
      for (final task in ['collect_arrears', 'sell_surplus']) {
        var s = fresh()..treasury = 0;
        s.financialWeeks.clear();
        s.rng = 100;
        s = send(s, 'action', target: task, option: 'trade_officer');
        expect(s.treasury, 0);
        final due = task == 'collect_arrears' ? 2 : 1;
        final payment = s.pending.single;
        expect(payment.dueWeek, due);
        expect(payment.effects['treasury'], greaterThan(0));
        expect(
          () => send(s, 'action', target: 'train', option: 'general'),
          throwsA(isA<GameRuleException>()),
        );
        if (task == 'collect_arrears') {
          expect(s.cooldowns['task:collect_arrears'], 3);
          s = close(s);
          expect(s.pending, hasLength(1));
          expect(revenueTaskBlocked(s, task), isNotNull);
        }
        s = close(s);
        expect(s.pending, isEmpty);
        final entries = s.financialWeeks
            .expand((w) => w.entries)
            .where(
              (e) => e.title == 'Kết quả: ${payment.title}' && e.amount > 0,
            );
        expect(entries.single.amount, payment.effects['treasury']);
        for (final w in s.financialWeeks) {
          expect(w.closingBalance, w.openingBalance + w.income - w.expense);
        }
      }
    },
  );

  test('retry and reload cannot pay a delayed receipt twice', () async {
    final store = MemoryGameStore();
    final gateway = LocalGameGateway(store);
    await store.update((a) => a.active = fresh()..rng = 100);
    final s = (await gateway.load()).active!;
    final command = GameCommand(
      id: 'sale',
      runId: s.runId,
      expectedRevision: s.revision,
      type: 'action',
      target: 'sell_surplus',
      option: 'trade_officer',
    );
    final first = await gateway.dispatch(command);
    final repeated = await gateway.dispatch(command);
    expect(repeated.active!.pending, hasLength(1));
    expect(repeated.active!.toJson(), first.active!.toJson());
    final beforeClose = repeated.active!;
    beforeClose.petitions.clear();
    beforeClose.midSeasonDelivered = true;
    beforeClose.affairsThisWeek = 1;
    await store.update((a) => a.active = beforeClose);
    final ending = GameCommand(
      id: 'close-sale',
      runId: s.runId,
      expectedRevision: beforeClose.revision,
      type: 'endWeek',
    );
    final paid = await gateway.dispatch(ending);
    expect(paid.active!.pending, isEmpty);
    expect(
      (await gateway.dispatch(ending)).active!.toJson(),
      paid.active!.toJson(),
    );
  });

  test(
    'safe broad benefits are smaller and expensive; existing drawbacks remain',
    () {
      final s = fresh();
      const safe = EventChoice('Fund', '', {
        'people': 6,
        'authority': 4,
      }, cost: 30);
      final costly = seasonalPetitionChoice(s, safe);
      expect(costly.cost, 60);
      expect(costly.effects, {'people': 3, 'authority': 2});
      const tradeoff = EventChoice('Levy', '', {'treasury': 30, 'people': -4});
      expect(seasonalPetitionChoice(s, tradeoff).effects, {
        'treasury': 30,
        'people': -4,
      });
      const free = EventChoice('Accept', '', {'authority': 3});
      expect(seasonalPetitionChoice(s, free).effects, {
        'authority': 1,
        'stress': 2,
      });
      for (final e in events) {
        final fallback = eventForState(s, e.id).choices.last;
        expect(fallback.cost, 0, reason: e.id);
        expect(fallback.grainCost, 0, reason: e.id);
      }
    },
  );

  test('engine charges the same petition prices shown in the preview', () {
    final s = fresh();
    addPetition(s, 'tax_abuse');
    final c = eventForState(s, 'tax_abuse').choices[1];
    expect(c.cost, 60);
    expect(c.effects['people'], 4);
    final result = send(s, 'petition', target: 'tax_abuse', option: '1');
    expect(result.treasury, s.treasury - c.cost);
    expect(result.people, s.people + c.effects['people']!);
    expect(result.points, 11);
    expect(result.financialWeeks.last.entries.last.requiredAmount, c.cost);
  });

  test(
    'new majors require talent and related expertise even with unlimited money',
    () {
      final s = fresh()..treasury = 9999;
      s.major = mission(s);
      final d = majorDefinition('flood').objectives.first;
      final weak = s.court.firstWhere((c) => c.id == 'treasurer');
      final wrong = s.court.firstWhere((c) => c.id == 'general');
      weak.specialty = d.specialty;
      expect(missionOfficerBlocked(s.major!, d, weak), contains('năng lực'));
      expect(missionOfficerBlocked(s.major!, d, wrong), contains('chuyên môn'));
      for (final id in [weak.id, wrong.id]) {
        final before = jsonEncode(s.toJson());
        expect(
          () => send(s, 'mission', target: d.key, option: id),
          throwsA(isA<GameRuleException>()),
        );
        expect(jsonEncode(s.toJson()), before);
      }
      final c = missionOfficers(s, d).first;
      final cost = missionCost(s.major!, d);
      final grain = missionGrain(s.major!, d);
      expect(cost, greaterThan(d.cost));
      final result = send(s, 'mission', target: d.key, option: c.id);
      expect(result.treasury, s.treasury - cost);
      expect(result.grain, s.grain - grain);
      expect(result.copy().major!.demanding, true);
    },
  );

  test(
    'replacing a mission officer with an unqualified one interrupts execution',
    () {
      var s = fresh();
      s.major = mission(s);
      final d = majorDefinition('flood').objectives.first;
      final c = missionOfficers(s, d).first;
      s = send(s, 'mission', target: d.key, option: c.id);
      s.court.firstWhere((o) => o.id == c.id).ability = 40;
      s = close(s);
      expect(s.major!.objectives.first.working, false);
      expect(s.major!.objectives.first.done, false);
      expect(
        s.journal.any((n) => n.title == 'Nhiệm vụ đại biến cố gián đoạn'),
        true,
      );
    },
  );

  test(
    'initial warning and subsequent gaps allow 3–5 full seasons of preparation',
    () {
      for (var seed = 1; seed <= 30; seed++) {
        final s = engine.start('gap-$seed', 'An', seed);
        expect(s.nextMajorWeek - s.week, inInclusiveRange(3, 5));
        for (var stage = 0; stage < 6; stage++) {
          s.completedWeeks = seasonalStageStarts[stage];
          for (var random = 0; random < 3; random++) {
            expect(majorGap(s, random), 3 + random);
          }
        }
      }
    },
  );

  test('economic major benefits wait until the same season next year', () {
    var s = fresh();
    final definition = majorDefinitions.firstWhere(
      (d) => (d.agreement?.income ?? 0) > 0,
    );
    s.major = MajorMission(
      id: 'economic',
      kind: definition.id,
      openedWeek: s.week,
      deadline: s.week,
      severity: 1,
      preparedness: 0,
      demanding: true,
      objectives:
          definition.objectives
              .map(
                (d) => MissionObjective(key: d.key, done: true, delivered: 100),
              )
              .toList(),
    );
    s = close(s);
    final benefit = s.obligations.singleWhere((o) => o.kind == 'benefit');
    expect(benefit.nextWeek, 5);
    for (var i = 0; i < 3; i++) {
      expect(budgetIncome(s).any((b) => b.title == benefit.title), false);
      s = close(s);
    }
    expect(s.week, 5);
    expect(budgetIncome(s).any((b) => b.title == benefit.title), true);
  });

  test(
    'security slows a plot and waits until winter after spring deployment',
    () {
      var s = fresh()..rng = 100;
      final suspect = s.court.firstWhere((c) => c.id == 'prince');
      suspect.plot = 50;
      suspect.discontent = 70;
      suspect.loyalty = 20;
      suspect.ambition = 90;
      s = send(s, 'action', target: 'security', option: 'spy');
      final remaining = s.court.firstWhere((c) => c.id == suspect.id).plot;
      expect(remaining, inInclusiveRange(35, 49));
      expect(s.treasury, 465);
      expect(s.stress, 18);
      final before = jsonEncode(s.toJson());
      expect(
        () => send(s, 'action', target: 'security', option: 'spy'),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
      s = close(s);
      expect(
        s.court.firstWhere((c) => c.id == suspect.id).plot,
        greaterThan(remaining),
      );
      expect(s.cooldowns['task:security'], 4);
      expect(securityBlocked(s), contains('mùa Đông · năm 1'));
      expect(
        () => send(s, 'action', target: 'security', option: 'spy'),
        throwsA(isA<GameRuleException>()),
      );
      s = close(s);
      expect(securityBlocked(s), isNotNull);
      s = close(s);
      expect(s.season, 'Đông');
      expect(securityBlocked(s), isNull);
      s.rng = 100;
      s = send(s, 'action', target: 'security', option: 'spy');
      expect(s.cooldowns['task:security'], 7);
    },
  );

  test(
    'failed deployments wait three seasons; rejected orders do not start a cooldown',
    () {
      var s = fresh()..rng = 69; // execution roll 99, beyond the success cap.
      s = send(s, 'action', target: 'security', option: 'spy');
      expect(s.cooldowns['task:security'], 4);
      expect(s.treasury, 465);
      expect(s.authority, lessThan(90));
      s = close(s);
      expect(securityBlocked(s), isNotNull);
      s = close(s);
      expect(securityBlocked(s), isNotNull);
      s = close(s);
      expect(securityBlocked(s), isNull);
      final poor = fresh()..treasury = 54;
      final before = jsonEncode(poor.toJson());
      expect(
        () => send(poor, 'action', target: 'security', option: 'spy'),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(poor.toJson()), before);
      expect(poor.cooldowns['task:security'], isNull);
    },
  );

  test(
    'upgrading 0.11.0 adds four actions and derives the cooldown from the actual deployment turn',
    () {
      for (final turn in [1, 2, 3, 4]) {
        var s = fresh();
        s.rng = 100;
        s = send(s, 'action', target: 'security', option: 'spy');
        s.completedWeeks = turn - 1;
        s.points = 6;
        if (turn > 1) s.actionCounts.clear();
        final raw = s.toJson()..['rulesVersion'] = 'mvp-0.11.0';
        (raw['cooldowns'] as Map).remove('task:security');
        final restored = GameState.fromJson(raw);
        expect(restored.points, 10);
        expect(restored.cooldowns['task:security'], 4);
        expect(securityBlocked(restored) == null, turn >= 4);
        expect(restored.rng, s.rng);
        expect(restored.revision, s.revision);
        expect(restored.copy().toJson(), restored.toJson());
      }
    },
  );

  test(
    'investigation costs 20, records current intelligence and hardened plots resist later verification',
    () {
      final s = fresh();
      final spy = s.court.firstWhere((c) => c.id == 'spy');
      final suspect = s.court.firstWhere((c) => c.id == 'prince');
      final easy = investigationChance(s, spy, suspect);
      suspect.plot = 65;
      expect(investigationChance(s, spy, suspect), lessThan(easy));
      final result = send(
        s,
        'courtier',
        target: suspect.id,
        option: 'investigate',
      );
      expect(result.treasury, 500);
      expect(
        result.court.firstWhere((c) => c.id == suspect.id).lastInvestigation,
        isNull,
      );
      expect(result.pending.single.investigation!.plot, 65);
      expect(result.pending.single.dueWeek, 2);
      expect(result.court.firstWhere((c) => c.id == suspect.id).plot, 65);
    },
  );

  test(
    'upgrading a 0.10 seasonal save adds two unspent actions exactly once',
    () {
      final s = fresh();
      s.points = 7;
      s.seasonActionsSpent = 3;
      s.projects.add(
        WorkOrder(
          id: 'old-trade',
          kind: 'commerce',
          officerId: 'treasurer',
          startedWeek: 1,
          duration: 1,
        ),
      );
      s.major = mission(s, demanding: false);
      final raw =
          s.toJson()
            ..['rulesVersion'] = 'mvp-0.10.1'
            ..['contentVersion'] = 11;
      (raw['major'] as Map).remove('demanding');
      final restored = GameState.fromJson(raw);
      expect(restored.points, 9);
      expect(restored.rng, s.rng);
      expect(restored.revision, s.revision);
      expect(restored.treasury, s.treasury);
      expect(restored.projects.single.duration, 1);
      expect(restored.major!.demanding, false);
      expect(
        missionCost(restored.major!, majorDefinition('flood').objectives.first),
        majorDefinition('flood').objectives.first.cost,
      );
      expect(restored.copy().points, 9);
      expect(restored.copy().toJson(), restored.toJson());
    },
  );
}
