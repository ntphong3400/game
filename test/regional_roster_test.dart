import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState fresh() => engine.start('regional', 'An', 42);
  GameState send(
    GameState s,
    String type, {
    String target = '',
    String option = '',
  }) => engine.execute(
    s,
    GameCommand(
      id: 'regional-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
    ),
  );

  test(
    'regional people have distinct identities, varied skills and persisted relationships',
    () {
      final s = fresh();
      final regional =
          s.court.where((c) => c.category == 'Địa phương').toList();
      expect(regional, hasLength(10));
      expect(regional.map((c) => c.id).toSet(), hasLength(10));
      expect(regional.map((c) => c.name).toSet(), hasLength(10));
      expect(regional.map((c) => c.ability).toSet().length, greaterThan(5));
      expect(regional.map((c) => c.affection).toSet().length, greaterThan(3));
      for (final c in regional) {
        expect(c.specialty, c.role == 'Quan điền' ? 'Kinh tế' : 'Công trình');
        expect(appointmentRanks, contains(c.role));
        expect(taskOfficers(s, 'repair').any((p) => p.id == c.id), true);
      }
      expect(s.copy().toJson(), s.toJson());
      expect(s.officialsPool, hasLength(12));
    },
  );

  test(
    'replacing one of several prefects preserves other prefects and ongoing work',
    () {
      final s = fresh();
      const first = 'regional-north-prefect';
      const second = 'regional-east-prefect';
      s.projects.add(
        WorkOrder(
          id: 'unrelated',
          kind: 'repair',
          officerId: second,
          startedWeek: 1,
          duration: 4,
          progress: 2,
        ),
      );
      final other = s.court.firstWhere((c) => c.id == second).toJson();
      final candidate = s.officialsPool.first;
      final quote = appointmentCost(candidate, 'Tri phủ');
      final result = send(s, 'appoint', target: first, option: candidate.id);
      expect(result.treasury, s.treasury - quote);
      expect(result.court.firstWhere((c) => c.id == first).available, false);
      expect(
        result.court.firstWhere((c) => c.id == candidate.id).role,
        'Tri phủ',
      );
      expect(
        result.court.firstWhere((c) => c.id == second).toJson()['role'],
        other['role'],
      );
      expect(result.court.firstWhere((c) => c.id == second).available, true);
      expect(result.projects.single.officerId, second);
      expect(result.projects.single.progress, 2);
      expect(
        result.court.where((c) => c.available && c.role == 'Tri phủ'),
        hasLength(4),
      );
      expect(
        result.court.where((c) => c.available && c.category == 'Địa phương'),
        hasLength(10),
      );
    },
  );

  test(
    'v0.7 roster is archived verbatim without resurrecting or adding officials',
    () {
      final s = fresh();
      s.court.firstWhere((c) => c.id == 'regional-north-prefect').available =
          false;
      s.court.removeWhere((c) => c.id == 'regional-delta-land');
      final raw = object(
        jsonDecode(jsonEncode((GameArchive()..active = s).toJson())),
      );
      final old =
          object(raw['active'])
            ..['rulesVersion'] = 'mvp-0.7.2'
            ..['contentVersion'] = 6;
      raw['active'] = old;
      final archived = GameArchive.fromJson(raw);
      expect(archived.active, isNull);
      expect(archived.archivedRuns.single, old);
      expect(GameArchive.fromJson(archived.toJson()).archivedRuns.single, old);
    },
  );
}
