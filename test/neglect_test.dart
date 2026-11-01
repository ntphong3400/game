import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState fresh([int seed = 42]) => engine.start('neglect', 'An', seed);
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

  test(
    'consecutive neglect escalates and survives save/load without a new roll',
    () {
      var s = fresh();
      s.petitions.clear();
      s = step(s, 'endWeek');
      expect(s.neglectedWeeks, 1);
      expect(s.authority, 57); // Four lost to neglect, one to routine decay.
      expect(s.journal.any((n) => n.title == 'Bỏ bê triều chính'), true);
      final restored = s.copy();
      final second = step(restored, 'endWeek');
      expect(second.neglectedWeeks, 2);
      expect(second.deltas['authority'], lessThan(-4));
      expect(second.toJson(), step(s, 'endWeek').toJson());
    },
  );

  test(
    'governing and rest allow recovery without erasing previously lost trust',
    () {
      var s = fresh();
      for (var i = 0; i < 3; i++) {
        s = step(s, 'endWeek');
      }
      final weakened = s.authority;
      s = step(s, 'action', target: 'govern');
      s = step(s, 'action', target: 'rest');
      s = step(s, 'endWeek');
      expect(s.neglectedWeeks, 0);
      expect(s.affairsThisWeek, 0);
      expect(s.authority, lessThan(62));
      expect(s.authority, greaterThanOrEqualTo(weakened));
      expect(s.ended, false);
    },
  );

  test(
    'rest, treatment and harem appointments do not count as state affairs',
    () {
      for (final action in ['rest', 'treat', 'revel']) {
        var s = step(fresh(), 'action', target: action);
        s = step(s, 'endWeek');
        expect(s.neglectedWeeks, 1, reason: action);
      }
      var s = step(
        fresh(),
        'courtier',
        target: 'consort_lan',
        option: 'invite',
      );
      s = step(s, 'courtier', target: 'consort_lan', option: 'queen');
      expect(step(s, 'endWeek').neglectedWeeks, 1);
      for (final option in ['audience', 'reward']) {
        final personal = step(
          fresh(),
          'courtier',
          target: 'consort_lan',
          option: option,
        );
        expect(step(personal, 'endWeek').neglectedWeeks, 1, reason: option);
      }
    },
  );

  test(
    'an explicit zero-point civic decision counts, automatic expiry does not',
    () {
      final start = fresh();
      final p = start.petitions.single;
      final e = eventById(p.definitionId);
      expect(e.choices.last.points, 0);
      var s = step(
        start,
        'petition',
        target: p.id,
        option: '${e.choices.length - 1}',
      );
      expect(s.affairsThisWeek, 1);
      expect(step(s, 'endWeek').neglectedWeeks, 0);
      expect(step(start, 'endWeek').neglectedWeeks, 1);
    },
  );

  test(
    'ignoring a crisis costs trust in addition to its default outcome, only once',
    () {
      final s = fresh()..affairsThisWeek = 1;
      s.petitions = [
        Petition(
          id: 'flood',
          definitionId: 'flood',
          openedWeek: 1,
          deadline: 1,
        ),
      ];
      final ignored = step(s, 'endWeek');
      final explicit = step(
        step(s, 'petition', target: 'flood', option: '2'),
        'endWeek',
      );
      expect(ignored.people, explicit.people);
      expect(ignored.authority, explicit.authority - 4);
      expect(ignored.stability, explicit.stability - 3);
      expect(
        ignored.journal.where((n) => n.title == 'Khủng hoảng bị bỏ mặc'),
        hasLength(1),
      );
      final next = step(ignored, 'endWeek');
      expect(
        next.journal.where((n) => n.title == 'Khủng hoảng bị bỏ mặc'),
        hasLength(1),
      );
    },
  );

  test(
    'repeated skipping or rest-only loses within ten weeks across seeds',
    () {
      for (var seed = 1; seed <= 20; seed++) {
        for (final restOnly in [false, true]) {
          var s = fresh(seed);
          var turns = 0;
          while (!s.ended && turns < 10) {
            if (restOnly) {
              for (var i = 0; i < 3; i++) {
                s = step(s, 'action', target: 'rest');
              }
            }
            s = step(s, 'endWeek');
            turns++;
          }
          expect(s.ended, true, reason: 'seed $seed, rest=$restOnly');
          expect(turns, greaterThanOrEqualTo(3));
          expect(s.completedWeeks, turns - 1);
          expect(s.endReason, isNotEmpty);
        }
      }
    },
  );

  test(
    'there is no fixed short reign limit when attending to state affairs',
    () {
      var s = fresh();
      for (var i = 0; i < 12 && !s.ended; i++) {
        s = step(s, 'action', target: 'govern');
        s = step(s, 'action', target: 'rest');
        s = step(s, 'action', target: i % 2 == 0 ? 'security' : 'rest');
        s = step(s, 'endWeek');
      }
      expect(s.ended, false);
      expect(s.completedWeeks, 12);
      expect(s.neglectedWeeks, 0);
    },
  );
}
