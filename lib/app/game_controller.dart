import 'dart:math';
import 'package:flutter/foundation.dart';
import '../game/logic/game_gateway.dart';
import '../game/models/game_state.dart';

class GameController extends ChangeNotifier {
  GameController(this.gateway);
  final GameGateway gateway;
  final _random = Random.secure();
  GameArchive archive = GameArchive();
  bool loading = true, busy = false;
  String? error;
  GameState? get state => archive.active;

  String _id() => List.generate(
    4,
    (_) => _random.nextInt(0x7fffffff).toRadixString(36),
  ).join('-');

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      archive = await gateway.load();
    } catch (e) {
      error = 'Không thể đọc bản lưu: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> start(String name) => _commit(
    () => gateway.start(
      name: name,
      runId: _id(),
      seed: _random.nextInt(2147483645) + 1,
      previousRunId: state?.runId,
      previousRevision: state?.revision,
    ),
  );

  Future<bool> act(
    String type, {
    String target = '',
    String option = '',
    String assigneeId = '',
  }) async {
    final s = state;
    if (s == null || busy) return false;
    final command = GameCommand(
      id: _id(),
      runId: s.runId,
      expectedRevision: s.revision,
      type: type,
      target: target,
      option: option,
      assigneeId: assigneeId,
    );
    return _commit(() => gateway.dispatch(command));
  }

  Future<bool> _commit(Future<GameArchive> Function() operation) async {
    if (busy) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      archive = await operation();
      return true;
    } catch (e) {
      error =
          e is GameRuleException
              ? e.message
              : 'Chưa lưu được thay đổi. Hãy thử lại. ($e)';
      try {
        archive = await gateway.load();
      } catch (_) {
        /* retain last good view */
      }
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
