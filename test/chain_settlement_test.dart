import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/data/story_petitions.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/chain_settlement_rules.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';

final settlementEngine = GameEngine();
GameState settlementState(String kind) {
  final s =
      settlementEngine.start('settlement', 'An', 42)
        ..petitions.clear()
        ..nextMajorWeek = 10000
        ..nextChainWeek = 10000
        ..treasury = 5000
        ..grain = 100
        ..people = 70
        ..stability = 70
        ..authority = 70
        ..army = 70
        ..levee = 35
        ..chains = [StoryArc(id: 'arc', kind: kind, dueWeek: 1)];
  s.factions.updateAll((k, v) => 65);
  for (final c in s.court) {
    c.loyalty = c.integrity = 95;
    c.affection = 60;
    c.ambition = 10;
    c.discontent = c.plot = 0;
  }
  final people = s.court.where((c) => c.isConsort).take(2).toList();
  for (final c in people) {
    c.inHarem = true;
    c.queen = false;
    c.ability = 60;
  }
  people[0].faction = 'Văn thần';
  people[1].faction = 'Hoàng tộc'; // Different factions need not be opponents.
  settlementEngine.prepareStoryPetitions(s);
  return s;
}

GameCommand settlementCommand(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => GameCommand(
  id: 'settlement-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: type,
  target: target,
  option: option,
);
GameState settlementSend(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => settlementEngine.execute(
  s,
  settlementCommand(s, type, target: target, option: option),
);
GameState settleChoice(GameState s, String option) => settlementSend(
  s,
  'petition',
  target: s.petitions.singleWhere((p) => p.storyId == 'arc').id,
  option: option,
);
GameState nextSettlementSeason(GameState s) {
  s.petitions.removeWhere((p) => !p.isStory);
  s.affairsThisWeek = 1;
  return settlementSend(s, 'endWeek');
}

void main() {
  test('all twelve chains have four dated steps with deferred rewards', () {
    expect(chainDefinitions, hasLength(12));
    expect(chainDefinitions.map((d) => d.id).toSet(), hasLength(12));
    for (final d in chainDefinitions) {
      expect(d.stages, hasLength(4));
      var s = settlementState(d.id);
      final initialPool = s.officialsPool.length;
      for (var i = 0; i < 4; i++) {
        final arc = s.chains.single;
        final p = s.petitions.singleWhere((p) => p.storyId == arc.id);
        final e = eventForState(s, p.definitionId);
        expect(e.choices, hasLength(3));
        expect(
          e.body,
          contains('Thành quả sẽ được ghi nhận khi hồ sơ khép lại.'),
        );
        for (final spoiler in [
          '/4',
          '%',
          'chi phí quy đổi',
          'Dừng hiện tại nhận',
          'Dự kiến hoàn thành',
          '80–90',
        ]) {
          expect(e.body, isNot(contains(spoiler)), reason: '${d.id}: $i');
          for (final choice in e.choices) {
            expect(choice.label, isNot(contains(spoiler)));
            expect(choice.hint, isNot(contains(spoiler)));
          }
        }
        final index = d.id == 'haremHarmony' ? 2 : 1;
        final expectedReward = chainSettlementEffects(
          projectedChainChoice(arc, index),
        );
        final cash = s.treasury,
            points = s.points,
            army = s.army,
            grain = s.grain;
        s = settleChoice(s, '$index');
        expect(
          s.treasury,
          cash -
              e.choices[index].cost +
              (i == 3 ? expectedReward['treasury'] ?? 0 : 0),
          reason: d.id,
        );
        expect(s.points, points - 1);
        if (i < 3) {
          expect(s.army, army);
          expect(s.grain, grain);
          expect(s.officialsPool, hasLength(initialPool));
          expect(s.chains.single.completedSteps, i + 1);
          s = nextSettlementSeason(s);
          expect(s.ended, false, reason: d.id);
        }
      }
      expect(s.chains, isEmpty);
      expect(s.completedChains, contains(d.id));
      expect(
        s.outcomes.where((o) => o.title == 'Quyết toán: ${d.title}'),
        hasLength(1),
      );
      expect(
        s.obligations.where(
          (o) => o.kind == 'benefit' || o.kind == 'chainPromise',
        ),
        isEmpty,
      );
      expect(s.officialsPool.length, initialPool + (d.id == 'exams' ? 1 : 0));
      if (d.id == 'exams') {
        expect(s.officialsPool.last.ability, inInclusiveRange(80, 90));
      }
    }
  });

  for (final funding in ['cash', 'stats', 'mixed']) {
    for (var completed = 0; completed <= 4; completed++) {
      test(
        'market $funding funding settles $completed/4 from only paid steps',
        () {
          var s = settlementState('market');
          final expected = [0, 0, 45, 150, 550][completed];
          for (var i = 0; i < completed; i++) {
            final index =
                funding == 'cash' || (funding == 'mixed' && i.isEven) ? 1 : 2;
            final money = s.treasury;
            s = settleChoice(s, '$index');
            if (i < 3) {
              expect(
                s.treasury,
                money - (index == 1 ? [40, 50, 60, 70][i] : 0),
              );
              s = nextSettlementSeason(s);
            }
          }
          if (completed < 4) {
            final money = s.treasury,
                authority = s.authority,
                people = s.people,
                stability = s.stability;
            s = settleChoice(s, '0');
            expect(s.treasury, money + expected);
            expect(s.authority, authority);
            expect(s.people, people);
            expect(s.stability, stability);
          }
          final receipts =
              s.financialWeeks
                  .expand((w) => w.entries)
                  .where(
                    (e) =>
                        e.title == 'Quyết toán: Bến chợ Đông Hà' &&
                        e.amount > 0,
                  )
                  .toList();
          expect(receipts.length, expected == 0 ? 0 : 1);
          if (receipts.isNotEmpty) expect(receipts.single.amount, expected);
          expect(s.chains, isEmpty);
        },
      );
    }
  }

  test(
    'partial thematic rewards floor values and grant no full-only benefit',
    () {
      for (var completed = 0; completed <= 4; completed++) {
        var s = settlementState('dyke');
        for (var i = 0; i < completed; i++) {
          s = settleChoice(s, '1');
          if (i < 3) s = nextSettlementSeason(s);
        }
        if (completed < 4) {
          final levee = s.levee, people = s.people;
          s = settleChoice(s, '0');
          expect(s.levee - levee, [0, 0, 7, 14][completed]);
          expect(s.people - people, [0, 0, 1, 2][completed]);
        }
      }
      final partial = StoryArc(
        id: 'p',
        kind: 'border',
        dueWeek: 1,
        completedSteps: 3,
      );
      expect(chainSettlementEffects(partial).containsKey('war'), false);
      partial.completedSteps = 4;
      expect(chainSettlementEffects(partial)['war'], -1);
    },
  );

  test(
    'expiry settles prior progress without charging or completing pending work',
    () {
      for (final kind in ['market', 'haremHarmony']) {
        var s = settlementState(kind);
        final choice = kind == 'market' ? '1' : '2';
        for (var i = 0; i < 2; i++) {
          s = settleChoice(s, choice);
          s = nextSettlementSeason(s);
        }
        final arc = s.chains.single;
        final expected = chainSettlementEffects(arc);
        s.petitions.removeWhere((p) => !p.isStory);
        s.petitions.single.deadline = s.week;
        s = nextSettlementSeason(s);
        expect(s.chains.where((a) => a.id == 'arc'), isEmpty);
        final report = s.outcomes.singleWhere(
          (o) => o.title == 'Quyết toán: ${chainDefinition(kind).title}',
        );
        expect(report.detail, contains('Quá hạn ở 2/4'));
        expect(report.changes['Ngân khố'] ?? 0, expected['treasury'] ?? 0);
        expect(
          s.financialWeeks
              .expand((w) => w.entries)
              .where(
                (e) => e.title == 'Quyết toán: ${chainDefinition(kind).title}',
              )
              .length,
          kind == 'market' ? 1 : 0,
        );
      }
    },
  );

  test(
    'insufficient cash, political resources or actions cannot fund a step',
    () {
      for (final resource in ['cash', 'stats', 'actions']) {
        final s = settlementState('market');
        if (resource == 'cash') s.treasury = 39;
        if (resource == 'stats') s.people = 5;
        if (resource == 'actions') s.points = 0;
        final before = jsonEncode(s.toJson());
        expect(
          () => settleChoice(s, resource == 'stats' ? '2' : '1'),
          throwsA(isA<GameRuleException>()),
        );
        expect(jsonEncode(s.toJson()), before);
      }
    },
  );

  test(
    'harem eligibility requires two resident concubines of different factions',
    () {
      final s = settlementState('haremHarmony');
      final d = chainDefinition('haremHarmony');
      final people = s.court.where((c) => c.isConsort && c.inHarem).toList();
      expect(chainEligible(s, d), true);
      people[1].faction = people[0].faction;
      expect(chainEligible(s, d), false);
      people[1].faction = 'Hoàng tộc';
      people[1].inHarem = false;
      expect(chainEligible(s, d), false);
      people[1].inHarem = true;
      people[1].queen = true;
      expect(chainEligible(s, d), false);
    },
  );

  test(
    'harem choices shift only the pinned factions immediately and bias final relationships',
    () {
      var s = settlementState('haremHarmony');
      final arc = s.chains.single;
      final ids = List<String>.of(arc.participantIds),
          factions = List<String>.of(arc.participantFactions);
      for (var i = 0; i < 4; i++) {
        final before = Map<String, int>.of(s.factions);
        final a = s.court.firstWhere((c) => c.id == ids[0]),
            b = s.court.firstWhere((c) => c.id == ids[1]);
        final affectionA = a.affection, affectionB = b.affection;
        s = settleChoice(s, '0');
        expect(s.factions[factions[0]], before[factions[0]]! + [3, 4, 5, 6][i]);
        expect(
          s.factions[factions[1]],
          before[factions[1]]! - [5, 7, 8, 10][i],
        );
        for (final key in before.keys.where((k) => !factions.contains(k))) {
          expect(s.factions[key], before[key]);
        }
        final afterA = s.court.firstWhere((c) => c.id == ids[0]),
            afterB = s.court.firstWhere((c) => c.id == ids[1]);
        expect(afterA.ability, 0);
        expect(afterB.ability, 0);
        expect(afterA.affection, affectionA + (i == 3 ? 12 : 0));
        expect(afterB.affection, affectionB + (i == 3 ? 3 : 0));
        if (i < 3) s = nextSettlementSeason(s);
      }
    },
  );

  test(
    'missing harem participant blocks funding but preserves a separate exit',
    () {
      var s = settlementState('haremHarmony');
      s = settleChoice(s, '2');
      s = nextSettlementSeason(s);
      final ids = List<String>.of(s.chains.single.participantIds);
      s.court.firstWhere((c) => c.id == ids.first).inHarem = false;
      final before = jsonEncode(s.toJson());
      expect(() => settleChoice(s, '0'), throwsA(isA<GameRuleException>()));
      expect(() => settleChoice(s, '2'), throwsA(isA<GameRuleException>()));
      expect(jsonEncode(s.toJson()), before);
      final restored = GameState.fromJson(object(jsonDecode(before)));
      settlementEngine.prepareStoryPetitions(restored);
      expect(restored.chains.single.participantIds, ids);
      s = settleChoice(restored, 'abandon');
      expect(s.chains, isEmpty);
    },
  );

  test('settlement reload and replay cannot pay or recruit twice', () async {
    for (final kind in ['market', 'exams']) {
      var s = settlementState(kind);
      for (var i = 0; i < 3; i++) {
        s = settleChoice(s, '1');
        s = nextSettlementSeason(s);
      }
      final store = MemoryGameStore();
      await store.update((a) => a.active = s);
      final gateway = LocalGameGateway(store);
      final loaded = (await gateway.load()).active!;
      final cmd = settlementCommand(
        loaded,
        'petition',
        target: loaded.petitions.singleWhere((p) => p.storyId == 'arc').id,
        option: '1',
      );
      final done = await gateway.dispatch(cmd);
      final reopened = LocalGameGateway(store);
      expect((await reopened.load()).toJson(), done.toJson());
      expect((await reopened.dispatch(cmd)).toJson(), done.toJson());
      expect(
        done.active!.outcomes.where(
          (o) => o.title == 'Quyết toán: ${chainDefinition(kind).title}',
        ),
        hasLength(1),
      );
    }
  });

  test(
    '0.18 saves keep active historical chains and paid benefits untouched',
    () async {
      final s = settlementState('market');
      s.chains = [
        StoryArc(
          id: 'old',
          kind: 'granary',
          dueWeek: 2,
          stage: 1,
          decisions: [1],
          facts: {'initialized': 1},
        ),
      ];
      s.petitions.clear();
      final raw =
          object(jsonDecode(jsonEncode(s.toJson())))
            ..['rulesVersion'] = 'mvp-0.18.0'
            ..['contentVersion'] = 17;
      final arc = (raw['chains'] as List).single as Map<String, dynamic>;
      for (final key in [
        'settlementVersion',
        'completedSteps',
        'investedValue',
        'cashSpent',
        'resourceCosts',
        'participantIds',
        'participantFactions',
      ]) {
        arc.remove(key);
      }
      final restored = GameState.fromJson(raw);
      expect(restored.chains.single.settlementVersion, 0);
      expect(chainDefinitionFor(restored.chains.single).stages, hasLength(3));
      expect(restored.chains.single.decisions, [1]);
      expect(restored.treasury, s.treasury);
      expect(restored.rng, s.rng);
      final store = MemoryGameStore();
      await store.update((a) => a.active = restored);
      final gateway = LocalGameGateway(store);
      final once = await gateway.load(), twice = await gateway.load();
      expect(once.toJson(), twice.toJson());
      expect(once.active!.chains.single.investedValue, 0);
    },
  );
}
