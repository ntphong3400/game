import 'package:idb_shim/idb.dart';
import 'outcome_read_factory_stub.dart'
    if (dart.library.html) 'outcome_read_factory_web.dart';

/// Interface acknowledgements live separately from the gameplay archive.
/// If browser storage is unavailable, reading reports still works in memory.
class OutcomeReadStore {
  OutcomeReadStore({IdbFactory? factory})
    : _factory = factory ?? outcomeReadFactory();

  final IdbFactory? _factory;
  final _memory = <String, Set<String>>{};
  Future<Database>? _database;

  Future<Database> _open() =>
      _database ??= _factory!.open(
        'van-tue-interface',
        version: 1,
        onUpgradeNeeded: (event) {
          event.database.createObjectStore('read-outcomes');
        },
      );

  Future<Set<String>> read(String runId) async {
    final known = _memory.putIfAbsent(runId, () => <String>{});
    if (_factory != null) {
      try {
        final db = await _open();
        final transaction = db.transaction('read-outcomes', idbModeReadOnly);
        final raw = await transaction
            .objectStore('read-outcomes')
            .getObject(runId);
        await transaction.completed;
        if (raw is List) known.addAll(raw.whereType<String>());
      } catch (_) {
        // A display preference must never prevent a game from loading.
      }
    }
    return Set.of(known);
  }

  Future<void> markRead(String runId, Iterable<String> ids) async {
    final known = _memory.putIfAbsent(runId, () => <String>{})..addAll(ids);
    if (_factory == null) return;
    try {
      final db = await _open();
      final transaction = db.transaction('read-outcomes', idbModeReadWrite);
      final completed = transaction.completed.then<Object?>(
        (_) => null,
        onError: (Object error) => error,
      );
      final store = transaction.objectStore('read-outcomes');
      final raw = await store.getObject(runId);
      final merged = {...known, if (raw is List) ...raw.whereType<String>()};
      await store.put(merged.toList(), runId);
      await completed;
      known.addAll(merged);
    } catch (_) {
      // Keep the in-memory acknowledgement when persistence is unavailable.
    }
  }
}
