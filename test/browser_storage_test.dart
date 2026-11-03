@TestOn('browser')
library;

import 'dart:convert';
import 'palace_test.dart' show freshPalace, palaceCommand;
import 'package:van_tue/game/logic/harem_rules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'story_petition_test.dart' show storyState, storyMajor, storyCommand;

void main() {
  test(
    'story petitions survive real IndexedDB reopen, duplicate delivery and competing choices',
    () async {
      final factory = getIdbFactory()!;
      final name = 'van-tue-stories-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      final secondStore = await IndexedGameStore.open(factory, name: name);
      try {
        final s =
            storyState()
              ..major = storyMajor('flood')
              ..chains = [
                StoryArc(
                  settlementVersion: 0,
                  id: 'arc',
                  kind: 'border',
                  dueWeek: 1,
                ),
              ];
        await store.update((a) => a.active = s);
        final first = LocalGameGateway(store),
            second = LocalGameGateway(secondStore);
        final loads = await Future.wait([first.load(), second.load()]);
        expect(loads[0].toJson(), loads[1].toJson());
        final initial = loads.first.active!;
        expect(initial.petitions.where((p) => p.isStory), hasLength(2));
        final p = initial.petitions.singleWhere((p) => p.storyKind == 'major');
        final command = storyCommand(
          initial,
          'petition',
          target: p.id,
          option: '0',
        );
        final committed = await Future.wait([
          first.dispatch(command),
          second.dispatch(command),
        ]);
        expect(committed[0].toJson(), committed[1].toJson());
        expect(committed.first.active!.major!.decisions, [0]);
        expect(committed.first.active!.treasury, initial.treasury - 55);
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final reopened = LocalGameGateway(store);
        expect((await reopened.load()).toJson(), committed.first.toJson());
        expect(
          (await reopened.dispatch(command)).toJson(),
          committed.first.toJson(),
        );
        final next = committed.first.active!;
        final chain = next.petitions.singleWhere((p) => p.storyKind == 'chain');
        final a = storyCommand(next, 'petition', target: chain.id, option: '0');
        final b = GameCommand(
          id: 'competing-choice',
          runId: next.runId,
          expectedRevision: next.revision,
          type: 'petition',
          target: chain.id,
          option: '1',
        );
        final results = await Future.wait<Object>([
          reopened.dispatch(a).then<Object>((v) => v, onError: (Object e) => e),
          second.dispatch(b).then<Object>((v) => v, onError: (Object e) => e),
        ]);
        expect(results.whereType<GameArchive>(), hasLength(1));
        expect(results.whereType<GameRuleException>(), hasLength(1));
        final finalState = (await reopened.load()).active!;
        expect(finalState.chains.single.decisions, hasLength(1));
        final turn = await reopened.dispatch(
          storyCommand(finalState, 'endWeek'),
        );
        expect(
          turn.active!.petitions.where((p) => p.storyKind == 'major'),
          hasLength(1),
        );
        expect(
          turn.active!.petitions.where((p) => p.storyKind == 'chain'),
          hasLength(1),
        );
        expect((await reopened.load()).toJson(), turn.toJson());
      } finally {
        store.close();
        secondStore.close();
        await factory.deleteDatabase(name);
      }
    },
  );
  test(
    'relationship allocation and chapter payments survive real IndexedDB reopen and competing tabs',
    () async {
      final factory = getIdbFactory()!;
      final name =
          'van-tue-harem-quests-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      final secondStore = await IndexedGameStore.open(factory, name: name);
      try {
        await store.update((a) => a.active = freshPalace());
        final gateway = LocalGameGateway(store),
            second = LocalGameGateway(secondStore);
        final loaded = await Future.wait([gateway.load(), second.load()]);
        expect(loaded[0].toJson(), loaded[1].toJson());
        final initial = loaded.first.active!;
        final route = haremQuestFor(initial, 'wife-0')!.definitionId;
        final cost = haremChapterCost(
          initial,
          haremQuestFor(initial, 'wife-0')!,
          'A',
        );
        final command = palaceCommand(
          initial,
          'harem-quest',
          target: 'wife-0',
          option: 'personal:A',
        );
        final paid = await Future.wait([
          gateway.dispatch(command),
          second.dispatch(command),
        ]);
        expect(paid[0].toJson(), paid[1].toJson());
        expect(paid.first.active!.treasury, initial.treasury - cost);
        expect(paid.first.active!.points, initial.points - 1);
        expect(haremQuestFor(paid.first.active!, 'wife-0')!.choices, ['A']);
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final reopened = LocalGameGateway(store);
        expect((await reopened.load()).toJson(), paid.first.toJson());
        expect(
          (await reopened.dispatch(command)).toJson(),
          paid.first.toJson(),
        );
        var latest = paid.first.active!;
        for (var chapter = 1; chapter < 3; chapter++) {
          await store.update((a) {
            a.active!.petitions.clear();
            a.active!.affairsThisWeek = 1;
          });
          latest = (await reopened.load()).active!;
          latest =
              (await reopened.dispatch(
                palaceCommand(latest, 'endWeek'),
              )).active!;
          final next = palaceCommand(
            latest,
            'harem-quest',
            target: 'wife-0',
            option: 'personal:A',
          );
          final result = await Future.wait([
            reopened.dispatch(next),
            second.dispatch(next),
          ]);
          expect(result[0].toJson(), result[1].toJson());
          latest = result.first.active!;
        }
        expect(haremQuestFor(latest, 'wife-0')!.completed, isTrue);
        expect(haremQuestFor(latest, 'wife-0')!.definitionId, route);
        expect(latest.court.first.toJson().containsKey('ability'), isFalse);
        final finalSnapshot = latest.toJson();
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        expect(
          (await LocalGameGateway(store).load()).active!.toJson(),
          finalSnapshot,
        );
      } finally {
        store.close();
        secondStore.close();
        await factory.deleteDatabase(name);
      }
    },
  );
  test(
    'two tabs reveal a legacy partial season only once and retain it on reopen',
    () async {
      final factory = getIdbFactory()!;
      final name = 'van-tue-partial-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      final secondStore = await IndexedGameStore.open(factory, name: name);
      try {
        final gateway = LocalGameGateway(store);
        final archive = await gateway.start(
          name: 'An',
          runId: 'partial',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        final target = archive.active!.seasonPetitionTarget;
        final resolvedId = archive.active!.petitions.first.id;
        await store.update((a) {
          final s = a.active!;
          s.petitions =
              s.petitions.skip(1).take((target + 1) ~/ 2 - 1).toList();
          s.midSeasonDelivered = false;
          s.points = 11;
          s.seasonActionsSpent = 1;
        });
        final snapshots = await Future.wait([
          gateway.load(),
          LocalGameGateway(secondStore).load(),
        ]);
        expect(snapshots[0].toJson(), snapshots[1].toJson());
        final s = snapshots.first.active!;
        expect(s.petitions, hasLength(target - 1));
        expect(s.petitions.map((p) => p.id).toSet(), hasLength(target - 1));
        expect(s.petitions.any((p) => p.id == resolvedId), false);
        expect(s.points, 11);
        expect(s.revision, 1);
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        expect(
          (await LocalGameGateway(store).load()).toJson(),
          snapshots.first.toJson(),
        );
      } finally {
        store.close();
        secondStore.close();
        await factory.deleteDatabase(name);
      }
    },
  );

  test(
    'native annual tax settlement and pending winter policy survive reopen and retry',
    () async {
      final factory = getIdbFactory()!;
      final name =
          'van-tue-annual-tax-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      try {
        final gateway = LocalGameGateway(store);
        await gateway.start(
          name: 'An',
          runId: 'annual',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((a) {
          final s = a.active!;
          s.completedWeeks = 2;
          s.tax = 2;
          s.people = 60;
          s.petitions.clear();
          s.nextMajorWeek = s.nextChainWeek = 10000;
          s.affairsThisWeek = 1;
        });
        const command = GameCommand(
          id: 'autumn',
          runId: 'annual',
          expectedRevision: 0,
          type: 'endWeek',
        );
        final paid = await gateway.dispatch(command);
        expect(paid.active!.lastTaxRevenue, 440);
        final pending = await gateway.dispatch(
          GameCommand(
            id: 'winter',
            runId: 'annual',
            expectedRevision: paid.active!.revision,
            type: 'tax',
            option: '0',
          ),
        );
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final reopened = LocalGameGateway(store);
        expect((await reopened.load()).toJson(), pending.toJson());
        final retried = await reopened.dispatch(command);
        expect(retried.toJson(), pending.toJson());
        expect(retried.active!.tax, 0);
        expect(retried.active!.effectiveTax, 2);
        expect(retried.active!.lastTaxYear, 1);
        expect(retried.active!.lastTaxRevenue, 440);
      } finally {
        store.close();
        await factory.deleteDatabase(name);
      }
    },
  );
  test(
    'native seasonal save preserves all opening petitions, cadence, random and major calendar on reopen/retry',
    () async {
      final factory = getIdbFactory()!;
      final name = 'van-tue-seasonal-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      try {
        final g = LocalGameGateway(store);
        var archive = await g.start(
          name: 'An',
          runId: 'seasons',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        late GameCommand last;
        for (var i = 0; i < 7; i++) {
          last = GameCommand(
            id: 'season-$i',
            runId: 'seasons',
            expectedRevision: archive.active!.revision,
            type: 'action',
            target: 'rest',
          );
          archive = await g.dispatch(last);
        }
        expect(archive.active!.seasonal, true);
        expect(archive.active!.midSeasonDelivered, true);
        expect(archive.active!.points, 5);
        final before = jsonEncode(archive.toJson());
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final reopened = LocalGameGateway(store);
        expect(jsonEncode((await reopened.load()).toJson()), before);
        expect(jsonEncode((await reopened.dispatch(last)).toJson()), before);
        final next = await reopened.dispatch(
          GameCommand(
            id: 'close-season',
            runId: 'seasons',
            expectedRevision: archive.active!.revision,
            type: 'endWeek',
          ),
        );
        expect(next.active!.season, 'Hạ');
        expect(next.active!.age, 18);
        expect(next.active!.points, 12);
        expect(next.active!.midSeasonDelivered, true);
        final reloaded = await reopened.load();
        expect(reloaded.toJson(), next.toJson());
      } finally {
        store.close();
        await factory.deleteDatabase(name);
      }
    },
  );
  test(
    'current save missing optional ledger starts a partial ledger and retries once',
    () async {
      final factory = getIdbFactory()!;
      final name = 'van-tue-finance-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      try {
        final gateway = LocalGameGateway(store, seasonal: false);
        final current = await gateway.start(
          name: 'An',
          runId: 'finance-upgrade',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        final legacy = current.toJson();
        final old =
            object(legacy['active'])
              ..remove('financialWeeks')
              ..['rulesVersion'] = rulesVersion
              ..['completedWeeks'] = 10
              ..['revision'] = 7;
        legacy['active'] = old;
        final tx = store.database.transaction('archive', idbModeReadWrite);
        await tx.objectStore('archive').put(jsonEncode(legacy), 'current');
        await tx.completed;
        final loaded = await gateway.load();
        expect(loaded.active!.financialWeeks, isEmpty);
        expect(loaded.active!.rng, old['rng']);
        expect(loaded.active!.treasury, old['treasury']);
        final command = GameCommand(
          id: 'first-finance',
          runId: 'finance-upgrade',
          expectedRevision: 7,
          type: 'action',
          target: 'revel',
        );
        final first = await gateway.dispatch(command);
        final report = first.active!.financialWeeks.single;
        expect(report.week, 11);
        expect(report.partial, true);
        expect(report.entries.single.amount, -18);
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final reloaded = await LocalGameGateway(store, seasonal: false).load();
        expect(reloaded.toJson(), first.toJson());
        final retry = await LocalGameGateway(
          store,
          seasonal: false,
        ).dispatch(command);
        expect(retry.toJson(), first.toJson());
      } finally {
        store.close();
        await factory.deleteDatabase(name);
      }
    },
  );

  for (final (oldRules, oldContent) in [
    ('mvp-0.2.0', 1),
    ('mvp-0.3.0', 2),
    ('mvp-0.4.0', 3),
    ('mvp-0.5.0', 4),
    ('mvp-0.6.0', 5),
    ('mvp-0.7.0', 6),
    ('mvp-0.7.1', 6),
    ('mvp-0.7.2', 6),
    ('mvp-0.7.3', 6),
    ('mvp-0.7.4', 6),
  ]) {
    test(
      '$oldRules IndexedDB data survives an explicit new-rules start and reopen',
      () async {
        final factory = getIdbFactory()!;
        final name =
            'van-tue-migration-test-${DateTime.now().microsecondsSinceEpoch}';
        var store = await IndexedGameStore.open(factory, name: name);
        try {
          final gateway = LocalGameGateway(store, seasonal: false);
          final current = await gateway.start(
            name: 'Cũ',
            runId: 'legacy',
            seed: 42,
            previousRunId: null,
            previousRevision: null,
          );
          final legacy =
              current.toJson()
                ..['schemaVersion'] = oldRules == 'mvp-0.2.0' ? 1 : 2;
          final oldRun =
              object(legacy['active'])
                ..['rulesVersion'] = oldRules
                ..['contentVersion'] = oldContent;
          legacy['active'] = oldRun;
          legacy['scores'] = [
            ScoreEntry('finished-old', 'Cũ', 52, rules: oldRules).toJson(),
          ];
          final tx = store.database.transaction('archive', idbModeReadWrite);
          await tx.objectStore('archive').put(jsonEncode(legacy), 'current');
          await tx.completed;
          final loaded = await gateway.load();
          expect(loaded.active, isNull);
          expect(loaded.archivedRuns.single, oldRun);
          expect(loaded.scores.single.rules, oldRules);
          expect(rankedScores(loaded.scores), isEmpty);
          final updated = await gateway.start(
            name: 'Mới',
            runId: 'new',
            seed: 73,
            previousRunId: null,
            previousRevision: null,
          );
          expect(updated.active!.runId, 'new');
          expect(updated.archivedRuns.single, oldRun);
          store.close();
          store = await IndexedGameStore.open(factory, name: name);
          final reopened = await store.read();
          expect(reopened.archivedRuns.single, oldRun);
          expect(reopened.scores.single.weeks, 52);
          expect(reopened.active!.runId, 'new');
        } finally {
          store.close();
          await factory.deleteDatabase(name);
        }
      },
    );
  }

  test(
    'IndexedDB reopens major objectives, story decisions and obligations without duplicate charges',
    () async {
      final factory = getIdbFactory()!;
      final name = 'van-tue-major-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      try {
        final gateway = LocalGameGateway(store, seasonal: false);
        await gateway.start(
          name: 'An',
          runId: 'major-native',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((a) {
          final s = a.active!;
          s.major = MajorMission(
            id: 'm',
            kind: 'flood',
            openedWeek: 1,
            deadline: 6,
            severity: 1,
            preparedness: 1,
            objectives:
                majorDefinition(
                  'flood',
                ).objectives.map((o) => MissionObjective(key: o.key)).toList(),
          );
          s.chains = [
            StoryArc(
              settlementVersion: 0,
              id: 'arc',
              kind: 'border',
              dueWeek: 3,
              stage: 1,
              decisions: [0],
            ),
          ];
          s.obligations = [
            Obligation(
              id: 'loan',
              kind: 'borrow',
              title: 'Vay thế gia',
              remaining: 10,
              nextWeek: 2,
              amount: 15,
            ),
          ];
        });
        const command = GameCommand(
          id: 'major-order',
          runId: 'major-native',
          expectedRevision: 0,
          type: 'mission',
          target: 'levee',
          option: 'works',
        );
        final once = await gateway.dispatch(command);
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final reopened = await LocalGameGateway(store, seasonal: false).load();
        expect(reopened.toJson(), once.toJson());
        expect(reopened.active!.major!.objectives.first.working, true);
        expect(reopened.active!.chains.single.decisions, [0]);
        expect(reopened.active!.obligations.single.remaining, 10);
        final retry = await LocalGameGateway(
          store,
          seasonal: false,
        ).dispatch(command);
        expect(retry.toJson(), once.toJson());
      } finally {
        store.close();
        await factory.deleteDatabase(name);
      }
    },
  );

  test(
    'native IndexedDB preserves new recurring income, milestones and successor state across reopen and retry',
    () async {
      final factory = getIdbFactory()!;
      final name = 'van-tue-catalog66-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      try {
        final g = LocalGameGateway(store, seasonal: false);
        await g.start(
          name: 'An',
          runId: 'catalog66',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((a) {
          final s = a.active!;
          s.heirId = 'prince';
          s.heirCondition = 'care';
          s.successionCertified = true;
          s.major = MajorMission(
            id: 'port',
            kind: 'db-12',
            openedWeek: 1,
            deadline: 6,
            severity: 1,
            preparedness: 0,
            objectives:
                majorDefinition('db-12').objectives
                    .map((o) => MissionObjective(key: o.key, done: true))
                    .toList(),
          );
        });
        const settlement = GameCommand(
          id: 'settle-port',
          runId: 'catalog66',
          expectedRevision: 0,
          type: 'endWeek',
        );
        final once = await g.dispatch(settlement);
        expect(once.active!.obligations.single.income, 5);
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final reopened = await LocalGameGateway(store, seasonal: false).load();
        expect(reopened.toJson(), once.toJson());
        expect(reopened.active!.realmMilestones['db-12'], 1);
        expect(reopened.active!.heirId, 'prince');
        expect(reopened.active!.heirCondition, 'care');
        expect(reopened.active!.successionCertified, true);
        final retry = await LocalGameGateway(
          store,
          seasonal: false,
        ).dispatch(settlement);
        expect(retry.toJson(), once.toJson());
        final s = retry.active!;
        final next = await LocalGameGateway(store, seasonal: false).dispatch(
          GameCommand(
            id: 'income',
            runId: s.runId,
            expectedRevision: s.revision,
            type: 'endWeek',
          ),
        );
        final entries = next.active!.financialWeeks.last.entries.where(
          (e) => e.title == 'Nguồn thu cảng quốc tế',
        );
        expect(entries, hasLength(1));
        expect(entries.single.amount, 5);
        expect(next.active!.obligations.single.remaining, 7);
      } finally {
        store.close();
        await factory.deleteDatabase(name);
      }
    },
  );

  test(
    'native content-7 save continues with its active objective when the 66-event catalog loads',
    () async {
      final factory = getIdbFactory()!;
      final name = 'van-tue-content7-${DateTime.now().microsecondsSinceEpoch}';
      var store = await IndexedGameStore.open(factory, name: name);
      try {
        final g = LocalGameGateway(store, seasonal: false);
        final a = await g.start(
          name: 'An',
          runId: 'content7',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        final raw = a.toJson();
        final old =
            object(raw['active'])
              ..['contentVersion'] = 7
              ..['rulesVersion'] = 'mvp-0.8.0';
        for (final person in [
          ...old['court'] as List,
          ...old['officialsPool'] as List,
        ]) {
          (person as Map).remove('personalities');
          person.remove('personalityContacts');
        }
        old['major'] =
            MajorMission(
              id: 'old-flood',
              kind: 'flood',
              openedWeek: 1,
              deadline: 6,
              severity: 1,
              preparedness: 0,
              objectives:
                  majorDefinition('flood').objectives
                      .map((o) => MissionObjective(key: o.key))
                      .toList(),
            ).toJson();
        final goals = object(old['major'])['objectives'] as List;
        goals.first['officerId'] = 'works';
        goals.first['finishWeek'] = 3;
        raw['active'] = old;
        final tx = store.database.transaction('archive', idbModeReadWrite);
        await tx.objectStore('archive').put(jsonEncode(raw), 'current');
        await tx.completed;
        final loaded = await g.load();
        expect(loaded.active!.rng, old['rng']);
        expect(
          loaded.active!.court.every(
            (c) => c.personalities.length >= 2 && c.knownPersonalityCount == 1,
          ),
          true,
        );
        expect(loaded.active!.major!.objectives.first.finishWeek, 3);
        expect(loaded.archivedRuns, isEmpty);
        final saved = await g.dispatch(
          const GameCommand(
            id: 'continue',
            runId: 'content7',
            expectedRevision: 0,
            type: 'action',
            target: 'rest',
          ),
        );
        store.close();
        store = await IndexedGameStore.open(factory, name: name);
        final restored = await LocalGameGateway(store, seasonal: false).load();
        expect(restored.toJson(), saved.toJson());
        expect(restored.active!.toJson()['contentVersion'], contentVersion);
        expect(restored.active!.major!.id, 'old-flood');
        expect(restored.active!.major!.objectives.first.officerId, 'works');
      } finally {
        store.close();
        await factory.deleteDatabase(name);
      }
    },
  );

  test(
    'native IndexedDB persists, serializes connections and rolls back invalid writes',
    () async {
      final factory = getIdbFactory()!;
      final name =
          'van-tue-browser-test-${DateTime.now().microsecondsSinceEpoch}';
      var first = await IndexedGameStore.open(factory, name: name);
      final second = await IndexedGameStore.open(factory, name: name);
      try {
        final a = LocalGameGateway(first, seasonal: false),
            b = LocalGameGateway(second, seasonal: false);
        final initial = await a.start(
          name: 'An',
          runId: 'run',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        final s = initial.active!;
        GameCommand command(String id) => GameCommand(
          id: id,
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'endWeek',
        );
        var success = 0, conflict = 0;
        await Future.wait(
          [a.dispatch(command('a')), b.dispatch(command('b'))].map((f) async {
            try {
              await f;
              success++;
            } on GameRuleException {
              conflict++;
            }
          }),
        );
        expect(success, 1);
        expect(conflict, 1);
        expect((await b.load()).active!.completedWeeks, 1);
        final before = (await b.load()).toJson();
        await expectLater(
          first.update((archive) {
            archive.active!.treasury = 999999;
            throw const GameRuleException('rollback');
          }),
          throwsA(isA<GameRuleException>()),
        );
        expect((await b.load()).toJson(), before);
        first.close();
        first = await IndexedGameStore.open(factory, name: name);
        expect((await first.read()).toJson(), before);
      } finally {
        first.close();
        second.close();
        await factory.deleteDatabase(name);
      }
    },
  );
}
