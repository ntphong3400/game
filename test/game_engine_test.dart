import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState fresh([int seed = 42]) =>
      engine.start('run', 'Vua thử nghiệm', seed);
  GameState step(
    GameState s,
    String type, {
    String target = '',
    String option = '',
  }) => engine.execute(
    s,
    GameCommand(
      id: 'cmd-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );

  test('a failed action does not mutate state or advance random', () {
    final s = fresh()..treasury = 0;
    final before = jsonEncode(s.toJson());
    expect(
      () => step(s, 'action', target: 'repair', option: 'governor'),
      throwsA(isA<GameRuleException>()),
    );
    expect(jsonEncode(s.toJson()), before);
  });

  test('seed and restored random state reproduce a multiweek game exactly', () {
    var a = fresh();
    var b = GameState.fromJson(object(jsonDecode(jsonEncode(a.toJson()))));
    for (var week = 0; week < 30 && !a.ended; week++) {
      for (final action in ['govern', 'rest', 'relief']) {
        if (action == 'relief' && (a.treasury < 20 || a.grain < 25)) continue;
        a = step(a, 'action', target: action);
        b = step(b, 'action', target: action);
      }
      a = step(a, 'endWeek');
      b = step(b, 'endWeek');
      b = GameState.fromJson(object(jsonDecode(jsonEncode(b.toJson()))));
      expect(b.toJson(), a.toJson());
    }
  });

  test('historical weekly saves retain their rest and recreation recovery', () {
    final s =
        fresh()
          ..fatigue = 70
          ..stress = 100;
    s.petitions.clear();
    final baseline = step(s, 'endWeek');
    final rested = step(step(s, 'action', target: 'rest'), 'endWeek');
    final entertained = step(step(s, 'action', target: 'revel'), 'endWeek');
    expect(rested.fatigue, baseline.fatigue - 19);
    expect(rested.stress, baseline.stress - 8);
    expect(entertained.fatigue, baseline.fatigue);
    expect(entertained.stress, baseline.stress - 9);
  });

  test('weekly treatment also restores fatigue without adding work', () {
    final s =
        fresh()
          ..health = 60
          ..illness = 40
          ..fatigue = 70
          ..stress = 55
          ..workThisWeek = 1;
    s.petitions.clear();
    final result = step(s, 'action', target: 'treat');
    expect(result.health, 62);
    expect(result.illness, 24);
    expect(result.fatigue, 58);
    expect(result.workThisWeek, 1);
    final baseline = step(s, 'endWeek');
    final closed = step(result, 'endWeek');
    expect(closed.fatigue, baseline.fatigue - 12);
    expect(closed.stress, baseline.stress);
  });

  test('moderate recreation heals but excess recreation harms health', () {
    var moderate = fresh()..health = 60;
    moderate = step(moderate, 'action', target: 'revel');
    moderate = step(moderate, 'endWeek');
    expect(moderate.health, greaterThan(60));
    var excess = fresh()..health = 60;
    for (var i = 0; i < 3; i++) {
      excess = step(excess, 'action', target: 'revel');
    }
    excess = step(excess, 'endWeek');
    expect(excess.health, lessThan(60));
    expect(excess.healthReport, contains('hưởng lạc quá mức'));
  });

  test('repeated indulgence stops healing and persists across save/load', () {
    var s = fresh()..health = 60;
    for (var i = 0; i < 8; i++) {
      s = step(s, 'action', target: 'revel');
      s = step(s, 'action', target: 'govern');
      s = step(s, 'endWeek');
    }
    expect(s.indulgence, greaterThan(5));
    expect(s.healthReport, contains('hưởng lạc quá mức'));
    final restored = GameState.fromJson(
      object(jsonDecode(jsonEncode(s.toJson()))),
    );
    expect(restored.indulgence, s.indulgence);
  });

  test('overwork is harmful and fatigue accumulates across weeks', () {
    var s = fresh()..health = 90;
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 3; j++) {
        s = step(s, 'action', target: 'govern');
      }
      s = step(s, 'endWeek');
    }
    expect(s.health, lessThan(90));
    expect(s.fatigue, greaterThan(50));
    expect(s.healthReport, contains('làm việc quá độ'));
  });

  test('overtime is limited and stacks with excessive revelry', () {
    var s = fresh()..health = 80;
    expect(() => step(s, 'overtime'), throwsA(isA<GameRuleException>()));
    for (var i = 0; i < 3; i++) {
      s = step(s, 'action', target: 'revel');
    }
    s = step(s, 'overtime');
    s = step(s, 'action', target: 'govern');
    expect(() => step(s, 'overtime'), throwsA(isA<GameRuleException>()));
    s = step(s, 'endWeek');
    expect(s.healthReport, contains('hưởng lạc quá mức'));
    expect(s.healthReport, contains('làm việc quá độ'));
  });

  test('failed week is not scored; successful year rolls over at 52 weeks', () {
    var s = fresh()..completedWeeks = 51;
    s = step(s, 'endWeek');
    expect(s.completedWeeks, 52);
    expect(s.age, 19);
    expect(s.duration, '1 năm 0 tuần');
    var doomed =
        fresh()
          ..completedWeeks = 51
          ..health = 1
          ..illness = 100;
    doomed = step(doomed, 'endWeek');
    expect(doomed.ended, true);
    expect(doomed.completedWeeks, 51);
    expect(() => step(doomed, 'endWeek'), throwsA(isA<GameRuleException>()));
  });

  test('scheduled results execute after the advertised number of weeks', () {
    var s = fresh();
    s.pending.add(Consequence(kind: 'weapons', dueWeek: s.week + 3));
    for (var i = 0; i < 3; i++) {
      s = step(s, 'endWeek');
    }
    expect(s.pending.any((p) => p.kind == 'weapons'), true);
    s = step(s, 'endWeek');
    expect(s.pending.any((p) => p.kind == 'weapons'), false);
    expect(s.journal.any((n) => n.title == 'Quân khí đã tới'), true);
    var diplomat = fresh();
    diplomat = step(diplomat, 'action', target: 'diplomacy');
    for (var i = 0; i < 2; i++) {
      diplomat = step(diplomat, 'endWeek');
    }
    expect(diplomat.pending.any((p) => p.kind == 'envoy'), true);
    diplomat = step(diplomat, 'endWeek');
    expect(diplomat.pending.any((p) => p.kind == 'envoy'), false);
  });

  test('event eligibility observes season, state and cooldown', () {
    final s = fresh();
    expect(engine.eligible(s, eventById('flood')), false);
    s.completedWeeks = 13;
    s.levee = 10;
    expect(engine.eligible(s, eventById('flood')), true);
    s.cooldowns['flood'] = s.week + 3;
    expect(engine.eligible(s, eventById('flood')), false);
    s.grain = 10;
    expect(engine.eligible(s, eventById('hunger')), true);
  });

  test('expired petitions apply default consequence once', () {
    var s = fresh();
    s.affairsThisWeek = 1; // Isolate the petition from separate neglect losses.
    s.petitions.clear();
    s.petitions.add(
      Petition(
        id: 'tax',
        definitionId: 'petition_tax',
        openedWeek: 1,
        deadline: 1,
      ),
    );
    final before = s.people;
    s = step(s, 'endWeek');
    expect(s.people, before - 7);
    expect(s.petitions.any((p) => p.id == 'tax'), false);
  });

  test(
    'projects require a living official and complete through weekly progress',
    () {
      var s = fresh();
      expect(
        () => step(s, 'action', target: 'repair', option: 'consort_lan'),
        throwsA(isA<GameRuleException>()),
      );
      s = step(s, 'action', target: 'repair', option: 'governor');
      expect(s.projects, hasLength(1));
      expect(
        () => step(s, 'action', target: 'repair', option: 'governor'),
        throwsA(isA<GameRuleException>()),
      );
      for (var i = 0; i < 4; i++) {
        // Exercise successful completion explicitly, independent of roster RNG.
        // Failure branches are covered by personnel_test.dart.
        if (i == 3) s.rng = 100;
        s = step(s, 'endWeek');
      }
      expect(s.projects, isEmpty);
      expect(s.journal.any((n) => n.title == 'Đê điều được tu bổ'), true);
    },
  );

  test('harem selection and queen appointment persist and are exclusive', () {
    var s = fresh();
    s = step(s, 'courtier', target: 'consort_lan', option: 'invite');
    s = step(s, 'courtier', target: 'consort_lan', option: 'queen');
    expect(s.court.where((c) => c.queen).single.id, 'consort_lan');
    expect(s.court.firstWhere((c) => c.id == 'consort_lan').inHarem, true);
    expect(s.copy().court.where((c) => c.queen), hasLength(1));
  });

  test('all event defaults are affordable and all event IDs are unique', () {
    expect(events.length, greaterThanOrEqualTo(40));
    expect(events.map((e) => e.id).toSet().length, events.length);
    for (final e in events) {
      expect(e.choices.last.cost, 0, reason: e.id);
      // Recruitment decisions already require one action in the current rules.
      expect(
        e.choices.last.points,
        e.id == 'consort_recommendation' ? 1 : 0,
        reason: e.id,
      );
    }
  });

  test('scoreboard preserves only personal bests and competition ties', () {
    final scores = rankedScores([
      ScoreEntry('1', 'An', 100),
      ScoreEntry('2', 'Bình', 90),
      ScoreEntry('3', 'Chi', 90),
      ScoreEntry('4', 'Dũng', 80),
      ScoreEntry('5', 'AN', 70),
      ScoreEntry('6', 'Old', 999, rules: 'old'),
    ]);
    expect(scores.map((s) => s.rank), [1, 2, 2, 4]);
    expect(scores.map((s) => s.score.weeks), [100, 90, 90, 80]);
  });
}
