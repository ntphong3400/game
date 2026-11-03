import 'package:van_tue/game/data/harem_quests.dart';
import 'package:van_tue/game/logic/harem_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

/// Tests of unrelated finance/UI behavior explicitly start after the story.
/// Quest progression itself is exercised through commands in harem_quests_test.
void completeHaremStory(GameState s, Courtier c, {bool queen = false}) {
  final benefit = haremPassives(c, asQueen: queen)[queen ? 1 : 0].benefit;
  final d = haremQuestCatalog.firstWhere(
    (d) =>
        !d.conflict && d.queen == queen && d.benefit == benefit && d.foundation,
  );
  s.haremQuests.removeWhere((q) => q.personId == c.id && q.queen == queen);
  s.haremQuests.add(
    HaremQuest(
      personId: c.id,
      definitionId: d.id,
      assignedTurn: 1,
      faction: 'Võ tướng',
      queen: queen,
      stage: 3,
    ),
  );
}
