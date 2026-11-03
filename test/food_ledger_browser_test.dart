@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'food_ledger_test.dart' show ledgerState, reconcilesFood;

void main() {
  test(
    'food ledger and ration offsets survive two-tab replay and reopen',
    () async {
      final factory = getIdbFactory()!;
      final name = 'food-ledger-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      final other = await IndexedGameStore.open(factory, name: name);
      try {
        await store.update((a) => a.active = ledgerState());
        final first = LocalGameGateway(store), second = LocalGameGateway(other);
        Future<GameArchive> once(
          String type,
          String target,
          String option,
        ) async {
          final s = (await first.load()).active!;
          final command = GameCommand(
            id: '$type-$target-${s.revision}',
            runId: s.runId,
            expectedRevision: s.revision,
            type: type,
            target: target,
            option: option,
          );
          final results = await Future.wait([
            first.dispatch(command),
            second.dispatch(command),
          ]);
          expect(results.first.toJson(), results.last.toJson());
          expect(
            (await first.dispatch(command)).toJson(),
            results.first.toJson(),
          );
          reconcilesFood(results.first.active!);
          return results.first;
        }

        var archive = await once('action', 'buy_grain', 'treasurer');
        expect(
          archive.active!.foodWeeks.single.entries.where(
            (e) => e.category == 'purchase',
          ),
          hasLength(1),
        );
        archive = await once('population', 'supply_army', '');
        expect(archive.active!.foodWeeks.single.prepaid, 20000);
        expect(
          archive.active!.foodWeeks.single.entries.where((e) => e.prepaid > 0),
          hasLength(1),
        );
        await store.update((a) {
          a.active!.petitions.clear();
          a.active!.affairsThisWeek =
              a.active!.workThisWeek = a.active!.restThisWeek = 1;
        });
        archive = await once('endWeek', '', '');
        final closed = archive.active!.foodWeeks.first;
        expect(closed.closed, isTrue);
        expect(closed.prepaid, 20000);
        expect(closed.applied, 20000);
        expect(closed.outstanding, 0);
        expect(
          closed.entries.where((e) => e.category == 'consumption'),
          hasLength(1),
        );
        expect(archive.active!.foodWeeks.last.openingPrepaid, 0);
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final reopened = LocalGameGateway(store);
        expect((await reopened.load()).toJson(), archive.toJson());
        reconcilesFood((await reopened.load()).active!);
      } finally {
        store.close();
        other.close();
        await factory.deleteDatabase(name);
      }
    },
  );
}
