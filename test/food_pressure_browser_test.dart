@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/food_pressure_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  test(
    'food pressure, prepaid relief and two-tab replay survive IndexedDB reopen',
    () async {
      final factory = getIdbFactory()!;
      final name = 'food-pressure-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      final other = await IndexedGameStore.open(factory, name: name);
      try {
        final s = GameEngine().start('food-browser', 'An', 42)
          ..petitions.clear();
        s.foodDisruptions.add(
          FoodDisruption(
            id: 'browser',
            title: 'Mất mùa',
            percent: 25,
            start: 0,
            until: 2,
          ),
        );
        await store.update((a) => a.active = s);
        final first = LocalGameGateway(store), second = LocalGameGateway(other);
        final loaded = (await first.load()).active!;
        final p = loaded.petitions.singleWhere(
          (p) => isFoodRecoveryEvent(p.definitionId),
        );
        final command = GameCommand(
          id: 'relief-once',
          runId: loaded.runId,
          expectedRevision: loaded.revision,
          type: 'petition',
          target: p.id,
          option: '0',
        );
        final results = await Future.wait([
          first.dispatch(command),
          second.dispatch(command),
        ]);
        expect(results.first.toJson(), results.last.toJson());
        final result = results.first.active!;
        expect(result.grain, 4000000 - 281250);
        expect(result.population!.foodCredit, 225000);
        expect(result.foodDisruptions.single.percent, 0);
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
