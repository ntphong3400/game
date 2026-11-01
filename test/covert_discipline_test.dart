import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/court_rules.dart';
import 'package:van_tue/game/logic/court_personnel_rules.dart';
import 'package:van_tue/game/logic/investigation_rules.dart';
import 'package:van_tue/game/logic/management_rules.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

final engine = GameEngine();
GameState fresh() {
  final s = engine.start('covert', 'Thiên Hòa', 42);
  s.petitions.clear();
  s.nextMajorWeek = s.nextChainWeek = s.nextCourtPersonnelTurn = 100000;
  s.treasury = 500000;
  s.grain = 7000000;
  s.health = s.stability = s.authority = s.people = 90;
  for (final c in s.court) {
    c.loyalty = c.integrity = c.affection = 100;
  }
  s.factions.updateAll((key, value) => 80);
  return s;
}

GameCommand command(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => GameCommand(
  id: '$type-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: type,
  target: target,
  option: option,
);
Courtier spy(GameState s) => s.court.firstWhere((c) => c.role == 'Mật thám');
Courtier target(GameState s) =>
    courtOfficeHolder(
      s,
      s.courtOffices.firstWhere((o) => o.role == 'Thân vương'),
    )!;
GameState start(
  GameState s, {
  int funding = 20,
  String? spyId,
  String? targetId,
}) => engine.execute(
  s,
  command(
    s,
    'investigate',
    target: targetId ?? target(s).id,
    option: jsonEncode({'spy': spyId ?? spy(s).id, 'funding': funding}),
  ),
);
void forceOutcome(GameState s, {bool success = true, bool fatal = false}) {
  final i = s.pending.indexWhere((p) => p.covertMission != null);
  final p = s.pending[i];
  s.pending[i] = Consequence.fromJson({
    ...p.toJson(),
    'covertMission': {
      ...p.covertMission!.toJson(),
      'succeeded': success,
      'fatal': fatal,
    },
  });
}

GameState close(GameState s) {
  s.petitions.clear();
  s.workThisWeek = s.affairsThisWeek = 1;
  s.grain = 7000000;
  s.treasury = 500000;
  s.health = s.stability = s.authority = s.people = 90;
  return engine.execute(s, command(s, 'endWeek'));
}

void evidence(GameState s, Courtier c, int plot) {
  c.lastInvestigation = CharacterInvestigation(
    week: s.week,
    plot: plot,
    discontent: 30,
  );
  c.evidenceTurn = s.week;
}

CourtPersonnelMatter nomination(
  GameState s,
  CourtOffice office,
  Courtier nominee,
) {
  final m = CourtPersonnelMatter(
    id: 'fill-${s.revision}',
    kind: 'nominate',
    personId: nominee.id,
    sponsorId: s.court.firstWhere((c) => !c.isConsort && c.id != nominee.id).id,
    officeId: office.id,
    openedTurn: s.week,
  );
  s.courtPersonnelMatters.add(m);
  s.petitions.add(
    Petition(
      id: m.id,
      definitionId: m.eventId,
      openedWeek: s.week,
      deadline: s.week + 1,
    ),
  );
  return m;
}

void main() {
  test(
    'rank and funding change public success; target rank and harem rank set death risk',
    () {
      final s = fresh(),
          investigator =
              spy(s)
                ..ability = 80
                ..grade = 4;
      final victim = target(s)..grade = 1;
      expect(
        [for (final f in covertFunding) covertChance(investigator, victim, f)],
        [49, 59, 69],
      );
      investigator.grade = 1;
      expect(covertChance(investigator, victim, 20), 55);
      for (final entry
          in {
            0: 1,
            9: 2,
            8: 2,
            7: 4,
            6: 4,
            5: 6,
            4: 6,
            3: 9,
            2: 9,
            1: 12,
          }.entries) {
        victim.grade = entry.key;
        expect(investigationDeathRisk(victim), entry.value);
      }
      final lady = s.court.firstWhere((c) => c.isConsort);
      lady.inHarem = lady.queen = false;
      expect(investigationDeathRisk(lady), 1);
      lady.inHarem = true;
      expect(investigationDeathRisk(lady), 4);
      lady.queen = true;
      expect(investigationDeathRisk(lady), 12);
      final chance = covertChance(investigator, victim, 20);
      victim.plot = 99;
      victim.discontent = 99;
      expect(
        covertChance(investigator, victim, 20),
        chance,
        reason: 'hidden stats cannot leak through the preview',
      );
    },
  );

  test(
    'assignment selects a real free spy, charges once, freezes all risks and snapshots',
    () {
      final before = fresh();
      final id = target(before).id, spyId = spy(before).id;
      target(before).plot = 80;
      final s = start(before, funding: 40);
      expect(s.treasury, before.treasury - 4000);
      expect(s.points, before.points - 1);
      final p = s.pending.singleWhere((p) => p.covertMission != null);
      expect(p.covertMission!.spyId, spyId);
      expect(p.investigation!.plot, 80);
      expect(officerBusy(s, spyId), true);
      expect(s.court.firstWhere((c) => c.id == id).lastInvestigation, isNull);
      final restored = s.copy();
      final frozen = jsonEncode(p.toJson());
      spy(restored).grade = 1;
      spy(restored).ability = 100;
      target(restored).grade = 9;
      expect(
        jsonEncode(
          restored.pending.singleWhere((p) => p.covertMission != null).toJson(),
        ),
        frozen,
      );
      expect(restored.rng, s.rng);
    },
  );

  test(
    'invalid, self, busy, duplicate and unaffordable requests are atomic',
    () {
      var s = fresh();
      final original = jsonEncode(s.toJson());
      for (final request in [
        command(s, 'courtier', target: target(s).id, option: 'investigate'),
        command(s, 'investigate', target: target(s).id, option: '{}'),
        command(
          s,
          'investigate',
          target: target(s).id,
          option: jsonEncode({'spy': spy(s).id, 'funding': 20.5}),
        ),
      ]) {
        expect(
          () => engine.execute(s, request),
          throwsA(isA<GameRuleException>()),
        );
      }
      expect(
        () => start(s, spyId: target(s).id),
        throwsA(isA<GameRuleException>()),
      );
      expect(
        () => start(s, targetId: spy(s).id),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), original);
      s.treasury = 1999;
      expect(() => start(s), throwsA(isA<GameRuleException>()));
      s.treasury = 50000;
      s = start(s);
      final snapshot = jsonEncode(s.toJson());
      expect(() => start(s), throwsA(isA<GameRuleException>()));
      expect(jsonEncode(s.toJson()), snapshot);
      expect(
        covertSpies(
          s,
          target(s),
        ).any((c) => c.id == s.pending.single.covertMission!.spyId),
        false,
      );
    },
  );

  test(
    'successful investigation publishes captured figures only on completion, with a full year of evidence',
    () {
      var s = fresh();
      target(s).plot = 80;
      target(s).discontent = 67;
      final id = target(s).id, spyId = spy(s).id, ability = spy(s).ability;
      s = start(s);
      forceOutcome(s);
      target(s).plot = 30;
      s = close(s.copy());
      expect(s.court.firstWhere((c) => c.id == id).lastInvestigation, isNull);
      s = close(s.copy());
      final c = s.court.firstWhere((c) => c.id == id);
      expect(c.lastInvestigation!.plot, 80);
      expect(c.lastInvestigation!.discontent, 67);
      expect(c.evidenceTurn, s.week);
      expect(evidenceExpires(s, c), s.week + 4);
      expect(s.court.firstWhere((c) => c.id == spyId).ability, ability + 1);
      expect(evidenceBlocked(s, c, 75), isNull);
      expect(s.copy().toJson(), s.toJson());
      final issued = c.evidenceTurn;
      for (var i = 0; i < 4; i++) {
        s.completedWeeks = issued + i - 1;
        expect(evidenceBlocked(s, c, 75), isNull);
      }
      s.completedWeeks = issued + 3;
      expect(evidenceBlocked(s, c, 75), contains('hết hạn'));
    },
  );

  test(
    'failure preserves previous report and expiry; fatal failure permanently vacates spy office',
    () {
      for (final fatal in [false, true]) {
        var s = fresh();
        final victim = target(s), investigator = spy(s);
        evidence(s, victim, 80);
        final previous = victim.lastInvestigation!.toJson(),
            issued = victim.evidenceTurn;
        final seat = courtOfficeFor(s, investigator.id)!.id;
        s = start(s);
        forceOutcome(s, success: false, fatal: fatal);
        s = close(close(s));
        final c = s.court.firstWhere((c) => c.id == victim.id);
        expect(c.lastInvestigation!.toJson(), previous);
        expect(c.evidenceTurn, issued);
        final agent = s.court.firstWhere((c) => c.id == investigator.id);
        expect(agent.dead, fatal);
        expect(agent.available, !fatal);
        expect(
          s.courtOffices.firstWhere((o) => o.id == seat).holderId,
          fatal ? '' : investigator.id,
        );
        expect(s.copy().court.firstWhere((c) => c.id == agent.id).dead, fatal);
      }
    },
  );

  test(
    'interrupted investigations cannot kill a spy or publish intelligence',
    () {
      var s = start(fresh());
      forceOutcome(s, success: false, fatal: true);
      final spyId = s.pending.single.covertMission!.spyId;
      target(s).available = false;
      s = close(close(s));
      expect(s.court.firstWhere((c) => c.id == spyId).dead, false);
      expect(s.outcomes.any((o) => o.status == 'interrupted'), true);
    },
  );

  test('strict demotion thresholds, expiry and exact rank limits', () {
    final s = fresh(), c = target(s);
    for (final entry
        in {
          50: [false, false],
          51: [true, false],
          60: [true, false],
          61: [true, true],
        }.entries) {
      evidence(s, c, entry.key);
      expect(courtDemotionBlocked(s, c, 1) == null, entry.value[0]);
      expect(courtDemotionBlocked(s, c, 2) == null, entry.value[1]);
    }
    evidence(s, c, 80);
    c.grade = 8;
    expect(courtDemotionBlocked(s, c, 1), isNull);
    expect(courtDemotionBlocked(s, c, 2), isNotNull);
    c.grade = 9;
    expect(courtDemotionBlocked(s, c, 1), isNotNull);
    c.grade = 1;
    s.completedWeeks = 4;
    expect(courtDemotionBlocked(s, c, 1), contains('hết hạn'));
  });

  test(
    'a prince loses his title on demotion and costs one action and only two faction points',
    () {
      final s = fresh(), c = target(s);
      evidence(s, c, 61);
      final office = courtOfficeFor(s, c.id)!;
      final after = engine.execute(
        s,
        command(s, 'demote-court', target: c.id, option: '1'),
      );
      final demoted = courtPerson(after, c.id)!;
      expect(demoted.grade, 2);
      expect(demoted.role, 'Chờ bổ nhiệm');
      expect(
        after.courtOffices.firstWhere((o) => o.id == office.id).holderId,
        '',
      );
      expect(demoted.royalEligible, true);
      expect(after.points, s.points - 1);
      expect(after.treasury, s.treasury);
      expect(after.stability, s.stability);
      expect(after.authority, s.authority);
      expect(after.factions[c.faction], s.factions[c.faction]! - 2);
      final doubleDrop = engine.execute(
        s,
        command(s, 'demote-court', target: c.id, option: '2'),
      );
      expect(courtPerson(doubleDrop, c.id)!.grade, 3);
      expect(doubleDrop.factions[c.faction], s.factions[c.faction]! - 2);
    },
  );

  test(
    'conviction uses verified report, removes rank and posting, and cannot be replayed or used after expiry',
    () {
      final s = fresh(), c = target(s);
      evidence(s, c, 80);
      c.plot = 20;
      final seat = courtOfficeFor(s, c.id)!.id;
      final changed = engine.execute(s, command(s, 'convict', target: c.id));
      final prisoner = changed.court.firstWhere((p) => p.id == c.id);
      expect(prisoner.imprisoned, true);
      expect(prisoner.available, false);
      expect(prisoner.grade, 0);
      expect(changed.courtOffices.firstWhere((o) => o.id == seat).holderId, '');
      expect(changed.stability, s.stability);
      expect(changed.authority, s.authority);
      expect(changed.points, s.points - 1);
      expect(changed.factions[c.faction], s.factions[c.faction]! - 5);
      expect(
        () =>
            engine.execute(changed, command(changed, 'convict', target: c.id)),
        throwsA(isA<GameRuleException>()),
      );
      s.completedWeeks = 4;
      expect(
        () => engine.execute(s, command(s, 'convict', target: c.id)),
        throwsA(isA<GameRuleException>()),
      );
      expect(
        changed.copy().court.firstWhere((p) => p.id == c.id).imprisoned,
        true,
      );
    },
  );

  test(
    'imprisoning a manager or queen stops their contributions and leaves their office vacant',
    () {
      for (final queen in [false, true]) {
        final s = fresh();
        const post = ManagementPost('prefect', 'bac-son');
        final c =
            queen
                ? s.court.firstWhere((c) => c.isConsort)
                : managementHolder(s, post)!;
        if (queen) {
          c.inHarem = c.queen = true;
        }
        evidence(s, c, 76);
        final changed = engine.execute(s, command(s, 'convict', target: c.id));
        final prisoner = changed.court.firstWhere((p) => p.id == c.id);
        expect(prisoner.inHarem, false);
        expect(prisoner.queen, false);
        if (!queen) {
          expect(managementHolder(changed, post), isNull);
          expect(managementDirection(changed, post), -1);
        }
      }
    },
  );

  test(
    'vacancy petition promotes and appoints for promotion fee and merit, waiving ability and affection',
    () {
      final s = fresh(), old = target(s);
      evidence(s, old, 61);
      var changed = engine.execute(
        s,
        command(s, 'demote-court', target: old.id, option: '1'),
      );
      final seat = changed.courtOffices.firstWhere(
        (o) => o.role == 'Thân vương',
      );
      final c =
          changed.officialsPool.first
            ..grade = 2
            ..ability = 20
            ..affection = 10
            ..merit = 100
            ..majorMerits = 4
            ..royalEligible = true;
      final quote = vacancyPromotion(changed, c, seat),
          m = nomination(changed, seat, c);
      expect(courtPersonnelChoiceBlocked(changed, m, 0), isNull);
      final before = changed.copy();
      changed = engine.execute(
        changed,
        command(changed, 'petition', target: m.id, option: '0'),
      );
      final appointed = courtPerson(changed, c.id)!;
      expect(appointed.grade, 1);
      expect(appointed.role, 'Thân vương');
      expect(changed.treasury, before.treasury - quote.cost);
      expect(changed.points, before.points - 1);
      expect(appointed.merit, 100 - quote.merit);
      expect(changed.stability, before.stability);
      expect(changed.authority, before.authority);
      expect(
        courtOfficeDirection(
          changed,
          changed.courtOffices.firstWhere((o) => o.id == seat.id),
        ),
        0,
      );
    },
  );

  test(
    'conviction recalls an army without losing or duplicating its soldiers',
    () {
      var s = fresh();
      final id = target(s).id;
      s = engine.execute(
        s,
        command(
          s,
          'war',
          target: 'north',
          option: jsonEncode({'action': 'declare'}),
        ),
      );
      final mission = s.warfare!.missions.first;
      s = engine.execute(
        s,
        GameCommand(
          id: 'deployment',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'war',
          target: mission.id,
          option: jsonEncode({'action': 'deploy', 'ratio': 1}),
          assigneeId: id,
        ),
      );
      final soldiers = s.population!.soldiers,
          stationed = s.population!.stationed('north');
      evidence(s, s.court.firstWhere((c) => c.id == id), 80);
      final before = s.copy();
      s = engine.execute(s, command(s, 'convict', target: id));
      expect(s.points, before.points - 1);
      expect(s.stability, before.stability);
      expect(s.authority, before.authority);
      expect(
        s.warfare!.missions.firstWhere((m) => m.id == mission.id).status,
        'returning',
      );
      expect(s.population!.deployments.single.losses, 0);
      expect(s.population!.soldiers, soldiers);
      expect(s.population!.stationed('north'), stationed);
      s = close(s);
      expect(s.population!.deployments, isEmpty);
      expect(
        s.population!.garrisons.values.fold<int>(
          0,
          (sum, count) => sum + count,
        ),
        s.population!.soldiers,
      );
      expect(
        s.warfare!.reports.any(
          (r) => r['missionId'] == mission.id && r['result'] == 'recalled',
        ),
        true,
      );
    },
  );

  test(
    'historical intelligence does not fabricate a successful evidence certificate',
    () {
      final s = fresh(), c = target(s);
      c.lastInvestigation = const CharacterInvestigation(
        week: 1,
        plot: 99,
        discontent: 99,
      );
      c.investigated = true;
      final raw = s.toJson();
      for (final person in raw['court'] as List) {
        (person as Map).remove('evidenceTurn');
        person.remove('imprisoned');
        person.remove('dead');
      }
      final restored = GameState.fromJson(raw),
          person = restored.court.firstWhere((p) => p.id == c.id);
      expect(person.evidenceTurn, 0);
      expect(person.imprisoned, false);
      expect(person.dead, false);
      expect(evidenceBlocked(restored, person, 75), contains('thành công'));
      expect(person.lastInvestigation!.plot, 99);
    },
  );

  test(
    'vacancy exception keeps merit, major achievement, royal ancestry and busy requirements',
    () {
      final s = fresh(), seat = courtOfficeFor(s, target(s).id)!;
      seat.holderId = '';
      final c =
          s.officialsPool.first
            ..grade = 2
            ..ability = 1
            ..affection = 1
            ..royalEligible = true
            ..merit = 0
            ..majorMerits = 4;
      expect(vacancyNominationBlocked(s, c, seat), contains('công trạng'));
      c.merit = 100;
      c.majorMerits = 0;
      expect(vacancyNominationBlocked(s, c, seat), contains('thành tích'));
      c.majorMerits = 4;
      c.royalEligible = false;
      expect(vacancyNominationBlocked(s, c, seat), contains('thân phận'));
      c.royalEligible = true;
      expect(vacancyNominationBlocked(s, c, seat), isNull);
    },
  );

  test(
    'gateway receipts protect mission rolls and discipline from duplicate dispatch',
    () async {
      final store = MemoryGameStore();
      final s = fresh();
      evidence(s, target(s), 80);
      await store.update((a) => a.active = s);
      final gateway = LocalGameGateway(store);
      final order = command(
        s,
        'investigate',
        target: target(s).id,
        option: jsonEncode({'spy': spy(s).id, 'funding': 40}),
      );
      final first = await gateway.dispatch(order);
      final repeated = await gateway.dispatch(order);
      expect(repeated.toJson(), first.toJson());
      final next = first.active!,
          punish = command(
            next,
            'demote-court',
            target: target(next).id,
            option: '2',
          );
      final done = await gateway.dispatch(punish);
      expect((await gateway.dispatch(punish)).toJson(), done.toJson());
    },
  );
}
