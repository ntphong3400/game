@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:van_tue/game/data/character_identity.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  test(
    'two tabs migrate legacy public IDs atomically and preserve them on reopen/replay',
    () async {
      final factory = getIdbFactory()!;
      final name =
          'king-character-identity-${DateTime.now().microsecondsSinceEpoch}';
      final firstStore = await IndexedGameStore.open(factory, name: name);
      final secondStore = await IndexedGameStore.open(factory, name: name);
      final engine = GameEngine(seasonal: false, populationEnabled: false);
      try {
        final legacy = engine.start('legacy-identities', 'An', 42);
        await firstStore.update((a) => a.active = legacy);
        final first = LocalGameGateway(firstStore, engine: engine);
        final second = LocalGameGateway(secondStore, engine: engine);
        final results = await Future.wait([first.load(), second.load()]);
        expect(results[0].toJson(), results[1].toJson());
        final migrated = results.first.active!;
        expect(needsCharacterPublicIds(migrated), isFalse);
        expect(migrated.rng, legacy.rng);
        expect(migrated.revision, legacy.revision);
        final ids = {
          for (final p in [...migrated.court, ...migrated.officialsPool])
            p.id: p.publicId,
        };
        final command = GameCommand(
          id: 'talk',
          runId: migrated.runId,
          expectedRevision: migrated.revision,
          type: 'courtier',
          target: 'treasurer',
          option: 'audience',
        );
        final committed = await Future.wait([
          first.dispatch(command),
          second.dispatch(command),
        ]);
        expect(committed[0].toJson(), committed[1].toJson());
        for (final p in [
          ...committed.first.active!.court,
          ...committed.first.active!.officialsPool,
        ]) {
          expect(p.publicId, ids[p.id]);
        }
        firstStore.close();
        final reopened = await IndexedGameStore.open(factory, name: name);
        try {
          expect(
            (await LocalGameGateway(reopened, engine: engine).load()).toJson(),
            committed.first.toJson(),
          );
        } finally {
          reopened.close();
        }
      } finally {
        firstStore.close();
        secondStore.close();
        await factory.deleteDatabase(name);
      }
    },
  );
}
