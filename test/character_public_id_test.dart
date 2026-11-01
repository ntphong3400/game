import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/character_identity.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';

List<Courtier> people(GameState s) => [...s.court, ...s.officialsPool];

Map<String, dynamic> gameplay(GameState s) {
  final json = object(jsonDecode(jsonEncode(s.toJson())));
  for (final list in ['court', 'officialsPool']) {
    for (final person in json[list] as List) {
      (person as Map).remove('publicId');
    }
  }
  return json;
}

class CountingStore extends MemoryGameStore {
  int writes = 0;
  @override
  Future<GameArchive> update(void Function(GameArchive archive) change) {
    writes++;
    return super.update(change);
  }
}

Future<GameArchive> start(
  LocalGameGateway gateway, [
  String run = 'identity',
]) => gateway.start(
  name: 'An',
  runId: run,
  seed: 42,
  previousRunId: null,
  previousRevision: null,
);

void main() {
  test(
    'new reigns allocate unique UUIDs independently of gameplay RNG',
    () async {
      final firstGateway = LocalGameGateway(MemoryGameStore());
      final secondGateway = LocalGameGateway(MemoryGameStore());
      final first = (await start(firstGateway)).active!;
      final second = (await start(secondGateway)).active!;
      final ids = people(first).map((p) => p.publicId).toSet();
      expect(ids.every(isCharacterPublicId), isTrue);
      expect(ids.length, people(first).map((p) => p.id).toSet().length);
      expect(people(second).any((p) => ids.contains(p.publicId)), isFalse);
      expect(gameplay(first), gameplay(second));
      expect(
        gameplay(first),
        gameplay(firstGateway.engine.start('identity', 'An', 42)),
      );
      expect(first.copy().toJson(), first.toJson());
      expect((await firstGateway.load()).active!.toJson(), first.toJson());
    },
  );

  for (final seasonal in [false, true]) {
    for (final ended in [false, true]) {
      test(
        'legacy migration is persisted once: seasonal=$seasonal ended=$ended',
        () async {
          final store = CountingStore();
          final engine = GameEngine(seasonal: seasonal);
          final old = engine.start('old', 'An', 42);
          if (ended) old.endReason = 'Triều đại đã kết thúc.';
          await store.update((a) => a.active = old);
          final before = (await store.read()).toJson();
          final gateway = LocalGameGateway(store, engine: engine);
          final migrated = await gateway.load();
          expect(
            people(
              migrated.active!,
            ).every((p) => isCharacterPublicId(p.publicId)),
            isTrue,
          );
          expect(gameplay(migrated.active!), before['active']);
          expect(store.writes, 2);
          expect((await store.read()).toJson(), migrated.toJson());
          final loadedAgain =
              await LocalGameGateway(store, engine: engine).load();
          expect(loadedAgain.toJson(), migrated.toJson());
          expect(store.writes, 2);
        },
      );
    }
  }

  test(
    'appointment keeps both identities and assigns a UUID to the new candidate',
    () async {
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(
        store,
        engine: GameEngine(seasonal: false, populationEnabled: false),
      );
      final initial = (await start(gateway)).active!;
      final candidate = initial.officialsPool.first;
      final old = initial.court.firstWhere((p) => p.id == 'treasurer');
      final before = {for (final p in people(initial)) p.id: p.publicId};
      final command = GameCommand(
        id: 'appoint',
        runId: initial.runId,
        expectedRevision: initial.revision,
        type: 'appoint',
        target: old.id,
        option: candidate.id,
      );
      final expected = gateway.engine.execute(initial, command);
      final appointed = await gateway.dispatch(command);
      final next = appointed.active!;
      expect(gameplay(next), gameplay(expected));
      expect(next.court.firstWhere((p) => p.id == candidate.id).role, old.role);
      for (final p in people(next)) {
        if (before.containsKey(p.id)) {
          expect(p.publicId, before[p.id], reason: p.id);
        } else {
          expect(isCharacterPublicId(p.publicId), isTrue);
          expect(before.values, isNot(contains(p.publicId)));
        }
      }
      expect(people(next).length, greaterThan(people(initial).length));
      expect((await gateway.dispatch(command)).toJson(), appointed.toJson());
    },
  );

  test(
    'palace admission changes rank without changing the public ID',
    () async {
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store);
      final initial = (await start(gateway)).active!;
      final person = initial.court.firstWhere((p) => p.id == 'consort_lan');
      expect(person.inHarem, isFalse);
      final next =
          (await gateway.dispatch(
            GameCommand(
              id: 'invite',
              runId: initial.runId,
              expectedRevision: initial.revision,
              type: 'courtier',
              target: person.id,
              option: 'invite',
            ),
          )).active!;
      final invited = next.court.firstWhere((p) => p.id == person.id);
      expect(invited.inHarem, isTrue);
      expect(invited.publicId, person.publicId);
      expect((await gateway.load()).active!.toJson(), next.toJson());
    },
  );

  test(
    'migration unifies copies of the same person and repairs conflicting IDs',
    () async {
      final store = MemoryGameStore();
      final state = GameEngine(seasonal: false).start('duplicates', 'An', 42);
      const existing = '550e8400-e29b-41d4-a716-446655440000';
      final original = state.court.first;
      final copy = Courtier.fromJson(original.toJson())..publicId = existing;
      state.officialsPool.add(copy);
      state.court[1].publicId = existing;
      state.court[2].publicId = 'not-a-uuid';
      await store.update((a) => a.active = state);
      final migrated = (await LocalGameGateway(store).load()).active!;
      expect(needsCharacterPublicIds(migrated), isFalse);
      final matching = people(migrated).where((p) => p.id == original.id);
      expect(matching.map((p) => p.publicId).toSet(), {existing});
      expect(migrated.court[1].publicId, isNot(existing));
      expect(isCharacterPublicId(migrated.court[2].publicId), isTrue);
    },
  );
}
