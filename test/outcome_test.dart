import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_io.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/data/content.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final engine = GameEngine(seasonal: false);
  GameState fresh() {
    final s = engine.start('reports', 'An', 42);
    s.petitions.clear();
    s.factions.updateAll((k, v) => 60);
    s.affairsThisWeek = s.workThisWeek = 1;
    for (final c in s.court) {
      c.loyalty = 100;
      c.ambition = c.plot = 0;
      c.ability = c.integrity = 100;
    }
    return s;
  }

  GameState advance(GameState s) => engine.execute(
    s,
    GameCommand(
      id: 'week-${s.revision}',
      runId: s.runId,
      expectedRevision: s.revision,
      type: 'endWeek',
    ),
  );

  void roll(GameState s, int value) =>
      s.rng = value == 0 ? 100 : value * 31 % 100;

  test(
    'delayed event reports only its own gains and losses, and survives reload',
    () {
      final s = fresh();
      s.pending.add(
        Consequence(
          kind: 'eventOutcome',
          dueWeek: 1,
          title: 'Thuế chợ',
          detail: 'Đối chiếu: thất bại.',
          effects: {'treasury': -20, 'people': -4, 'grain': 12},
        ),
      );
      final result = advance(s);
      final report = result.outcomes.single;
      expect(report.week, 1);
      expect(report.title, 'Thuế chợ');
      expect(report.status, 'failure');
      expect(report.changes, {
        'Ngân khố': -20,
        'Lòng dân': -4,
        'Lương thực': 12,
      });
      expect(result.pending, isEmpty);
      expect(result.copy().outcomes.single.toJson(), report.toJson());
      final again = advance(result.copy()..petitions.clear());
      expect(again.outcomes, hasLength(1));
      expect(again.outcomes.single.toJson(), report.toJson());
    },
  );

  test(
    'legacy follow-ups keep the original event and decision in their report',
    () {
      final s = fresh();
      final event = events.firstWhere(
        (e) => e.choices.any((c) => c.followup == 'school'),
      );
      final index = event.choices.indexWhere((c) => c.followup == 'school');
      s.petitions.add(
        Petition(
          id: 'source',
          definitionId: event.id,
          openedWeek: 1,
          deadline: 2,
        ),
      );
      var state = engine.execute(
        s,
        GameCommand(
          id: 'decision',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'petition',
          target: 'source',
          option: '$index',
        ),
      );
      final due = state.pending.single.dueWeek;
      expect(state.pending.single.title, event.title);
      while (state.week <= due && !state.ended) {
        state.petitions.clear();
        state.affairsThisWeek = state.workThisWeek = 1;
        state = advance(state);
      }
      final report = state.outcomes.single;
      expect(report.title, event.title);
      expect(report.detail, contains(event.choices[index].label));
      expect(report.changes['Lòng dân'], 8);
    },
  );

  for (final kind in ['repair', 'farm', 'commerce']) {
    for (final success in [true, false]) {
      test(
        '$kind completion reports ${success ? 'success' : 'failure'} and actual cash effects',
        () {
          final s = fresh();
          final officer = s.court.firstWhere((c) => c.id == 'treasurer');
          officer.specialty = kind == 'repair' ? 'Công trình' : 'Kinh tế';
          s.projects.add(
            WorkOrder(
              id: 'project',
              kind: kind,
              officerId: officer.id,
              startedWeek: 1,
              duration: 1,
            ),
          );
          roll(s, success ? 0 : 99);
          final result = advance(s);
          final report = result.outcomes.single;
          expect(report.status, success ? 'success' : 'failure');
          expect(report.detail, contains(officer.name));
          expect(result.projects, isEmpty);
          if (success) {
            expect(
              report.changes[kind == 'repair'
                  ? 'Đê điều'
                  : kind == 'farm'
                  ? 'Lương thực'
                  : 'Ngân khố'],
              greaterThan(0),
            );
            if (kind == 'farm') expect(report.changes['Lòng dân'], 4);
          } else {
            expect(
              report.changes[kind == 'repair'
                  ? 'Đê điều'
                  : kind == 'farm'
                  ? 'Lương thực'
                  : 'Ngân khố'],
              lessThan(0),
            );
            expect(report.detail, contains('không được hoàn lại'));
          }
          final entries = result.financialWeeks.first.entries.where(
            (e) => e.category == 'project',
          );
          expect(
            entries.fold<int>(0, (sum, e) => sum + e.amount),
            report.changes['Ngân khố'] ?? 0,
          );
        },
      );
    }
  }

  test(
    'pending projects/events produce no result before due and legacy saves accept reports',
    () {
      final s = fresh();
      s.pending.add(Consequence(kind: 'school', dueWeek: 3));
      s.projects.add(
        WorkOrder(
          id: 'future',
          kind: 'farm',
          officerId: 'treasurer',
          startedWeek: 1,
          duration: 3,
        ),
      );
      final legacy = s.toJson()..remove('outcomes');
      final loaded = GameState.fromJson(legacy);
      expect(loaded.outcomes, isEmpty);
      final result = advance(loaded);
      expect(result.outcomes, isEmpty);
      expect(result.pending, hasLength(1));
      expect(result.projects.single.progress, 1);
    },
  );

  for (final kind in [
    'school',
    'trade',
    'weapons',
    'audit',
    'security',
    'investigate',
    'envoy',
  ]) {
    test('$kind follow-up produces a distinct completion receipt', () {
      final s = fresh();
      final target = s.court.firstWhere((c) => c.id == 'treasurer');
      target.specialty = 'Ngoại giao';
      s.war = 3;
      s.pending.add(Consequence(kind: kind, dueWeek: 1, target: target.id));
      roll(s, 0);
      final result = advance(s);
      final report = result.outcomes.single;
      expect(report.status, 'success');
      expect(report.detail, isNotEmpty);
      expect(report.week, 1);
      expect(result.pending, isEmpty);
      if (kind == 'school') {
        expect(report.changes, {'Lòng dân': 8, 'Uy quyền': 3});
      }
      if (kind == 'trade') {
        expect(report.changes['Ngân khố'], inInclusiveRange(65, 95));
      }
      if (kind == 'weapons') expect(report.changes, {'Quân lực': 15});
      if (kind == 'envoy') {
        expect(report.changes['Áp lực chiến tranh'], lessThan(0));
      }
      if (kind == 'investigate') {
        expect(report.detail, contains('Triều thần'));
        expect(
          result.court.firstWhere((c) => c.id == target.id).investigated,
          true,
        );
      }
    });
  }

  for (final kind in ['audit', 'investigate', 'envoy']) {
    test(
      '$kind unsuccessful investigation or diplomacy is not reported as success',
      () {
        final s = fresh();
        s.pending.add(Consequence(kind: kind, dueWeek: 1, target: 'treasurer'));
        for (final c in s.court.where(
          (c) => ['Ngự sử', 'Mật thám'].contains(c.role),
        )) {
          c.ability = 1;
          c.specialty = 'Cung đình';
        }
        roll(s, 99);
        final report = advance(s).outcomes.single;
        expect(report.status, kind == 'envoy' ? 'failure' : 'inconclusive');
        if (kind == 'envoy') expect(report.changes['Uy quyền'], lessThan(0));
      },
    );
  }

  test(
    'missing officer or investigation target also produces an interruption receipt',
    () {
      final s = fresh();
      s.projects.add(
        WorkOrder(
          id: 'gone',
          kind: 'repair',
          officerId: 'missing',
          startedWeek: 1,
          duration: 3,
        ),
      );
      s.pending.addAll([
        Consequence(kind: 'envoy', dueWeek: 1, target: 'missing'),
        Consequence(kind: 'investigate', dueWeek: 1, target: 'missing'),
      ]);
      final reports = advance(s).outcomes;
      expect(reports, hasLength(3));
      expect(reports.every((r) => r.status == 'interrupted'), true);
      expect(reports.map((r) => r.id).toSet(), hasLength(3));
    },
  );

  for (final indexed in [false, true]) {
    test(
      'completion effects and receipts commit once and reload together (${indexed ? 'IndexedDB' : 'memory'})',
      () async {
        final store =
            indexed
                ? await IndexedGameStore.open(
                  idbFactoryMemory,
                  name: 'outcome-${DateTime.now().microsecondsSinceEpoch}',
                )
                : MemoryGameStore();
        addTearDown(store.close);
        await store.update((a) {
          a.active =
              fresh()..pending.add(Consequence(kind: 'trade', dueWeek: 1));
        });
        final gateway = LocalGameGateway(store, seasonal: false);
        final s = (await gateway.load()).active!;
        final command = GameCommand(
          id: 'once',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'endWeek',
        );
        final first = await gateway.dispatch(command);
        final second = await LocalGameGateway(
          store,
          seasonal: false,
        ).dispatch(command);
        expect(second.toJson(), first.toJson());
        expect(second.active!.outcomes, hasLength(1));
        expect((await gateway.load()).toJson(), first.toJson());
      },
    );
  }
}
