import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_engine.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/logic/harem_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'support/harem_fixture.dart';

Courtier consort(
  String id, {
  String faction = 'Văn thần',
  Personality personality = Personality.decisive,
  int ability = 80,
  int affection = 71,
  bool queen = false,
}) => Courtier(
  id: id,
  name: id,
  role: 'Tiểu thư',
  faction: faction,
  trait: '',
  age: 25,
  ability: ability,
  affection: affection,
  baseAffection: affection,
  loyalty: 90,
  ambition: 10,
  integrity: 90,
  influence: 30,
  inHarem: true,
  queen: queen,
  personalities: [personality],
);

GameState fresh() {
  final s = GameEngine().start('harem', 'An', 42);
  s.court.removeWhere((c) => c.isConsort);
  s.petitions.clear();
  s.financialWeeks.clear();
  s.nextMajorWeek = s.nextChainWeek = 10000;
  s.treasury = 1000;
  s.people = s.authority = s.stability = 60;
  s.health = s.army = 90;
  s.affairsThisWeek = s.restThisWeek = s.workThisWeek = 1;
  s.factions.updateAll((k, v) => 60);
  for (final c in s.court) {
    c.loyalty = c.integrity = 90;
    c.affection = c.baseAffection = 50;
    c.ambition = 10;
    c.plot = 0;
  }
  return s;
}

GameState send(
  GameState s,
  String type, {
  String target = '',
  String option = '',
}) => GameEngine().execute(
  s,
  GameCommand(
    id: 'harem-${s.revision}',
    runId: s.runId,
    expectedRevision: s.revision,
    type: type,
    target: target,
    option: option,
  ),
);

void main() {
  test(
    'passives require completed stories and affection over 70; 96 doubles stats',
    () {
      for (final (completed, affection, value) in [
        (false, 96, 0),
        (true, 70, 0),
        (true, 71, 1),
        (true, 95, 1),
        (true, 96, 2),
      ]) {
        final s = fresh();
        final c = consort('a', affection: affection);
        s.court.add(c);
        if (completed) completeHaremStory(s, c);
        expect(HaremBenefits(s).total(HaremBenefit.authority), value);
      }
    },
  );

  test(
    'candidates, departed women and weekly games do not receive seasonal benefits',
    () {
      final s = fresh();
      final c = consort('a');
      s.court.add(c);
      c.inHarem = false;
      expect(HaremBenefits(s).contributions, isEmpty);
      c.inHarem = true;
      c.available = false;
      expect(HaremBenefits(s).contributions, isEmpty);
      c.available = true;
      s.seasonal = false;
      expect(HaremBenefits(s).contributions, isEmpty);
    },
  );

  test(
    'only some wealthy/royal women have income; affection never doubles the 10 coins',
    () {
      for (final faction in factionOpponents.keys) {
        final s =
            fresh()
              ..court.add(
                consort(
                  'family',
                  faction: faction,
                  personality: Personality.familyFirst,
                  affection: 96,
                ),
              );
        completeHaremStory(s, s.court.last);
        expect(
          HaremBenefits(s).total(HaremBenefit.treasury),
          ['Thế gia', 'Hoàng tộc'].contains(faction) ? 10 : 0,
        );
      }
      final s = fresh();
      s.court.add(
        consort(
          'consort_nguyet',
          faction: 'Hoàng tộc',
          personality: Personality.diplomatic,
        ),
      );
      expect(primaryHaremBenefit(s.court.last), HaremBenefit.stability);
      for (var i = 0; i < 6; i++) {
        s.court.add(
          consort(
            'rich-$i',
            faction: 'Thế gia',
            personality: Personality.familyFirst,
            affection: 96,
          ),
        );
      }
      for (final c in s.court.where((c) => c.isConsort)) {
        completeHaremStory(s, c);
      }
      final income = HaremBenefits(s);
      expect(income.total(HaremBenefit.treasury), 50);
      expect(
        income.contributions
            .where((c) => c.passive.benefit == HaremBenefit.treasury)
            .map((c) => c.amount),
        [10, 10, 10, 10, 10, 0],
      );
      expect(
        budgetIncome(s).where((i) => i.title.startsWith('Gia sản hậu cung:')),
        hasLength(5),
      );
    },
  );

  test(
    'each stat caps at five and queen requires a separate story and 85 affection',
    () {
      final s = fresh();
      for (var i = 0; i < 3; i++) {
        final c = consort('stat-$i', affection: 96);
        s.court.add(c);
        completeHaremStory(s, c);
      }
      expect(HaremBenefits(s).total(HaremBenefit.authority), 5);
      s.court.removeWhere((c) => c.isConsort);
      final queen = consort('queen', queen: true, affection: 85);
      s.court.add(queen);
      completeHaremStory(s, queen);
      expect(HaremBenefits(s).total(HaremBenefit.stability), 0);
      completeHaremStory(s, queen, queen: true);
      expect(HaremBenefits(s).total(HaremBenefit.stability), 1);
      queen.affection = 84;
      expect(HaremBenefits(s).total(HaremBenefit.stability), 0);
      queen.affection = 96;
      expect(HaremBenefits(s).total(HaremBenefit.stability), 2);
      queen.queen = false;
      expect(HaremBenefits(s).total(HaremBenefit.stability), 0);
    },
  );

  test(
    'conversation lowers all opposing women, including candidates and consorts, once',
    () {
      final s = fresh();
      final target = consort('meet', faction: 'Văn thần');
      final candidate = consort('candidate', faction: 'Võ tướng')
        ..inHarem = false;
      final rival = consort('rival', faction: 'Võ tướng');
      final absent = consort('absent', faction: 'Võ tướng')..available = false;
      final neutral = consort('neutral', faction: 'Thế gia');
      s.court.addAll([target, candidate, rival, absent, neutral]);
      final result = send(s, 'courtier', target: target.id, option: 'audience');
      Courtier person(String id) => result.court.firstWhere((c) => c.id == id);
      expect(person('candidate').affection, 69);
      expect(person('rival').affection, 69);
      expect(person('absent').affection, 71);
      expect(person('neutral').affection, 71);
      expect(result.factions['Võ tướng'], 57);
      expect(result.points, 11);
      expect(
        HaremBenefits(result).contributions.any((c) => c.person.id == 'rival'),
        false,
      );
    },
  );

  test(
    'season closes pay stats exactly once and match the cash forecast and ledger',
    () async {
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store);
      final s = fresh();
      s.court.addAll([
        consort('queen', queen: true, ability: 91, affection: 96),
        consort(
          'rich',
          faction: 'Thế gia',
          personality: Personality.familyFirst,
        ),
        consort('people', personality: Personality.compassionate),
      ]);
      for (final c in s.court.where((c) => c.isConsort)) {
        completeHaremStory(s, c);
        if (c.queen) completeHaremStory(s, c, queen: true);
      }
      final control = s.copy();
      for (final q in control.haremQuests) {
        q.stage = 0;
      }
      final baseline = send(control, 'endWeek');
      final forecast = BudgetProjection(s);
      await store.update((a) => a.active = s);
      final command = GameCommand(
        id: 'close-harem',
        runId: s.runId,
        expectedRevision: s.revision,
        type: 'endWeek',
      );
      final a = await gateway.dispatch(command);
      final result = a.active!;
      expect(result.treasury, forecast.closingBalance);
      expect(result.treasury, baseline.treasury + 10);
      expect(result.authority, baseline.authority + 2);
      expect(result.stability, baseline.stability + 2);
      expect(result.people, baseline.people + 1);
      final report = result.financialWeeks.first;
      expect(
        report.closingBalance,
        report.openingBalance + report.income - report.expense,
      );
      expect(
        report.entries
            .where((e) => e.title == 'Gia sản hậu cung: rich')
            .single
            .amount,
        10,
      );
      expect(
        result.journal.where((n) => n.title == 'Đóng góp hậu cung'),
        hasLength(1),
      );
      expect((await gateway.dispatch(command)).toJson(), a.toJson());
      expect((await gateway.load()).toJson(), a.toJson());
      expect(result.copy().toJson(), result.toJson());
    },
  );

  test(
    'passive identity survives old saves and ignores hidden traits without consuming RNG',
    () {
      final s = fresh()..court.add(consort('a', ability: 91, queen: true));
      final before = jsonEncode(s.toJson());
      haremPassivePreview(s.court.last);
      HaremBenefits(s);
      expect(jsonEncode(s.toJson()), before);
      final raw =
          s.toJson()
            ..['rulesVersion'] = 'mvp-0.12.1'
            ..['contentVersion'] = 13;
      final restored = GameState.fromJson(raw);
      expect(restored.points, s.points);
      expect(restored.rng, s.rng);
      expect(HaremBenefits(restored).summary, HaremBenefits(s).summary);
      final c = restored.court.last;
      final primary = primaryHaremBenefit(c);
      c.personalities[1] = Personality.greedy;
      expect(primaryHaremBenefit(c), primary);
      expect(haremPassivePreview(c), isNot(contains('Tham lợi')));
    },
  );
}
