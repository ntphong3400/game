import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_io.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';

void main() {
  for (final useIndexedDb in [false, true]) {
    group(useIndexedDb ? 'IndexedDB transaction contract' : 'Memory store', () {
      late GameStore store;
      late LocalGameGateway gateway;
      setUp(() async {
        store =
            useIndexedDb
                ? await IndexedGameStore.open(
                  idbFactoryMemory,
                  name: 'test-${DateTime.now().microsecondsSinceEpoch}',
                )
                : MemoryGameStore();
        gateway = LocalGameGateway(store, seasonal: false);
        await gateway.start(
          name: 'An',
          runId: 'run',
          seed: 73,
          previousRunId: null,
          previousRevision: null,
        );
      });
      tearDown(() => store.close());
      test(
        'retrying an event choice never rerolls or duplicates its deferred result',
        () async {
          await store.update((archive) {
            archive.active!.petitions = [
              Petition(
                id: 'deferred',
                definitionId: 'finance_02',
                openedWeek: 1,
                deadline: 2,
              ),
            ];
          });
          final s = (await gateway.load()).active!;
          final c = GameCommand(
            id: 'deferred-once',
            runId: s.runId,
            expectedRevision: s.revision,
            type: 'petition',
            target: 'deferred',
            option: '0',
          );
          final first = await gateway.dispatch(c);
          final retry = await LocalGameGateway(
            store,
            seasonal: false,
          ).dispatch(c);
          expect(retry.toJson(), first.toJson());
          expect(retry.active!.pending, hasLength(1));
          expect(retry.active!.treasury, s.treasury - 20);
          expect(
            (await gateway.load()).active!.pending.single.toJson(),
            first.active!.pending.single.toJson(),
          );
        },
      );
      GameCommand command(
        GameState s,
        String id,
        String type, [
        String target = '',
      ]) => GameCommand(
        id: id,
        runId: s.runId,
        expectedRevision: s.revision,
        type: type,
        target: target,
      );

      test(
        'duplicate request is applied once and conflicting/stale requests fail',
        () async {
          final original = (await gateway.load()).active!;
          final c = command(original, 'once', 'action', 'relief');
          final first = await gateway.dispatch(c);
          final second = await gateway.dispatch(c);
          expect(second.active!.toJson(), first.active!.toJson());
          expect(second.active!.treasury, original.treasury - 20);
          await expectLater(
            gateway.dispatch(command(original, 'stale', 'endWeek')),
            throwsA(isA<GameRuleException>()),
          );
          await expectLater(
            gateway.dispatch(command(original, 'once', 'action', 'train')),
            throwsA(isA<GameRuleException>()),
          );
          expect(
            (await gateway.load()).active!.toJson(),
            first.active!.toJson(),
          );
        },
      );

      test('two gateways cannot both commit the same revision', () async {
        final other = LocalGameGateway(store, seasonal: false);
        final original = (await gateway.load()).active!;
        final requests = [
          gateway.dispatch(command(original, 'tab-a', 'endWeek')),
          other.dispatch(command(original, 'tab-b', 'endWeek')),
        ];
        var successes = 0, conflicts = 0;
        await Future.wait(
          requests.map((future) async {
            try {
              await future;
              successes++;
            } on GameRuleException {
              conflicts++;
            }
          }),
        );
        expect(successes, 1);
        expect(conflicts, 1);
        expect((await gateway.load()).active!.completedWeeks, 1);
      });

      test(
        'full unattended run ends naturally and records scoreboard once',
        () async {
          var archive = await gateway.load();
          GameCommand? last;
          var steps = 0;
          while (!archive.active!.ended && steps < 300) {
            last = command(archive.active!, 'week-${steps++}', 'endWeek');
            archive = await gateway.dispatch(last);
            archive = await LocalGameGateway(store, seasonal: false).load();
          }
          expect(archive.active!.ended, true);
          expect(archive.scores, hasLength(1));
          expect(archive.scores.single.weeks, archive.active!.completedWeeks);
          expect(archive.active!.history.length, steps);
          final retry = await gateway.dispatch(last!);
          expect(retry.scores, hasLength(1));
          expect(jsonEncode(retry.toJson()), jsonEncode(archive.toJson()));
        },
      );

      test('abandoning an unfinished run does not create a score', () async {
        await gateway.start(
          name: 'Bình',
          runId: 'new',
          seed: 12,
          previousRunId: 'run',
          previousRevision: 0,
        );
        final archive = await gateway.load();
        expect(archive.scores, isEmpty);
        expect(archive.active!.playerName, 'Bình');
        await expectLater(
          gateway.start(
            name: 'Chi',
            runId: 'conflict',
            seed: 1,
            previousRunId: 'run',
            previousRevision: 0,
          ),
          throwsA(isA<GameRuleException>()),
        );
      });

      test(
        'retrying a paid appointment never charges twice or rerolls its pool',
        () async {
          final s = (await gateway.load()).active!;
          final candidate = s.officialsPool.first;
          final c = GameCommand(
            id: 'appointment-once',
            runId: s.runId,
            expectedRevision: s.revision,
            type: 'appoint',
            target: 'treasurer',
            option: candidate.id,
          );
          final first = await gateway.dispatch(c);
          final retry = await gateway.dispatch(c);
          expect(retry.toJson(), first.toJson());
          expect(
            first.active!.treasury,
            s.treasury - appointmentCost(candidate, 'Hộ bộ'),
          );
          expect(first.active!.officialsPool, hasLength(12));
          final updated = first.active!;
          await expectLater(
            gateway.dispatch(
              GameCommand(
                id: 'reuse-applicant',
                runId: updated.runId,
                expectedRevision: updated.revision,
                type: 'appoint',
                target: 'chancellor',
                option: candidate.id,
              ),
            ),
            throwsA(isA<GameRuleException>()),
          );
          expect((await gateway.load()).toJson(), first.toJson());
        },
      );

      test(
        'each zero-stat ending is saved and retries never duplicate its score',
        () async {
          for (final stat in ['people', 'army', 'health', 'stability']) {
            final current = await gateway.load();
            await gateway.start(
              name: stat,
              runId: 'zero-$stat',
              seed: 42,
              previousRunId: current.active!.runId,
              previousRevision: current.active!.revision,
            );
            await store.update((archive) {
              final s = archive.active!;
              switch (stat) {
                case 'people':
                  s.people = 0;
                case 'army':
                  s.army = 0;
                case 'health':
                  s.health = 0;
                case 'stability':
                  s.stability = 0;
              }
            });
            final s = (await gateway.load()).active!;
            final c = command(s, 'finish-$stat', 'endWeek');
            final first = await gateway.dispatch(c);
            final retry = await gateway.dispatch(c);
            final restored =
                await LocalGameGateway(store, seasonal: false).load();
            expect(first.active!.ended, true);
            expect(restored.active!.endKind, first.active!.endKind);
            expect(
              restored.scores.where((score) => score.runId == s.runId),
              hasLength(1),
            );
            expect(retry.toJson(), restored.toJson());
            expect(restored.active!.completedWeeks, 0);
          }
        },
      );
    });
  }
}
