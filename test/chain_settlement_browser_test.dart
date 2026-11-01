@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'chain_settlement_test.dart'
    show settlementState, settleChoice, nextSettlementSeason, settlementCommand;

void main() {
  for (final kind in ['market', 'exams', 'haremHarmony']) {
    test(
      '$kind progress and final settlement persist atomically in IndexedDB',
      () async {
        final factory = getIdbFactory()!;
        final name =
            'van-tue-settlement-$kind-${DateTime.now().microsecondsSinceEpoch}';
        var store = await IndexedGameStore.open(factory, name: name);
        final other = await IndexedGameStore.open(factory, name: name);
        try {
          var s = settlementState(kind);
          final option = kind == 'haremHarmony' ? '2' : '1';
          for (var i = 0; i < 3; i++) {
            s = settleChoice(s, option);
            s = nextSettlementSeason(s);
          }
          await store.update((a) => a.active = s);
          store.close();
          store = await IndexedGameStore.open(factory, name: name);
          final first = LocalGameGateway(store),
              second = LocalGameGateway(other);
          final loads = await Future.wait([first.load(), second.load()]);
          expect(loads[0].toJson(), loads[1].toJson());
          final loaded = loads.first.active!;
          expect(loaded.chains.single.toJson(), s.chains.single.toJson());
          expect(loaded.rng, s.rng);
          final p = loaded.petitions.singleWhere((p) => p.storyId == 'arc');
          final cmd = settlementCommand(
            loaded,
            'petition',
            target: p.id,
            option: option,
          );
          final commits = await Future.wait([
            first.dispatch(cmd),
            second.dispatch(cmd),
          ]);
          expect(commits[0].toJson(), commits[1].toJson());
          final done = commits.first.active!;
          expect(done.chains, isEmpty);
          expect(
            done.outcomes.where((o) => o.title.startsWith('Quyết toán:')),
            hasLength(1),
          );
          if (kind == 'market') {
            expect(done.treasury, loaded.treasury - 70 + 550);
            expect(
              done.financialWeeks
                  .expand((w) => w.entries)
                  .where((e) => e.title == 'Quyết toán: Bến chợ Đông Hà'),
              hasLength(1),
            );
          }
          if (kind == 'exams') {
            expect(done.officialsPool.length, loaded.officialsPool.length + 1);
          }
          if (kind == 'haremHarmony') {
            for (final id in loaded.chains.single.participantIds) {
              expect(
                done.court.firstWhere((c) => c.id == id).ability,
                loaded.court.firstWhere((c) => c.id == id).ability + 5,
              );
            }
          }
          store.close();
          store = await IndexedGameStore.open(factory, name: name);
          final reopened = LocalGameGateway(store);
          expect((await reopened.load()).toJson(), commits.first.toJson());
          expect(
            (await reopened.dispatch(cmd)).toJson(),
            commits.first.toJson(),
          );
        } finally {
          store.close();
          other.close();
          await factory.deleteDatabase(name);
        }
      },
    );
  }
}
