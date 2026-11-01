import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState fresh() => engine.start('personnel', 'An', 42);
  GameState send(
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
  Courtier person(GameState s, String id) =>
      s.court.firstWhere((c) => c.id == id);
  // Invert the first LCG roll modulo 100 without bypassing engine decisions.
  void roll(GameState s, int value) {
    s.rng = value == 0 ? 100 : value * 31 % 100;
  }

  test(
    'all offices have explicit ranks and the new price is about a tenth to a fifth',
    () {
      final roles =
          initialCourt().where((c) => !c.isConsort).map((c) => c.role).toSet();
      expect(roles, hasLength(28));
      expect(appointmentRanks.keys.toSet(), roles);
      final candidate = fresh().officialsPool.first;
      candidate.ability = 80;
      candidate.influence = 40;
      expect(appointmentCost(candidate, 'Võ quan'), 20);
      expect(appointmentCost(candidate, 'Tri phủ'), 23);
      expect(appointmentCost(candidate, 'Hộ bộ'), 26);
      expect(appointmentCost(candidate, 'Tể tướng'), 30);
      for (var a = 0; a <= 100; a++) {
        candidate.ability = a;
        final oldPrice = 20 + a + a * a ~/ 100;
        for (final influence in [0, 25, 50, 75, 100]) {
          candidate.influence = influence;
          for (final role in roles) {
            final cost = appointmentCost(candidate, role);
            expect(
              cost,
              inInclusiveRange(oldPrice * .1 - .5, oldPrice * .2 + .5),
              reason: '$a/$influence/$role',
            );
            expect(cost, inInclusiveRange(2, 44));
          }
        }
      }
    },
  );

  test(
    'ability, candidate standing and destination office each affect the quote',
    () {
      final candidate =
          fresh().officialsPool.first
            ..ability = 80
            ..influence = 0;
      final basic = appointmentCost(candidate, 'Tri phủ');
      candidate.influence = 100;
      expect(appointmentCost(candidate, 'Tri phủ'), greaterThan(basic));
      final established = appointmentCost(candidate, 'Tri phủ');
      candidate.ability = 90;
      expect(appointmentCost(candidate, 'Tri phủ'), greaterThan(established));
      final ordered =
          [
            'Võ quan',
            'Tri phủ',
            'Hộ bộ',
            'Tể tướng',
          ].map((r) => appointmentCost(candidate, r)).toList();
      for (var i = 1; i < ordered.length; i++) {
        expect(ordered[i], greaterThan(ordered[i - 1]));
      }
      final quote = appointmentCost(candidate, 'Tri phủ');
      candidate.role = 'Tể tướng';
      expect(appointmentCost(candidate, 'Tri phủ'), quote);
      candidate.role = 'Ứng viên';
      expect(appointmentCost(candidate, 'Tri phủ'), quote);
    },
  );

  test(
    'engine uses the destination price and logs the same actual payment',
    () {
      for (final target in ['marshal', 'governor', 'treasurer', 'chancellor']) {
        final s = fresh();
        final old = person(s, target);
        final candidate =
            s.officialsPool.first
              ..ability = 80
              ..influence = 40;
        final quote = appointmentCost(candidate, old.role);
        s.treasury = quote;
        final result = send(s, 'appoint', target: target, option: candidate.id);
        expect(result.treasury, 0);
        expect(result.points, 2);
        final note = result.journal.first;
        expect(note.text, contains('Chi $quote;'));
        expect(note.text, contains('bậc ${appointmentRank(old.role)}/4'));
        expect(note.text, contains('ảnh hưởng) 40/100'));
        expect(person(result, candidate.id).role, old.role);
      }
    },
  );

  test(
    'budget can cover a lower office while a higher appointment fails atomically',
    () {
      final s = fresh()..treasury = 20;
      final candidate =
          s.officialsPool.first
            ..ability = 80
            ..influence = 40;
      final before = jsonEncode(s.toJson());
      expect(
        () => send(s, 'appoint', target: 'chancellor', option: candidate.id),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
      final result = send(
        s,
        'appoint',
        target: 'marshal',
        option: candidate.id,
      );
      expect(result.treasury, 0);
      expect(result.officialsPool, hasLength(12));
    },
  );

  test(
    'initial court has weak officials and a persisted, varied appointment pool',
    () {
      final s = fresh();
      expect(
        s.court.where((c) => !c.isConsort && c.ability < 50).length,
        greaterThanOrEqualTo(6),
      );
      expect(s.officialsPool, hasLength(12));
      expect(s.officialsPool.map((c) => c.faction).toSet(), hasLength(4));
      expect(s.officialsPool.map((c) => c.specialty).toSet(), hasLength(8));
      expect(s.officialsPool.any((c) => c.ability >= 80), true);
      expect(s.officialsPool.any((c) => c.ability < 50), true);
      expect(
        [...s.court, ...s.officialsPool].map((c) => c.id).toSet(),
        hasLength(s.court.length + 12),
      );
      expect(s.copy().toJson(), s.toJson());
      final low = s.officialsPool.reduce(
        (a, b) => a.ability < b.ability ? a : b,
      );
      final high = s.officialsPool.reduce(
        (a, b) => a.ability > b.ability ? a : b,
      );
      expect(
        appointmentCost(high, 'Hộ bộ'),
        greaterThan(appointmentCost(low, 'Hộ bộ')),
      );
    },
  );

  test(
    'high ability and matching specialty improve actual success frequency and reward',
    () {
      final wins = <String, int>{};
      final gains = <String, int>{};
      for (final id in ['general', 'doctor', 'marshal']) {
        var success = 0;
        for (var value = 0; value < 100; value++) {
          final s = fresh()..army = 40;
          roll(s, value);
          final result = send(s, 'action', target: 'train', option: id);
          if (result.army > 40) success++;
          if (value == 0) gains[id] = result.army - 40;
        }
        wins[id] = success;
      }
      expect(wins['general'], greaterThan(wins['doctor']!));
      expect(wins['general'], greaterThan(wins['marshal']!));
      expect(gains['general'], greaterThan(gains['doctor']!));
      expect(gains['general'], greaterThan(gains['marshal']!));
      expect(wins['general'], lessThan(100));
    },
  );

  test(
    'failure consumes cost and action, with mission-specific serious consequences',
    () {
      for (final task in [
        'govern',
        'relief',
        'buy_grain',
        'train',
        'security',
        'mediate',
      ]) {
        final s = fresh();
        roll(s, 99);
        final result = send(s, 'action', target: task, option: 'marshal');
        expect(result.points, s.points - 1, reason: task);
        expect(result.workThisWeek, 1, reason: task);
        expect(
          result.journal.first.title,
          'Công việc thất bại nặng',
          reason: task,
        );
        expect(result.authority, lessThan(s.authority), reason: task);
        if (task == 'train') expect(result.army, lessThan(s.army));
        if (task == 'relief') {
          expect(result.people, lessThan(s.people));
          expect(result.grain, lessThan(s.grain - 25));
        }
        if (task == 'security') {
          expect(
            person(result, 'duke').plot,
            greaterThan(person(s, 'duke').plot),
          );
        }
        if (task == 'buy_grain') {
          expect(result.grain, s.grain);
          expect(result.treasury, lessThan(s.treasury - 45));
        }
      }
    },
  );

  test(
    'long projects roll at completion and failures cannot grant their rewards',
    () {
      for (final task in ['repair', 'farm']) {
        var s = send(fresh(), 'action', target: task, option: 'marshal');
        expect(s.projects, hasLength(1));
        s.projects.single.progress = s.projects.single.duration - 1;
        final before = s.copy();
        roll(s, 99);
        final failed = send(s, 'endWeek');
        expect(failed.projects, isEmpty);
        expect(
          failed.journal.any((c) => c.title == 'Công việc thất bại nặng'),
          true,
        );
        expect(
          task == 'repair' ? failed.levee : failed.grain,
          lessThan(task == 'repair' ? before.levee : before.grain),
        );
        roll(before, 0);
        final success = send(before, 'endWeek');
        expect(
          task == 'repair' ? success.levee : success.grain,
          greaterThan(task == 'repair' ? s.levee : s.grain),
        );
        expect(success.projects, isEmpty);
      }
    },
  );

  test(
    'envoys use the selected officer, and losing a mission has real consequences',
    () {
      var s = send(fresh(), 'action', target: 'diplomacy', option: 'marshal');
      expect(s.pending.single.target, 'marshal');
      s.pending.single.dueWeek = s.week;
      roll(s, 99);
      final failed = send(s, 'endWeek');
      expect(failed.pending.where((p) => p.kind == 'envoy'), isEmpty);
      expect(failed.war, greaterThan(0));
      expect(failed.authority, lessThan(s.authority));
      expect(
        failed.journal.any((n) => n.title == 'Công việc thất bại nặng'),
        true,
      );
      expect(failed.copy().toJson(), failed.toJson());
    },
  );

  test(
    'replacement charges the chosen price and changes the selected and rival factions',
    () {
      final s = fresh();
      final old = person(s, 'treasurer');
      final candidate = s.officialsPool.firstWhere(
        (c) => c.faction == 'Văn thần',
      );
      final price = appointmentCost(candidate, old.role);
      final result = send(s, 'appoint', target: old.id, option: candidate.id);
      expect(result.treasury, s.treasury - price);
      expect(result.points, 2);
      expect(result.factions['Văn thần'], s.factions['Văn thần']! + 5);
      expect(result.factions['Võ tướng'], s.factions['Võ tướng']! - 6);
      expect(result.factions['Thế gia'], s.factions['Thế gia']! - 4);
      expect(person(result, old.id).available, false);
      expect(person(result, candidate.id).role, old.role);
      expect(person(result, candidate.id).specialty, candidate.specialty);
      expect(
        result.court.where((c) => c.available && !c.isConsort),
        hasLength(35),
      );
      expect(result.officialsPool, hasLength(12));
      expect(result.officialsPool.any((c) => c.id == candidate.id), false);
    },
  );

  test('appointing within the same faction still improves that faction', () {
    final s = fresh();
    final candidate = s.officialsPool.firstWhere((c) => c.faction == 'Thế gia');
    final result = send(
      s,
      'appoint',
      target: 'treasurer',
      option: candidate.id,
    );
    expect(result.factions['Thế gia'], s.factions['Thế gia']! + 5);
    expect(result.factions['Hoàng tộc'], s.factions['Hoàng tộc']! - 6);
  });

  test(
    'insufficient funds, invalid candidates and legacy dismissal never reroll or mutate',
    () {
      for (final kind in ['cash', 'points', 'candidate', 'consort', 'legacy']) {
        final s = fresh();
        if (kind == 'cash') s.treasury = 0;
        if (kind == 'points') s.points = 0;
        final before = jsonEncode(s.toJson());
        expect(
          () => send(
            s,
            kind == 'legacy' ? 'courtier' : 'appoint',
            target: kind == 'consort' ? 'consort_lan' : 'treasurer',
            option:
                kind == 'legacy'
                    ? 'dismiss'
                    : kind == 'candidate'
                    ? 'not-a-candidate'
                    : s.officialsPool.first.id,
          ),
          throwsA(isA<GameRuleException>()),
          reason: kind,
        );
        expect(jsonEncode(s.toJson()), before);
      }
    },
  );

  test(
    'replacement transfers ongoing projects and envoys without resetting progress or specialty',
    () {
      var s = send(fresh(), 'action', target: 'repair', option: 'governor');
      s.projects.single.progress = 2;
      s.pending.add(Consequence(kind: 'envoy', dueWeek: 5, target: 'governor'));
      final candidate = s.officialsPool.firstWhere(
        (c) => c.specialty == 'Y thuật',
      );
      final result = send(
        s,
        'appoint',
        target: 'governor',
        option: candidate.id,
      );
      expect(result.projects.single.officerId, candidate.id);
      expect(result.projects.single.progress, 2);
      expect(result.pending.single.target, candidate.id);
      expect(person(result, candidate.id).specialty, 'Y thuật');
      expect(TaskAssessment('repair', person(result, candidate.id)).fit, 20);
      expect(result.copy().toJson(), result.toJson());
      final reload = result.copy();
      final nextCandidate = result.officialsPool.first;
      expect(
        send(
          result,
          'appoint',
          target: 'treasurer',
          option: nextCandidate.id,
        ).toJson(),
        send(
          reload,
          'appoint',
          target: 'treasurer',
          option: nextCandidate.id,
        ).toJson(),
      );
    },
  );

  test('busy officers and consorts cannot be assigned to national work', () {
    final s = send(fresh(), 'action', target: 'farm', option: 'governor');
    expect(taskOfficers(s, 'train').any((c) => c.id == 'governor'), false);
    for (final id in ['governor', 'consort_lan']) {
      expect(
        () => send(s, 'action', target: 'train', option: id),
        throwsA(isA<GameRuleException>()),
      );
    }
  });

  test('severe failure can end the reign and unpaid losses become debt', () {
    for (final task in ['train', 'relief']) {
      final s = fresh();
      if (task == 'train') {
        s.army = 1;
      } else {
        s.people = 1;
      }
      roll(s, 99);
      final result = send(s, 'action', target: task, option: 'marshal');
      expect(result.endKind, task == 'train' ? 'armyCollapse' : 'rebellion');
      expect(result.completedWeeks, 0);
      expect(result.points, 2);
    }
    final s = fresh()..treasury = 45;
    roll(s, 99);
    final result = send(s, 'action', target: 'buy_grain', option: 'marshal');
    expect(result.treasury, 0);
    expect(result.debt, 15);
  });
}
