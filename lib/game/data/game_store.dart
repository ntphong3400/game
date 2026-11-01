import 'dart:convert';

import 'package:idb_shim/idb.dart';

import '../models/game_state.dart';

abstract class GameStore {
  Future<GameArchive> read();
  Future<GameArchive> update(void Function(GameArchive archive) change);
  void close();
}

/// One IndexedDB read/write transaction owns the complete archive. Reads and
/// writes from competing tabs are serialized by the browser, including CAS.
class IndexedGameStore implements GameStore {
  IndexedGameStore._(this.database);
  final Database database;
  static Future<IndexedGameStore> open(
    IdbFactory factory, {
    String name = 'van-tue-mvp',
  }) async {
    final db = await factory.open(
      name,
      version: 1,
      onUpgradeNeeded: (event) {
        event.database.createObjectStore('archive');
      },
    );
    return IndexedGameStore._(db);
  }

  GameArchive _decode(dynamic raw) =>
      raw == null
          ? GameArchive()
          : GameArchive.fromJson(object(jsonDecode(raw as String)));

  @override
  Future<GameArchive> read() async {
    final transaction = database.transaction('archive', idbModeReadOnly);
    final raw = await transaction.objectStore('archive').getObject('current');
    await transaction.completed;
    return _decode(raw);
  }

  @override
  Future<GameArchive> update(void Function(GameArchive archive) change) async {
    final transaction = database.transaction('archive', idbModeReadWrite);
    // Attach the abort handler immediately, including when validation fails.
    final completed = transaction.completed.then<Object?>(
      (_) => null,
      onError: (Object error) => error,
    );
    try {
      final store = transaction.objectStore('archive');
      final archive = _decode(await store.getObject('current'));
      change(archive); // Synchronous engine work; no timer/network awaits here.
      await store.put(jsonEncode(archive.toJson()), 'current');
      final error = await completed;
      if (error != null) throw error;
      return archive;
    } catch (_) {
      try {
        transaction.abort();
      } catch (_) {
        /* already completed */
      }
      await completed;
      rethrow;
    }
  }

  @override
  void close() => database.close();
}

class MemoryGameStore implements GameStore {
  String? _data;
  @override
  Future<GameArchive> read() async =>
      _data == null
          ? GameArchive()
          : GameArchive.fromJson(object(jsonDecode(_data!)));
  @override
  Future<GameArchive> update(void Function(GameArchive archive) change) async {
    final archive =
        _data == null
            ? GameArchive()
            : GameArchive.fromJson(object(jsonDecode(_data!)));
    change(archive);
    _data = jsonEncode(archive.toJson());
    return archive;
  }

  @override
  void close() {}
}
