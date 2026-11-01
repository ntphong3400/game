import 'package:flutter_test/flutter_test.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState fresh() => engine.start('ending', 'An', 42);
  GameState next(GameState s, {String type = 'endWeek', String target = ''}) =>
      engine.execute(
        s,
        GameCommand(
          id: 'cmd-${s.revision}',
          runId: s.runId,
          expectedRevision: s.revision,
          type: type,
          target: target,
        ),
      );
  GameState plot(String actorId) {
    final s = fresh();
    final actor = s.court.firstWhere((c) => c.id == actorId);
    actor.loyalty = 0;
    actor.ambition = actor.role == 'Thân vương' ? 100 : 40;
    actor.discontent = 100;
    actor.influence = 100;
    actor.plot = 70;
    s.court = [actor];
    s.rng = 1;
    s.authority = 20;
    return s;
  }

  test(
    'fatal poisoning identifies the attacker and faction before a simultaneous invasion',
    () {
      final s =
          plot('duke')
            ..health = 30
            ..war = 8
            ..siege = 3
            ..army = 4;
      final result = next(s);
      expect(result.endKind, 'poisoning');
      expect(result.endReason, contains('Đặng Quốc Hưng (phe Thế gia)'));
      expect(result.endReason, contains('mưu sát'));
      expect(result.health, 0);
      expect(result.completedWeeks, 0);
      expect(result.copy().endReason, result.endReason);
    },
  );

  test('coup identifies the actual usurper and their faction', () {
    final result = next(plot('prince'));
    expect(result.endKind, 'coup');
    expect(result.endReason, contains('Hoàng Minh Viễn (phe Hoàng tộc)'));
    expect(result.endReason, contains('phế truất'));
    expect(result.completedWeeks, 0);
  });

  test('invasion explains loss of the capital and country', () {
    final s =
        fresh()
          ..war = 8
          ..siege = 3
          ..army = 0;
    for (final c in s.court) {
      c.plot = 0;
      c.loyalty = 100;
      c.ambition = 0;
    }
    final result = next(s);
    expect(result.endKind, 'invasion');
    expect(result.endReason, contains('ngoại xâm'));
    expect(result.endReason, contains('đất nước rơi vào tay quân địch'));
    expect(result.completedWeeks, 0);
  });

  test(
    'health failure takes precedence over plots after the king has already died',
    () {
      final s =
          plot('duke')
            ..health = 1
            ..fatigue = 100
            ..stress = 95
            ..workThisWeek = 3;
      final result = next(s);
      expect(result.endKind, 'exhaustion');
      expect(result.endReason, contains('làm việc quá độ'));
      expect(result.journal.any((e) => e.title == 'Một vụ đầu độc'), false);
    },
  );

  test(
    'poisoning attribution survives save/load and later death from its illness',
    () {
      final poisoned = next(plot('duke')..health = 40);
      expect(poisoned.ended, false);
      expect(poisoned.illnessSource, 'Đặng Quốc Hưng (phe Thế gia)');
      final restored = poisoned.copy()..health = 1;
      final result = next(restored);
      expect(result.endKind, 'poisoning');
      expect(result.endReason, contains('Đặng Quốc Hưng (phe Thế gia)'));
      expect(result.endReason, contains('Di chứng'));
    },
  );

  test(
    'curing poison clears attribution so an unrelated later death is not blamed on it',
    () {
      var s = next(plot('duke')..health = 40);
      s = next(s, type: 'action', target: 'treat');
      // This fixture has no physician, so several low-effect treatments are needed.
      s = next(s, type: 'action', target: 'treat');
      s = next(s, type: 'action', target: 'treat');
      expect(s.illness, 0);
      expect(s.illnessSource, isNull);
      s.health = 1;
      s.fatigue = 100;
      final result = next(s);
      expect(result.endKind, 'exhaustion');
      expect(result.endReason, isNot(contains('Đặng Quốc Hưng')));
    },
  );

  test('cause fields are optional when loading a current-rules snapshot', () {
    final json =
        fresh().toJson()
          ..remove('endKind')
          ..remove('illnessSource');
    json['endReason'] = 'Kinh thành thất thủ. Vương quốc mất chủ quyền.';
    final restored = GameState.fromJson(json);
    expect(restored.ended, true);
    expect(restored.endKind, isNull);
    expect(restored.endReason, json['endReason']);
  });

  for (final stat in ['people', 'army', 'health']) {
    final rescue = switch (stat) {
      'people' => 'relief',
      'army' => 'train',
      _ => 'treat',
    };
    test('$stat at zero ends before another rescue action can be applied', () {
      final s = fresh();
      switch (stat) {
        case 'people':
          s.people = 0;
        case 'army':
          s.army = 0;
        case 'health':
          s.health = 0;
      }
      final result = next(s.copy(), type: 'action', target: rescue);
      expect(result.endKind, switch (stat) {
        'people' => 'rebellion',
        'army' => 'armyCollapse',
        _ => 'exhaustion',
      });
      expect(result.points, s.points);
      expect(result.treasury, s.treasury);
      expect(result.completedWeeks, 0);
      expect(result.copy().endReason, result.endReason);
    });
    test('$stat above zero can still be rescued', () {
      final s = fresh();
      switch (stat) {
        case 'people':
          s.people = 1;
        case 'army':
          s.army = 1;
        case 'health':
          s.health = 1;
      }
      final result = next(s, type: 'action', target: rescue);
      expect(result.ended, false);
      expect(switch (stat) {
        'people' => result.people,
        'army' => result.army,
        _ => result.health,
      }, greaterThan(1));
    });
  }

  test('zero support loses even with a full army and strong court', () {
    final s =
        fresh()
          ..people = 1
          ..army = 100
          ..authority = 100
          ..stability = 100
          ..tax = 2
          ..workThisWeek = 1
          ..affairsThisWeek = 1;
    s.petitions.clear();
    final result = next(s);
    expect(result.people, 0);
    expect(result.army, greaterThan(90));
    expect(result.endKind, 'rebellion');
    expect(result.endReason, contains('Lòng dân đã giảm về 0'));
    expect(result.completedWeeks, 0);
  });

  for (final war in [0, 8]) {
    test(
      'army reaches zero during ${war == 0 ? 'peace' : 'war'} and ends that week',
      () {
        final s =
            fresh()
              ..army = 1
              ..war = war
              ..workThisWeek = 1
              ..affairsThisWeek = 1;
        s.petitions.clear();
        final result = next(s);
        expect(result.army, 0);
        expect(result.endKind, war == 0 ? 'armyCollapse' : 'invasion');
        expect(result.endReason, contains('Quân lực đã giảm về 0'));
        expect(result.completedWeeks, 0);
      },
    );
  }

  for (final event in ['petition_tax', 'army_pay']) {
    test('$event can cause immediate defeat between weeks', () {
      final s =
          fresh()
            ..people = 1
            ..army = 1;
      s.petitions = [
        Petition(id: 'last', definitionId: event, openedWeek: 1, deadline: 2),
      ];
      final result = engine.execute(
        s,
        GameCommand(
          id: 'decision',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'petition',
          target: 'last',
          option: '1',
        ),
      );
      expect(
        result.endKind,
        event == 'petition_tax' ? 'rebellion' : 'armyCollapse',
      );
      expect(result.completedWeeks, 0);
      expect(() => next(result), throwsA(isA<GameRuleException>()));
    });
  }

  test('zero stability loses despite full authority, army and health', () {
    final s =
        fresh()
          ..stability = 2
          ..authority = 100
          ..army = 100
          ..health = 100
          ..completedWeeks = 10;
    s.petitions.clear();
    final result = next(s);
    expect(result.endKind, 'courtCollapse');
    expect(result.stability, 0);
    expect(result.authority, greaterThan(80));
    expect(result.army, greaterThan(80));
    expect(result.health, 100);
    expect(result.completedWeeks, 10);
    expect(result.endReason, contains('Ổn định triều đình đã giảm về 0'));
    expect(result.endReason, contains('thoái vị'));
  });

  test(
    'a paid replacement that collapses court ends immediately between weeks',
    () {
      final s = fresh()..stability = 1;
      final result = engine.execute(
        s,
        GameCommand(
          id: 'dismiss',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'appoint',
          target: 'chancellor',
          option: s.officialsPool.first.id,
        ),
      );
      expect(result.endKind, 'courtCollapse');
      expect(result.stability, 0);
      expect(result.completedWeeks, 0);
      expect(result.points, 2);
      expect(() => next(result), throwsA(isA<GameRuleException>()));
      expect(result.copy().endReason, result.endReason);
    },
  );

  test(
    'a saved zero-stability court cannot be revived by one governance action',
    () {
      final s = fresh()..stability = 0;
      final result = next(s.copy(), type: 'action', target: 'govern');
      expect(result.endKind, 'courtCollapse');
      expect(result.stability, 0);
      expect(result.authority, s.authority);
      expect(result.points, s.points);
      expect(result.fatigue, s.fatigue);
      expect(result.completedWeeks, 0);
    },
  );

  test('positive stability is still recoverable and does not force a loss', () {
    var s = fresh()..stability = 1;
    s.petitions.clear();
    s = next(s, type: 'action', target: 'govern');
    expect(s.stability, 2);
    s = next(s);
    expect(s.ended, false);
    expect(s.completedWeeks, 1);
  });

  for (final seasonal in [false, true]) {
    final rules = GameEngine(seasonal: seasonal);
    GameState command(
      GameState s,
      String type, {
      String target = '',
      String option = '',
    }) => rules.execute(
      s,
      GameCommand(
        id: 'puppet-${s.revision}',
        runId: s.runId,
        expectedRevision: s.revision,
        type: type,
        target: target,
        option: option,
      ),
    );

    test(
      'zero or negative authority cannot be rescued, seasonal=$seasonal',
      () {
        for (final authority in [0, -1]) {
          final s =
              rules.start('puppet', 'An', 42)
                ..authority = authority
                ..stability = 100
                ..people = 100
                ..army = 100
                ..health = 100;
          final result = command(s.copy(), 'action', target: 'govern');
          expect(result.endKind, 'puppet');
          expect(result.endReason, contains('bù nhìn'));
          expect(result.points, s.points);
          expect(result.treasury, s.treasury);
          expect(result.fatigue, s.fatigue);
          expect(result.completedWeeks, 0);
          expect(result.copy().endKind, 'puppet');
          expect(result.copy().endReason, result.endReason);
          expect(
            () => command(result, 'endWeek'),
            throwsA(isA<GameRuleException>()),
          );
        }
      },
    );

    test('a petition can end authority immediately, seasonal=$seasonal', () {
      final s = rules.start('puppet-petition', 'An', 42)..authority = 1;
      s.petitions = [
        Petition(
          id: 'warning',
          definitionId: 'plot_warning',
          openedWeek: 1,
          deadline: 2,
        ),
      ];
      final result = command(s, 'petition', target: 'warning', option: '1');
      expect(result.authority, 0);
      expect(result.stability, greaterThan(25));
      expect(result.endKind, 'puppet');
      expect(result.completedWeeks, 0);
    });

    test(
      'neglect ends authority before an active plot, seasonal=$seasonal',
      () {
        final s = rules.start('puppet-neglect', 'An', 42)..authority = 1;
        final actor = s.court.firstWhere((c) => c.id == 'duke');
        actor.loyalty = 0;
        actor.ambition = 100;
        actor.plot = 70;
        s.petitions.clear();
        final result = command(s, 'endWeek');
        expect(result.endKind, 'puppet');
        expect(result.stability, greaterThan(25));
        expect(result.completedWeeks, 0);
        expect(result.journal.any((e) => e.title == 'Một vụ đầu độc'), false);
      },
    );

    test('positive authority can still be restored, seasonal=$seasonal', () {
      final s = rules.start('restore-authority', 'An', 42)..authority = 1;
      final result = command(s, 'action', target: 'govern');
      expect(result.ended, false);
      expect(result.authority, greaterThan(1));
    });
  }

  test('health and court collapse take precedence over zero authority', () {
    expect(
      next(
        fresh()
          ..health = 0
          ..authority = 0,
      ).endKind,
      'exhaustion',
    );
    expect(
      next(
        fresh()
          ..stability = 0
          ..authority = 0,
      ).endKind,
      'courtCollapse',
    );
    expect(
      next(
        fresh()
          ..authority = 0
          ..people = 0
          ..army = 0,
      ).endKind,
      'puppet',
    );
  });

  test('0.14.0 saves retain progress and use the new authority ending', () {
    final s =
        fresh()
          ..authority = 0
          ..completedWeeks = 10;
    final json =
        s.toJson()
          ..['rulesVersion'] = 'mvp-0.14.0'
          ..remove('scoreRules');
    final restored = GameState.fromJson(json);
    expect(restored.completedWeeks, 10);
    expect(restored.scoreRules, 'mvp-0.14.0');
    final result = next(restored, type: 'action', target: 'govern');
    expect(result.endKind, 'puppet');
    expect(result.completedWeeks, 10);
  });

  test('court collapse stops a plot that has not yet been carried out', () {
    final s = plot('duke')..stability = 1;
    final result = next(s);
    expect(result.endKind, 'courtCollapse');
    expect(result.journal.any((e) => e.title == 'Một vụ đầu độc'), false);
  });

  test(
    'fatal health takes precedence when health and court fail in the same week',
    () {
      final s =
          fresh()
            ..stability = 1
            ..health = 1
            ..illness = 100;
      final result = next(s);
      expect(result.stability, 0);
      expect(result.health, 0);
      expect(result.endKind, 'illness');
      expect(
        result.journal.where((e) => e.title == 'Triều đại khép lại'),
        hasLength(1),
      );
    },
  );
}
