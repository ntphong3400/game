import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/harem_quests.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/harem_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

const engine = _EngineHolder();

class _EngineHolder {
  const _EngineHolder();
  GameState send(
    GameState s,
    String type, {
    String target = '',
    String option = '',
  }) => GameEngine().execute(
    s,
    GameCommand(
      id: 'test-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );
}

Courtier woman(
  String id, {
  int affection = 80,
  bool queen = false,
  List<Personality> traits = const [
    Personality.compassionate,
    Personality.grateful,
  ],
}) => Courtier(
  id: id,
  name: id,
  role: 'Tiểu thư',
  faction: 'Văn thần',
  trait: '',
  age: 24,
  ability: 99,
  loyalty: 70,
  ambition: 40,
  integrity: 70,
  influence: 40,
  affection: affection,
  inHarem: true,
  queen: queen,
  personalities: traits,
);

GameState fixture({
  int seed = 101,
  List<Personality>? traits,
  bool queen = false,
}) {
  final c = woman(
    'owner',
    queen: queen,
    affection: queen ? 90 : 80,
    traits: traits ?? const [Personality.compassionate, Personality.grateful],
  )..personalityContacts = 6;
  final s =
      GameState(
          runId: 'quests',
          playerName: 'An',
          seed: seed,
          rng: seed,
          court: [c],
        )
        ..seasonal = true
        ..goldStandard = true
        ..courtSystemVersion = 1
        ..treasury = 1000000
        ..health = 100
        ..people = 80
        ..authority = 80
        ..stability = 80
        ..grain = 1000000
        ..points = 20;
  return s;
}

void complete(GameState s, Courtier c, {bool queen = false}) {
  final benefit = haremPassives(c, asQueen: queen)[queen ? 1 : 0].benefit;
  final d = haremQuestCatalog.firstWhere(
    (d) =>
        !d.conflict && d.queen == queen && d.benefit == benefit && d.foundation,
  );
  s.haremQuests.removeWhere((q) => q.personId == c.id && q.queen == queen);
  s.haremQuests.add(
    HaremQuest(
      personId: c.id,
      definitionId: d.id,
      assignedTurn: 1,
      faction: 'Võ tướng',
      queen: queen,
      stage: 3,
    ),
  );
}

GameState closeSeason(GameState s) {
  s.petitions.clear();
  s.pending.clear();
  s.major = null;
  s.health = 100;
  s.people = 80;
  s.authority = 80;
  s.stability = 80;
  s.treasury = 1000000;
  s.grain = 1000000;
  s.affairsThisWeek = 1;
  s.workThisWeek = 1;
  return engine.send(s, 'endWeek');
}

void addConflictTargets(GameState s) {
  final target = Courtier(
    id: 'official-target',
    name: 'Quan đương nhiệm',
    role: 'Tri phủ',
    faction: 'Võ tướng',
    trait: '',
    age: 40,
    ability: 80,
    loyalty: 70,
    ambition: 40,
    integrity: 70,
    influence: 50,
    grade: 3,
  );
  s.court.add(target);
  s.courtOffices.add(
    CourtOffice(
      id: 'conflict-office',
      role: 'Tri phủ',
      group: 'Văn ban',
      grade: s.court.first.queen ? 3 : 5,
      holderId: target.id,
    ),
  );
  s.officialsPool.add(
    Courtier(
      id: 'replacement',
      name: 'Ứng viên',
      role: 'Chờ bổ nhiệm',
      faction: 'Văn thần',
      trait: '',
      age: 35,
      ability: 75,
      loyalty: 70,
      ambition: 40,
      integrity: 70,
      influence: 40,
      grade: 3,
    ),
  );
  final rival = woman(
    'rival',
    traits: const [Personality.upright, Personality.honest],
  )..faction = 'Võ tướng';
  s.court.add(rival);
  complete(s, rival);
}

void main() {
  test(
    'all nine conflict objectives require native personnel actions and role-specific verification',
    () {
      for (final d in haremQuestCatalog.where((d) => d.conflict)) {
        var s = fixture(queen: d.queen, traits: d.traits);
        addConflictTargets(s);
        if (d.queen) complete(s, s.court.first);
        final consort = d.objective == HaremObjective.removeConsort;
        final q = HaremQuest(
          personId: 'owner',
          definitionId: d.id,
          assignedTurn: 1,
          faction: 'Võ tướng',
          queen: d.queen,
          stage: 2,
          choices: ['A', 'A'],
          targetId: consort ? 'rival' : 'official-target',
          officeId: consort ? '' : 'conflict-office',
          familyIds: ['replacement'],
        );
        s.haremQuests.add(q);
        expect(haremCommitmentMet(s, q), isFalse, reason: d.id);
        final option = '${d.queen ? 'queen' : 'personal'}:A';
        expect(
          () => engine.send(s, 'harem-quest', target: 'owner', option: option),
          throwsA(isA<GameRuleException>()),
          reason: d.id,
        );
        if (consort) {
          s = engine.send(s, 'courtier', target: 'rival', option: 'demote');
        } else if ([
          HaremObjective.familyOffice,
          HaremObjective.factionOffice,
        ].contains(d.objective)) {
          s = engine.send(
            s,
            'appoint-office',
            target: 'conflict-office',
            option: 'replacement',
          );
        } else {
          s = engine.send(s, 'dismiss-office', target: 'conflict-office');
        }
        final progress = haremQuestFor(s, 'owner', queen: d.queen)!;
        expect(haremCommitmentMet(s, progress), isTrue, reason: d.id);
        expect(progress.completed, isFalse);
        for (var season = 0; season <= d.requiredSeasons; season++) {
          s = closeSeason(s);
        }
        s = engine.send(s, 'harem-quest', target: 'owner', option: option);
        expect(
          haremPassiveBlocked(s, s.court.first, queen: d.queen),
          isNull,
          reason: d.id,
        );
        if (d.queen) {
          s.court.first.queen = false;
          GameEngine().prepareHaremQuests(s);
          expect(
            haremQuestFor(s, 'owner', queen: true)!.verifiedSeasons,
            greaterThanOrEqualTo(3),
          );
          expect(haremPassiveBlocked(s, s.court.first, queen: true), isNotNull);
          s.court.first.queen = true;
          GameEngine().prepareHaremQuests(s);
          expect(haremPassiveBlocked(s, s.court.first, queen: true), isNull);
        }
      }
    },
  );

  test(
    'post-unlock previews respect the new cap, subtract expelled contributors and never mutate state',
    () {
      final s = fixture();
      for (var i = 0; i < 3; i++) {
        final c = woman('aaa-$i', affection: 96);
        s.court.add(c);
        complete(s, c);
      }
      final before = jsonEncode(s.toJson());
      final capped = HaremBenefits(s, previewPersonId: 'owner');
      expect(capped.total(HaremBenefit.people), 5);
      expect(capped.contributions.last.amount, 0);
      final replacing = HaremBenefits(
        s,
        previewPersonId: 'owner',
        excludePersonId: 'aaa-0',
      );
      expect(replacing.total(HaremBenefit.people), 5);
      expect(replacing.contributions.last.amount, 1);
      expect(jsonEncode(s.toJson()), before);
    },
  );

  test(
    'old over-cap saves preserve people but only ten, including the queen, contribute',
    () {
      final s = fixture()..haremVersion = 0;
      s.court.clear();
      for (var i = 0; i < 11; i++) {
        final c = woman(
          'resident-$i',
          queen: i == 10,
          affection: i == 10 ? 90 : 80,
        );
        s.court.add(c);
        complete(s, c);
        if (c.queen) complete(s, c, queen: true);
      }
      GameEngine().prepareHaremQuests(s);
      expect(haremResidentCount(s), 11);
      expect(haremAdmissionBlocked(s), isNotNull);
      final contributing = HaremBenefits(s).contributions;
      expect(contributing.map((x) => x.person.id).toSet(), hasLength(10));
      expect(contributing.where((x) => x.person.queen), hasLength(2));
    },
  );

  test(
    '29 authored routes have connected chapters and exact approved budgets',
    () {
      expect(haremQuestCatalog.where((d) => !d.queen), hasLength(22));
      expect(haremQuestCatalog.where((d) => d.queen), hasLength(7));
      expect(haremQuestCatalog.map((d) => d.id).toSet(), hasLength(29));
      expect(haremQuestCatalog.every((d) => d.chapters.length == 3), isTrue);
      final costs = [
        48,
        60,
        48,
        60,
        48,
        60,
        48,
        48,
        60,
        72,
        60,
        60,
        48,
        72,
        60,
        60,
        24,
        18,
        30,
        24,
        30,
        36,
      ];
      for (var i = 0; i < costs.length; i++) {
        expect(
          haremQuestDefinition('PT${(i + 1).toString().padLeft(2, '0')}').cost,
          costs[i],
        );
      }
      expect(
        [for (var i = 1; i <= 7; i++) haremQuestDefinition('HH0$i').cost],
        [72, 84, 84, 96, 36, 48, 48],
      );
    },
  );

  test(
    '60 opens a fixed assignment; completing at 70 does not activate until 71',
    () {
      final s = fixture();
      final c = s.court.first;
      c.affection = 59;
      GameEngine().prepareHaremQuests(s);
      expect(s.haremQuests, isEmpty);
      c.affection = 60;
      GameEngine().prepareHaremQuests(s);
      expect(s.haremQuests, hasLength(1));
      final allocated = s.haremQuests.single.definitionId;
      final rng = s.rng;
      final restored = GameState.fromJson(
        object(jsonDecode(jsonEncode(s.toJson()))),
      );
      GameEngine().prepareHaremQuests(restored);
      expect(restored.rng, rng);
      expect(restored.haremQuests.single.definitionId, allocated);
      restored.haremQuests.single.stage = 3;
      restored.court.first.affection = 70;
      expect(HaremBenefits(restored).total(HaremBenefit.people), 0);
      restored.court.first.affection = 71;
      expect(HaremBenefits(restored).total(HaremBenefit.people), 1);
      restored.court.first.affection = 96;
      expect(HaremBenefits(restored).total(HaremBenefit.people), 2);
      restored.court.first.affection = 65;
      expect(HaremBenefits(restored).total(HaremBenefit.people), 0);
      expect(restored.haremQuests.single.completed, isTrue);
    },
  );

  test(
    'mixed chapter choices debit once, affect exactly the named faction, and persist',
    () {
      var s = fixture();
      s.haremQuests.add(
        HaremQuest(
          personId: 'owner',
          definitionId: 'PT09',
          assignedTurn: 1,
          faction: 'Võ tướng',
        ),
      );
      final before = s.treasury;
      s = engine.send(s, 'harem-quest', target: 'owner', option: 'personal:A');
      expect(s.treasury, before - 2000);
      final frozen = jsonEncode(s.toJson());
      expect(
        () => engine.send(
          s,
          'harem-quest',
          target: 'owner',
          option: 'personal:B',
        ),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), frozen);
      s.completedWeeks++;
      final faction = s.factions['Võ tướng']!;
      s = engine.send(s, 'harem-quest', target: 'owner', option: 'personal:B');
      expect(s.factions['Võ tướng'], faction - 4);
      s.completedWeeks++;
      s = engine.send(s, 'harem-quest', target: 'owner', option: 'personal:A');
      expect(s.treasury, before - 5000);
      expect(s.points, 17);
      expect(s.haremQuests.single.choices, ['A', 'B', 'A']);
      expect(
        s.financialWeeks
            .expand((w) => w.entries)
            .where((e) => e.category == 'harem-quest')
            .length,
        3,
      );
    },
  );

  test(
    'every ordinary route applies its full B price, faction and stat loss exactly',
    () {
      for (final d in haremQuestCatalog.where((d) => !d.conflict)) {
        var s = fixture(queen: d.queen);
        if (d.queen) complete(s, s.court.first);
        final q = HaremQuest(
          personId: 'owner',
          definitionId: d.id,
          assignedTurn: 1,
          faction: 'Võ tướng',
          queen: d.queen,
        );
        s.haremQuests.add(q);
        final cash = s.treasury, mood = s.factions['Võ tướng']!;
        final authority = s.authority, stability = s.stability;
        for (var i = 0; i < 3; i++) {
          s = engine.send(
            s,
            'harem-quest',
            target: 'owner',
            option: '${d.queen ? 'queen' : 'personal'}:B',
          );
          s.completedWeeks++;
        }
        expect(s.treasury, cash - d.cost * 50, reason: d.id);
        expect(s.factions['Võ tướng'], mood - d.factionLoss, reason: d.id);
        expect(
          s.authority,
          authority - (d.stat == 'authority' ? d.statLoss : 0),
          reason: d.id,
        );
        expect(
          s.stability,
          stability - (d.stat == 'stability' ? d.statLoss : 0),
          reason: d.id,
        );
      }
    },
  );

  test(
    'queen requires her own completion and 85 affection; demotion does not erase it',
    () {
      final s = fixture(queen: true);
      final c = s.court.first;
      complete(s, c);
      c.affection = 84;
      GameEngine().prepareHaremQuests(s);
      expect(haremQuestFor(s, c.id, queen: true), isNull);
      c.affection = 85;
      GameEngine().prepareHaremQuests(s);
      expect(haremQuestFor(s, c.id, queen: true), isNotNull);
      expect(HaremBenefits(s).contributions, hasLength(1));
      complete(s, c, queen: true);
      expect(HaremBenefits(s).contributions, hasLength(2));
      c.queen = false;
      expect(HaremBenefits(s).contributions, hasLength(1));
      c.queen = true;
      expect(haremQuestFor(s, c.id, queen: true)!.completed, isTrue);
    },
  );

  test(
    'ten residents include queen; admission failures roll back all money and favor',
    () {
      var s = fixture(queen: true);
      for (var i = 1; i < 10; i++) {
        s.court.add(woman('resident-$i'));
      }
      s.court.add(woman('candidate')..inHarem = false);
      final before = jsonEncode(s.toJson());
      expect(
        () => engine.send(s, 'courtier', target: 'candidate', option: 'invite'),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
      s = engine.send(s, 'courtier', target: 'owner', option: 'demote');
      expect(haremResidentCount(s), 10);
      s = engine.send(s, 'courtier', target: 'resident-1', option: 'demote');
      expect(haremResidentCount(s), 9);
      s = engine.send(s, 'courtier', target: 'candidate', option: 'invite');
      expect(haremResidentCount(s), 10);
    },
  );

  test('new global caps include queen and treasury is scaled exactly once', () {
    final s = fixture(queen: true);
    s.court.clear();
    for (var i = 0; i < 5; i++) {
      final c = woman(
        'treasury-$i',
        affection: 96,
        traits: const [Personality.familyFirst, Personality.partisan],
      )..faction = 'Thế gia';
      s.court.add(c);
      complete(s, c);
    }
    for (var i = 0; i < 3; i++) {
      final c = woman('people-$i', affection: 96);
      s.court.add(c);
      complete(s, c);
    }
    final c = woman(
      'queen',
      queen: true,
      affection: 96,
      traits: const [Personality.diplomatic, Personality.flexible],
    );
    s.court.add(c);
    complete(s, c);
    complete(s, c, queen: true);
    final benefits = HaremBenefits(s);
    expect(benefits.total(HaremBenefit.treasury), 50);
    expect(benefits.total(HaremBenefit.people), 5);
    expect(benefits.total(HaremBenefit.stability), 2);
    expect(benefits.total(HaremBenefit.authority), 2);
  });

  test(
    'conflict is verified across full seasons and stops immediately on reversal',
    () {
      var s = fixture(
        traits: const [Personality.resentful, Personality.cautious],
      );
      addConflictTargets(s);
      s.haremQuests.add(
        HaremQuest(
          personId: 'owner',
          definitionId: 'PT17',
          assignedTurn: 1,
          faction: 'Võ tướng',
          targetId: 'official-target',
          officeId: 'conflict-office',
        ),
      );
      s = engine.send(s, 'harem-quest', target: 'owner', option: 'personal:A');
      s.completedWeeks++;
      s = engine.send(s, 'harem-quest', target: 'owner', option: 'personal:A');
      final before = s.treasury;
      s = engine.send(s, 'dismiss-office', target: 'conflict-office');
      expect(
        s.treasury,
        before,
      ); // Native dismissal is not charged a fictitious quest fee.
      expect(
        () => engine.send(
          s,
          'harem-quest',
          target: 'owner',
          option: 'personal:A',
        ),
        throwsA(isA<GameRuleException>()),
      );
      for (var i = 0; i < 3; i++) {
        s = closeSeason(s);
      }
      s = engine.send(s, 'harem-quest', target: 'owner', option: 'personal:A');
      expect(haremPassiveBlocked(s, s.court.first), isNull);
      s.courtOffices.first.holderId = 'official-target';
      GameEngine().prepareHaremQuests(s);
      expect(haremPassiveBlocked(s, s.court.first), isNotNull);
      expect(haremQuestFor(s, 'owner')!.verifiedSeasons, 0);
      s.courtOffices.first.holderId = '';
      GameEngine().prepareHaremQuests(s);
      expect(haremPassiveBlocked(s, s.court.first), isNotNull);
      for (var i = 0; i < 3; i++) {
        s = closeSeason(s);
      }
      expect(haremPassiveBlocked(s, s.court.first), isNull);
      expect(haremQuestFor(s, 'owner')!.choices, ['A', 'A', 'A']);
    },
  );

  test(
    'refusal is once, waits two seasons, and never changes the assigned route',
    () {
      var s = fixture();
      s.haremQuests.add(
        HaremQuest(
          personId: 'owner',
          definitionId: 'PT17',
          assignedTurn: 1,
          faction: 'Võ tướng',
        ),
      );
      s = engine.send(
        s,
        'harem-quest',
        target: 'owner',
        option: 'personal:refuse',
      );
      expect(s.court.first.affection, 72);
      final points = s.points, cash = s.treasury;
      expect(
        () => engine.send(
          s,
          'harem-quest',
          target: 'owner',
          option: 'personal:refuse',
        ),
        throwsA(isA<GameRuleException>()),
      );
      expect(
        () => engine.send(
          s,
          'harem-quest',
          target: 'owner',
          option: 'personal:resume',
        ),
        throwsA(isA<GameRuleException>()),
      );
      s.completedWeeks += 2;
      s = engine.send(
        s,
        'harem-quest',
        target: 'owner',
        option: 'personal:resume',
      );
      expect(s.haremQuests.single.definitionId, 'PT17');
      expect(s.points, points);
      expect(s.treasury, cash);
    },
  );

  test(
    'allocation frequencies follow traits and role, independent of pool size',
    () {
      const risky = [
        Personality.resentful,
        Personality.familyFirst,
        Personality.partisan,
      ];
      for (final queen in [false, true]) {
        for (var count = 1; count <= 3; count++) {
          var conflictCount = 0;
          const samples = 1800;
          for (var seed = 1; seed <= samples; seed++) {
            final s = fixture(
              seed: seed * 997,
              queen: queen,
              traits: risky.take(count).toList(),
            );
            addConflictTargets(s);
            if (queen) complete(s, s.court.first);
            GameEngine().prepareHaremQuests(s);
            final q = haremQuestFor(s, 'owner', queen: queen)!;
            if (haremQuestDefinition(q.definitionId).conflict) conflictCount++;
          }
          final expected =
              (queen ? [0, 35, 50, 60] : [0, 25, 40, 50])[count] / 100;
          expect(
            conflictCount / samples,
            closeTo(expected, .045),
            reason: 'queen=$queen count=$count',
          );
        }
      }
    },
  );

  test(
    'no target falls back to normal; views and later reveals cannot reroll',
    () {
      final s = fixture(
        traits: const [
          Personality.resentful,
          Personality.familyFirst,
          Personality.partisan,
        ],
      );
      s.court.first.personalityContacts = 0;
      GameEngine().prepareHaremQuests(s);
      final id = s.haremQuests.single.definitionId, rng = s.rng;
      expect(haremQuestDefinition(id).conflict, isFalse);
      s.court.first.personalityContacts = 6;
      addConflictTargets(s);
      GameEngine().prepareHaremQuests(s);
      haremPassivePreview(s.court.first, state: s);
      HaremBenefits(s);
      expect(haremQuestFor(s, 'owner')!.definitionId, id);
      expect(s.rng, rng);
    },
  );

  test(
    'old saves stop learning, remove female ability, and do not gift completions',
    () {
      final s = fixture()..haremVersion = 0;
      s.palaceWorks.add(
        PalaceWork(
          id: 'old-study',
          kind: 'study',
          personId: 'owner',
          startedTurn: 1,
          duration: 2,
        ),
      );
      final raw = s.toJson();
      raw.remove('haremVersion');
      (raw['court'] as List).first['ability'] = 99;
      final restored = GameState.fromJson(object(raw));
      final rng = restored.rng;
      GameEngine().prepareHaremQuests(restored);
      expect(restored.palaceWorks, isEmpty);
      expect(restored.palaceEffects, isEmpty);
      expect(restored.court.first.toJson().containsKey('ability'), isFalse);
      expect(restored.haremQuests.single.completed, isFalse);
      expect(HaremBenefits(restored).contributions, isEmpty);
      expect(restored.rng, isNot(rng));
      final saved = GameState.fromJson(object(restored.toJson()));
      final allocated = saved.rng;
      GameEngine().prepareHaremQuests(saved);
      expect(saved.rng, allocated);
      expect(
        () => engine.send(saved, 'palace', target: 'owner', option: 'study'),
        throwsA(isA<GameRuleException>()),
      );
    },
  );
}
