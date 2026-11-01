import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  for (final seasonal in [true, false]) {
    final engine = GameEngine(seasonal: seasonal);
    GameState fresh(String faction) {
      final s = engine.start('recruitment', 'An', 42);
      s.court.firstWhere((c) => c.id == 'consort_lan').faction = faction;
      s.petitions = [
        Petition(
          id: 'recommendation',
          definitionId: 'consort_recommendation',
          openedWeek: s.week,
          deadline: s.week + 1,
          targetId: 'consort_lan',
        ),
      ];
      return s;
    }

    GameState choose(GameState s, String option) => engine.execute(
      s,
      GameCommand(
        id: 'decision',
        runId: s.runId,
        expectedRevision: s.revision,
        type: 'petition',
        target: 'recommendation',
        option: option,
      ),
    );

    for (final faction in factionOpponents.keys) {
      for (final accept in [true, false]) {
        test(
          'recruitment seasonal=$seasonal faction=$faction accept=$accept',
          () {
            final before = fresh(faction);
            final definition = eventForState(before, 'consort_recommendation');
            expect(definition.choices.map((c) => c.label), [
              'Nhận làm tú nữ',
              'Khước từ tiến cử',
            ]);
            final next = choose(before, accept ? '0' : '1');
            expect(next.treasury, before.treasury - (accept ? 20 : 0));
            expect(next.points, before.points - 1);
            expect(next.stress, before.stress);
            expect(next.stability, before.stability);
            expect(next.petitions.any((p) => p.id == 'recommendation'), false);
            expect(
              budgetExpenses(next)['court']!.amount,
              budgetExpenses(before)['court']!.amount,
            );
            for (final f in before.factions.keys) {
              final delta =
                  f == faction
                      ? (accept ? 3 : -5)
                      : f == factionOpponents[faction]
                      ? (accept ? -5 : 3)
                      : 0;
              expect(next.factions[f], before.factions[f]! + delta);
            }
            for (final person in next.court) {
              final original = before.court.firstWhere(
                (c) => c.id == person.id,
              );
              expect(person.affection, original.affection);
              expect(person.discontent, original.discontent);
            }
            expect(
              next.court.firstWhere((c) => c.id == 'consort_lan').inHarem,
              false,
            );
            expect(
              next.court.firstWhere((c) => c.id == 'consort_lan').category,
              'Tú nữ',
            );
            expect(next.copy().toJson(), next.toJson());
          },
        );
      }
    }

    test(
      'accepted tú nữ enters the palace only by invitation seasonal=$seasonal',
      () {
        final accepted = choose(fresh('Văn thần'), '0');
        final restored = accepted.copy();
        final admitted = engine.execute(
          restored,
          GameCommand(
            id: 'invite-after-acceptance',
            runId: restored.runId,
            expectedRevision: restored.revision,
            type: 'courtier',
            target: 'consort_lan',
            option: 'invite',
          ),
        );
        final person = admitted.court.firstWhere((c) => c.id == 'consort_lan');
        expect(person.inHarem, true);
        expect(person.category, 'Phi tần');
        expect(admitted.treasury, accepted.treasury - 35);
        expect(admitted.points, accepted.points - 1);
        expect(
          budgetExpenses(admitted)['court']!.amount,
          budgetExpenses(accepted)['court']!.amount + (seasonal ? 6 : 2),
        );
      },
    );

    test('recruitment checks money and actions seasonal=$seasonal', () {
      final s = fresh('Văn thần')..treasury = 19;
      final saved = s.toJson();
      expect(() => choose(s, '0'), throwsA(isA<GameRuleException>()));
      expect(s.toJson(), saved);
      s.treasury = 20;
      expect(choose(s, '0').treasury, 0);
      s.treasury = 0;
      expect(choose(s, '1').treasury, 0);
      s.points = 0;
      for (final option in ['0', '1', '2']) {
        expect(() => choose(s, option), throwsA(isA<GameRuleException>()));
      }
    });
  }
}
