import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';

Courtier person(GameState s) =>
    s.court.firstWhere((c) => c.id == 'consort_lan');

GameCommand command(GameState s, String option) => GameCommand(
  id: 'snapshot-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type:
      option == 'investigate' && s.hasCourtSystem ? 'investigate' : 'courtier',
  target: 'consort_lan',
  option:
      option == 'investigate' && s.hasCourtSystem
          ? jsonEncode({
            'spy': s.court.firstWhere((c) => c.role == 'Mật thám').id,
            'funding': 20,
          })
          : option,
);

GameCommand closeCommand(GameState s) => GameCommand(
  id: 'close-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: 'endWeek',
);

GameState close(GameEngine engine, GameState s) {
  s.petitions.clear();
  s.nextMajorWeek = s.nextChainWeek = 10000;
  return engine.execute(s, closeCommand(s));
}

Consequence pending(GameState s) =>
    s.pending.singleWhere((p) => p.kind == 'investigate');

void main() {
  for (final mode in [(true, false), (false, false)]) {
    final (seasonal, gold) = mode;
    test(
      'captured intelligence stays hidden until completion and survives reload/replay seasonal=$seasonal gold=$gold',
      () async {
        final engine = GameEngine(seasonal: seasonal, goldEnabled: gold);
        final s = engine.start('snapshot', 'An', 42);
        person(s)
          ..plot = 43
          ..discontent = 67
          ..affection = 40;
        s.treasury = gold ? 100000 : 1000;
        s.petitions.clear();
        s.nextMajorWeek = s.nextChainWeek = 10000;
        final store = MemoryGameStore();
        await store.update((a) => a.active = s);
        final gateway = LocalGameGateway(store, engine: engine);
        final request = command(s, 'investigate');
        final committed = await gateway.dispatch(request);
        var state = committed.active!;
        expect(state.treasury, s.treasury - (gold ? 2000 : 20));
        expect(state.points, s.points - 1);
        expect(person(state).lastInvestigation, isNull);
        final captured = {'week': s.week, 'plot': 43, 'discontent': 67};
        expect(pending(state).investigation!.toJson(), captured);
        expect(state.journal.first.text, isNot(contains('43/100')));
        expect(state.journal.first.text, isNot(contains('67/100')));
        expect((await gateway.dispatch(request)).toJson(), committed.toJson());

        state = (await gateway.dispatch(command(state, 'reward'))).active!;
        expect(person(state).discontent, lessThan(67));
        expect(person(state).lastInvestigation, isNull);
        expect(pending(state).investigation!.toJson(), captured);
        state = (await gateway.load()).active!;
        expect(person(state).lastInvestigation, isNull);
        expect(pending(state).investigation!.toJson(), captured);

        await store.update((a) {
          person(a.active!)
            ..plot = 18
            ..discontent = 35;
        });
        state = (await gateway.load()).active!;
        state = (await gateway.dispatch(closeCommand(state))).active!;
        expect(person(state).lastInvestigation, isNull);
        expect(pending(state).investigation!.toJson(), captured);
        final finish = closeCommand(state);
        final completed = await gateway.dispatch(finish);
        state = completed.active!;
        expect(person(state).lastInvestigation!.toJson(), captured);
        expect(state.pending.where((p) => p.kind == 'investigate'), isEmpty);
        expect(
          state.outcomes.any(
            (o) => o.detail.contains('Âm mưu 43/100, bất mãn 67/100'),
          ),
          true,
        );
        expect((await gateway.dispatch(finish)).toJson(), completed.toJson());
        expect(
          person((await gateway.load()).active!).lastInvestigation!.toJson(),
          captured,
        );

        // Starting another investigation retains the old published result.
        person(state)
          ..plot = 18
          ..discontent = 35;
        state = engine.execute(state, command(state, 'investigate'));
        expect(person(state).lastInvestigation!.toJson(), captured);
        final nextCapture = pending(state).investigation!.toJson();
        expect(nextCapture, {'week': state.week, 'plot': 18, 'discontent': 35});
        state = close(engine, state.copy());
        expect(person(state).lastInvestigation!.toJson(), captured);
        state = close(engine, state.copy());
        expect(person(state).lastInvestigation!.toJson(), nextCapture);
        state = close(engine, state);
        expect(person(state).lastInvestigation!.toJson(), nextCapture);
      },
    );
  }

  test(
    'old saves and pending reports never invent intelligence from live stats',
    () {
      final engine = GameEngine();
      for (final hasPrevious in [false, true]) {
        var s = engine.start('old', 'An', 42)..treasury = 100000;
        final previous =
            hasPrevious
                ? const CharacterInvestigation(
                  week: 1,
                  plot: 12,
                  discontent: 23,
                )
                : null;
        person(s)
          ..investigated = true
          ..plot = 58
          ..discontent = 79
          ..lastInvestigation = previous;
        s.pending.add(
          Consequence(
            kind: 'investigate',
            dueWeek: s.week,
            target: person(s).id,
          ),
        );
        s = GameState.fromJson(s.toJson());
        expect(pending(s).investigation, isNull);
        s = close(engine, s);
        expect(person(s).lastInvestigation?.toJson(), previous?.toJson());
      }
    },
  );

  test(
    'legacy in-flight results return to pending storage until completion',
    () {
      final engine = GameEngine();
      final old = engine.start('early-result', 'An', 42)..treasury = 100000;
      const captured = CharacterInvestigation(
        week: 1,
        plot: 43,
        discontent: 67,
      );
      person(old).lastInvestigation = captured;
      old.pending.add(
        Consequence(kind: 'investigate', dueWeek: 2, target: person(old).id),
      );
      final raw = old.toJson();
      var loaded = GameState.fromJson(raw);
      expect(person(loaded).lastInvestigation, isNull);
      expect(pending(loaded).investigation!.toJson(), captured.toJson());
      // Loading neither mutates the source save nor consumes RNG.
      expect(
        (raw['court'] as List)
            .where((c) => c['id'] == person(old).id)
            .single['lastInvestigation'],
        captured.toJson(),
      );
      expect(loaded.rng, old.rng);
      loaded = loaded.copy();
      expect(person(loaded).lastInvestigation, isNull);
      loaded = close(engine, loaded);
      expect(person(loaded).lastInvestigation, isNull);
      loaded = close(engine, loaded);
      expect(person(loaded).lastInvestigation!.toJson(), captured.toJson());
    },
  );

  test('interrupted investigations do not publish captured intelligence', () {
    final engine = GameEngine();
    var s = engine.start('interrupted', 'An', 42)..treasury = 100000;
    s = engine.execute(s, command(s, 'investigate'));
    person(s).available = false;
    s = close(engine, close(engine, s));
    expect(person(s).lastInvestigation, isNull);
    expect(s.pending.where((p) => p.kind == 'investigate'), isEmpty);
    expect(s.outcomes.any((o) => o.status == 'interrupted'), true);
  });

  test(
    'duplicate and unaffordable investigations cannot capture or spend again',
    () {
      final engine = GameEngine();
      var s = engine.start('poor', 'An', 42)..treasury = 1999;
      var before = s.toJson();
      expect(
        () => engine.execute(s, command(s, 'investigate')),
        throwsA(isA<GameRuleException>()),
      );
      expect(s.toJson(), before);
      expect(person(s).lastInvestigation, isNull);
      s.treasury = 100000;
      s = engine.execute(s, command(s, 'investigate'));
      before = s.toJson();
      expect(
        () => engine.execute(s, command(s, 'investigate')),
        throwsA(isA<GameRuleException>()),
      );
      expect(s.toJson(), before);
    },
  );
}
