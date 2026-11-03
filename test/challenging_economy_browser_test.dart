@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  test(
    'new-profile final settlement survives two-tab replay and reopen',
    () async {
      final factory = getIdbFactory()!;
      final name = 'challenge-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      final other = await IndexedGameStore.open(factory, name: name);
      try {
        final engine = GameEngine();
        final state =
            engine.start('challenge', 'An', 42)
              ..petitions.clear()
              ..midSeasonDelivered = true
              ..chains = [
                StoryArc(
                  id: 'market',
                  kind: 'market',
                  dueWeek: 1,
                  stage: 3,
                  completedSteps: 3,
                  currencyScale: 100,
                  settlementVersion: 2,
                  investedValue: 15000,
                  cashSpent: 15000,
                ),
              ];
        engine.prepareStoryPetitions(state);
        await store.update((archive) => archive.active = state);
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final first = LocalGameGateway(store), second = LocalGameGateway(other);
        final loaded = (await first.load()).active!;
        expect(loaded.balanceVersion, 2);
        expect(loaded.chains.single.settlementVersion, 2);
        final command = GameCommand(
          id: 'final',
          runId: loaded.runId,
          expectedRevision: loaded.revision,
          type: 'petition',
          target: loaded.petitions.single.id,
          option: '1',
        );
        final results = await Future.wait([
          first.dispatch(command),
          second.dispatch(command),
        ]);
        expect(results.first.toJson(), results.last.toJson());
        final done = results.first.active!;
        expect(done.treasury, loaded.treasury - 7000 + 30800);
        expect(done.chains, isEmpty);
        expect(
          done.financialWeeks
              .expand((w) => w.entries)
              .where((e) => e.title == 'Quyết toán: Bến chợ Đông Hà'),
          hasLength(1),
        );
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final reopened = LocalGameGateway(store);
        expect((await reopened.load()).toJson(), results.first.toJson());
        expect(
          (await reopened.dispatch(command)).toJson(),
          results.first.toJson(),
        );
      } finally {
        store.close();
        other.close();
        await factory.deleteDatabase(name);
      }
    },
  );
}
