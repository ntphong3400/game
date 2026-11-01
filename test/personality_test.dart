import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/reign_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  Courtier officer({
    List<Personality>? traits,
    int integrity = 90,
    int loyalty = 50,
    int affection = 50,
  }) => Courtier(
    id: 'test-officer',
    name: 'Quan thử',
    role: 'Hộ bộ',
    faction: 'Văn thần',
    trait: 'Biography must not appear as discovered traits',
    age: 35,
    ability: 60,
    loyalty: loyalty,
    ambition: 40,
    integrity: integrity,
    influence: 40,
    affection: affection,
    personalities: traits ?? [Personality.grateful, Personality.diplomatic],
  );
  GameState fresh([Courtier? c]) {
    final s = engine.start('personality', 'An', 42);
    s.court = [c ?? officer()];
    s.petitions.clear();
    s.nextMajorWeek = s.nextChainWeek = 1000;
    s.factions.updateAll((k, v) => 50);
    s.people = s.army = s.stability = s.authority = s.health = 85;
    s.grain = 100;
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
      id: 'p-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );
  int rngFor(bool corrupt) {
    for (var rng = 1; rng < 10000; rng++) {
      final first = rng * 48271 % 2147483647;
      final second = first * 48271 % 2147483647;
      if (first % 100 < 40 && (second % 100 < 60) == corrupt) return rng;
    }
    throw StateError('No controlled roll');
  }

  test(
    'catalog has 20 distinct behavioral types, all starting people have 2–3 compatible traits',
    () {
      expect(Personality.values, hasLength(20));
      final s = engine.start('catalog', 'An', 42);
      for (final c in [...s.court, ...s.officialsPool]) {
        expect(c.personalities.length, inInclusiveRange(2, 3));
        expect(c.knownPersonalities, hasLength(1));
        expect(c.personalities.toSet().length, c.personalities.length);
        for (final a in c.personalities) {
          for (final b in c.personalities.where((b) => b != a)) {
            expect(personalitiesConflict(a, b), false);
          }
        }
        if (c.personalities.contains(Personality.honest)) {
          expect(c.integrity, greaterThanOrEqualTo(80));
        }
        if (c.personalities.contains(Personality.greedy)) {
          expect(c.integrity, lessThanOrEqualTo(40));
        }
      }
      expect(s.copy().toJson(), s.toJson());
    },
  );

  test(
    'third, sixth and ninth audience unlock exactly one trait; rewards and investigation do not',
    () {
      var s = fresh(
        officer(
          traits: [
            Personality.disciplined,
            Personality.diplomatic,
            Personality.impartial,
            Personality.dutiful,
          ],
        ),
      );
      for (var i = 1; i <= 9; i++) {
        s.points = 3;
        s =
            send(
              s,
              'courtier',
              target: 'test-officer',
              option: 'audience',
            ).copy();
        expect(s.court.single.personalityContacts, i);
        expect(s.court.single.knownPersonalityCount, 1 + i ~/ 3);
      }
      expect(
        s.journal.where((n) => n.title == 'Hiểu thêm về Quan thử'),
        hasLength(3),
      );
      s.points = 3;
      s = send(s, 'courtier', target: 'test-officer', option: 'reward');
      expect(s.court.single.personalityContacts, 9);
      s.court.single.investigated = true;
      expect(s.court.single.knownPersonalityCount, 4);
      final untouched = fresh()..court.single.investigated = true;
      expect(untouched.court.single.knownPersonalityCount, 1);
    },
  );

  test('contacts are personal and invalid actions spend no contact or AP', () {
    var s = fresh();
    final another = Courtier.fromJson(
      s.court.single.toJson()..['id'] = 'another',
    );
    s.court.add(another);
    s = send(s, 'courtier', target: 'test-officer', option: 'audience');
    expect(s.court.last.personalityContacts, 0);
    s.points = 0;
    final before = jsonEncode(s.toJson());
    expect(
      () => send(s, 'courtier', target: 'test-officer', option: 'audience'),
      throwsA(isA<GameRuleException>()),
    );
    expect(jsonEncode(s.toJson()), before);
  });

  test(
    'v0.8 migration assigns stable traits without changing random, revision or ongoing work',
    () {
      final s =
          fresh()
            ..rng = 123456
            ..revision = 12;
      s.projects.add(
        WorkOrder(
          id: 'work',
          kind: 'farm',
          officerId: 'test-officer',
          startedWeek: 1,
          duration: 5,
          progress: 2,
        ),
      );
      final old =
          s.toJson()
            ..['rulesVersion'] = 'mvp-0.8.0'
            ..['contentVersion'] = 8;
      for (final raw in [
        ...old['court'] as List,
        ...old['officialsPool'] as List,
      ]) {
        (raw as Map).remove('personalities');
        raw.remove('personalityContacts');
      }
      final a = GameState.fromJson(old), b = GameState.fromJson(old);
      expect(a.toJson(), b.toJson());
      expect(a.rng, 123456);
      expect(a.revision, 12);
      expect(a.projects.single.progress, 2);
      expect(a.court.single.knownPersonalityCount, 1);
      expect(a.toJson()['rulesVersion'], rulesVersion);
      expect(a.toJson()['contentVersion'], contentVersion);
      expect(a.copy().toJson(), a.toJson());
    },
  );

  test(
    'hidden personality and hidden numeric qualities cannot change estimates or ordering',
    () {
      final a = officer(
        traits: [Personality.grateful, Personality.greedy],
        integrity: 10,
        loyalty: 10,
      );
      final b = officer(
        traits: [Personality.grateful, Personality.dutiful],
        integrity: 90,
        loyalty: 90,
      );
      final sa = fresh(a), sb = fresh(b);
      final comparison = officer()..id = 'comparison';
      sa.court.add(comparison);
      sb.court.add(Courtier.fromJson(comparison.toJson()));
      expect(
        taskOfficers(sa, 'farm').map((c) => c.id).toList(),
        taskOfficers(sb, 'farm').map((c) => c.id).toList(),
      );
      expect(
        TaskAssessment.preview('farm', a, sa).successChance,
        TaskAssessment.preview('farm', b, sb).successChance,
      );
      expect(
        TaskAssessment.preview('farm', a, sa).rewardPercent,
        TaskAssessment.preview('farm', b, sb).rewardPercent,
      );
      expect(
        revenueRewardPreview('commerce', a, sa),
        revenueRewardPreview('commerce', b, sb),
      );
      expect(personalityWorkHint(sa, a), personalityWorkHint(sb, b));
      expect(
        TaskAssessment('farm', a, sa).successChance,
        lessThan(TaskAssessment('farm', b, sb).successChance),
      );
      expect(
        TaskAssessment('farm', a, sa).personality.corruptionChance,
        greaterThan(TaskAssessment('farm', b, sb).personality.corruptionChance),
      );
      a.personalityContacts = b.personalityContacts = 3;
      expect(
        TaskAssessment.preview('farm', a, sa).successChance,
        lessThan(TaskAssessment.preview('farm', b, sb).successChance),
      );
    },
  );

  test(
    'affection, loyalty and faction mood independently change success; impartiality dampens faction effects',
    () {
      final c = officer(), s = fresh(c);
      int chance() => TaskAssessment('farm', c, s).successChance;
      final neutral = chance();
      c.affection = 0;
      expect(chance(), lessThan(neutral));
      c.affection = 50;
      c.loyalty = 0;
      expect(chance(), lessThan(neutral));
      c.loyalty = 50;
      s.factions[c.faction] = 0;
      expect(chance(), lessThan(neutral));
      final partisan = officer(
        traits: [Personality.grateful, Personality.partisan],
      );
      final impartial = officer(
        traits: [Personality.grateful, Personality.impartial],
      );
      expect(
        TaskAssessment('farm', partisan, s).successChance,
        lessThan(TaskAssessment('farm', impartial, s).successChance),
      );
    },
  );

  test('traits affect matching tasks and severity rather than just labels', () {
    final base = officer(), s = fresh();
    final diplomatic = officer(
      traits: [Personality.grateful, Personality.diplomatic],
    );
    final hot = officer(
      traits: [Personality.grateful, Personality.hotTempered],
    );
    expect(
      TaskAssessment('diplomacy', diplomatic, s).successChance,
      greaterThan(TaskAssessment('diplomacy', hot, s).successChance),
    );
    final cautious = officer(
      traits: [Personality.grateful, Personality.cautious],
    );
    final reckless = officer(
      traits: [Personality.grateful, Personality.reckless],
    );
    expect(
      TaskAssessment('farm', cautious, s).personality.severeMargin,
      greaterThan(TaskAssessment('farm', reckless, s).personality.severeMargin),
    );
    expect(
      TaskAssessment('farm', reckless, s).reward(35),
      greaterThan(TaskAssessment('farm', base, s).reward(35)),
    );
  });

  test(
    'successful cash work loses real proceeds without double debit or revealing hidden trait',
    () {
      final c = officer(
        traits: [Personality.grateful, Personality.greedy],
        integrity: 10,
      );
      final s = fresh(c)..rng = rngFor(true);
      final result = send(s, 'action', target: 'collect_arrears', option: c.id);
      final gross = TaskAssessment('collect_arrears', c, s).reward(45);
      expect(result.treasury - s.treasury, lessThan(gross));
      expect(result.treasury, greaterThan(s.treasury));
      final shortfall = result.journal.firstWhere(
        (n) => n.title == 'Thành quả bị thất thoát',
      );
      expect(shortfall.text, isNot(contains('Tham lợi')));
      expect(result.court.single.knownPersonalityCount, 1);
      final report = result.financialWeeks.last;
      expect(
        report.closingBalance,
        report.openingBalance + report.income - report.expense,
      );
      expect(result.copy().toJson(), result.toJson());
    },
  );

  test(
    'low affection alone does not cause embezzlement by an honest person',
    () {
      final c = officer(
        traits: [Personality.grateful, Personality.honest],
        integrity: 95,
        affection: 0,
      );
      final s = fresh(c)..rng = 100;
      expect(PersonalityAssessment(c, s).corruptionChance, 0);
      final result = send(s, 'action', target: 'collect_arrears', option: c.id);
      expect(
        result.treasury - s.treasury,
        TaskAssessment('collect_arrears', c, s).reward(45),
      );
      expect(
        result.journal.any((n) => n.title == 'Thành quả bị thất thoát'),
        false,
      );
    },
  );

  test(
    'major shortfalls retain partial work, require retry and charge only remaining resources',
    () {
      final c = officer(
        traits: [Personality.grateful, Personality.greedy],
        integrity: 10,
      );
      c.specialty = 'Công trình';
      var s = fresh(c);
      s.major = MajorMission(
        id: 'major',
        kind: 'flood',
        openedWeek: 1,
        deadline: 10,
        severity: 1,
        preparedness: 0,
        objectives:
            majorDefinition(
              'flood',
            ).objectives.map((d) => MissionObjective(key: d.key)).toList(),
      );
      s = send(s, 'mission', target: 'levee', option: c.id);
      s.major!.objectives.first.finishWeek = s.week;
      s.rng = rngFor(true);
      s = send(s, 'endWeek').copy();
      final goal = s.major!.objectives.first;
      expect(goal.done, false);
      expect(goal.delivered, inInclusiveRange(1, 99));
      expect(goal.working, false);
      expect(s.major!.achieved, 0);
      final money = s.treasury;
      final def = majorDefinition('flood').objectives.first;
      s = send(s, 'mission', target: 'levee', option: c.id);
      expect(money - s.treasury, missionRemainingCost(def.cost, goal));
      s.court.single.integrity = 100;
      s.major!.objectives.first.finishWeek = s.week;
      s.rng = 100;
      s = send(s, 'endWeek');
      expect(s.major!.objectives.first.done, true);
      expect(s.major!.objectives.first.delivered, 100);
      expect(s.major!.achieved, 1);
    },
  );

  test('public petition biography includes only discovered traits', () {
    final s = fresh();
    final c = s.court.single;
    c.role = 'Tiểu thư';
    final p = Petition(
      id: 'petition',
      definitionId: 'consort_recommendation',
      openedWeek: 1,
      deadline: 5,
      targetId: c.id,
    );
    expect(petitionText(p, s), contains(c.knownPersonalityText));
    expect(petitionText(p, s), isNot(contains('Khéo léo')));
    expect(petitionText(p, s), isNot(contains(c.trait)));
  });

  test(
    'the same skilled official and roll can succeed for a friendly court and fail with poor relations',
    () {
      final friendly = fresh(officer(affection: 90)..ability = 80)..rng = 90;
      friendly.factions['Văn thần'] = 90;
      final hostile = fresh(officer(affection: 0)..ability = 80)..rng = 90;
      hostile.factions['Văn thần'] = 0;
      final success = send(
        friendly,
        'action',
        target: 'collect_arrears',
        option: 'test-officer',
      );
      final failure = send(
        hostile,
        'action',
        target: 'collect_arrears',
        option: 'test-officer',
      );
      expect(success.treasury, greaterThan(friendly.treasury));
      expect(failure.treasury, lessThanOrEqualTo(hostile.treasury));
      expect(
        failure.journal.any((n) => n.title.contains('Công việc thất bại')),
        true,
      );
    },
  );

  test(
    'an assessment remains a snapshot when fatigue and affection later change',
    () {
      final c = officer(traits: [Personality.grateful, Personality.dutiful]);
      final s = fresh(c);
      final before = TaskAssessment('farm', c, s);
      final chance = before.successChance, reward = before.rewardPercent;
      c.strain = 80;
      c.affection = 0;
      s.factions[c.faction] = 0;
      expect(before.successChance, chance);
      expect(before.rewardPercent, reward);
      expect(TaskAssessment('farm', c, s).successChance, lessThan(chance));
    },
  );

  test(
    'retrying a conversation cannot spend twice or unlock extra personality',
    () async {
      final gateway = LocalGameGateway(MemoryGameStore(), seasonal: false);
      var archive = await gateway.start(
        name: 'An',
        runId: 'contacts-retry',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      final s = archive.active!;
      final command = GameCommand(
        id: 'same-conversation',
        runId: s.runId,
        expectedRevision: s.revision,
        type: 'courtier',
        target: 'chancellor',
        option: 'audience',
      );
      archive = await gateway.dispatch(command);
      final first = jsonEncode(archive.active!.toJson());
      archive = await gateway.dispatch(command);
      expect(jsonEncode(archive.active!.toJson()), first);
      expect(
        archive.active!.court
            .firstWhere((c) => c.id == 'chancellor')
            .personalityContacts,
        1,
      );
    },
  );
}
