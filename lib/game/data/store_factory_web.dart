import 'package:idb_shim/idb_browser.dart';
import 'game_store.dart';

Future<GameStore> openGameStore() async {
  final factory = getIdbFactory();
  if (factory == null) throw StateError('Trình duyệt không hỗ trợ IndexedDB.');
  return IndexedGameStore.open(factory);
}
