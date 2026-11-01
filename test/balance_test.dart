import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState fresh([int seed = 42]) => engine.start('balance', 'An', seed);
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
    'expanded roster covers categories and four factions with ten regional offices',
    () {
      final s = fresh();
      final officials = s.court.where((c) => !c.isConsort).toList();
      expect(officials, hasLength(35));
      final regional =
          officials.where((c) => c.category == 'Địa phương').toList();
      expect(regional, hasLength(10));
      expect(regional.where((c) => c.role == 'Tri phủ'), hasLength(4));
      expect(regional.where((c) => c.role == 'Tuần phủ'), hasLength(3));
      expect(regional.where((c) => c.role == 'Quan điền'), hasLength(3));
      expect(regional.any((c) => c.ability < 50), true);
      expect(regional.any((c) => c.ability >= 80), true);
      expect(regional.map((c) => c.faction).toSet(), hasLength(4));
      expect(s.court.where((c) => c.isConsort), hasLength(10));
      expect(s.court.map((c) => c.id).toSet(), hasLength(s.court.length));
      expect(
        officials.map((c) => c.category).toSet(),
        officialCategories.toSet(),
      );
      for (final f in factionOpponents.keys) {
        expect(
          officials.where((c) => c.faction == f),
          hasLength(f == 'Thế gia' ? 8 : 9),
        );
        expect(factionOpponents[factionOpponents[f]], f);
      }
      expect(s.court.where((c) => c.isConsort).every((c) => c.age >= 18), true);
    },
  );

  test('each seed has a hostile faction and varied personal affection', () {
    final factions = <String>{};
    for (final seed in [7, 42, 73, 123, 2026, 333]) {
      final s = fresh(seed);
      factions.add(s.hostileFaction);
      final hostile = s.court.where((c) => c.faction == s.hostileFaction);
      expect(hostile.every((c) => c.affection <= 35), true);
      expect(
        s.court
            .where((c) => c.faction != s.hostileFaction)
            .every((c) => c.affection >= 36),
        true,
      );
      expect(s.court.map((c) => c.affection).toSet().length, greaterThan(8));
      expect(s.copy().hostileFaction, s.hostileFaction);
    }
    expect(factions.length, greaterThan(1));
  });

  test(
    'relief consumes real grain and money, with diminishing support gains',
    () {
      var s = fresh();
      final cash = s.treasury, grain = s.grain, support = s.people;
      s = step(s, 'action', target: 'relief');
      expect(s.treasury, cash - 20);
      expect(s.grain, grain - 25);
      expect(s.people, greaterThan(support));
      final firstGain = s.people - support;
      final first = s.people;
      s = step(s, 'action', target: 'relief');
      expect(s.people - first, lessThan(firstGain));
      expect(s.grain, grain - 50);
      final empty = fresh()..grain = 24;
      final before = jsonEncode(empty.toJson());
      expect(
        () => step(empty, 'action', target: 'relief'),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(empty.toJson()), before);
      final highSupport = fresh()..people = 90;
      expect(
        step(highSupport, 'action', target: 'relief').people - 90,
        lessThan(firstGain),
      );
    },
  );

  test(
    'event food payments cannot spend missing grain, while disaster loss can expire',
    () {
      var s = fresh()..grain = 24;
      s.petitions.add(
        Petition(
          id: 'flood',
          definitionId: 'flood',
          openedWeek: 1,
          deadline: 1,
        ),
      );
      expect(
        () => step(s, 'petition', target: 'flood', option: '0'),
        throwsA(isA<GameRuleException>()),
      );
      s = step(s, 'endWeek');
      expect(s.petitions.any((p) => p.id == 'flood'), false);
      expect(s.grain, greaterThanOrEqualTo(0));
    },
  );

  test(
    'governance trades smaller gains for fatigue and stress, repeat gains shrink',
    () {
      var s = fresh();
      final original = s.copy();
      s = step(s, 'action', target: 'govern');
      expect(s.authority, greaterThan(original.authority));
      final firstGain = s.authority - original.authority;
      expect(s.stability, original.stability + 1);
      expect(s.fatigue, original.fatigue + 6);
      expect(s.stress, original.stress + 4);
      final first = s.authority;
      s = step(s.copy(), 'action', target: 'govern');
      expect(s.authority - first, lessThan(firstGain));
      expect(s.stability, original.stability + 1);
      s = step(s, 'endWeek');
      expect(s.actionCounts, isEmpty);
      expect(s.fatigue, greaterThan(original.fatigue));
    },
  );

  test(
    'audience and rewards antagonize rivals and share diminishing returns',
    () {
      var s = fresh();
      final target = s.court.firstWhere((c) => c.id == 'chancellor');
      final rivalFaction = factionOpponents[target.faction]!;
      final rival = s.court.firstWhere(
        (c) => c.faction == rivalFaction && !c.isConsort,
      );
      final originalAffection = target.affection,
          originalRival = rival.affection;
      final originalMood = s.factions[rivalFaction]!;
      s = step(s, 'courtier', target: target.id, option: 'audience');
      final firstGain =
          s.court.firstWhere((c) => c.id == target.id).affection -
          originalAffection;
      expect(
        s.court.firstWhere((c) => c.id == rival.id).affection,
        originalRival - 2,
      );
      expect(s.factions[rivalFaction], lessThan(originalMood));
      final beforeRepeat =
          s.court.firstWhere((c) => c.id == target.id).affection;
      s = step(s.copy(), 'courtier', target: target.id, option: 'audience');
      expect(
        s.court.firstWhere((c) => c.id == target.id).affection - beforeRepeat,
        lessThan(firstGain),
      );
      s = step(s, 'courtier', target: target.id, option: 'reward');
      expect(s.favorsThisWeek[target.id], 3);
      expect(
        s.court.firstWhere((c) => c.id == rival.id).affection,
        originalRival - 7,
      );
    },
  );

  test(
    'high affection is expensive to improve and reconciliation has a weekly limit',
    () {
      var s = fresh();
      s.court.firstWhere((c) => c.id == 'chancellor').affection = 90;
      s = step(s, 'courtier', target: 'chancellor', option: 'audience');
      expect(s.court.firstWhere((c) => c.id == 'chancellor').affection, 91);
      s = step(s, 'courtier', target: 'chancellor', option: 'reward');
      expect(s.court.firstWhere((c) => c.id == 'chancellor').affection, 91);
      s = step(s, 'action', target: 'mediate');
      s.points =
          1; // isolate the once-per-week rule from the action-point rule.
      expect(
        () => step(s, 'action', target: 'mediate'),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test(
    'first seasonal recruitment is guaranteed and targets a persisted adult candidate',
    () {
      var s = fresh();
      for (var i = 0; i < 3; i++) {
        s = step(s, 'endWeek');
      }
      expect(s.week, 4);
      final p = s.petitions.singleWhere(
        (p) => p.definitionId == 'consort_recommendation',
      );
      final c = s.court.firstWhere((c) => c.id == p.targetId);
      expect(c.age, greaterThanOrEqualTo(18));
      expect(petitionText(p, s), contains(c.name));
      final before = s.copy();
      s = step(s.copy(), 'petition', target: p.id, option: '0');
      expect(s.court.firstWhere((c) => c.id == p.targetId).inHarem, false);
      expect(s.court.firstWhere((c) => c.id == p.targetId).category, 'Tú nữ');
      expect(s.treasury, before.treasury - 20);
      expect(s.points, before.points - 1);
      expect(s.petitions.any((p2) => p2.id == p.id), false);
      expect(
        () => step(s, 'petition', target: p.id, option: '0'),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test(
    'declining leaves a candidate available and next season offers someone new',
    () {
      var s = fresh();
      for (var i = 0; i < 3; i++) {
        s = step(s, 'endWeek');
      }
      final p = s.petitions.singleWhere(
        (p) => p.definitionId == 'consort_recommendation',
      );
      s = step(s, 'petition', target: p.id, option: '1');
      expect(s.court.firstWhere((c) => c.id == p.targetId).inHarem, false);
      // Advance to just before next seasonal offer, with existing consequences intact.
      s.completedWeeks = 15;
      s = step(s, 'endWeek');
      final next = s.petitions.singleWhere(
        (p) => p.definitionId == 'consort_recommendation',
      );
      expect(next.targetId, isNot(p.targetId));
    },
  );

  test('manual recruitment closes its pending recommendation', () {
    var s = fresh();
    for (var i = 0; i < 3; i++) {
      s = step(s, 'endWeek');
    }
    final p = s.petitions.singleWhere(
      (p) => p.definitionId == 'consort_recommendation',
    );
    s = step(s, 'courtier', target: p.targetId, option: 'invite');
    expect(s.petitions.any((p2) => p2.id == p.id), false);
    expect(s.court.where((c) => c.id == p.targetId && c.inHarem), hasLength(1));
  });

  test('unadmitted candidates cannot launch palace plots', () {
    var s = fresh();
    final candidate = s.court.firstWhere((c) => c.id == 'consort_mai');
    candidate.plot = 69;
    candidate.loyalty = 0;
    candidate.ambition = 100;
    s = step(s, 'endWeek');
    expect(s.health, 88);
    expect(s.court.firstWhere((c) => c.id == candidate.id).plot, 69);
  });

  test('old runs are preserved verbatim and old scores remain separate', () {
    final legacy =
        fresh().toJson()
          ..['rulesVersion'] = 'mvp-0.2.0'
          ..['contentVersion'] = 1;
    final archive = GameArchive.fromJson({
      'schemaVersion': 1,
      'active': legacy,
      'scores': [ScoreEntry('old', 'An', 100, rules: 'mvp-0.2.0').toJson()],
      'receipts': <String, String>{},
      'starts': <String, String>{},
    });
    expect(archive.active, isNull);
    expect(archive.archivedRuns.single, legacy);
    expect(rankedScores(archive.scores), isEmpty);
    expect(
      rankedScores(archive.scores, rules: 'mvp-0.2.0').single.score.weeks,
      100,
    );
    final restored = GameArchive.fromJson(
      object(jsonDecode(jsonEncode(archive.toJson()))),
    );
    expect(restored.archivedRuns, hasLength(1));
    expect(restored.archivedRuns.single, legacy);
  });
}
