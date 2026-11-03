import '../data/game_store.dart';
import '../data/character_identity.dart';
import '../models/game_state.dart';
import 'game_engine.dart';

/// Replace this boundary with an HTTP implementation when server play arrives.
abstract class GameGateway {
  Future<GameArchive> load();
  Future<GameArchive> start({
    required String name,
    required String runId,
    required int seed,
    required String? previousRunId,
    required int? previousRevision,
  });
  Future<GameArchive> dispatch(GameCommand command);
}

class LocalGameGateway implements GameGateway {
  LocalGameGateway(this.store, {GameEngine? engine, bool seasonal = true})
    : engine = engine ?? GameEngine(seasonal: seasonal);
  final GameStore store;
  final GameEngine engine;

  Future<GameArchive> _update(void Function(GameArchive) change) =>
      store.update((archive) {
        change(archive);
        final state = archive.active;
        if (state != null) ensureCharacterPublicIds(state);
      });

  @override
  Future<GameArchive> load() async {
    final archive = await store.read();
    final state = archive.active;
    if (state == null) return archive;
    final syncStory =
        state.seasonal &&
        !state.ended &&
        (!state.midSeasonDelivered || engine.storyPetitionsNeedSync(state));
    final syncHarem = engine.haremQuestsNeedSync(state);
    if (!syncStory && !syncHarem && !needsCharacterPublicIds(state)) {
      return archive;
    }
    return _update((latest) {
      final current = latest.active;
      if (current != null && current.seasonal && !current.ended) {
        final stories = engine.prepareStoryPetitions(current);
        final petitions = engine.revealSeasonPetitions(current);
        final harem = engine.prepareHaremQuests(current);
        if (stories || petitions || harem) current.revision++;
      }
    });
  }

  @override
  Future<GameArchive> start({
    required String name,
    required String runId,
    required int seed,
    required String? previousRunId,
    required int? previousRevision,
  }) {
    if (name.trim().isEmpty || name.trim().length > 32 || runId.isEmpty) {
      throw const GameRuleException('Tên người chơi cần từ 1 đến 32 ký tự.');
    }
    return _update((archive) {
      final signature = '$name|$seed|$previousRunId|$previousRevision';
      if (archive.starts.containsKey(runId)) {
        if (archive.starts[runId] != signature) {
          throw const GameRuleException('Mã lượt chơi đã được sử dụng.');
        }
        return;
      }
      if (archive.active?.runId != previousRunId ||
          archive.active?.revision != previousRevision) {
        throw const GameRuleException(
          'Có lượt chơi mới hơn ở cửa sổ khác. Hãy tải lại trước khi bắt đầu.',
        );
      }
      archive.active = engine.start(runId, name, seed);
      archive.starts[runId] = signature;
    });
  }

  @override
  Future<GameArchive> dispatch(GameCommand command) => _update((archive) {
    if (archive.receipts.containsKey(command.id)) {
      if (archive.receipts[command.id] != command.signature) {
        throw const GameRuleException(
          'Mã yêu cầu đã được dùng cho một hành động khác.',
        );
      }
      return; // Return latest committed snapshot; never execute a retry again.
    }
    final current = archive.active;
    if (current == null) {
      throw const GameRuleException('Chưa có lượt chơi để tiếp tục.');
    }
    final result = engine.execute(current, command);
    archive.active = result;
    archive.receipts[command.id] = command.signature;
    if (result.ended &&
        !archive.scores.any((score) => score.runId == result.runId)) {
      archive.scores.add(
        ScoreEntry(
          result.runId,
          result.playerName,
          result.completedWeeks,
          rules: result.scoreRules,
          seasonal: result.seasonal,
        ),
      );
    }
  });
}
