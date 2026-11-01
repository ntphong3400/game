import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_client_memory.dart';
import 'package:van_tue/game/presentation/outcome_read_store.dart';
import 'package:van_tue/game/presentation/outcome_read_factory_stub.dart'
    if (dart.library.html) 'package:van_tue/game/presentation/outcome_read_factory_web.dart';

void main() {
  test(
    'report acknowledgements survive reopening and remain separate per run',
    () async {
      final factory = outcomeReadFactory() ?? newIdbFactoryMemory();
      final first = OutcomeReadStore(factory: factory);
      expect(await first.read('run-a'), isEmpty);
      await first.markRead('run-a', ['a', 'b']);
      final reopened = OutcomeReadStore(factory: factory);
      expect(await reopened.read('run-a'), {'a', 'b'});
      expect(await reopened.read('run-b'), isEmpty);
      await reopened.markRead('run-b', ['a']);
      expect(await first.read('run-b'), {'a'});
      expect(await first.read('run-a'), {'a', 'b'});
    },
  );

  test(
    'concurrent acknowledgements merge rather than dropping read reports',
    () async {
      final factory = outcomeReadFactory() ?? newIdbFactoryMemory();
      final first = OutcomeReadStore(factory: factory);
      final second = OutcomeReadStore(factory: factory);
      await Future.wait([
        first.markRead('same-run', ['a']),
        second.markRead('same-run', ['b']),
      ]);
      expect(await OutcomeReadStore(factory: factory).read('same-run'), {
        'a',
        'b',
      });
    },
  );
}
