import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState send(
    GameState s,
    String type, {
    String target = '',
    String option = '',
  }) => engine.execute(
    s,
    GameCommand(
      id: 'revenue-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );
  GameState fresh() {
    final s = engine.start('revenue', 'An', 42);
    s.petitions.clear();
    s.people = s.army = s.stability = s.authority = s.health = 90;
    s.factions.updateAll((k, v) => 60);
    for (final c in s.court) {
      c.plot = 0;
      c.loyalty = 90;
      c.ambition = 10;
    }
    return s;
  }

  void roll(GameState s, int value) {
    s.rng = value == 0 ? 100 : value * 31 % 100;
  }

  Courtier officer(GameState s) =>
      s.court.firstWhere((c) => c.id == 'treasurer');

  test(
    'revenue tasks are visible economic work with positive basic cash returns',
    () {
      expect(revenueTasks, hasLength(3));
      for (final id in revenueTasks) {
        expect(actions.any((a) => a.id == id), true);
        expect(taskSpecialties[id], 'Kinh tế');
        expect(revenueBaseReturns[id], greaterThan(0));
        expect(
          revenueRewardPreview(id, officer(fresh())),
          contains('ngân khố'),
        );
        expect(taskFailureHint(id), contains('Thất bại'));
      }
    },
  );

  test(
    'arrears rescue an empty treasury but cost support, health pressure and quota',
    () {
      final s = fresh()..treasury = 0;
      roll(s, 0);
      final gain = TaskAssessment('collect_arrears', officer(s)).reward(45);
      final result = send(
        s,
        'action',
        target: 'collect_arrears',
        option: 'treasurer',
      );
      expect(result.treasury, gain);
      expect(result.people, s.people - 2);
      expect(result.points, 2);
      expect(result.fatigue, s.fatigue + 4);
      expect(result.stress, s.stress + 3);
      expect(result.workThisWeek, 1);
      expect(result.affairsThisWeek, 1);
      expect(result.cooldowns['task:collect_arrears'], 5);
      final restored = result.copy();
      final before = jsonEncode(restored.toJson());
      expect(
        () => send(
          restored,
          'action',
          target: 'collect_arrears',
          option: 'treasurer',
        ),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(restored.toJson()), before);
    },
  );

  test('arrears unlock at week five, not at the next week or after reload', () {
    final s = fresh();
    roll(s, 0);
    var result = send(
      s,
      'action',
      target: 'collect_arrears',
      option: 'treasurer',
    );
    for (var i = 0; i < 4; i++) {
      result.petitions.clear();
      result.affairsThisWeek = 1;
      result.restThisWeek = 1;
      result = send(result, 'endWeek').copy();
      expect(
        revenueTaskBlocked(result, 'collect_arrears') == null,
        result.week == 5,
      );
    }
    roll(result, 0);
    expect(
      send(
        result,
        'action',
        target: 'collect_arrears',
        option: 'treasurer',
      ).cooldowns['task:collect_arrears'],
      9,
    );
  });

  test(
    'failed arrears grant no money, lock quota and severe losses become debt',
    () {
      final s = fresh()..treasury = 0;
      roll(s, 99);
      final result = send(
        s,
        'action',
        target: 'collect_arrears',
        option: 'treasurer',
      );
      expect(result.treasury, 0);
      expect(result.debt, 10);
      expect(result.people, s.people - 4);
      expect(result.authority, s.authority - 4);
      expect(result.stability, s.stability - 2);
      expect(result.points, 2);
      expect(result.cooldowns['task:collect_arrears'], 5);
    },
  );

  test(
    'surplus sale pays instantly, spends actual grain and cannot be repeated',
    () {
      final s = fresh()..grain = 65;
      roll(s, 0);
      final result = send(
        s,
        'action',
        target: 'sell_surplus',
        option: 'treasurer',
      );
      expect(
        result.treasury - s.treasury,
        TaskAssessment('sell_surplus', officer(s)).reward(28),
      );
      expect(result.grain, 25);
      expect(result.fatigue, s.fatigue + 2);
      result.grain = 100;
      expect(
        () => send(
          result.copy(),
          'action',
          target: 'sell_surplus',
          option: 'treasurer',
        ),
        throwsA(isA<GameRuleException>()),
      );
      result.petitions.clear();
      result.affairsThisWeek = 1;
      final next = send(result, 'endWeek');
      expect(revenueTaskBlocked(next, 'sell_surplus'), isNull);
    },
  );

  test(
    'surplus reserve, resources, official and action checks never mutate or reroll',
    () {
      for (final kind in ['reserve', 'points', 'consort', 'busy', 'capital']) {
        final s = fresh();
        if (kind == 'reserve') s.grain = 64;
        if (kind == 'points') s.points = 0;
        if (kind == 'capital') s.treasury = 39;
        if (kind == 'busy') {
          s.projects.add(
            WorkOrder(
              id: 'busy',
              kind: 'farm',
              officerId: 'treasurer',
              startedWeek: 1,
              duration: 5,
            ),
          );
        }
        final before = jsonEncode(s.toJson());
        expect(
          () => send(
            s,
            'action',
            target: kind == 'capital' ? 'commerce' : 'sell_surplus',
            option: kind == 'consort' ? 'consort_lan' : 'treasurer',
          ),
          throwsA(isA<GameRuleException>()),
          reason: kind,
        );
        expect(jsonEncode(s.toJson()), before);
      }
    },
  );

  test(
    'failed sale loses goods, consumes quota and cannot claim success revenue',
    () {
      final s = fresh();
      roll(s, 99);
      final result = send(
        s,
        'action',
        target: 'sell_surplus',
        option: 'treasurer',
      );
      expect(result.grain, s.grain - 40);
      expect(result.treasury, s.treasury - 8);
      expect(result.actionCounts['sell_surplus'], 1);
      expect(result.points, 2);
      expect(result.affairsThisWeek, 1);
    },
  );

  test(
    'commercial mission pays only at fourth week and survives reload exactly',
    () {
      final s = fresh();
      final officerBefore = officer(s);
      final expected = TaskAssessment('commerce', officerBefore).reward(110);
      var a = send(s, 'action', target: 'commerce', option: 'treasurer');
      expect(a.treasury, s.treasury - 40);
      expect(a.rng, s.rng);
      expect(a.projects.single.duration, 4);
      expect(
        taskOfficers(a, 'collect_arrears').any((c) => c.id == 'treasurer'),
        false,
      );
      expect(
        () => send(a, 'action', target: 'commerce', option: 'chancellor'),
        throwsA(isA<GameRuleException>()),
      );
      var b = a.copy();
      for (var i = 1; i <= 4; i++) {
        a.petitions.clear();
        b.petitions.clear();
        a.affairsThisWeek = b.affairsThisWeek = 1;
        a.restThisWeek = b.restThisWeek = 1;
        if (i == 4) {
          roll(a, 0);
          roll(b, 0);
        }
        final before = a.treasury;
        a = send(a, 'endWeek');
        b = send(b, 'endWeek').copy();
        expect(a.toJson(), b.toJson());
        expect(
          a.treasury - before - a.lastIncome + a.lastExpense,
          i == 4 ? expected : 0,
        );
        expect(a.projects.length, i == 4 ? 0 : 1);
      }
      expect(
        a.journal.where((n) => n.title == 'Đoàn thương mại trở về'),
        hasLength(1),
      );
      a.petitions.clear();
      a = send(a, 'endWeek');
      expect(
        a.journal.where((n) => n.title == 'Đoàn thương mại trở về'),
        hasLength(1),
      );
    },
  );

  test(
    'commercial failure loses capital and additional funds without paying revenue',
    () {
      var s = send(fresh(), 'action', target: 'commerce', option: 'treasurer');
      s.projects.single.progress = 3;
      roll(s, 99);
      final result = send(s, 'endWeek');
      expect(
        result.treasury - s.treasury - result.lastIncome + result.lastExpense,
        -20,
      );
      expect(result.projects, isEmpty);
      expect(
        result.journal.any((n) => n.title == 'Đoàn thương mại trở về'),
        false,
      );
      expect(
        result.journal
            .firstWhere((n) => n.title == 'Công việc thất bại nặng')
            .text,
        contains('ngân khố -20'),
      );
    },
  );

  test(
    'better fit and ability improve revenue and chance; grain round trip loses money',
    () {
      final s = fresh();
      final strong =
          officer(s)
            ..ability = 100
            ..specialty = 'Kinh tế';
      final weak = s.court.firstWhere((c) => c.id == 'doctor')..ability = 30;
      for (final task in revenueTasks) {
        expect(
          TaskAssessment(task, strong).successChance,
          greaterThan(TaskAssessment(task, weak).successChance),
        );
        expect(
          TaskAssessment(task, strong).reward(revenueBaseReturns[task]!),
          greaterThan(
            TaskAssessment(task, weak).reward(revenueBaseReturns[task]!),
          ),
        );
      }
      roll(s, 0);
      final bought = send(s, 'action', target: 'buy_grain', option: strong.id);
      roll(bought, 0);
      final sold = send(
        bought,
        'action',
        target: 'sell_surplus',
        option: strong.id,
      );
      expect(sold.treasury, lessThan(s.treasury));
      expect(
        TaskAssessment('sell_surplus', strong).reward(28) *
            TaskAssessment('buy_grain', strong).reward(30) /
            40,
        lessThan(45),
      );
    },
  );

  test(
    'appointment transfers commercial work and uses new official at completion',
    () {
      final s = send(
        fresh(),
        'action',
        target: 'commerce',
        option: 'treasurer',
      );
      s.projects.single.progress = 3;
      final candidate = s.officialsPool.firstWhere(
        (c) => c.specialty == 'Y thuật',
      );
      final replaced = send(
        s,
        'appoint',
        target: 'treasurer',
        option: candidate.id,
      );
      expect(replaced.projects.single.officerId, candidate.id);
      expect(replaced.projects.single.progress, 3);
      final expected = TaskAssessment('commerce', candidate).reward(110);
      roll(replaced, 0);
      final result = send(replaced, 'endWeek');
      expect(
        result.treasury -
            replaced.treasury -
            result.lastIncome +
            result.lastExpense,
        expected,
      );
      expect(
        result.journal
            .firstWhere((n) => n.title == 'Đoàn thương mại trở về')
            .text,
        contains(candidate.name),
      );
    },
  );

  test(
    'v0.7 run is archived and new-rule revenue retries pay only once',
    () async {
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store, seasonal: false);
      final original = await gateway.start(
        name: 'An',
        runId: 'existing-07',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      final legacy = object(jsonDecode(jsonEncode(original.toJson())));
      final oldRun =
          object(legacy['active'])
            ..['rulesVersion'] = 'mvp-0.7.0'
            ..['contentVersion'] = 6;
      legacy['active'] = oldRun;
      final restored = GameArchive.fromJson(legacy);
      expect(restored.active, isNull);
      expect(restored.archivedRuns.single, oldRun);
      expect(object(legacy['active'])['rulesVersion'], 'mvp-0.7.0');
      final command = GameCommand(
        id: 'income-once',
        runId: original.active!.runId,
        expectedRevision: 0,
        type: 'action',
        target: 'collect_arrears',
        option: 'treasurer',
      );
      final a = await gateway.dispatch(command);
      final b = await LocalGameGateway(
        store,
        seasonal: false,
      ).dispatch(command);
      expect(a.toJson(), b.toJson());
      expect(b.active!.history, hasLength(1));
      expect(b.active!.cooldowns['task:collect_arrears'], 5);
    },
  );
}
