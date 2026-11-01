import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/logic/court_politics_rules.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine();

  GameState scenario(
    int affection, {
    required bool senior,
    int loyalty = 50,
    int ambition = 80,
  }) {
    final s = engine.start('politics-timing', 'An', 42);
    final c = s.court.first;
    s.court = [c];
    c.role = senior ? 'Tể tướng' : 'Tri phủ';
    c.age = 25;
    c.loyalty = loyalty;
    c.ambition = ambition;
    c.affection = c.baseAffection = affection;
    c.discontent = (40 - affection).clamp(0, 100);
    c.plot = c.strain = 0;
    c.influence = 100;
    c.personalities
      ..clear()
      ..addAll([Personality.grateful, Personality.diplomatic]);
    s.nextMajorWeek = s.nextChainWeek = 10000;
    return s;
  }

  // Hold the stated external conditions steady; the actual engine evolves
  // discontent, loyalty and plot progress, including their order of resolution.
  GameState close(GameState s, int affection, int mood) {
    final c = s.court.first;
    c.affection = c.baseAffection = affection;
    c.strain = 0;
    s.factions.updateAll((key, value) => 50);
    s.factions[c.faction] = mood;
    s.authority = s.stability = 50;
    s.people = s.army = 80;
    s.health = 30;
    s.treasury = 10000;
    s.grain = 200;
    s.debt = s.neglectedWeeks = 0;
    s.fatigue = s.stress = s.illness = s.indulgence = 0;
    s.workThisWeek = s.affairsThisWeek = 1;
    s.restThisWeek = s.revelThisWeek = 0;
    s.petitions.clear();
    s.midSeasonDelivered = true;
    // The political roll succeeds with or without autumn's preceding harvest.
    s.rng = 10;
    return engine.execute(
      s,
      GameCommand(
        id: 'timing-${s.revision}',
        runId: s.runId,
        expectedRevision: s.revision,
        type: 'endWeek',
      ),
    );
  }

  for (final (affection, mood, lowTurn, highTurn) in [
    (30, 50, 20, 18),
    (20, 50, 13, 12),
    (30, 28, 13, 12),
    (20, 28, 11, 10),
  ]) {
    for (final senior in [false, true]) {
      test(
        'relations $affection/$mood reach action in 2–5 years, senior=$senior',
        () {
          var s = scenario(affection, senior: senior);
          final expectedTurn = senior ? highTurn : lowTurn;
          var warned = false;
          for (var turn = 1; turn <= expectedTurn; turn++) {
            s = close(s, affection, mood);
            expect(s.authority, greaterThan(40));
            expect(s.stability, greaterThan(40));
            if (!s.ended && s.court.first.plot >= 30) warned = true;
            expect(s.ended, turn == expectedTurn, reason: 'season $turn');
          }
          expect(warned, true);
          expect(s.endKind, senior ? 'coup' : 'poisoning');
          expect(expectedTurn, inInclusiveRange(8, 20));
          expect(s.completedWeeks, expectedTurn - 1);
        },
      );
    }
  }

  test(
    'an extreme initial traitor reaches a coup in eight seasons, with earlier warning',
    () {
      var s = scenario(20, senior: true, loyalty: 0, ambition: 100);
      for (var turn = 1; turn <= 8; turn++) {
        s = close(s, 20, 28);
        expect(s.ended, turn == 8);
        if (turn == 4) expect(s.court.first.plot, greaterThanOrEqualTo(30));
      }
      expect(s.endKind, 'coup');
    },
  );

  for (final senior in [false, true]) {
    test(
      'good relations do not create a plot over six years, senior=$senior',
      () {
        var s = scenario(50, senior: senior);
        for (var turn = 1; turn <= 24; turn++) {
          s = close(s, 50, 50);
          expect(s.ended, false);
          expect(s.court.first.discontent, 0);
          expect(s.court.first.plot, 0);
        }
      },
    );
  }

  test(
    'seasonal pressure accelerates while calming and legacy weekly rates stay unchanged',
    () {
      final s = scenario(20, senior: true);
      final c = s.court.first;
      s.factions[c.faction] = 28;
      expect(discontentChange(s, c), 21);
      s.seasonal = false;
      expect(discontentChange(s, c), 7);
      c.discontent = 80;
      expect(plotProgressPerTurn(s, c), 3);
      s.seasonal = true;
      expect(plotProgressPerTurn(s, c), 7);
      c.affection = 50;
      s.factions[c.faction] = 50;
      expect(discontentChange(s, c), -2);
    },
  );

  test(
    'a 0.15.0 save retains progress and applies the faster rate only on closing',
    () {
      final s = scenario(20, senior: true);
      s.court.first.discontent = 40;
      s.court.first.plot = 12;
      final raw =
          s.toJson()
            ..['rulesVersion'] = 'mvp-0.15.0'
            ..remove('scoreRules');
      final loaded = GameState.fromJson(raw);
      expect(loaded.court.first.discontent, 40);
      expect(loaded.court.first.plot, 12);
      expect(loaded.rng, s.rng);
      expect(loaded.scoreRules, 'mvp-0.15.0');
      final result = close(loaded, 20, 28);
      expect(result.court.first.discontent, 61);
      expect(result.court.first.plot, greaterThan(12));
      expect(result.scoreRules, 'mvp-0.15.0');
      expect(result.copy().toJson(), result.toJson());
    },
  );
}
