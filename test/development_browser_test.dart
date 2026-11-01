@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  test(
    'IndexedDB keeps upgrade capital, frozen chances and crop samples across tabs',
    () async {
      final factory = getIdbFactory()!;
      final name = 'king-development-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      final otherStore = await IndexedGameStore.open(factory, name: name);
      try {
        final s = GameEngine().start('browser-development', 'An', 42);
        s.treasury = 5000;
        s.economyLevel = 2;
        s.nextMajorWeek = s.nextChainWeek = 10000;
        s.petitions.clear();
        final c = s.court.firstWhere((c) => c.id == 'treasurer');
        c.ability = 95;
        c.specialty = 'Kinh tế';
        await store.update((a) => a.active = s);
        final first = LocalGameGateway(store),
            second = LocalGameGateway(otherStore);
        final command = GameCommand(
          id: 'start-upgrade',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'action',
          target: 'upgrade_economy',
          option: c.id,
        );
        final results = await Future.wait([
          first.dispatch(command),
          second.dispatch(command),
        ]);
        expect(results[0].toJson(), results[1].toJson());
        final begun = results.first.active!;
        expect(begun.treasury, 4850);
        expect(begun.projects, hasLength(1));
        await store.update((a) {
          final current = a.active!;
          current.petitions.clear();
          current.affairsThisWeek =
              current.workThisWeek = current.restThisWeek = 1;
          current.rng = 100;
        });
        final turn = GameCommand(
          id: 'spring-close',
          runId: begun.runId,
          expectedRevision: begun.revision,
          type: 'endWeek',
        );
        final closed = await first.dispatch(turn);
        expect(closed.active!.projects.single.progress, 1);
        final sample = closed.active!.springLeveePercent;
        expect(sample, isNotNull);
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final reopened = LocalGameGateway(store);
        expect((await store.read()).toJson(), closed.toJson());
        expect((await reopened.dispatch(turn)).toJson(), closed.toJson());
        final loaded = (await store.read()).active!;
        expect(
          loaded.projects.single.successChance,
          begun.projects.single.successChance,
        );
        expect(loaded.springLeveePercent, sample);
        await store.update((a) {
          a.active!.petitions.clear();
          a.active!.affairsThisWeek =
              a.active!.workThisWeek = a.active!.restThisWeek = 1;
          a.active!.rng = 100;
        });
        final completion = GameCommand(
          id: 'summer-close',
          runId: loaded.runId,
          expectedRevision: loaded.revision,
          type: 'endWeek',
        );
        final settled = await Future.wait([
          reopened.dispatch(completion),
          second.dispatch(completion),
        ]);
        expect(settled[0].toJson(), settled[1].toJson());
        expect(settled.first.active!.economyLevel, 3);
        expect(settled.first.active!.projects, isEmpty);
        expect(settled.first.active!.springLeveePercent, sample);
        expect(settled.first.active!.summerLeveePercent, isNotNull);
      } finally {
        store.close();
        otherStore.close();
        await factory.deleteDatabase(name);
      }
    },
  );
}
