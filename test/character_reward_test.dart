import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/currency_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

Courtier lan(GameState s) => s.court.firstWhere((c) => c.id == 'consort_lan');

GameState send(
  GameEngine engine,
  GameState s,
  String option, {
  String? target,
}) => engine.execute(
  s,
  GameCommand(
    id: 'reward-${s.revision}',
    runId: s.runId,
    expectedRevision: s.revision,
    type: 'courtier',
    target: target ?? 'consort_lan',
    option: option,
  ),
);

void main() {
  const rows = [
    (0, 30, [3, 5, 8]),
    (31, 50, [2, 4, 6]),
    (51, 65, [2, 3, 4]),
    (66, 80, [1, 2, 3]),
    (81, 90, [0, 1, 2]),
    (91, 100, [0, 0, 1]),
  ];
  for (final gold in [true, false]) {
    test('reward matches every table boundary and persists, gold=$gold', () {
      final engine = GameEngine(goldEnabled: gold);
      for (final row in rows) {
        for (final affection in [row.$1, row.$2, if (row.$2 == 100) 99]) {
          for (final tier in CharacterReward.values) {
            final s = engine.start('table', 'An', 42)..treasury = 100000;
            lan(s).affection = affection;
            lan(s).discontent = 50;
            // Neither personality bonuses nor repeated favors change the table.
            lan(s).personalities
              ..clear()
              ..addAll([
                Personality.greedy,
                Personality.grateful,
                Personality.fameSeeking,
              ]);
            s.favorsThisWeek[lan(s).id] = 3;
            final gain = row.$3[tier.index].clamp(0, 100 - affection);
            final result = send(engine, s, tier.option);
            expect(lan(result).affection, affection + gain);
            expect(lan(result).discontent, 50 - gain);
            expect(
              result.treasury,
              s.treasury - money(s, [20, 40, 80][tier.index]),
            );
            expect(result.points, s.points - 1);
            expect(lan(result).influence, lan(s).influence + 2);
            expect(result.favorsThisWeek[lan(s).id], 4);
            final loaded = GameState.fromJson(result.toJson());
            expect(lan(loaded).affection, affection + gain);
            expect(
              result.financialWeeks.last.entries.last.amount,
              -tier.cost(s),
            );
            expect(lan(s).affection, affection);
          }
        }
      }
    });

    test('each tier validates funds atomically, gold=$gold', () {
      final engine = GameEngine(goldEnabled: gold);
      for (final tier in CharacterReward.values) {
        final s = engine.start('poor', 'An', 42);
        s.treasury = tier.cost(s) - 1;
        final before = s.toJson();
        expect(
          () => send(engine, s, tier.option),
          throwsA(isA<GameRuleException>()),
        );
        expect(s.toJson(), before);
        s.treasury++;
        final result = send(engine, s, tier.option);
        expect(result.treasury, 0);
        expect(result.points, s.points - 1);
        s.points = 0;
        s.treasury = 100000;
        expect(
          () => send(engine, s, tier.option),
          throwsA(isA<GameRuleException>()),
        );
      }
      final s = engine.start('invalid', 'An', 42);
      final before = s.toJson();
      expect(
        () => send(engine, s, 'reward:25'),
        throwsA(isA<GameRuleException>()),
      );
      expect(s.toJson(), before);
      expect(send(engine, s, 'reward').treasury, s.treasury - money(s, 20));
    });
  }

  test('100 is permanent for assignments, overflows and old saves', () {
    final engine = GameEngine();
    final s = engine.start('lock', 'An', 42);
    final c = lan(s)..affection = 99;
    c.affection--;
    expect(c.affection, 98);
    c.affection += 8;
    expect(c.affection, 100);
    c.affection -= 1000;
    c.affection = -100;
    expect(c.affection, 100);
    final loaded = Courtier.fromJson(c.toJson());
    loaded.affection = 1;
    expect(loaded.affection, 100);
    final old = Courtier.fromJson({...c.toJson(), 'affection': 100});
    old.affection--;
    expect(old.affection, 100);
  });

  for (final seasonal in [true, false]) {
    for (final queen in [true, false]) {
      test(
        '100 survives demotion and later seasons, seasonal=$seasonal queen=$queen',
        () {
          final engine = GameEngine(seasonal: seasonal);
          var s = engine.start('demotion', 'An', 42)..treasury = 200000;
          lan(s)
            ..affection = 99
            ..inHarem = true
            ..queen = queen;
          // Reach 100 through a real reward and persist before punishment.
          s = send(engine, s, 'reward:80').copy();
          expect(lan(s).affection, 100);
          final oldDiscontent = lan(s).discontent;
          s = send(engine, s, 'demote');
          expect(lan(s).affection, 100);
          expect(lan(s).discontent, oldDiscontent + (queen ? 30 : 20));
          expect(lan(s).queen, false);
          expect(lan(s).inHarem, queen);
          expect(s.journal.first.text, contains('Thiện cảm giữ ở 100'));
          for (var i = 0; i < 3; i++) {
            s.petitions.clear();
            s.nextMajorWeek = s.nextChainWeek = 10000;
            s = engine.execute(
              s,
              GameCommand(
                id: 'close-${s.revision}',
                runId: s.runId,
                expectedRevision: s.revision,
                type: 'endWeek',
              ),
            );
            expect(lan(s).affection, 100);
          }
        },
      );
    }
  }

  test('favoring an opposing faction cannot lower a locked relationship', () {
    final engine = GameEngine();
    var s = engine.start('opponents', 'An', 42)..treasury = 200000;
    lan(s).affection = 100;
    final opponent = s.court.firstWhere(
      (c) => c.faction == factionOpponents[lan(s).faction],
    );
    s = send(engine, s, 'reward:80', target: opponent.id);
    expect(lan(s).affection, 100);
    s = send(engine, s, 'audience', target: opponent.id);
    expect(lan(s).affection, 100);
  });
}
