import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/data/story_petitions.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';

final storyEngine = GameEngine();
GameState storyState() {
  final s =
      storyEngine.start('story-test', 'An', 42)
        ..petitions.clear()
        ..nextMajorWeek = 10000
        ..nextChainWeek = 10000
        ..treasury = 100000
        ..grain = 10000
        ..people = 95
        ..stability = 95
        ..authority = 95
        ..army = 95;
  for (final c in s.court) {
    c.loyalty = 95;
    c.ambition = 10;
    c.discontent = 0;
  }
  return s;
}

GameCommand storyCommand(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => GameCommand(
  id: 'story-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: type,
  target: target,
  option: option,
);
GameState storySend(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => storyEngine.execute(
  s,
  storyCommand(s, type, target: target, option: option),
);
GameState nextStorySeason(GameState s) {
  s.petitions.removeWhere((p) => !p.isStory);
  s.affairsThisWeek = 1;
  return storySend(s, 'endWeek');
}

MajorMission storyMajor(String kind, {int severity = 1}) {
  final d = majorDefinition(kind);
  return MajorMission(
    id: 'major-$kind',
    kind: kind,
    openedWeek: 1,
    deadline: 4,
    dueWeek: 1,
    severity: severity,
    preparedness: 0,
    petitionDriven: true,
    demanding: true,
    objectives: d.objectives.map((o) => MissionObjective(key: o.key)).toList(),
  );
}

void main() {
  test(
    'four limited responses settle as partial protection without applying stage losses twice',
    () {
      var s = storyState()..major = storyMajor('flood');
      storyEngine.prepareStoryPetitions(s);
      final losses = <String, int>{};
      for (var i = 0; i < 4; i++) {
        final p = s.petitions.singleWhere((p) => p.storyKind == 'major');
        final c = eventForState(s, p.definitionId).choices[1];
        for (final entry in c.effects.entries) {
          losses.update(
            entry.key,
            (v) => v + entry.value,
            ifAbsent: () => entry.value,
          );
        }
        final money = s.treasury;
        s = storySend(s, 'petition', target: p.id, option: '1');
        expect(s.treasury, money - c.cost + (c.effects['treasury'] ?? 0));
        if (i < 3) s = nextStorySeason(s);
      }
      expect(s.major, isNull);
      final past = s.majorHistory.single;
      expect(past.responseScore, 2);
      expect(past.result, 'Ứng phó một phần');
      expect(past.damageTaken, losses);
      expect(s.obligations.where((o) => o.kind == 'aftermath'), isEmpty);
    },
  );

  test('the seasonal grain loan is paid once on the promised later season', () {
    var s =
        storyState()
          ..chains = [
            StoryArc(
              settlementVersion: 0,
              id: 'arc',
              kind: 'granary',
              dueWeek: 1,
            ),
          ];
    storyEngine.prepareStoryPetitions(s);
    s = storySend(s, 'petition', target: s.petitions.single.id, option: '1');
    expect(s.obligations.single.amount, 35);
    expect(s.obligations.single.nextWeek, 2);
    s = nextStorySeason(s);
    expect(s.obligations.single.remaining, 1);
    s = nextStorySeason(s);
    expect(s.obligations, isEmpty);
    final payments = s.financialWeeks
        .expand((w) => w.entries)
        .where((e) => e.title.contains('Hoàn trả khoản vay thóc'));
    expect(payments, hasLength(1));
    expect(payments.single.amount, -35);
  });

  test('a successor who died is never restored by a later care petition', () {
    final s =
        storyState()
          ..major = storyMajor('db-55')
          ..heirId = 'prince'
          ..heirCondition = 'deceased';
    s.major!.subjectId = 'prince';
    s.court.firstWhere((c) => c.id == 'prince').available = false;
    storyEngine.prepareStoryPetitions(s);
    final p = s.petitions.single;
    expect(petitionText(p, s), contains('Người kế vị đã qua đời'));
    expect(
      eventForState(s, p.definitionId).choices.first.label,
      'Huy động cho phương án dự phòng',
    );
    final next = storySend(s, 'petition', target: p.id, option: '0');
    expect(next.heirCondition, 'deceased');
    expect(next.major!.objectives.first.done, false);
    expect(next.court.firstWhere((c) => c.id == 'prince').available, false);
  });

  test('all ten chains are playable exclusively through dated petitions', () {
    expect(legacyChainDefinitions.map((d) => d.id).toSet(), hasLength(10));
    for (final definition in legacyChainDefinitions) {
      var s =
          storyState()
            ..chains = [
              StoryArc(
                settlementVersion: 0,
                id: 'arc',
                kind: definition.id,
                dueWeek: 1,
              ),
            ];
      storyEngine.prepareStoryPetitions(s);
      for (var stage = 0; stage < definition.stages.length; stage++) {
        final p = s.petitions.singleWhere((p) => p.storyId == 'arc');
        expect(p.storyStage, stage);
        final event = eventForState(s, p.definitionId);
        expect(event.choices, hasLength(3));
        expect(event.body, contains('Bản tấu ${stage + 1}'));
        final before = s.treasury, points = s.points;
        final choice = event.choices.first;
        s = storySend(s, 'petition', target: p.id, option: '0');
        expect(
          s.treasury,
          before - choice.cost + (choice.effects['treasury'] ?? 0),
        );
        expect(s.points, points - 1);
        expect(s.petitions.where((p) => p.storyId == 'arc'), isEmpty);
        if (s.chains.isNotEmpty) {
          final due = s.chains.single.dueWeek;
          expect(due, greaterThan(s.week));
          expect(storyEngine.prepareStoryPetitions(s), false);
          while (s.week < due) {
            s = nextStorySeason(s);
          }
          expect(s.ended, false, reason: definition.id);
        }
      }
      expect(s.completedChains, contains(definition.id));
      expect(s.chains, isEmpty);
    }
  });

  test('different orders change the next petition and its real cost', () {
    GameState branch(String kind, int choice) {
      var s =
          storyState()
            ..chains = [
              StoryArc(settlementVersion: 0, id: 'arc', kind: kind, dueWeek: 1),
            ];
      storyEngine.prepareStoryPetitions(s);
      final p = s.petitions.single;
      s = storySend(s, 'petition', target: p.id, option: '$choice');
      return nextStorySeason(s);
    }

    final repaired = branch('dyke', 0),
        surveyed = branch('dyke', 1),
        ignored = branch('dyke', 2);
    expect(
      eventForState(repaired, 'chain:dyke:1').title,
      'Đê đã sửa, dân vẫn bất an',
    );
    expect(
      eventForState(surveyed, 'chain:dyke:1').title,
      'Đoạn đê yếu hơn lời báo',
    );
    expect(
      eventForState(ignored, 'chain:dyke:1').title,
      'Nước sông dâng sát mặt đê',
    );
    final envoy = branch('border', 0), escort = branch('border', 1);
    expect(
      petitionText(envoy.petitions.firstWhere((p) => p.isStory), envoy),
      contains('Sứ giả đã trở về'),
    );
    expect(
      eventForState(escort, 'chain:border:1').choices.first.cost,
      greaterThan(eventForState(envoy, 'chain:border:1').choices.first.cost),
    );
  });

  test('copper can end peacefully at its first petition', () {
    final s =
        storyState()
          ..chains = [
            StoryArc(
              settlementVersion: 0,
              id: 'arc',
              kind: 'copper',
              dueWeek: 1,
            ),
          ];
    storyEngine.prepareStoryPetitions(s);
    final next = storySend(
      s,
      'petition',
      target: s.petitions.single.id,
      option: '2',
    );
    expect(next.chains, isEmpty);
    expect(next.completedChains, ['copper']);
    expect(next.people, s.people);
  });

  test(
    'deadline fallback happens once and next stage never opens in the same season',
    () {
      var s =
          storyState()
            ..chains = [
              StoryArc(
                settlementVersion: 0,
                id: 'arc',
                kind: 'granary',
                dueWeek: 1,
              ),
            ];
      storyEngine.prepareStoryPetitions(s);
      expect(s.petitions.single.deadline, 2);
      s = nextStorySeason(s);
      expect(s.chains.single.stage, 0);
      s = nextStorySeason(s);
      expect(s.chains.single.decisions, [2]);
      expect(s.chains.single.stage, 1);
      expect(s.petitions.where((p) => p.storyId == 'arc'), hasLength(1));
      final snapshot = jsonEncode(s.toJson());
      expect(storyEngine.prepareStoryPetitions(s), false);
      expect(jsonEncode(s.toJson()), snapshot);
    },
  );

  test(
    'all 66 major scenarios have four seasonal decisions, exact costs and a single settlement',
    () {
      for (final definition in majorDefinitions) {
        var s = storyState()..major = storyMajor(definition.id);
        storyEngine.prepareStoryPetitions(s);
        for (var stage = 0; stage < 4; stage++) {
          final p = s.petitions.singleWhere((p) => p.storyKind == 'major');
          expect(p.storyStage, stage);
          expect(p.deadline, s.week);
          final event = eventForState(s, p.definitionId);
          final action = majorActionTitle(definition.objectives[stage]);
          expect(
            '${event.title}\n${event.body}'.toLowerCase(),
            contains(action.toLowerCase()),
          );
          expect(event.choices.first.label, action);
          for (final raw in [
            '/4',
            '· mức',
            'DB-',
            '%',
            'Không thu hoặc trừ lại',
            'Diễn biến cần ngự phê:',
            'Tổn thất đã xảy ra:',
          ]) {
            expect(
              event.body,
              isNot(contains(raw)),
              reason: '${definition.id}: $stage',
            );
          }
          for (final option in event.choices) {
            expect(option.hint, isEmpty);
          }
          final c = event.choices.first, money = s.treasury, points = s.points;
          expect(c.cost, greaterThanOrEqualTo(55));
          s = storySend(s, 'petition', target: p.id, option: '0');
          expect(
            s.treasury,
            money -
                c.cost +
                (stage == 3 ? definition.rewards['treasury'] ?? 0 : 0),
          );
          expect(s.points, points - 2);
          expect(s.petitions.where((p) => p.storyKind == 'major'), isEmpty);
          if (stage < 3) {
            expect(s.major!.stage, stage + 1);
            expect(s.major!.dueWeek, s.week + 1);
            s = nextStorySeason(s);
            expect(s.ended, false, reason: definition.id);
          }
        }
        expect(s.major, isNull);
        expect(s.majorHistory, hasLength(1));
        expect(s.majorHistory.single.decisions, [0, 0, 0, 0]);
        expect(s.nextMajorWeek, greaterThanOrEqualTo(s.week + 4));
      }
    },
  );

  test(
    'partial and ignored responses cause immediate losses and make the next season more expensive',
    () {
      final s = storyState()..major = storyMajor('flood');
      storyEngine.prepareStoryPetitions(s);
      final p = s.petitions.single;
      final e = eventForState(s, p.definitionId);
      final damage = e.choices[2].effects;
      expect(damage.values.any((v) => v < 0), true);
      final ignored = storySend(s, 'petition', target: p.id, option: '2');
      final full = storySend(s, 'petition', target: p.id, option: '0');
      expect(ignored.major!.damageTaken, damage);
      expect(ignored.major!.objectives.first.done, false);
      final ignoredNext = nextStorySeason(ignored),
          fullNext = nextStorySeason(full);
      expect(
        eventForState(ignoredNext, 'major:flood:1').choices.first.cost,
        greaterThan(
          eventForState(fullNext, 'major:flood:1').choices.first.cost,
        ),
      );
      final partial = storySend(s, 'petition', target: p.id, option: '1');
      expect(partial.major!.objectives.first.delivered, 50);
      for (final entry in damage.entries) {
        expect(
          partial.major!.damageTaken[entry.key]!.abs(),
          lessThanOrEqualTo(entry.value.abs()),
        );
      }
    },
  );

  test('major expiry is lethal before the economy can restore a zero stat', () {
    var s =
        storyState()
          ..major = storyMajor('rumor', severity: 6)
          ..authority = 1;
    storyEngine.prepareStoryPetitions(s);
    s.affairsThisWeek = 1;
    s = storySend(s, 'endWeek');
    expect(s.ended, true);
    expect(s.completedWeeks, 0);
    expect(s.major!.decisions, [2]);
  });

  test(
    'continuations share the 4–6 petition draw, co-exist and never enter the random pool',
    () {
      var s =
          storyState()
            ..major = storyMajor('flood')
            ..chains = [
              StoryArc(
                settlementVersion: 0,
                id: 'arc',
                kind: 'border',
                dueWeek: 1,
              ),
            ];
      storyEngine.prepareStoryPetitions(s);
      final chain = s.petitions.firstWhere((p) => p.storyKind == 'chain');
      s = storySend(s, 'petition', target: chain.id, option: '0');
      final major = s.petitions.singleWhere((p) => p.storyKind == 'major');
      s = storySend(s, 'petition', target: major.id, option: '0');
      s = nextStorySeason(s);
      expect(
        s.petitions.where((p) => p.openedWeek == s.week).length,
        s.seasonPetitionTarget,
      );
      expect(s.petitions.where((p) => p.storyKind == 'major'), hasLength(1));
      expect(s.petitions.where((p) => p.storyKind == 'chain'), hasLength(1));
      for (final p in s.petitions.where((p) => p.isStory)) {
        expect(storyEngine.eligible(s, eventById(p.definitionId)), false);
      }
    },
  );

  test(
    'legacy chain and mission commands cannot bypass petition scheduling',
    () {
      final s =
          storyState()
            ..major = storyMajor('flood')
            ..chains = [
              StoryArc(
                settlementVersion: 0,
                id: 'arc',
                kind: 'border',
                dueWeek: 1,
              ),
            ];
      expect(
        () => storySend(s, 'mission', target: 'levee', option: 'works'),
        throwsA(isA<GameRuleException>()),
      );
      expect(
        () => storySend(s, 'chain', target: 'arc', option: '0'),
        throwsA(isA<GameRuleException>()),
      );
      storyEngine.prepareStoryPetitions(s);
      final p = s.petitions.first;
      p.storyStage = 9;
      expect(
        () => storySend(s, 'petition', target: p.id, option: '0'),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test(
    'insufficient resources and invalid choices leave the saved snapshot unchanged',
    () {
      final s =
          storyState()
            ..treasury = 0
            ..major = storyMajor('flood');
      storyEngine.prepareStoryPetitions(s);
      final before = jsonEncode(s.toJson()), p = s.petitions.single;
      expect(
        () => storySend(s, 'petition', target: p.id, option: '0'),
        throwsA(isA<GameRuleException>()),
      );
      expect(
        () => storySend(s, 'petition', target: p.id, option: '5'),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
    },
  );

  test(
    'old seasonal save migration preserves decisions, partial work and paid assignments; loads are idempotent',
    () async {
      final s = storyState()..storySystemVersion = 0;
      s.chains = [
        StoryArc(
          settlementVersion: 0,
          id: 'old-arc',
          kind: 'granary',
          stage: 1,
          decisions: [1],
          dueWeek: 3,
        ),
      ];
      s.major = storyMajor('flood')..petitionDriven = false;
      s.major!.objectives[0]
        ..done = true
        ..delivered = 100;
      s.major!.objectives[1]
        ..officerId = 'works'
        ..finishWeek = 2
        ..delivered = 40;
      final raw =
          s.toJson()
            ..remove('storySystemVersion')
            ..['rulesVersion'] = 'mvp-0.16.0'
            ..['contentVersion'] = 15;
      final old = GameState.fromJson(object(jsonDecode(jsonEncode(raw))));
      final store = MemoryGameStore();
      await store.update((a) => a.active = old);
      final gateway = LocalGameGateway(store);
      final loaded = (await gateway.load()).active!;
      expect(loaded.treasury, old.treasury);
      expect(loaded.points, old.points);
      expect(loaded.rng, old.rng);
      expect(loaded.scoreRules, old.scoreRules);
      expect(loaded.major!.stage, 1);
      expect(loaded.major!.objectives[1].officerId, 'works');
      expect(loaded.major!.objectives[1].delivered, 40);
      expect(loaded.chains.single.decisions, [1]);
      expect(loaded.petitions, isEmpty);
      final again = await gateway.load();
      expect(again.active!.toJson(), loaded.toJson());
      expect(loaded.majorHistory, isEmpty);
    },
  );

  test(
    'save, reopen and retry never repeat a payment or advance a story twice',
    () async {
      final s = storyState()..major = storyMajor('flood');
      final store = MemoryGameStore();
      await store.update((a) => a.active = s);
      final gateway = LocalGameGateway(store);
      final loaded = (await gateway.load()).active!;
      final cmd = storyCommand(
        loaded,
        'petition',
        target: loaded.petitions.single.id,
        option: '0',
      );
      final committed = await gateway.dispatch(cmd);
      final reopened = LocalGameGateway(store);
      expect((await reopened.load()).toJson(), committed.toJson());
      expect((await reopened.dispatch(cmd)).toJson(), committed.toJson());
      expect(committed.active!.major!.decisions, [0]);
      final stale = storyCommand(
        loaded,
        'petition',
        target: loaded.petitions.single.id,
        option: '1',
      );
      expect(() => reopened.dispatch(stale), throwsA(isA<GameRuleException>()));
      expect((await reopened.load()).toJson(), committed.toJson());
    },
  );

  test(
    'allegations persist across save and are not treated as proven before investigation',
    () {
      for (final innocent in [0, 1]) {
        final s =
            storyState()
              ..chains = [
                StoryArc(
                  settlementVersion: 0,
                  id: 'arc',
                  kind: 'justice',
                  stage: 2,
                  dueWeek: 1,
                  decisions: [0, 0],
                  facts: {'innocent': innocent},
                ),
              ];
        storyEngine.prepareStoryPetitions(s);
        final reloaded = s.copy();
        final text = petitionText(reloaded.petitions.single, reloaded);
        expect(
          text,
          contains(innocent == 1 ? 'có ép cung' : 'vật chứng buộc tội hợp lệ'),
        );
        expect(reloaded.chains.single.facts, s.chains.single.facts);
      }
    },
  );

  test('partially delivered migrated goal charges only remaining work', () {
    final s = storyState()..major = storyMajor('flood');
    s.major!.objectives.first.delivered = 40;
    storyEngine.prepareStoryPetitions(s);
    final c = eventForState(s, s.petitions.single.definitionId).choices.first;
    expect(c.cost, 33);
    final next = storySend(
      s,
      'petition',
      target: s.petitions.single.id,
      option: '1',
    );
    expect(next.major!.objectives.first.delivered, 70);
  });
}
