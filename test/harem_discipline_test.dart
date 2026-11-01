import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/currency_rules.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/harem_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

Courtier lan(GameState s) => s.court.firstWhere((c) => c.id == 'consort_lan');

GameState fresh(GameEngine engine, String rank) {
  final s = engine.start('discipline', 'An', 42);
  s.treasury = 0;
  s.stability = 80;
  s.factions.updateAll((k, v) => 60);
  final c = lan(s);
  c.inHarem = rank != 'Tú nữ';
  c.queen = rank == 'Hoàng hậu';
  c.affection = 80;
  c.discontent = 10;
  c.ability = 99;
  return s;
}

GameCommand command(
  GameState s,
  String option, {
  String target = 'consort_lan',
}) => GameCommand(
  id: 'discipline-${s.revision}',
  runId: s.runId,
  expectedRevision: s.revision,
  type: 'courtier',
  target: target,
  option: option,
);

void main() {
  for (final seasonal in [true, false]) {
    final engine = GameEngine(seasonal: seasonal);
    test(
      'expulsion costs one action and only lowers the own faction by two seasonal=$seasonal',
      () async {
        final s = fresh(engine, 'Tú nữ');
        final original = s.toJson();
        final faction = lan(s).faction;
        final upkeep = budgetExpenses(s)['court']!.amount;
        final store = MemoryGameStore();
        await store.update((a) => a.active = s);
        final gateway = LocalGameGateway(store, engine: engine);
        final request = command(s, 'expel');
        final committed = await gateway.dispatch(request);
        final result = committed.active!;
        expect(result.points, s.points - 1);
        expect(result.treasury, 0);
        expect(result.debt, s.debt);
        expect(result.grain, s.grain);
        expect(result.factions[faction], 58);
        expect(result.stability, s.stability);
        expect(
          result.journal.first.text,
          contains('Ổn định triều đình không đổi'),
        );
        for (final other in s.factions.keys.where((f) => f != faction)) {
          expect(result.factions[other], s.factions[other]);
        }
        expect(lan(result).available, false);
        expect(
          result.court.length,
          s.court.length,
        ); // Keep historical identity.
        expect(
          result.court
              .where((c) => c.available)
              .any((c) => c.id == 'consort_lan'),
          false,
        );
        expect(budgetExpenses(result)['court']!.amount, upkeep);
        expect(result.journal.first.title, 'Trục xuất ${lan(s).name}');
        expect(
          result.financialWeeks.last.entries.any((e) => e.amount != 0),
          false,
        );
        expect((await gateway.dispatch(request)).toJson(), committed.toJson());
        expect((await gateway.load()).active!.toJson(), result.toJson());
        expect(GameState.fromJson(result.toJson()).toJson(), result.toJson());
        for (final option in ['expel', 'demote', 'invite', 'audience']) {
          expect(
            () => engine.execute(result, command(result, option)),
            throwsA(isA<GameRuleException>()),
          );
        }
        expect(s.toJson(), original);
      },
    );

    for (final rank in ['Hoàng hậu', 'Phi tần']) {
      test(
        'demotion lowers exactly one rank without money or refunds from $rank seasonal=$seasonal',
        () {
          final s = fresh(engine, rank);
          final original = s.toJson();
          final person = lan(s);
          final upkeep = budgetExpenses(s)['court']!.amount;
          final result = engine.execute(s, command(s, 'demote'));
          final queen = rank == 'Hoàng hậu';
          final loss = queen ? 30 : 20;
          expect(lan(result).displayRole, queen ? 'Phi tần' : 'Tú nữ');
          expect(lan(result).available, true);
          expect(lan(result).queen, false);
          expect(lan(result).inHarem, queen);
          expect(lan(result).affection, 80 - loss);
          expect(lan(result).discontent, 10 + loss);
          expect(result.factions[person.faction], queen ? 48 : 52);
          expect(result.stability, queen ? s.stability - 8 : s.stability);
          expect(
            result.journal.first.text,
            contains(
              queen ? 'Ổn định triều đình −8' : 'Ổn định triều đình không đổi',
            ),
          );
          expect(result.points, s.points - 1);
          expect(result.treasury, 0);
          expect(result.grain, s.grain);
          expect(result.debt, s.debt);
          expect(lan(result).loyalty, person.loyalty);
          expect(lan(result).influence, person.influence);
          expect(lan(result).ambition, person.ambition);
          expect(lan(result).ability, person.ability);
          expect(result.court.where((c) => c.queen), isEmpty);
          expect(haremPassives(lan(result)).length, 1);
          expect(
            budgetExpenses(result)['court']!.amount,
            upkeep - (queen ? 0 : money(s, seasonal ? 6 : 2)),
          );
          if (!queen) {
            expect(
              HaremBenefits(
                result,
              ).contributions.any((c) => c.person.id == person.id),
              false,
            );
          }
          expect(haremPromotionBlocked(result, lan(result)), isNotNull);
          final reloaded = GameState.fromJson(result.toJson());
          reloaded.treasury = money(
            s,
            1000,
          ); // Test the cooldown, independently of funds.
          final beforeRetry = reloaded.toJson();
          expect(
            () => engine.execute(
              reloaded,
              command(reloaded, queen ? 'queen' : 'invite'),
            ),
            throwsA(
              isA<GameRuleException>().having(
                (e) => e.message,
                'reason',
                contains('Chỉ tuyển hoặc sắc phong lại'),
              ),
            ),
          );
          expect(reloaded.toJson(), beforeRetry);
          reloaded.completedWeeks++;
          expect(haremPromotionBlocked(reloaded, lan(reloaded)), isNull);
          final restored = engine.execute(
            reloaded,
            command(reloaded, queen ? 'queen' : 'invite'),
          );
          expect(lan(restored).displayRole, rank);
          expect(s.toJson(), original);
        },
      );
    }

    test(
      'rank restrictions and exhausted actions reject atomically seasonal=$seasonal',
      () {
        for (final rank in ['Tú nữ', 'Phi tần', 'Hoàng hậu']) {
          final s = fresh(engine, rank);
          final snapshot = s.toJson();
          expect(
            () => engine.execute(
              s,
              command(s, rank == 'Tú nữ' ? 'demote' : 'expel'),
            ),
            throwsA(isA<GameRuleException>()),
          );
          expect(s.toJson(), snapshot);
          s.points = 0;
          final empty = s.toJson();
          expect(
            () => engine.execute(
              s,
              command(s, rank == 'Tú nữ' ? 'expel' : 'demote'),
            ),
            throwsA(isA<GameRuleException>()),
          );
          expect(s.toJson(), empty);
        }
        final s = fresh(engine, 'Tú nữ');
        final official = s.court.firstWhere((c) => !c.isConsort);
        for (final option in ['expel', 'demote']) {
          expect(
            () => engine.execute(s, command(s, option, target: official.id)),
            throwsA(isA<GameRuleException>()),
          );
        }
      },
    );

    test(
      'discipline stats clamp at zero and one hundred seasonal=$seasonal',
      () {
        final s = fresh(engine, 'Hoàng hậu');
        lan(s).affection = 5;
        lan(s).discontent = 95;
        s.factions[lan(s).faction] = 1;
        final result = engine.execute(s, command(s, 'demote'));
        expect(lan(result).affection, 0);
        expect(lan(result).discontent, 100);
        expect(result.factions[lan(s).faction], 0);
      },
    );
  }

  test(
    'a demoted consort stops studying without a refund or experience reward',
    () {
      final engine = GameEngine();
      var s = fresh(engine, 'Phi tần');
      s.treasury = 100000;
      s = engine.execute(
        s,
        GameCommand(
          id: 'study',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'palace',
          target: 'consort_lan',
          option: 'study',
        ),
      );
      final ability = lan(s).ability;
      final experience = lan(s).palaceExperience;
      final treasury = s.treasury;
      s = engine.execute(s, command(s, 'demote'));
      expect(s.treasury, treasury);
      expect(s.palaceWorks, hasLength(1));
      s.petitions.clear();
      s = engine.execute(
        s,
        GameCommand(
          id: 'close',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'endWeek',
        ),
      );
      expect(s.palaceWorks, isEmpty);
      expect(lan(s).ability, ability);
      expect(lan(s).palaceExperience, experience);
      expect(
        s.outcomes.any(
          (o) => o.title.contains(lan(s).name) && o.status == 'interrupted',
        ),
        true,
      );
    },
  );
}
