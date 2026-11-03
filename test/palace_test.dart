import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/logic/harem_rules.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';

GameState freshPalace() {
  final s = GameEngine().start('palace', 'An', 42);
  s.court = List.generate(
    4,
    (i) => Courtier(
      id: 'wife-$i',
      name: 'Nàng $i',
      role: 'Tiểu thư',
      faction: 'Văn thần',
      trait: '',
      age: 25,
      ability: 70,
      loyalty: 90,
      integrity: 95,
      ambition: 10,
      influence: 20,
      affection: 60,
      baseAffection: 60,
      personalities: [Personality.disciplined, Personality.honest],
      inHarem: true,
    ),
  );
  s.petitions.clear();
  s.nextMajorWeek = s.nextChainWeek = 10000;
  s.treasury = 1000;
  s.stability = 60;
  s.people = s.authority = s.health = s.army = 80;
  s.affairsThisWeek = 1;
  s.factions.updateAll((k, v) => 60);
  return s;
}

GameCommand palaceCommand(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => GameCommand(
  id: 'p-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: type,
  target: target,
  option: option,
);
GameState palaceSend(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => GameEngine().execute(
  s,
  palaceCommand(s, type, target: target, option: option),
);
GameState closePalace(GameState s) {
  // Isolate palace settlement from unrelated petitions/neglect over long tests.
  s.petitions.clear();
  s.affairsThisWeek = s.restThisWeek = 1;
  s.health = s.army = s.authority = 80;
  s.grain = 150;
  return palaceSend(s, 'endWeek');
}

void main() {
  test('removed palace commands cannot charge money, actions or award XP', () {
    final s = freshPalace();
    final before = s.toJson();
    for (final kind in ['study', 'charity', 'inventory']) {
      expect(
        () => palaceSend(s, 'palace', target: 'wife-0', option: kind),
        throwsA(isA<GameRuleException>()),
      );
      expect(s.toJson(), before);
    }
  });
  test('legacy palace effects cannot revive a terminal king', () {
    final s =
        freshPalace()
          ..haremVersion = 0
          ..health = 0;
    s.palaceEffects.add(
      PalaceEffect(
        kind: 'kitchen',
        personId: 'wife-0',
        startsTurn: 1,
        endsTurn: 5,
        amount: 50,
      ),
    );
    final result = palaceSend(s, 'endWeek');
    expect(result.ended, isTrue);
    expect(result.health, 0);
    expect(result.palaceEffects, isEmpty);
  });
  test(
    'gateway migration and allocation persist once without changing old money',
    () async {
      final store = MemoryGameStore();
      final before = freshPalace()..haremVersion = 0;
      before.palaceWorks.add(
        PalaceWork(
          id: 'old',
          kind: 'study',
          personId: 'wife-0',
          startedTurn: 1,
          duration: 2,
        ),
      );
      await store.update((a) => a.active = before);
      final gateway = LocalGameGateway(store);
      final migrated = (await gateway.load()).active!;
      expect(migrated.palaceWorks, isEmpty);
      expect(migrated.haremQuests, hasLength(4));
      expect(migrated.treasury, before.treasury);
      expect(migrated.points, before.points);
      expect((await gateway.load()).active!.toJson(), migrated.toJson());
      final command = palaceCommand(
        migrated,
        'harem-quest',
        target: 'wife-0',
        option: 'personal:A',
      );
      final paid = await gateway.dispatch(command);
      expect((await gateway.dispatch(command)).toJson(), paid.toJson());
      expect(haremQuestFor(paid.active!, 'wife-0')!.choices, ['A']);
      expect((await gateway.load()).toJson(), paid.toJson());
    },
  );
}
