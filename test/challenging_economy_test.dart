import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/data/story_petitions.dart';
import 'package:van_tue/game/logic/chain_settlement_rules.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/development_rules.dart';
import 'package:van_tue/game/logic/population_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine();
  GameState fresh() =>
      engine.start('challenge', 'An', 42)
        ..petitions.clear()
        ..midSeasonDelivered = true
        ..nextChainWeek = 10000
        ..nextMajorWeek = 10000;
  GameState send(
    GameState s,
    String type, {
    String target = '',
    String option = '',
  }) => engine.execute(
    s,
    GameCommand(
      id: '${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );
  GameState reload(GameState s) =>
      GameState.fromJson(object(jsonDecode(jsonEncode(s.toJson()))));

  test(
    'new economy is persisted; historical saves and weekly games retain prices',
    () {
      final s = fresh();
      expect(s.balanceVersion, 2);
      expect(reload(s).challengingEconomy, true);
      s.pending.add(
        Consequence(
          kind: 'eventOutcome',
          dueWeek: s.week + 2,
          title: 'Cam kết đã chốt',
          effects: const {'gold': 7000},
        ),
      );
      s.chains.add(
        StoryArc(
          id: 'historical',
          kind: 'market',
          dueWeek: 3,
          settlementVersion: 1,
          currencyScale: 100,
          completedSteps: 4,
          investedValue: 22000,
        ),
      );
      final old = s.toJson()..remove('balanceVersion');
      old['rulesVersion'] = 'mvp-0.26.0';
      old['contentVersion'] = 23;
      old['scoreRules'] = 'mvp-0.26.0';
      final restored = GameState.fromJson(old);
      expect(restored.balanceVersion, 0);
      expect(restored.scoreRules, 'mvp-0.26.0');
      expect(restored.treasury, s.treasury);
      expect(restored.rng, s.rng);
      expect(restored.pending.single.toJson(), s.pending.single.toJson());
      expect(chainSettlementEffects(restored.chains.single), {'gold': 55000});
      expect(
        GameEngine(seasonal: false).start('weekly', 'An', 42).balanceVersion,
        0,
      );
      expect(
        GameEngine(
          challengeBalance: false,
        ).start('old', 'An', 42).balanceVersion,
        0,
      );
      expect(eventForState(restored, 'finance_03').choices.first.cost, 1000);
      expect(eventForState(s, 'finance_03').choices.first.cost, 2500);
    },
  );

  test(
    'all authored investments expose bounded cash returns in actual gold',
    () {
      final s = fresh();
      var count = 0;
      for (final raw in events) {
        final e = eventForState(s, raw.id);
        for (var i = 0; i < raw.choices.length; i++) {
          final economy = raw.choices[i].economy;
          if (economy == null) continue;
          count++;
          final c = e.choices[i];
          expect(c.cost, greaterThanOrEqualTo(2500));
          expect(
            c.laterEffects['gold'],
            lessThanOrEqualTo(
              (c.cost * (economy.isRecovery ? 2.2 : 1.7)).floor(),
            ),
          );
          expect(c.laterFailureEffects['gold'] ?? 0, 0);
          expect(c.currencyNative, true);
        }
      }
      expect(count, 63);
    },
  );

  test(
    'economic chain cannot use historical 250 percent yield in a new reign',
    () {
      final arc = StoryArc(
        id: 'market',
        kind: 'market',
        dueWeek: 1,
        settlementVersion: 2,
        currencyScale: 100,
        completedSteps: 4,
        investedValue: 22000,
      );
      expect(chainSettlementEffects(arc), {'gold': 30800});
      final historical = StoryArc.fromJson(arc.toJson())..settlementVersion = 1;
      expect(chainSettlementEffects(historical), {'gold': 55000});
      for (var steps = 0; steps < 4; steps++) {
        arc.completedSteps = steps;
        expect(
          chainSettlementEffects(arc)['gold'] ?? 0,
          lessThanOrEqualTo(arc.investedValue),
        );
      }
    },
  );

  test(
    'food reward is useful at population scale and settles exactly once',
    () {
      var s = fresh();
      final arc = StoryArc(
        id: 'granary',
        kind: 'granary',
        dueWeek: s.week,
        settlementVersion: 2,
        currencyScale: 100,
        completedSteps: 3,
        stage: 3,
        investedValue: 8000,
      );
      s.chains = [arc];
      engine.prepareStoryPetitions(s);
      final p = s.petitions.singleWhere((p) => p.storyId == arc.id);
      final projected = projectedChainChoice(s.chains.single, 1);
      expect(chainSettlementRewardText(s, projected), contains('600000'));
      final before = s.grain;
      s = send(s, 'petition', target: p.id, option: '1');
      expect(s.grain - before, 600000);
      expect(s.chains, isEmpty);
      expect(reload(s).grain, s.grain);
      expect(
        () => send(s, 'petition', target: p.id, option: '1'),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test(
    'major losses match preview; repeated omissions increase later costs',
    () {
      var s = fresh();
      final d = majorDefinition('db-21');
      s.major = MajorMission(
        id: 'major',
        kind: d.id,
        openedWeek: s.week,
        deadline: s.week + 3,
        severity: 2,
        preparedness: 0,
        demanding: true,
        petitionDriven: true,
        dueWeek: s.week,
        objectives: [
          for (final o in d.objectives) MissionObjective(key: o.key),
        ],
      );
      engine.prepareStoryPetitions(s);
      final e = eventForState(s, majorEventId(s.major!));
      final damage = e.choices[2].effects['food']!;
      final food = s.grain;
      final p = s.petitions.singleWhere((p) => p.storyId == 'major');
      s = send(s, 'petition', target: p.id, option: '2');
      expect(s.grain, food + damage);
      expect(s.major!.damageTaken['food'], damage);
      s = reload(s);
      expect(s.major!.damageTaken['food'], damage);
      // Compare the same next-stage quote, changing only past response history.
      s.major!.dueWeek = s.week;
      final penalized =
          eventForState(s, majorEventId(s.major!)).choices.first.cost;
      final comparison = s.copy();
      comparison.major!.decisions = [0];
      final protected =
          eventForState(
            comparison,
            majorEventId(comparison.major!),
          ).choices.first.cost;
      expect(penalized, greaterThan(protected));
      expect(penalized, (protected * 1.2).ceil());
    },
  );

  test('repairing only at harvest cannot erase earlier neglect', () {
    final timely =
        fresh()
          ..cropYear = 1
          ..springLeveePercent = 110
          ..summerLeveePercent = 110
          ..levee = 80;
    final late =
        timely.copy()
          ..springLeveePercent = 60
          ..summerLeveePercent = 60;
    // Same final levee, development, workforce, weather and seed. Only past
    // maintenance differs; its lost yield persists into the autumn harvest.
    expect(agricultureBaseYield(late), agricultureBaseYield(timely));
    expect(harvestLeveePercent(timely), 110);
    expect(harvestLeveePercent(late), 75);
    final yieldLoss = agricultureBaseYield(timely) * .35;
    expect(yieldLoss, greaterThan(populationFoodConsumption(timely)));
  });
}
