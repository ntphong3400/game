import 'package:flutter_test/flutter_test.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/logic/personality_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine();
  GameState fresh({String actorId = 'doctor'}) {
    final s = engine.start('politics', 'An', 42);
    final actor = s.court.firstWhere((c) => c.id == actorId);
    s.court = [actor];
    actor.loyalty = 20;
    actor.affection = actor.baseAffection = 50;
    actor.ambition = 90;
    actor.discontent = 100;
    actor.influence = 100;
    actor.plot = 69;
    actor.strain = 0;
    actor.personalities
      ..clear()
      ..addAll([Personality.grateful, Personality.diplomatic]);
    s.petitions.clear();
    s.factions.updateAll((key, value) => 50);
    s.nextMajorWeek = s.nextChainWeek = 1000;
    s.authority = 50;
    s.stability = s.army = s.people = 80;
    s.health = 30;
    s.treasury = 10000;
    s.grain = 200;
    s.affairsThisWeek = 1;
    s.rng = 2; // The first political roll succeeds with these stats.
    return s;
  }

  GameState send(
    GameState s,
    String type, {
    String target = '',
    String option = '',
  }) => engine.execute(
    s,
    GameCommand(
      id: 'politics-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );

  test(
    'a low-ranking doctor can poison from discontent without political ambition',
    () {
      final s = fresh();
      expect(s.court.single.politicalAmbition, isNull);
      final result = send(s, 'endWeek');
      expect(result.endKind, 'poisoning');
      expect(result.endReason, contains('Tôn Bách Thảo'));
      expect(result.completedWeeks, 0);
    },
  );

  test('latent ambition does not accelerate a low-ranking person\'s plot', () {
    final progress = <int>[];
    for (final potential in [10, 100]) {
      final s =
          fresh()
            ..court.first.plot = 0
            ..court.first.discontent = 80
            ..court.first.ambition = potential;
      progress.add(send(s, 'endWeek').court.first.plot);
    }
    expect(progress.first, greaterThan(0));
    expect(progress.first, progress.last);
  });

  test(
    'a legacy ready plot remains actionable after one ordinary calming tick',
    () {
      final raw = fresh().toJson()..['rulesVersion'] = 'mvp-0.14.1';
      (raw['court'] as List).first.remove('discontent');
      final restored = GameState.fromJson(raw);
      expect(restored.court.first.discontent, 62);
      expect(send(restored, 'endWeek').endKind, 'poisoning');
    },
  );

  for (final actorId in [
    'chancellor',
    'prince',
    'general',
    'duke',
    'treasurer',
    'regional-south-governor',
  ]) {
    test('$actorId can lead a coup with high discontent and ambition', () {
      final result = send(fresh(actorId: actorId), 'endWeek');
      expect(result.endKind, 'coup');
      expect(result.health, 30);
    });
  }

  test(
    'a high-ranking person without high ambition poisons instead of taking the throne',
    () {
      final s = fresh(actorId: 'chancellor')..court.single.ambition = 60;
      expect(send(s, 'endWeek').endKind, 'poisoning');
    },
  );

  test('a satisfied ambitious person cannot carry out a ready plot', () {
    final s =
        fresh(actorId: 'prince')
          ..court.single.discontent = 0
          ..court.single.plot = 75;
    final result = send(s, 'endWeek');
    expect(result.ended, false);
    expect(result.health, 30);
    expect(result.court.first.plot, 74);
  });

  test(
    'loyalty can prevent a plot despite extreme discontent and ambition',
    () {
      final s = fresh(actorId: 'prince')..court.single.loyalty = 57;
      final result = send(s, 'endWeek');
      expect(result.ended, false);
      expect(result.court.first.plot, 68);
    },
  );

  test('unadmitted candidates accumulate discontent but cannot plot', () {
    final s = fresh(actorId: 'consort_mai');
    s.court.single.discontent = 65;
    s.court.single.affection = 10;
    s.factions['Thế gia'] = 20;
    final result = send(s, 'endWeek');
    expect(result.court.first.discontent, greaterThan(65));
    expect(result.court.first.plot, 69);
    expect(result.health, 30);
    expect(result.ended, false);
  });

  test('a queen may lead a coup while an ordinary consort can only poison', () {
    for (final queen in [false, true]) {
      final s = fresh(actorId: 'consort_mai');
      s.court.single.inHarem = true;
      s.court.single.queen = queen;
      expect(s.court.single.politicalAmbition, queen ? 90 : isNull);
      expect(send(s, 'endWeek').endKind, queen ? 'coup' : 'poisoning');
    }
  });

  test(
    'grievances evolve for low ranks and recover independently of affection',
    () {
      final s = fresh();
      s.court.single.plot = 0;
      s.court.single.loyalty = 100;
      s.court.single.discontent = 20;
      s.court.single.affection = s.court.single.baseAffection = 10;
      s.factions['Văn thần'] = 20;
      var result = send(s, 'endWeek');
      expect(result.court.first.discontent, 41);
      result.court.first.affection = result.court.first.baseAffection = 70;
      result.factions['Văn thần'] = 70;
      result.affairsThisWeek = 1;
      result = send(result.copy(), 'endWeek');
      expect(result.court.first.discontent, 39);
      expect(result.court.first.affection, 70);
    },
  );

  test('resentful people calm more slowly without sources of grievance', () {
    final s =
        fresh()
          ..court.single.plot = 0
          ..court.single.discontent = 30;
    s.court.single.personalities
      ..clear()
      ..addAll([Personality.resentful, Personality.diplomatic]);
    expect(send(s, 'endWeek').court.first.discontent, 29);
  });

  test(
    'audience calms its recipient and aggravates people of the rival faction once',
    () {
      final s = engine.start('audience', 'An', 42);
      final target = s.court.firstWhere((c) => c.id == 'chancellor');
      final rival = s.court.firstWhere((c) => c.id == 'general');
      target.affection = 40;
      target.discontent = 70;
      rival.discontent = 99;
      final result = send(s, 'courtier', target: target.id, option: 'audience');
      final after = result.court.firstWhere((c) => c.id == target.id);
      expect(after.discontent, 70 - (after.affection - 40));
      expect(result.court.firstWhere((c) => c.id == rival.id).discontent, 100);
      expect(
        result.copy().court.firstWhere((c) => c.id == target.id).discontent,
        after.discontent,
      );
    },
  );

  test(
    'discontent reduces cooperation and creates sabotage risk for any low-loyalty worker',
    () {
      final s = fresh()..court.single.plot = 0;
      final worker = s.court.single..discontent = 0;
      final calm = PersonalityAssessment(worker, s);
      worker.discontent = 90;
      final upset = PersonalityAssessment(worker, s);
      expect(upset.cooperation, lessThan(calm.cooperation));
      expect(calm.sabotageChance, 0);
      expect(upset.sabotageChance, greaterThan(0));
      expect(worker.canHaveAmbition, false);
    },
  );

  test('appointing a candidate activates ambition only in a senior office', () {
    for (final roleId in ['chancellor', 'governor']) {
      final s = engine.start('appointment-$roleId', 'An', 42);
      final candidate = s.officialsPool.first..ambition = 83;
      expect(candidate.politicalAmbition, isNull);
      final result = send(s, 'appoint', target: roleId, option: candidate.id);
      final appointed = result.court.firstWhere((c) => c.id == candidate.id);
      expect(appointed.ambition, 83);
      expect(appointed.politicalAmbition, roleId == 'chancellor' ? 83 : isNull);
    }
  });

  test(
    'queen promotion and removal activate ambition and change discontent',
    () {
      final s = engine.start('queens', 'An', 42);
      final previous = s.court.firstWhere((c) => c.id == 'consort_lan');
      final promoted = s.court.firstWhere((c) => c.id == 'consort_mai');
      previous.inHarem = previous.queen = true;
      previous.discontent = 20;
      promoted.inHarem = true;
      promoted.discontent = 90;
      expect(promoted.politicalAmbition, isNull);
      final result = send(s, 'courtier', target: promoted.id, option: 'queen');
      final newQueen = result.court.firstWhere((c) => c.id == promoted.id);
      final oldQueen = result.court.firstWhere((c) => c.id == previous.id);
      expect(newQueen.politicalAmbition, promoted.ambition);
      expect(newQueen.discontent, 72);
      expect(oldQueen.politicalAmbition, isNull);
      expect(oldQueen.discontent, 45);
    },
  );

  test('the three-plot limit applies to new discontent plots', () {
    final s = fresh();
    final template = s.court.single.toJson()..['plot'] = 0;
    s.court = List.generate(
      4,
      (i) => Courtier.fromJson({...template, 'id': 'actor-$i'}),
    );
    final result = send(s, 'endWeek');
    expect(result.court.where((c) => c.plot > 0), hasLength(3));
  });

  test(
    'old saves migrate grievances once without resetting plots, RNG or known traits',
    () {
      final s = engine.start('old-politics', 'An', 42)..revision = 12;
      s.court.first.plot = 52;
      final raw = s.toJson()..['rulesVersion'] = 'mvp-0.14.1';
      for (final person in [
        ...raw['court'] as List,
        ...raw['officialsPool'] as List,
      ]) {
        (person as Map).remove('discontent');
      }
      final loaded = GameState.fromJson(raw);
      expect(loaded.court.first.discontent, 62);
      expect(loaded.court.first.plot, 52);
      expect(loaded.court.first.personalities, s.court.first.personalities);
      expect(loaded.rng, s.rng);
      expect(loaded.revision, 12);
      loaded.court.first.discontent = 15;
      final reloaded = loaded.copy();
      expect(reloaded.court.first.discontent, 15);
      expect(reloaded.court.first.plot, 52);
      expect(reloaded.rng, s.rng);
    },
  );
}
