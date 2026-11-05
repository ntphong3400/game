import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/court_personnel_petitions.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/court_rules.dart';
import 'package:van_tue/game/logic/court_personnel_rules.dart';
import 'package:van_tue/game/logic/currency_rules.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

final engine = GameEngine();
GameState fresh([int seed = 42]) {
  final s = engine.start('personnel', 'An', seed);
  s.petitions.clear();
  s.courtPersonnelMatters.clear();
  s.nextCourtPersonnelTurn = s.nextMajorWeek = s.nextChainWeek = 100000;
  s.authority = 95;
  s.stability = 90;
  s.health = 100;
  s.factions.updateAll((_, v) => 65);
  for (final c in s.court) {
    c.loyalty = c.integrity = 95;
    c.ambition = c.plot = c.discontent = 0;
  }
  return s;
}

GameState send(
  GameState s,
  String type, [
  String target = '',
  String option = '',
  String assignee = '',
]) => engine.execute(
  s,
  GameCommand(
    id: 'p-${s.revision}',
    runId: s.runId,
    expectedRevision: s.revision,
    type: type,
    target: target,
    option: option,
    assigneeId: assignee,
  ),
);
CourtOffice office(GameState s, String role) =>
    s.courtOffices.firstWhere((o) => o.role == role);
Courtier holder(GameState s, CourtOffice o) => courtOfficeHolder(s, o)!;
void vacate(GameState s, CourtOffice o) {
  final c = holder(s, o);
  s.court.remove(c);
  s.officialsPool.add(c);
  c.role = 'Chờ bổ nhiệm';
  o.holderId = '';
}

Courtier nominee(GameState s, CourtOffice o) {
  final c = s.officialsPool.first;
  c.grade = o.grade;
  c.ability = 95;
  c.affection = 100;
  c.specialty = specialtyForRole(o.role);
  c.royalEligible = true;
  return c;
}

CourtPersonnelMatter open(
  GameState s,
  String kind,
  Courtier c, {
  CourtOffice? seat,
  int grade = 0,
}) {
  final sponsor = s.court.firstWhere(
    (a) =>
        !a.isConsort &&
        a.id != c.id &&
        a.faction == factionOpponents[c.faction],
  );
  final m = CourtPersonnelMatter(
    id: 'test-${s.courtPersonnelMatters.length}',
    kind: kind,
    personId: c.id,
    sponsorId: sponsor.id,
    openedTurn: s.week,
    officeId: seat?.id ?? '',
    holderId: seat?.holderId ?? '',
    targetGrade: grade,
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

GameState resolve(
  GameState s,
  CourtPersonnelMatter m,
  int index, [
  String candidate = '',
]) => send(s, 'petition', m.id, '$index', candidate);
GameState close(GameState s) {
  s.workThisWeek = s.affairsThisWeek = 1;
  return send(s, 'endWeek');
}

void main() {
  test(
    'each office grade has the exact 1–8 disruption regardless of personal influence',
    () {
      final expected = {1: 8, 2: 7, 3: 6, 4: 5, 5: 4, 6: 3, 7: 2, 8: 1, 9: 1};
      for (final grade in expected.keys) {
        for (final influence in [0, 100]) {
          final s = fresh();
          final o = s.courtOffices.firstWhere((o) => o.grade == grade);
          final c = holder(s, o)..influence = influence;
          final before = s.toJson();
          final result = send(s, 'dismiss-office', o.id);
          expect(result.stability, s.stability - expected[grade]!);
          expect(result.treasury, s.treasury);
          expect(result.points, s.points - 1);
          final retired = courtPerson(result, c.id)!;
          expect(retired.retired, isTrue);
          expect(retired.role, 'Đã hồi hương');
          expect(retired.grade, c.grade);
          expect(retired.merit, c.merit);
          expect(s.toJson(), before);
        }
      }
    },
  );
  test(
    'authority comparisons are strictly greater and junior offices need no authority',
    () {
      for (final entry in {1: 80, 2: 70, 3: 60, 4: 50}.entries) {
        final s = fresh()..authority = entry.value;
        final o = s.courtOffices.firstWhere((o) => o.grade == entry.key);
        final before = s.toJson();
        expect(courtDismissalBlocked(s, o), contains('trên ${entry.value}'));
        expect(
          () => send(s, 'dismiss-office', o.id),
          throwsA(isA<GameRuleException>()),
        );
        expect(s.toJson(), before);
        s.authority++;
        expect(courtDismissalBlocked(s, o), isNull);
        expect(courtOfficeHolder(send(s, 'dismiss-office', o.id), o), isNull);
      }
      final s = fresh()..authority = 1;
      final junior = s.courtOffices.firstWhere((o) => o.grade == 9);
      expect(courtDismissalBlocked(s, junior), isNull);
    },
  );
  test(
    'replacement, transfer, swap and backfill cannot bypass outgoing office authority',
    () {
      for (final type in ['appoint-office', 'swap-office', 'appoint']) {
        final s = fresh()..authority = 80;
        final general = office(s, 'Đại tướng');
        final candidate = s.officialsPool.first..grade = 1;
        final before = s.toJson();
        expect(
          () => send(
            s,
            type,
            type == 'appoint' ? general.holderId : general.id,
            candidate.id,
          ),
          throwsA(isA<GameRuleException>()),
        );
        expect(s.toJson(), before);
      }
      final s = fresh()..authority = 80;
      final source = office(s, 'Đại tướng');
      final destination = office(s, 'Thư lại');
      final general = holder(s, source);
      vacate(s, destination);
      final backfill = s.officialsPool.first..grade = 1;
      expect(
        courtAppointmentBlocked(s, general, destination),
        contains('trên 80'),
      );
      expect(
        () => send(s, 'appoint-office', destination.id, general.id),
        throwsA(isA<GameRuleException>()),
      );
      expect(
        () => send(
          s,
          'appoint-office',
          destination.id,
          jsonEncode({'candidate': general.id, 'backfill': backfill.id}),
        ),
        throwsA(isA<GameRuleException>()),
      );
    },
  );
  test(
    'a permitted transfer counts both vacated seats once and empty appointment requires no authority',
    () {
      final s = fresh();
      final source = office(s, 'Đại tướng'), destination = office(s, 'Thư lại');
      final c = holder(s, source);
      final result = send(s, 'appoint-office', destination.id, c.id);
      expect(
        result.stability,
        s.stability -
            courtOfficeDisruption(source) -
            courtOfficeDisruption(destination),
      );
      final empty = fresh()..authority = 1;
      final o = office(empty, 'Đại tướng');
      vacate(empty, o);
      final candidate = nominee(empty, o)..retired = true;
      final recalled = send(empty, 'appoint-office', o.id, candidate.id);
      expect(courtPerson(recalled, candidate.id)!.retired, isFalse);
      expect(recalled.stability, empty.stability);
    },
  );
  test(
    'nomination spends the promotion cost and rewards only after a full qualified season',
    () {
      var s = fresh();
      final o = office(s, 'Thư lại');
      vacate(s, o);
      final c = nominee(s, o);
      final m = open(s, 'nominate', c, seat: o);
      final sponsorMerit = courtPerson(s, m.sponsorId)!.merit;
      final price = vacancyPromotion(s, c, o).cost;
      s = resolve(s, m, 0);
      expect(s.points, 11);
      expect(s.treasury, 50000 - price);
      expect(s.courtPersonnelMatters.last.status, 'watching');
      expect(courtPerson(s, m.sponsorId)!.merit, sponsorMerit);
      s = close(s);
      expect(courtPerson(s, m.sponsorId)!.merit, sponsorMerit);
      s = GameState.fromJson(s.toJson());
      s = close(s);
      expect(courtPerson(s, m.sponsorId)!.merit, sponsorMerit + 2);
      expect(s.courtPersonnelRewarded, contains(m.rewardKey));
      final awarded = courtPerson(s, m.sponsorId)!.merit;
      s = close(s);
      expect(courtPerson(s, m.sponsorId)!.merit, awarded);
    },
  );
  test(
    'alternative nominees use their own fees and cannot inject an invalid candidate',
    () {
      final s = fresh();
      final o = office(s, 'Thư lại');
      vacate(s, o);
      final c = nominee(s, o);
      final m = open(s, 'nominate', c, seat: o);
      expect(courtPersonnelChoiceBlocked(s, m, 1), contains('chọn người'));
      expect(
        () => resolve(s, m, 1, 'missing'),
        throwsA(isA<GameRuleException>()),
      );
      final alternate = s.officialsPool[1]..grade = 8;
      final price = vacancyPromotion(s, alternate, o).cost;
      final event = courtPersonnelEvent(s, m, nomineeId: alternate.id);
      expect(event.choices[1].cost, price);
      final result = resolve(s, m, 1, alternate.id);
      expect(result.courtPersonnelMatters.last.personId, alternate.id);
      expect(result.treasury, s.treasury - price);
      expect(courtOfficeFor(result, alternate.id)!.id, o.id);
    },
  );
  test('leaving and returning cannot farm nomination merit', () {
    var s = fresh();
    final o = office(s, 'Thư lại');
    vacate(s, o);
    final c = nominee(s, o);
    final m = open(s, 'nominate', c, seat: o);
    final merit = courtPerson(s, m.sponsorId)!.merit;
    s = resolve(s, m, 0);
    s = send(s, 'dismiss-office', o.id);
    expect(s.courtPersonnelMatters.last.status, 'closed');
    s = send(s, 'appoint-office', o.id, c.id);
    s = close(close(s));
    expect(courtPerson(s, m.sponsorId)!.merit, merit);
  });
  test('unqualified nominees receive no reward', () {
    var s = fresh();
    final o = office(s, 'Thư lại');
    vacate(s, o);
    final c = nominee(s, o)..ability = 20;
    final m = open(s, 'nominate', c, seat: o);
    final before = courtPerson(s, m.sponsorId)!.merit;
    s = resolve(s, m, 0);
    s = close(close(s));
    expect(s.courtPersonnelMatters.last.status, 'unqualified');
    expect(courtPerson(s, m.sponsorId)!.merit, before);
  });
  test(
    'retirement petitions keep authority checks, full costs and faction consequences',
    () {
      final s = fresh();
      final o = office(s, 'Đại tướng');
      final c = holder(s, o);
      final m = open(s, 'retire', c, seat: o);
      s.authority = 80;
      expect(courtPersonnelChoiceBlocked(s, m, 0), contains('trên 80'));
      expect(() => resolve(s, m, 0), throwsA(isA<GameRuleException>()));
      s.authority = 81;
      final sponsor = courtPerson(s, m.sponsorId)!;
      final result = resolve(s, m, 0);
      expect(result.stability, s.stability - 8);
      expect(result.points, s.points - 1);
      expect(result.factions[c.faction], s.factions[c.faction]! - 4);
      expect(
        result.factions[sponsor.faction],
        s.factions[sponsor.faction]! + 3,
      );
      expect(result.courtPersonnelMatters.last.status, 'completed');
    },
  );
  test(
    'regular and exceptional promotion share merit and fees but only a patronage petition waives ability',
    () {
      for (final exceptional in [false, true]) {
        final s = fresh();
        final c = holder(s, office(s, 'Thư lại'))..merit = 10;
        c.ability = exceptional ? 20 : 70;
        final m = open(s, exceptional ? 'patronage' : 'promote', c, grade: 8);
        if (exceptional) {
          expect(
            () => send(s, 'promote', c.id, '8'),
            throwsA(isA<GameRuleException>()),
          );
        }
        final quote = CourtPromotion(s, c, 8);
        final result = resolve(s, m, 0);
        final promoted = courtPerson(result, c.id)!;
        expect(promoted.grade, 8);
        expect(promoted.merit, 10 - quote.merit);
        expect(promoted.meritSpent, quote.merit);
        expect(result.treasury, s.treasury - quote.cost);
        expect(result.points, s.points - 1);
        expect(result.authority, s.authority + (exceptional ? -2 : 1));
        expect(result.stability, s.stability - (exceptional ? 1 : 0));
      }
    },
  );
  test(
    'an exceptional high grade does not enable office passives or grant ability',
    () {
      final s = fresh();
      final o = office(s, 'Hộ bộ');
      final c =
          holder(s, o)
            ..grade = 3
            ..ability = 20
            ..affection = 100
            ..merit = 100
            ..majorMerits = 3;
      final m = open(s, 'patronage', c, grade: 2);
      final result = resolve(s, m, 0);
      expect(courtPerson(result, c.id)!.grade, 2);
      expect(courtPerson(result, c.id)!.ability, 20);
      expect(courtOfficeDirection(result, office(result, 'Hộ bộ')), 0);
      expect(
        courtPassiveBlocked(result, office(result, 'Hộ bộ')),
        contains('năng lực'),
      );
    },
  );

  test(
    'exceptional promotion still requires merit, major achievements and money',
    () {
      final s = fresh();
      final c = holder(s, office(s, 'Thư lại'))..ability = 10;
      final m = open(s, 'patronage', c, grade: 3);
      expect(courtPersonnelChoiceBlocked(s, m, 0), contains('công trạng'));
      c.merit = 100;
      expect(courtPersonnelChoiceBlocked(s, m, 0), contains('thành tích lớn'));
      c.majorMerits = 1;
      s.treasury = 0;
      expect(courtPersonnelChoiceBlocked(s, m, 0), contains('Ngân khố'));
    },
  );
  test(
    'assessment preserves the candidate and never silently appoints or retires',
    () {
      for (final kind in ['recruit', 'retire']) {
        var s = fresh();
        final o = office(s, 'Thư lại');
        if (kind == 'recruit') vacate(s, o);
        final c = kind == 'recruit' ? nominee(s, o) : holder(s, o);
        final m = open(s, kind, c, seat: o);
        final beforePerson = c.toJson();
        final treasury = s.treasury;
        s = resolve(s, m, 1);
        expect(s.courtPersonnelMatters.last.verified, isTrue);
        expect(
          eventForState(s, m.eventId).body,
          contains('Kết quả khảo hạch/đối chiếu'),
        );
        expect(s.courtPersonnelMatters.last.status, 'open');
        expect(s.petitions.single.deadline, s.week + 1);
        expect(courtPerson(s, c.id)!.toJson(), beforePerson);
        expect(s.treasury, treasury - (kind == 'recruit' ? money(s, 5) : 0));
      }
    },
  );
  test(
    'legacy paid training still completes without offering new training',
    () {
      var s = fresh();
      final o = office(s, 'Đại tướng');
      final c =
          holder(s, o)
            ..ability = 70
            ..affection = 70;
      final m = open(s, 'reform', c, seat: o);
      m.status = 'training';
      m.acceptedTurn = s.week;
      s.petitions.clear();
      s = GameState.fromJson(s.toJson());
      expect(officerBusy(s, c.id), isTrue);
      expect(courtDismissalBlocked(s, office(s, 'Đại tướng')), contains('bận'));
      s = close(s);
      expect(courtPerson(s, c.id)!.ability, 70);
      final untrained = s.copy();
      untrained.courtPersonnelMatters.last.status = 'closed';
      final control = close(untrained);
      s = close(s);
      expect(courtPerson(s, c.id)!.ability, 72);
      expect(
        courtPerson(s, c.id)!.affection,
        courtPerson(control, c.id)!.affection + 2,
      );
      expect(officerBusy(s, c.id), isFalse);
      expect(
        courtPassiveBlocked(s, office(s, 'Đại tướng')),
        contains('năng lực'),
      );
    },
  );
  test(
    'reform only generates with a qualified replacement from either roster',
    () {
      for (final source in ['none', 'court', 'pool', 'blocked', 'healthy']) {
        var generated = 0;
        for (var seed = 1; seed <= 40; seed++) {
          var s = fresh(seed);
          for (final c in [...s.court, ...s.officialsPool]) {
            c.ability = 20;
            c.affection = 40;
            c.merit = 0;
          }
          Courtier? replacement;
          if (source != 'none') {
            final target = office(s, 'Tể tướng');
            replacement =
                source == 'court'
                    ? holder(s, office(s, 'Thư lại'))
                    : s.officialsPool.first;
            replacement
              ..grade = target.grade
              ..ability = 90
              ..affection = 80
              ..specialty = specialtyForRole(target.role)
              ..royalEligible = true;
          }
          if (source == 'blocked') s.authority = 0;
          if (source == 'healthy') {
            for (final o in s.courtOffices.where(
              (o) => courtPassives(o).isNotEmpty,
            )) {
              holder(s, o)
                ..ability = 100
                ..affection = 100;
            }
          }
          s.lastCourtRecruitYear = s.year;
          s.nextCourtPersonnelTurn = s.week;
          s.midSeasonDelivered = false;
          s.points = 12;
          s.treasury = 1000000;
          s = send(s, 'action', 'govern');
          for (final m in s.courtPersonnelMatters.where(
            (m) => m.kind == 'reform',
          )) {
            generated++;
            final target = courtMatterOffice(s, m)!;
            expect(m.personId, replacement?.id, reason: source);
            expect(m.personId, isNot(target.holderId));
            expect(
              courtReformCandidateBlocked(
                s,
                courtPerson(s, m.personId)!,
                target,
              ),
              isNull,
            );
          }
        }
        expect(
          generated,
          source == 'court' || source == 'pool' ? greaterThan(0) : 0,
          reason: source,
        );
      }
    },
  );
  test(
    'reform replaces the incumbent from either roster at passive thresholds',
    () {
      for (final source in ['court', 'pool']) {
        for (final index in [0, 1]) {
          final s = fresh();
          final o = office(s, 'Đại tướng');
          final incumbent = holder(s, o)..ability = 20;
          final c =
              source == 'court'
                  ? holder(s, office(s, 'Thư lại'))
                  : s.officialsPool.first;
          c
            ..grade = 1
            ..ability = 90
            ..affection = 80
            ..specialty = specialtyForRole(o.role);
          final m = open(s, 'reform', c, seat: o);
          final event = courtPersonnelEvent(s, m);
          expect(event.choices, hasLength(3));
          expect(event.choices.last.label, 'Bác đề nghị');
          expect(event.body, isNot(contains('bồi dưỡng')));
          final result = resolve(s, m, index, index == 1 ? c.id : '');
          expect(courtOfficeFor(result, c.id)!.id, o.id);
          expect(result.officialsPool.any((p) => p.id == incumbent.id), isTrue);
          expect(result.courtPersonnelMatters.last.status, 'watching');
          expect(
            courtPassiveBlocked(result, office(result, 'Đại tướng')),
            contains('mùa'),
          );
        }
      }
    },
  );
  test(
    'both reform appointment choices recheck replacement qualifications',
    () {
      for (final role in ['Đại tướng', 'Đại tư mã']) {
        for (final invalid in [
          'ability',
          'affection',
          'specialty',
          'grade',
          'retired',
        ]) {
          for (final index in [0, 1]) {
            final s = fresh();
            final o = office(s, role);
            holder(s, o).ability = 20;
            final c =
                s.officialsPool.first
                  ..grade = o.grade
                  ..ability = 95
                  ..affection = 80
                  ..specialty = specialtyForRole(o.role)
                  ..royalEligible = true;
            final m = open(s, 'reform', c, seat: o);
            switch (invalid) {
              case 'ability':
                c.ability = o.grade == 1 ? 89 : 79;
              case 'affection':
                c.affection = o.grade == 1 ? 79 : 69;
              case 'specialty':
                c.specialty = 'Y thuật';
              case 'grade':
                c.grade = o.grade + 1;
              case 'retired':
                c.retired = true;
            }
            final before = s.toJson();
            expect(
              courtPersonnelChoiceBlocked(s, m, index, nomineeId: c.id),
              isNotNull,
              reason: '$role/$invalid/$index',
            );
            expect(
              () => resolve(s, m, index, index == 1 ? c.id : ''),
              throwsA(isA<GameRuleException>()),
            );
            expect(s.toJson(), before);
          }
        }
      }
    },
  );
  test('reform rejection no longer starts training', () {
    final s = fresh();
    final o = office(s, 'Đại tướng');
    final incumbent = holder(s, o)..ability = 20;
    final m = open(s, 'reform', nominee(s, o), seat: o);
    final result = resolve(s, m, 2);
    expect(result.courtPersonnelMatters.last.status, 'rejected');
    expect(
      courtOfficeHolder(result, office(result, 'Đại tướng'))!.id,
      incumbent.id,
    );
    expect(officerBusy(result, incumbent.id), isFalse);
    expect(result.treasury, s.treasury);
    expect(courtPersonnelChoiceBlocked(s, m, 3), contains('không hợp lệ'));
    expect(
      courtPersonnelChoiceBlocked(s, m, 1, nomineeId: incumbent.id),
      contains('Đang giữ chức'),
    );
  });
  test('loading an old self-nomination closes it once without fees', () async {
    final store = MemoryGameStore();
    final gateway = LocalGameGateway(store);
    final s = fresh();
    final o = office(s, 'Đại tướng');
    final c = holder(s, o)..ability = 20;
    final m = open(s, 'reform', c, seat: o);
    s.midSeasonDelivered = true;
    await store.update((archive) => archive.active = s);
    final loaded = (await gateway.load()).active!;
    expect(loaded.courtPersonnelMatters.last.status, 'closed');
    expect(loaded.petitions.any((p) => p.definitionId == m.eventId), isFalse);
    expect(loaded.treasury, s.treasury);
    expect(loaded.points, s.points);
    expect(courtPerson(loaded, c.id)!.ability, 20);
    expect((await gateway.load()).active!.toJson(), loaded.toJson());
  });
  test(
    'stale and expired petitions close without executing personnel actions',
    () {
      var s = fresh();
      final o = office(s, 'Thư lại');
      vacate(s, o);
      final c = nominee(s, o);
      final m = open(s, 'nominate', c, seat: o);
      s = send(s, 'appoint-office', o.id, c.id);
      expect(s.petitions.any((p) => p.id == m.id), isFalse);
      expect(s.courtPersonnelMatters.last.status, 'closed');
      final target = holder(s, office(s, 'Hộ bộ'));
      final retirement = open(s, 'retire', target, seat: office(s, 'Hộ bộ'));
      s.petitions.single.deadline = s.week;
      s = close(s);
      expect(s.courtPersonnelMatters.last.status, 'expired');
      expect(courtOfficeFor(s, target.id), isNotNull);
      expect(courtPerson(s, target.id)!.retired, isFalse);
      expect(
        () => resolve(s, retirement, 0),
        throwsA(isA<GameRuleException>()),
      );
    },
  );
  test(
    'seasonal generation reaches all six kinds, binds real targets and limits discovery to one a year',
    () {
      final kinds = <String>{};
      for (var seed = 1; seed <= 120; seed++) {
        var s = fresh(seed);
        final junior = office(s, 'Thư lại');
        vacate(s, junior);
        for (var i = 0; i < s.court.length; i++) {
          final c = s.court[i];
          if (c.isConsort) continue;
          c.merit = 100;
          c.majorMerits = 3;
          c.ability = i.isEven ? 95 : 20;
          c.affection = 100;
        }
        nominee(s, junior);
        var discoveries = 0;
        for (var attempt = 0; attempt < 3; attempt++) {
          s.petitions.clear();
          for (final m in s.courtPersonnelMatters) {
            if (m.status == 'open') m.status = 'rejected';
          }
          s.nextCourtPersonnelTurn = s.week;
          s.midSeasonDelivered = false;
          s.points = 12;
          final previousCount = s.courtPersonnelMatters.length;
          s = send(s, 'action', 'govern');
          expect(s.courtPersonnelMatters.length, previousCount + 1);
          final m = s.courtPersonnelMatters.last;
          kinds.add(m.kind);
          expect(courtPerson(s, m.personId), isNotNull);
          expect(courtPerson(s, m.sponsorId), isNotNull);
          expect(s.petitions.any((p) => p.definitionId == m.eventId), isTrue);
          expect(s.nextCourtPersonnelTurn - s.week, inInclusiveRange(1, 2));
          expect(
            eventForState(s, m.eventId).body,
            contains(courtPerson(s, m.personId)!.name),
          );
          if (m.kind == 'recruit') discoveries++;
          final originalCount = s.courtPersonnelMatters.length;
          s = send(s, 'action', 'govern');
          expect(s.courtPersonnelMatters.length, originalCount);
        }
        expect(discoveries, lessThanOrEqualTo(1));
      }
      expect(
        kinds,
        containsAll([
          'nominate',
          'recruit',
          'retire',
          'promote',
          'patronage',
          'reform',
        ]),
      );
    },
  );

  test(
    'new personnel records roundtrip and existing 0.23.1 saves acquire safe defaults',
    () {
      final s = fresh();
      open(
        s,
        'retire',
        holder(s, office(s, 'Đại tướng')),
        seat: office(s, 'Đại tướng'),
      );
      s.officialsPool.first.retired = true;
      s.courtPersonnelRewarded.add('old:office');
      final loaded = GameState.fromJson(jsonDecode(jsonEncode(s.toJson())));
      expect(loaded.toJson(), s.toJson());
      final old =
          s.toJson()
            ..['rulesVersion'] = 'mvp-0.23.1'
            ..['contentVersion'] = 20;
      for (final key in [
        'courtPersonnelMatters',
        'courtPersonnelRewarded',
        'nextCourtPersonnelTurn',
        'lastCourtRecruitYear',
      ]) {
        old.remove(key);
      }
      final migrated = GameState.fromJson(old);
      expect(migrated.courtPersonnelMatters, isEmpty);
      expect(migrated.courtOffices.length, 53);
      expect(migrated.authority, s.authority);
    },
  );
}
