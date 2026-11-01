import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/court_rules.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/logic/health_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/data/content.dart';

final engine = GameEngine();
GameState fresh([int seed = 42]) {
  final s = engine.start('court', 'An', seed);
  s.petitions.clear();
  s.authority = 95;
  s.nextMajorWeek = s.nextChainWeek = 100000;
  s.factions.updateAll((_, v) => 60);
  for (final c in s.court) {
    c.loyalty = c.integrity = 90;
    c.ambition = 10;
    c.plot = c.discontent = 0;
  }
  return s;
}

GameCommand command(
  GameState s,
  String type, [
  String target = '',
  String option = '',
]) => GameCommand(
  id: 'court-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: type,
  target: target,
  option: option,
);
GameState send(
  GameState s,
  String type, [
  String target = '',
  String option = '',
]) => engine.execute(s, command(s, type, target, option));
GameState close(GameState s) {
  s.petitions.clear();
  s.workThisWeek = s.affairsThisWeek = 1;
  return send(s, 'endWeek');
}

CourtOffice office(GameState s, String role) =>
    s.courtOffices.firstWhere((o) => o.role == role);
Courtier holder(GameState s, String role) =>
    courtOfficeHolder(s, office(s, role))!;
void disablePassives(GameState s) {
  for (final c in s.court) {
    c.affection = 0;
  }
}

void main() {
  test(
    'opposing office effects cancel before bounds, regardless of office ordering',
    () {
      for (final training in [0.0, 100.0]) {
        var s = fresh();
        disablePassives(s);
        s = send(s, 'dismiss-office', office(s, 'Phó tướng').id);
        holder(s, 'Đại tướng')
          ..ability = 90
          ..affection = 80;
        s.population!.training = training;
        final reversed =
            s.copy()..courtOffices = s.copy().courtOffices.reversed.toList();
        final forward = close(s), backward = close(reversed);
        expect(forward.population!.training, backward.population!.training);
        final note =
            forward.journal
                .firstWhere((j) => j.title == 'Đóng góp bộ máy')
                .text;
        expect(
          note,
          contains(
            'Đại tướng · ${holder(forward, 'Đại tướng').name}: Huấn luyện +1',
          ),
        );
        expect(note, contains('Phó tướng · Bỏ trống: Huấn luyện -1'));
      }
    },
  );
  test(
    'dismissal leaves a persistent vacancy and preserves the former official',
    () {
      var s = fresh();
      final o = office(s, 'Tể tướng'), c = holder(s, 'Tể tướng')..merit = 17;
      final treasury = s.treasury, grade = c.grade;
      s = send(s, 'dismiss-office', o.id);
      expect(s.treasury, treasury);
      expect(s.points, 11);
      expect(
        s.courtOffices.firstWhere((item) => item.id == o.id).holderId,
        isEmpty,
      );
      final former = s.officialsPool.firstWhere((p) => p.id == c.id);
      expect(former.grade, grade);
      expect(former.merit, 17);
      expect(former.role, 'Đã hồi hương');
      expect(former.retired, isTrue);
      expect(s.court.any((p) => p.id == c.id), isFalse);
      final before = jsonEncode(s.toJson());
      expect(
        () => send(s, 'dismiss-office', o.id),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
      s = close(s.copy());
      expect(
        s.courtOffices.firstWhere((item) => item.id == o.id).holderId,
        isEmpty,
      );
      final note =
          s.journal.firstWhere((j) => j.title == 'Đóng góp bộ máy').text;
      expect(note, contains('Tể tướng · Bỏ trống: Ổn định triều đình -1'));
      expect(note, contains('Tể tướng · Bỏ trống: Uy quyền -1'));
      expect(s.lastCourtPassiveTurn, 1);
      s = close(s.copy());
      expect(s.lastCourtPassiveTurn, 2);
      expect(
        s.courtOffices.firstWhere((item) => item.id == o.id).holderId,
        isEmpty,
      );
    },
  );

  test(
    'an occupied unqualified office has zero contribution, not a vacancy penalty',
    () {
      var s = fresh();
      disablePassives(s);
      final o = office(s, 'Tể tướng');
      expect(courtOfficeDirection(s, o), 0);
      s = close(s);
      expect(
        s.journal
            .where((j) => j.title == 'Đóng góp bộ máy')
            .any((j) => j.text.contains('Tể tướng')),
        isFalse,
      );
    },
  );

  test(
    'refilling a vacant office stops the penalty and waits a full season for bonuses',
    () {
      var s = fresh();
      final o = office(s, 'Tể tướng');
      s = send(s, 'dismiss-office', o.id);
      final c =
          s.officialsPool.first
            ..grade = 1
            ..ability = 90
            ..affection = 80;
      s = send(s, 'appoint-office', o.id, c.id);
      expect(courtOfficeDirection(s, office(s, 'Tể tướng')), 0);
      s = close(s);
      expect(
        s.journal
            .where((j) => j.title == 'Đóng góp bộ máy')
            .any((j) => j.text.contains('Tể tướng')),
        isFalse,
      );
      expect(courtOfficeDirection(s, office(s, 'Tể tướng')), 1);
      s = close(s);
      expect(
        s.journal.firstWhere((j) => j.title == 'Đóng góp bộ máy').text,
        contains('Tể tướng'),
      );
    },
  );

  test(
    'vacancies invert military and fatigue passives with bounded actual changes',
    () {
      var s = fresh();
      disablePassives(s);
      for (final role in ['Đại tướng', 'Phó tướng', 'Thái sư']) {
        s = send(s, 'dismiss-office', office(s, role).id);
      }
      s.population!.training = .5;
      s.population!.morale = 0;
      s.fatigue = 10;
      s = close(s);
      final note =
          s.journal.firstWhere((j) => j.title == 'Đóng góp bộ máy').text;
      expect(note, contains('Đại tướng · Bỏ trống: Sĩ khí +0'));
      expect(note, contains('Đại tướng · Bỏ trống: Huấn luyện -0.5'));
      expect(note, contains('Phó tướng · Bỏ trống: Huấn luyện +0'));
      expect(note, contains('Thái sư · Bỏ trống: Mệt mỏi của vua +1'));
      expect(s.population!.training, greaterThanOrEqualTo(0));
    },
  );

  test(
    'treasury vacancy accrues a negative tax modifier, survives reload and forecasts the same settlement',
    () {
      var s = fresh();
      s = send(s, 'dismiss-office', office(s, 'Hộ bộ').id);
      final base = annualTaxGross(s) - annualTaxCredit(s);
      expect(courtTaxSeasonCount(s), -1);
      expect(annualTaxRevenue(s), base - (base * .0075).floor());
      s = close(s.copy());
      expect(s.courtTaxSeasons['1'], -1);
      expect(courtTaxSeasonCount(s.copy()), -2);
      s.courtTaxSeasons['1'] = -4;
      expect(courtTaxSeasonCount(s), -4);
      final json = s.toJson()..['rulesVersion'] = 'mvp-0.23.0';
      expect(GameState.fromJson(json).courtTaxSeasons['1'], -4);
    },
  );

  test(
    'dismissal of a busy official is rejected without charging or removing them',
    () {
      final s = fresh();
      final o = office(s, 'Tể tướng');
      s.projects.add(
        WorkOrder(
          id: 'busy-cut',
          kind: 'repair',
          officerId: o.holderId,
          startedWeek: 1,
          duration: 2,
        ),
      );
      final before = jsonEncode(s.toJson());
      expect(
        () => send(s, 'dismiss-office', o.id),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
    },
  );
  test('new court converts military petition choices to land operations', () {
    final s = fresh();
    for (final e in eventsForState(s)) {
      expect(
        eventForState(s, e.id).choices.every((c) => !c.naval),
        isTrue,
        reason: e.id,
      );
    }
  });
  test(
    'transfer and reserve backfill commit atomically as two appointments',
    () {
      final s = fresh();
      final target = office(s, 'Hộ bộ');
      final incoming = holder(s, 'Lễ bộ')..grade = 2;
      final source = courtOfficeFor(s, incoming.id)!;
      final fill = s.officialsPool.first;
      final price =
          courtAppointmentCost(s, incoming, target) +
          courtAppointmentCost(s, fill, source);
      final payload = jsonEncode({
        'candidate': incoming.id,
        'backfill': fill.id,
      });
      final insufficient = s.copy()..points = 1;
      final before = jsonEncode(insufficient.toJson());
      expect(
        () => send(insufficient, 'appoint-office', target.id, payload),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(insufficient.toJson()), before);
      final result = send(s, 'appoint-office', target.id, payload);
      expect(holder(result, 'Hộ bộ').id, incoming.id);
      expect(
        result.courtOffices.firstWhere((o) => o.id == source.id).holderId,
        fill.id,
      );
      expect(result.points, 10);
      expect(result.treasury, s.treasury - price);
      expect(result.courtOffices.where((o) => o.holderId.isEmpty), isEmpty);
      expect(result.court.where((c) => !c.isConsort), hasLength(53));
    },
  );

  test(
    'multi-result petition awards once after final result and survives reload',
    () {
      var s = fresh();
      final c = holder(s, 'Tri phủ');
      final assignment = PetitionAssignment(
        eventId: 'test',
        meritId: 'one-petition',
        assigneeId: c.id,
        assigneeName: c.name,
        specialty: c.specialty,
        chance: 100,
        succeeded: true,
        failureEffects: {},
      );
      s.pending.addAll([
        for (final due in [1, 2])
          Consequence(
            kind: 'eventOutcome',
            dueWeek: due,
            title: 'Hoàn thành tấu chương',
            effects: {'gold': 500},
            assignment: assignment,
          ),
      ]);
      s = close(s);
      expect(courtPerson(s, c.id)!.merit, 0);
      s = close(s.copy());
      expect(courtPerson(s, c.id)!.merit, 1);
      expect(
        courtPerson(s, c.id)!.meritHistory.where((m) => m.id == 'one-petition'),
        hasLength(1),
      );
      s = close(s.copy());
      expect(courtPerson(s, c.id)!.merit, 1);
    },
  );

  test(
    'completed long work grants weighted uncapped merit, not repeating on reload',
    () {
      var s = fresh();
      final c =
          holder(s, 'Tri phủ')
            ..merit = 100
            ..ability = 100
            ..integrity = 100;
      s.projects.add(
        WorkOrder(
          id: 'merit-project',
          kind: 'repair',
          officerId: c.id,
          startedWeek: 1,
          duration: 1,
        ),
      );
      s.levee = 30;
      s.rng = 100;
      s = close(s);
      expect(courtPerson(s, c.id)!.merit, 102);
      expect(courtPerson(s, c.id)!.meritHistory.single.points, 2);
      s = close(s.copy());
      expect(courtPerson(s, c.id)!.merit, 102);
    },
  );
  test(
    'new reign has 53 offices including twelve management posts, six royal ranks and paired senior/junior doctors and spies',
    () {
      for (final seed in [1, 42, 125, 999]) {
        final s = fresh(seed);
        expect(s.hasCourtSystem, isTrue);
        expect(s.court.where((c) => !c.isConsort), hasLength(53));
        expect(s.courtOffices, hasLength(53));
        expect(s.officialsPool, hasLength(12));
        expect(
          {
            for (final g in [
              'Văn ban',
              'Võ ban',
              'Hoàng thất',
              'Nội đình',
              'Địa phương',
            ])
              g: s.courtOffices.where((o) => o.group == g).length,
          },
          {
            'Văn ban': 18,
            'Võ ban': 15,
            'Hoàng thất': 6,
            'Nội đình': 8,
            'Địa phương': 6,
          },
        );
        expect(
          s.courtOffices
              .where((o) => o.group == 'Hoàng thất')
              .map((o) => o.grade)
              .toSet(),
          {1, 2, 3, 4, 5, 6},
        );
        for (final role in ['Ngự y', 'Mật thám']) {
          expect(
            s.courtOffices
                .where((o) => o.role == role)
                .map((o) => o.grade)
                .toSet(),
            {4, 7},
          );
        }
        expect(
          s.courtOffices
              .where((o) => o.group == 'Nội đình')
              .map((o) => o.grade)
              .reduce((a, b) => a < b ? a : b),
          3,
        );
        expect(s.court.any((c) => c.role == 'Đô đốc'), isFalse);
        expect(s.courtOffices.map((o) => o.holderId).toSet(), hasLength(53));
        final people = [
          ...s.court.where((c) => !c.isConsort),
          ...s.officialsPool,
        ];
        expect(people.map((c) => c.resolvedPortraitId).toSet(), hasLength(60));
      }
      expect(
        jsonEncode(engine.start('same', 'An', 99).toJson()),
        jsonEncode(engine.start('same', 'An', 99).toJson()),
      );
    },
  );

  test(
    'skip promotion consumes cumulative merit/fees and cumulative relationship changes',
    () {
      final s = fresh();
      final c =
          holder(s, 'Quan điền')
            ..merit = 10
            ..grade = 9
            ..ability = 60
            ..affection = 40
            ..discontent = 50;
      final before = s.treasury;
      final result = send(s, 'promote', c.id, '6');
      final promoted = courtPerson(result, c.id)!;
      expect(promoted.grade, 6);
      expect(promoted.merit, 1);
      expect(promoted.meritSpent, 9);
      expect(promoted.totalMerit, 10);
      expect(promoted.affection, 49);
      expect(promoted.discontent, 32);
      expect(result.treasury, before - 3000);
      expect(result.points, 11);
      expect(c.grade, 9);
      expect(c.merit, 10); // Atomic gateway never mutates the input.
    },
  );

  test('Cuu to That is 1800 and promotions have no cooldown', () {
    var s = fresh();
    final c =
        holder(s, 'Quan điền')
          ..merit = 5
          ..ability = 70
          ..affection = 40
          ..discontent = 30;
    s = send(s, 'promote', c.id, '8');
    s = send(s, 'promote', c.id, '7');
    final p = courtPerson(s, c.id)!;
    expect(p.grade, 7);
    expect(p.merit, 0);
    expect(p.affection, 45);
    expect(p.discontent, 20);
    expect(s.treasury, 48200);
    expect(s.completedWeeks, 0);
  });

  test(
    'failed promotions preserve every field and top ranks require ability and major achievements',
    () {
      final s = fresh();
      final c =
          holder(s, 'Quan điền')
            ..merit = 100
            ..ability = 90;
      final before = jsonEncode(s.toJson());
      expect(
        () => send(s, 'promote', c.id, '1'),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
      c.majorMerits = 3;
      c.affection = 99;
      c.discontent = 1;
      final p = courtPerson(send(s, 'promote', c.id, '1'), c.id)!;
      expect(p.merit, 38);
      expect(p.affection, 100);
      expect(p.discontent, 0);
      expect(CourtPromotion(s, c, 1).merit, 62);
    },
  );

  test(
    'appointment is grade-gated; dismissal preserves identity and source vacancy can be refilled',
    () {
      var s = fresh();
      final target = office(s, 'Hộ bộ');
      final incoming = holder(s, 'Thương chính');
      expect(
        courtAppointmentBlocked(s, incoming, target),
        contains('Nhị phẩm'),
      );
      final before = jsonEncode(s.toJson());
      expect(
        () => send(s, 'appoint-office', target.id, incoming.id),
        throwsA(isA<GameRuleException>()),
      );
      expect(jsonEncode(s.toJson()), before);
      incoming.grade = 2;
      incoming.merit = 17;
      final old = holder(s, 'Hộ bộ'), source = courtOfficeFor(s, incoming.id)!;
      old.merit = 23;
      old.affection = 88;
      s = send(s, 'appoint-office', target.id, incoming.id);
      expect(holder(s, 'Hộ bộ').id, incoming.id);
      expect(
        s.courtOffices.firstWhere((o) => o.id == source.id).holderId,
        isEmpty,
      );
      final dismissed = s.officialsPool.firstWhere((c) => c.id == old.id);
      expect(dismissed.merit, 23);
      expect(dismissed.affection, 88);
      expect(dismissed.available, isTrue);
      expect(holder(s, 'Hộ bộ').merit, 17);
      s = send(s, 'appoint-office', source.id, dismissed.id);
      expect(s.courtOffices.where((o) => o.holderId.isEmpty), isEmpty);
      final ids = [...s.court, ...s.officialsPool].map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
    },
  );

  test(
    'swap revalidates both grades and charges two actions without duplicate people',
    () {
      final s = fresh();
      final first = holder(s, 'Hộ bộ'),
          second = holder(s, 'Thương chính')..grade = 2;
      final a = office(s, 'Hộ bộ'), b = office(s, 'Thương chính');
      final expected =
          courtAppointmentCost(s, second, a) +
          courtAppointmentCost(s, first, b);
      final result = send(s, 'swap-office', a.id, second.id);
      expect(holder(result, 'Hộ bộ').id, second.id);
      expect(holder(result, 'Thương chính').id, first.id);
      expect(result.points, 10);
      expect(result.treasury, s.treasury - expected);
      expect(result.court.where((c) => !c.isConsort), hasLength(53));
    },
  );

  test(
    'passives belong to office and require grade, public ability and affection',
    () {
      final s = fresh();
      final general = office(s, 'Đại tướng'), deputy = office(s, 'Phó tướng');
      final c =
          holder(s, 'Đại tướng')
            ..ability = 89
            ..affection = 80;
      expect(courtPassiveBlocked(s, general), contains('năng lực'));
      c.ability = 90;
      c.affection = 79;
      expect(courtPassiveBlocked(s, general), contains('thiện cảm'));
      c.affection = 80;
      expect(courtPassiveBlocked(s, general), isNull);
      holder(s, 'Phó tướng').grade = 1;
      expect(courtPassives(deputy), hasLength(1));
      expect(courtPassives(general), hasLength(2));
      for (final o in s.courtOffices.where(
        (o) => ['Ngự y', 'Mật thám'].contains(o.role),
      )) {
        expect(courtPassives(o), isEmpty);
      }
    },
  );

  test(
    'season settlement stacks general and deputy once, persists and caps actual gains',
    () {
      var s = fresh();
      disablePassives(s);
      holder(s, 'Đại tướng')
        ..ability = 90
        ..affection = 80;
      holder(s, 'Phó tướng')
        ..ability = 80
        ..affection = 70;
      s.population!.training = 60;
      s.population!.morale = 60;
      s = close(s);
      final note =
          s.journal.firstWhere((j) => j.title == 'Đóng góp bộ máy').text;
      expect(note, contains('Đại tướng'));
      expect(note, contains('Phó tướng'));
      expect(note, contains('Huấn luyện +1'));
      expect(s.lastCourtPassiveTurn, 1);
      final reloaded = GameState.fromJson(jsonDecode(jsonEncode(s.toJson())));
      expect(reloaded.lastCourtPassiveTurn, 1);
      expect(reloaded.population!.training, s.population!.training);
      final same = engine.execute(s, command(s, 'endWeek'));
      expect(same.lastCourtPassiveTurn, 2);
    },
  );

  test(
    'new appointments wait until next season, tax bonus counts at most four seasons',
    () {
      var s = fresh();
      disablePassives(s);
      final c =
          s.officialsPool.first
            ..ability = 90
            ..affection = 80;
      final target = office(s, 'Hộ bộ');
      s = send(s, 'appoint-office', target.id, c.id);
      expect(
        courtPassiveBlocked(s, office(s, 'Hộ bộ')),
        contains('Nhận đóng góp'),
      );
      expect(courtTaxSeasonCount(s), 0);
      s = close(s);
      expect(s.courtTaxSeasons['1'] ?? 0, 0);
      expect(courtPassiveBlocked(s, office(s, 'Hộ bộ')), isNull);
      expect(courtTaxSeasonCount(s), 1);
      final plain = annualTaxRevenue(s);
      s.courtTaxSeasons['1'] = 4;
      expect(courtTaxSeasonCount(s), 4);
      expect(annualTaxRevenue(s), greaterThan(plain));
    },
  );

  test(
    'senior doctor is selected by office, not the ordering of character list',
    () {
      final s = fresh();
      final offices =
          s.courtOffices.where((o) => o.role == 'Ngự y').toList()
            ..sort((a, b) => a.grade.compareTo(b.grade));
      final senior =
          courtOfficeHolder(s, offices.first)!
            ..ability = 80
            ..specialty = 'Y thuật';
      final junior =
          courtOfficeHolder(s, offices.last)!
            ..ability = 30
            ..specialty = 'Y thuật';
      s.court.remove(junior);
      s.court.insert(0, junior);
      expect(s.officerForRole('Ngự y')!.id, senior.id);
      expect(treatmentIllnessRecovery(s), 16);
    },
  );

  test('historical save retains its old roster and disabled court system', () {
    final s = GameEngine(populationEnabled: false).start('legacy', 'An', 42);
    final json =
        s.toJson()
          ..remove('courtSystemVersion')
          ..remove('courtOffices');
    json['rulesVersion'] = 'mvp-0.22.0';
    json['contentVersion'] = 19;
    final loaded = GameState.fromJson(json);
    expect(loaded.hasCourtSystem, isFalse);
    expect(loaded.courtOffices, isEmpty);
    expect(loaded.court.where((c) => !c.isConsort), hasLength(35));
  });
}
