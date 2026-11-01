import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/management_rules.dart';
import 'package:van_tue/game/logic/court_rules.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/frontier_rules.dart';
import 'package:van_tue/game/logic/population_rules.dart';
import 'package:van_tue/game/logic/warfare_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

final engine = GameEngine();
const camp = ManagementPost('camp', 'north');
const command = ManagementPost('command', 'north');
const prefectA = ManagementPost('prefect', 'bac-son');
const prefectB = ManagementPost('prefect', 'dong-hai');
const assistantB = ManagementPost('assistant', 'dong-hai');

GameState fresh() {
  final s = engine.start('management', 'Thiên Hòa', 42);
  s.petitions.clear();
  s.nextMajorWeek = s.nextChainWeek = 100000;
  s.nextCourtPersonnelTurn = 100000;
  s.factions.updateAll((k, v) => 80);
  for (final c in s.court) {
    c.loyalty = c.integrity = 100;
    c.affection = 40;
  }
  return s;
}

GameCommand request(
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

GameState close(GameState s) {
  s.petitions.clear();
  s.health = s.authority = s.stability = 90;
  s.people = 50;
  s.workThisWeek = s.affairsThisWeek = 1;
  s.treasury = 500000;
  s.grain = 7000000;
  s.financialWeeks.clear();
  return engine.execute(s, request(s, 'endWeek'));
}

Courtier qualify(GameState s, ManagementPost post) =>
    managementHolder(s, post)!
      ..ability = post.abilityThreshold + 1
      ..affection = 100;

Courtier candidate(GameState s, ManagementPost post, {int grade = 6}) {
  final c = s.officialsPool.firstWhere((c) => c.available && !c.retired);
  c.courtGroup = post.group;
  c.grade = grade;
  c.affection = 60;
  return c;
}

void main() {
  test(
    'new reign fills twelve distinct positions, three VI military governors and three civil prefects',
    () {
      final s = fresh();
      expect(s.managementVersion, 1);
      expect(managementPosts, hasLength(12));
      final holders =
          managementPosts.map((p) => managementHolder(s, p)!).toList();
      expect(holders.map((c) => c.id).toSet(), hasLength(12));
      expect(s.court.where((c) => c.role == 'Trấn thủ'), hasLength(3));
      expect(s.court.where((c) => c.role == 'Tri phủ'), hasLength(3));
      for (final post in managementPosts) {
        final c = managementHolder(s, post)!;
        expect(c.category, post.group);
        if (post.senior) expect(c.grade, 6);
        expect(courtOfficeFor(s, c.id)!.id, post.id);
      }
      expect(s.copy().toJson(), s.toJson());
    },
  );

  test('strict ability and affection thresholds do not block appointment', () {
    final s = fresh();
    for (final p in managementPosts) {
      final c = managementHolder(s, p)!;
      c.ability = p.abilityThreshold;
      c.affection = p.affectionThreshold + 1;
      expect(managementDirection(s, p), 0);
      c.ability++;
      c.affection = p.affectionThreshold;
      expect(managementDirection(s, p), 0);
      c.affection++;
      expect(managementDirection(s, p), 1);
      c.ability = p.abilityThreshold;
      c.managementGrowthHalf = 1;
      expect(managementDirection(s, p), 1);
      expect(c.abilityScore, p.abilityThreshold + .5);
      c.managementGrowthHalf = 0;
    }
    final c = candidate(s, camp, grade: 0)..ability = 10;
    expect(managementCandidateBlocked(s, c, camp), isNull);
    expect(managementCandidateBlocked(s, c, command), contains('Lục phẩm'));
  });

  test(
    'camp contributes once per two qualified seasons, only to its own pass',
    () {
      var s = fresh();
      qualify(s, camp);
      final north = s.population!.trainingAt('north');
      s = close(s);
      expect(s.population!.trainingAt('north'), north);
      expect(managementOffice(s, camp)!.passiveProgress, 1);
      s = close(s.copy());
      expect(s.population!.trainingAt('north'), north + 1);
      expect(s.population!.trainingAt('west'), 60);
      expect(s.population!.trainingAt('south'), 60);
      expect(s.population!.trainingAt('capital'), 60);
    },
  );

  test(
    'vacancies reverse effects at their own cadence, unqualified holders remain neutral',
    () {
      var s = fresh();
      managementOffice(s, camp)!.holderId = '';
      final morale = s.population!.moraleAt('north');
      managementOffice(s, command)!.holderId = '';
      s = close(s);
      expect(s.population!.trainingAt('north'), 60);
      expect(s.population!.moraleAt('north'), morale - 1);
      s = close(s);
      expect(s.population!.trainingAt('north'), 59);
      expect(s.population!.trainingAt('west'), 60);
      expect(s.population!.moraleAt('north'), morale - 2);
      expect(s.population!.moraleAt('west'), morale);
    },
  );

  test(
    'levee contributions accumulate independently across two/four seasons and save/load',
    () {
      var s = fresh();
      qualify(s, prefectB);
      qualify(s, assistantB);
      final baseline = fresh();
      var without = baseline;
      for (var i = 1; i <= 4; i++) {
        s = close(s.copy());
        without = close(without.copy());
        expect(s.levee - without.levee, i ~/ 2 + i ~/ 4, reason: 'season $i');
      }
    },
  );

  test(
    'prefect and assistant population bonuses add; vacancies subtract independently',
    () {
      var active = fresh(), neutral = fresh(), vacant = fresh();
      qualify(active, prefectA);
      qualify(active, const ManagementPost('assistant', 'bac-son'));
      managementOffice(vacant, prefectA)!.holderId = '';
      managementOffice(vacant, const ManagementPost('assistant', 'bac-son'))!
          .holderId = '';
      active = close(active);
      neutral = close(neutral);
      vacant = close(vacant);
      // Passive arrivals are present for this season's population accounting.
      expect(
        active.population!.population,
        greaterThan(neutral.population!.population + 299),
      );
      expect(
        vacant.population!.population,
        lessThan(neutral.population!.population - 299),
      );
    },
  );

  test(
    'military production adds +100/+50 or -100/-50 to the seasonal workshop output',
    () {
      final s = fresh();
      final base = manufacturedEquipment(s);
      const prefect = ManagementPost('prefect', 'tay-linh');
      const assistant = ManagementPost('assistant', 'tay-linh');
      qualify(s, prefect);
      qualify(s, assistant);
      expect(manufacturedEquipment(s), base + 150);
      managementOffice(s, prefect)!.holderId = '';
      expect(manufacturedEquipment(s), base - 50);
      managementOffice(s, assistant)!.holderId = '';
      expect(manufacturedEquipment(s), base - 150);
    },
  );

  test(
    'automatic growth carries half points, stops at caps and does not lower skilled officials',
    () {
      var s = fresh();
      final junior = managementHolder(s, camp)!..ability = 59;
      final senior = managementHolder(s, command)!..ability = 69;
      final expert = managementHolder(s, prefectA)!..ability = 85;
      s = close(s);
      expect(courtPerson(s, junior.id)!.ability, 60);
      expect(courtPerson(s, senior.id)!.ability, 69);
      expect(courtPerson(s, senior.id)!.managementGrowthHalf, 1);
      expect(courtPerson(s, senior.id)!.abilityScore, 69.5);
      expect(courtPerson(s, senior.id)!.abilityLabel, '69,5');
      s = close(s.copy());
      expect(courtPerson(s, senior.id)!.ability, 70);
      expect(courtPerson(s, expert.id)!.ability, 85);
      expect(managementDirection(s, command), 0);
      s = close(s);
      expect(courtPerson(s, junior.id)!.ability, 60);
      expect(courtPerson(s, senior.id)!.ability, 70);
    },
  );

  test(
    'replacement is exactly 1000/one action, retains outgoing rank and ongoing work',
    () {
      final s = fresh();
      final old = managementHolder(s, camp)!..affection = 100;
      final grade = old.grade;
      final next = candidate(s, camp, grade: 9);
      s.projects.add(
        WorkOrder(
          id: 'ongoing',
          kind: 'repair',
          officerId: old.id,
          startedWeek: s.week,
          duration: 2,
        ),
      );
      final changed = engine.execute(
        s,
        request(s, 'appoint-manager', target: camp.id, option: next.id),
      );
      expect(changed.treasury, s.treasury - 1000);
      expect(changed.points, s.points - 1);
      expect(managementHolder(changed, camp)!.id, next.id);
      final outgoing = courtPerson(changed, old.id)!;
      expect(outgoing.grade, grade);
      expect(outgoing.affection, 90);
      expect(outgoing.role, 'Chờ bổ nhiệm');
      expect(courtOfficeFor(changed, old.id), isNull);
      expect(changed.court.any((c) => c.id == old.id), isTrue);
      expect(changed.projects.single.officerId, old.id);
      expect(courtPerson(changed, next.id)!.affection, 65);
      expect(changed.stability, s.stability);
      expect(changed.factions, s.factions);
    },
  );

  test(
    'appointment enforces one posting, group and VI rank, and failures are atomic',
    () {
      final s = fresh();
      final c = candidate(s, prefectA, grade: 7);
      final snapshot = jsonEncode(s.toJson());
      expect(
        () => engine.execute(
          s,
          request(s, 'appoint-manager', target: prefectA.id, option: c.id),
        ),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), snapshot);
      final moving = managementHolder(s, camp)!;
      const destination = ManagementPost('camp', 'west');
      final transferred = engine.execute(
        s,
        request(
          s,
          'appoint-manager',
          target: destination.id,
          option: moving.id,
        ),
      );
      expect(managementHolder(transferred, destination)!.id, moving.id);
      expect(managementHolder(transferred, camp), isNull);
      expect(
        transferred.courtOffices.where((o) => o.holderId == moving.id),
        hasLength(1),
      );
      expect(managementCandidateBlocked(s, c, camp), contains('Võ ban'));
      c.grade = 6;
      s.points = 0;
      expect(
        () => engine.execute(
          s,
          request(s, 'appoint-manager', target: prefectA.id, option: c.id),
        ),
        throwsA(isA<GameRuleException>()),
      );
      s.points = 3;
      s.treasury = 999;
      expect(
        () => engine.execute(
          s,
          request(s, 'appoint-manager', target: prefectA.id, option: c.id),
        ),
        throwsA(isA<GameRuleException>()),
      );
    },
  );

  test(
    'managers can receive missions and appointments can occur during an existing mission',
    () {
      final s = fresh();
      final c = managementHolder(s, camp)!;
      expect(taskOfficers(s, 'train').any((p) => p.id == c.id), isTrue);
      final next = candidate(s, camp);
      s.projects.add(
        WorkOrder(
          id: 'candidate-work',
          kind: 'repair',
          officerId: next.id,
          startedWeek: s.week,
          duration: 2,
        ),
      );
      final changed = engine.execute(
        s,
        request(s, 'appoint-office', target: camp.id, option: next.id),
      );
      expect(managementHolder(changed, camp)!.id, next.id);
      expect(changed.projects.single.officerId, next.id);
      expect(changed.treasury, s.treasury - 1000);
    },
  );

  test(
    'local qualities determine defense and war preview, global effects preserve differences',
    () {
      final s = fresh();
      final p = s.population!;
      p.setTrainingAt('north', 20);
      p.setMoraleAt('north', 30);
      p.setTrainingAt('west', 80);
      p.setMoraleAt('west', 90);
      final north = s.warfare!.neighbors.firstWhere((n) => n.id == 'north');
      final west = s.warfare!.neighbors.firstWhere((n) => n.id == 'west');
      expect(
        FrontierDefense(s, west).defense,
        greaterThan(FrontierDefense(s, north).defense),
      );
      final leader = warOfficers(s).first;
      final m = WarMission(
        id: 'quality',
        countryId: 'north',
        kind: 'battle',
        title: 'Trận đánh',
        opened: 1,
        deadline: 2,
        enemyTroops: 5000,
      );
      final low = WarPreview(s, m, 5000, leader, null).tacticalChance;
      p.setTrainingAt('north', 90);
      p.setMoraleAt('north', 90);
      expect(
        WarPreview(s, m, 5000, leader, null).tacticalChance,
        greaterThan(low),
      );
      p.setTrainingAt('north', 20);
      p.changeTraining(5);
      expect(p.trainingAt('north'), 25);
      expect(p.trainingAt('west'), 85);
      expect(s.copy().population!.trainingAt('north'), 25);
    },
  );

  test(
    'transfers blend destination qualities and preserve national weighted averages',
    () {
      final s = fresh();
      final p = s.population!;
      p.setTrainingAt('north', 30);
      p.setMoraleAt('north', 40);
      p.setTrainingAt('west', 90);
      p.setMoraleAt('west', 80);
      final training = p.training, morale = p.morale;
      final changed = engine.execute(
        s,
        request(
          s,
          'transfer',
          target: 'west',
          option: jsonEncode({'from': 'north', 'count': 5000}),
        ),
      );
      expect(changed.population!.trainingAt('west'), 70);
      expect(changed.population!.moraleAt('west'), closeTo(200 / 3, .00001));
      expect(changed.population!.trainingAt('north'), 30);
      expect(changed.population!.training, closeTo(training, .00001));
      expect(changed.population!.morale, closeTo(morale, .00001));
    },
  );

  test(
    'historical saves import global qualities and initialize management exactly once without RNG',
    () {
      final original = fresh();
      final raw =
          jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>;
      raw.remove('managementVersion');
      raw.remove('lastManagementTurn');
      raw['courtOffices'] =
          (raw['courtOffices'] as List)
              .where((o) => !(o['id'] as String).startsWith('management-'))
              .toList();
      raw['court'] =
          (raw['court'] as List)
              .where((c) => !(c['id'] as String).startsWith('manager-'))
              .toList();
      final pop = raw['population'] as Map;
      pop['training'] = 47.5;
      pop['morale'] = 53.5;
      for (final key in [
        'capitalTraining',
        'capitalMorale',
        'frontierTraining',
        'frontierMorale',
      ]) {
        pop.remove(key);
      }
      final before = jsonEncode(raw);
      final migrated = GameState.fromJson(raw);
      expect(jsonEncode(raw), before);
      expect(migrated.rng, original.rng);
      expect(migrated.population!.trainingAt('north'), 47.5);
      expect(migrated.population!.moraleAt('west'), 53.5);
      expect(migrated.copy().toJson(), migrated.toJson());
      final count = migrated.court.length;
      managementOffice(migrated, camp)!.holderId = '';
      expect(managementHolder(migrated.copy(), camp), isNull);
      expect(migrated.copy().court.length, count);
    },
  );

  test(
    'real 0.24 roster migration preserves ranks, vacancies and pending personnel references',
    () {
      final original = fresh();
      final raw =
          jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>;
      raw['rulesVersion'] = 'mvp-0.24.0';
      raw['contentVersion'] = 21;
      raw.remove('managementVersion');
      raw.remove('lastManagementTurn');
      final people =
          (raw['court'] as List)
              .cast<Map<String, dynamic>>()
              .where((c) => !(c['id'] as String).startsWith('manager-'))
              .toList();
      final offices =
          (raw['courtOffices'] as List)
              .cast<Map<String, dynamic>>()
              .where((o) => !(o['id'] as String).startsWith('management-'))
              .toList();
      String? prefectId, prefectOffice, commandId;
      for (final post in managementPosts) {
        final c =
            people
                .where((c) => c['id'] == managementHolder(original, post)?.id)
                .firstOrNull;
        if (c == null) continue;
        final role = post.kind == 'assistant' ? 'Tri phủ' : post.role;
        c['role'] = role;
        c['courtGroup'] = post.frontier ? 'Võ ban' : 'Địa phương';
        if (post.kind == 'command') {
          c['grade'] = 4;
          commandId = c['id'];
        }
        final officeId = 'office-${c['id']}';
        offices.add(
          CourtOffice(
            id: officeId,
            role: role,
            group: c['courtGroup'],
            grade: c['grade'],
            holderId: c['id'],
          ).toJson(),
        );
        if (post.kind == 'prefect' && prefectId == null) {
          prefectId = c['id'];
          prefectOffice = officeId;
        }
      }
      expect(offices, hasLength(46));
      // A historical vacant prefect must remain vacant after upgrading.
      offices.firstWhere(
            (o) => o['role'] == 'Tri phủ' && o['id'] != prefectOffice,
          )['holderId'] =
          '';
      raw['court'] = people;
      raw['courtOffices'] = offices;
      raw['courtPersonnelMatters'] = [
        CourtPersonnelMatter(
          id: 'old-petition',
          kind: 'reform',
          personId: prefectId!,
          sponsorId: people.first['id'],
          officeId: prefectOffice!,
          holderId: prefectId,
          openedTurn: 1,
        ).toJson(),
      ];
      raw['courtPersonnelRewarded'] = ['$prefectId:$prefectOffice'];
      final before = jsonEncode(raw);
      final upgraded = GameState.fromJson(raw);
      expect(jsonEncode(raw), before);
      expect(upgraded.rng, original.rng);
      expect(upgraded.treasury, original.treasury);
      expect(upgraded.points, original.points);
      expect(courtPerson(upgraded, commandId!)!.grade, 4);
      expect(managementOffice(upgraded, command)!.grade, 6);
      expect(
        upgraded.courtOffices.where((o) => o.role == 'Tri phủ'),
        hasLength(3),
      );
      expect(
        managementOffice(
          upgraded,
          const ManagementPost('prefect', 'dong-hai'),
        )!.holderId,
        '',
      );
      final matter = upgraded.courtPersonnelMatters.single;
      expect(matter.officeId, prefectA.id);
      expect(
        upgraded.courtPersonnelRewarded,
        contains('$prefectId:${prefectA.id}'),
      );
      expect(upgraded.copy().toJson(), upgraded.toJson());
    },
  );
}
