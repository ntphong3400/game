import 'support/navigation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    for (final personId in ['chancellor', 'consort_lan']) {
      testWidgets(
        'summon $personId returns to the live assignee picker at $size',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final store = MemoryGameStore();
          final live = LocalGameGateway(store);
          await live.start(
            name: 'An',
            runId: 'petition-summon',
            seed: 42,
            previousRunId: null,
            previousRevision: null,
          );
          await store.update((archive) {
            final s = archive.active!;
            s.treasury = 1000;
            s.petitions = [
              Petition(
                id: 'summon',
                definitionId: 'community_03',
                openedWeek: 1,
                deadline: 2,
              ),
            ];
            for (final p in s.court) {
              p.specialty = 'Quân sự';
            }
            final person = s.court.firstWhere((p) => p.id == personId);
            person.specialty = 'Dân chính';
            person.inHarem = true;
            person.ability = 80;
            person.affection = person.baseAffection = 50;
            person.discontent = person.strain = 0;
            person.personalities
              ..clear()
              ..addAll([Personality.grateful, Personality.honest]);
            s.factions[person.faction] = 50;
          });
          final controller = GameController(live);
          addTearDown(controller.dispose);
          await controller.load();
          final before = jsonEncode(controller.state!.toJson());
          await tester.pumpWidget(
            GameApp(controller: controller, initialRoute: 'court'),
          );
          await tester.pumpAndSettle();
          Future<void> tap(Finder finder) async {
            await tester.ensureVisible(finder);
            await tester.tap(finder);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }

          await tap(find.byKey(const ValueKey('read-petition-summon')));
          await tap(find.byKey(const ValueKey('petition-choice-0')));
          await tap(find.byKey(const ValueKey('petition-assignee')));
          final summon = find.byKey(
            ValueKey('petition-person-summon-$personId'),
          );
          final button = tester.widget<OutlinedButton>(summon);
          expect((button.child as Text).data, 'Triệu kiến');
          expect(
            find.descendant(of: summon, matching: find.byType(Icon)),
            findsNothing,
          );
          final chanceKey = find.byKey(
            ValueKey('petition-person-chance-$personId'),
          );
          final previousChance = tester.widget<Text>(chanceKey).data;
          await tap(summon);
          expect(
            find.byKey(const ValueKey('character-meeting-page')),
            findsOneWidget,
          );
          expect(controller.state!.pending, isEmpty);
          expect(jsonEncode(controller.state!.toJson()), before);
          await tap(find.byKey(const ValueKey('meeting-back')));
          expect(summon, findsOneWidget);
          expect(jsonEncode(controller.state!.toJson()), before);
          await tap(summon);
          await tap(find.byKey(const ValueKey('meeting-action-audience')));
          await tap(find.byKey(const ValueKey('meeting-action-confirm')));
          expect(controller.state!.points, 11);
          expect(controller.state!.pending, isEmpty);
          await tap(find.byKey(const ValueKey('meeting-back')));
          final updatedChance = tester.widget<Text>(chanceKey).data;
          expect(updatedChance, isNot(previousChance));
          if (personId == 'consort_lan') {
            final affection =
                controller.state!.court
                    .firstWhere((p) => p.id == personId)
                    .affection;
            expect(
              tester
                  .widget<Text>(
                    find.byKey(ValueKey('petition-person-stats-$personId')),
                  )
                  .data,
              contains('Thiện cảm: $affection'),
            );
          }
          await tap(find.byKey(ValueKey('petition-person-$personId')));
          final preview =
              tester
                  .widget<Text>(
                    find.byKey(const ValueKey('petition-success-chance')),
                  )
                  .data!;
          expect(preview, contains(updatedChance!));
          await tap(find.byKey(const ValueKey('confirm-petition')));
          expect(
            controller.state!.pending.single.assignment!.assigneeId,
            personId,
          );
          expect(
            updatedChance,
            '${controller.state!.pending.single.assignment!.chance}%',
          );
          expect(controller.state!.points, 10);
        },
      );
    }
  }

  for (final hasSpecialist in [true, false]) {
    testWidgets('repair picker filters exact specialists: $hasSpecialist', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final live = LocalGameGateway(store);
      await live.start(
        name: 'An',
        runId: 'repair-specialty',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((archive) {
        final s = archive.active!;
        s.treasury = 1000;
        s.petitions = [
          Petition(
            id: 'repair',
            definitionId: 'levee_warning',
            openedWeek: 1,
            deadline: 2,
          ),
        ];
        for (final person in s.court) {
          person.specialty = 'Quân sự';
        }
        s.court.firstWhere((p) => p.id == 'treasurer').specialty = 'Kinh tế';
        if (hasSpecialist) {
          final person = s.court.firstWhere((p) => p.id == 'chancellor');
          person.specialty = 'Công trình';
          person.ability = 100;
          person.affection = 100;
          person.discontent = person.strain = 0;
          s.factions[person.faction] = 100;
        }
      });
      final controller = GameController(live);
      await controller.load();
      await tester.pumpWidget(
        GameApp(initialRoute: 'court', controller: controller),
      );
      await tester.pumpAndSettle();
      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tap(find.byKey(const ValueKey('read-petition-repair')));
      await tap(find.byKey(const ValueKey('petition-choice-0')));
      expect(find.text('Tỷ lệ thành công: 30%'), findsOneWidget);
      expect(
        find.text('Người xử lý · yêu cầu chuyên môn Công trình'),
        findsOneWidget,
      );
      await tap(find.byKey(const ValueKey('petition-assignee')));
      expect(
        find.byKey(const ValueKey('petition-person-treasurer')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('petition-person-general')),
        findsNothing,
      );
      final specialist = find.byKey(
        const ValueKey('petition-person-chancellor'),
      );
      if (hasSpecialist) {
        expect(specialist, findsOneWidget);
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey('petition-person-stats-chancellor')),
              )
              .data,
          'Công Trình · Năng lực: 100 · Mệt: 0 · Bất mãn: Chưa rõ',
        );
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey('petition-person-chance-chancellor')),
              )
              .data,
          '90%',
        );
        await tap(specialist);
        expect(find.text('Tỷ lệ thành công: 90%'), findsOneWidget);
      } else {
        expect(specialist, findsNothing);
        expect(
          find.text(
            'Chưa có người chuyên môn Công trình đủ điều kiện và đang rảnh.',
          ),
          findsOneWidget,
        );
        await tap(find.byKey(const ValueKey('petition-unassigned')));
      }
      await tap(find.byKey(const ValueKey('confirm-petition')));
      expect(
        controller.state!.pending.single.assignment!.assigneeId,
        hasSpecialist ? 'chancellor' : '',
      );
      expect(
        controller.state!.pending.single.assignment!.chance,
        hasSpecialist ? 90 : 30,
      );
    });
  }

  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    for (final reportedDiscontent in <int?>[null, 0, 23]) {
      testWidgets(
        'picker uses published investigation $reportedDiscontent at $size',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final store = MemoryGameStore();
          final live = LocalGameGateway(store);
          await live.start(
            name: 'An',
            runId: 'picker-intelligence',
            seed: 42,
            previousRunId: null,
            previousRevision: null,
          );
          await store.update((archive) {
            final s = archive.active!;
            s.petitions = [
              Petition(
                id: 'p',
                definitionId: 'levee_warning',
                openedWeek: 1,
                deadline: 2,
              ),
            ];
            s.treasury = 1000;
            for (final p in s.court) {
              p.specialty = 'Quân sự';
            }
            final p = s.court.firstWhere((p) => p.id == 'chancellor');
            p.specialty = 'Công trình';
            p.investigated = true;
            p.discontent = 79;
            p.lastInvestigation =
                reportedDiscontent == null
                    ? null
                    : CharacterInvestigation(
                      week: 1,
                      plot: 12,
                      discontent: reportedDiscontent,
                    );
            s.pending.add(
              Consequence(
                kind: 'investigate',
                target: p.id,
                dueWeek: 2,
                investigation: const CharacterInvestigation(
                  week: 1,
                  plot: 44,
                  discontent: 67,
                ),
              ),
            );
          });
          final controller = GameController(live);
          addTearDown(controller.dispose);
          await controller.load();
          final before = jsonEncode(controller.state!.toJson());
          await tester.pumpWidget(
            GameApp(initialRoute: 'court', controller: controller),
          );
          await tester.pumpAndSettle();
          Future<void> tap(Finder finder) async {
            await tester.ensureVisible(finder);
            await tester.tap(finder);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }

          await tap(find.byKey(const ValueKey('read-petition-p')));
          await tap(find.byKey(const ValueKey('petition-choice-0')));
          await tap(find.byKey(const ValueKey('petition-assignee')));
          final stats =
              tester
                  .widget<Text>(
                    find.byKey(
                      const ValueKey('petition-person-stats-chancellor'),
                    ),
                  )
                  .data!;
          final noteFinder = find.byKey(
            const ValueKey('petition-person-investigation-chancellor'),
          );
          expect(
            stats,
            contains(
              reportedDiscontent == null
                  ? 'Bất mãn: Chưa rõ'
                  : 'Bất mãn: $reportedDiscontent/100',
            ),
          );
          expect(stats, isNot(contains('Bất mãn: 79')));
          expect(stats, isNot(contains('Bất mãn: 67')));
          if (reportedDiscontent == null) {
            expect(noteFinder, findsNothing);
            expect(
              find.text('Chưa điều tra · Điều tra kín để biết bất mãn.'),
              findsNothing,
            );
          } else {
            final note = tester.widget<Text>(noteFinder).data!;
            expect(note, contains('Ghi nhận ${controller.state!.date(1)}'));
            expect(
              note,
              contains('Chỉ cập nhật khi điều tra tiếp theo hoàn tất.'),
            );
          }
          expect(jsonEncode(controller.state!.toJson()), before);
        },
      );
    }
  }

  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    for (final personId in ['', 'chancellor', 'consort_lan']) {
      testWidgets(
        'petition delegation previews and commits $personId at $size',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final store = MemoryGameStore();
          final live = LocalGameGateway(store);
          await live.start(
            name: 'An',
            runId: 'ui-assignment',
            seed: 42,
            previousRunId: null,
            previousRevision: null,
          );
          await store.update((a) {
            final s = a.active!;
            s.treasury = 1000;
            s.rng = 1;
            s.petitions = [
              Petition(
                id: 'p',
                definitionId: 'community_03',
                openedWeek: 1,
                deadline: 2,
              ),
            ];
            for (final c in s.court.where(
              (c) => ['chancellor', 'consort_lan'].contains(c.id),
            )) {
              c.ability = c.loyalty = c.integrity = 100;
              c.specialty = 'Dân chính';
              c.affection = 80;
              c.discontent = c.strain = 0;
            }
            s.court.firstWhere((c) => c.id == 'consort_lan').inHarem = true;
          });
          final controller = GameController(live);
          await controller.load();
          final before = jsonEncode(controller.state!.toJson());
          await tester.pumpWidget(
            GameApp(initialRoute: 'court', controller: controller),
          );
          await tester.pumpAndSettle();
          Future<void> tap(Finder finder) async {
            await tester.ensureVisible(finder);
            await tester.tap(finder);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }

          await tap(find.byKey(const ValueKey('read-petition-p')));
          await tap(find.byKey(const ValueKey('petition-choice-0')));
          expect(
            tester
                .widget<Text>(
                  find.byKey(const ValueKey('petition-success-chance')),
                )
                .data,
            contains('30%'),
          );
          if (personId.isNotEmpty) {
            await tap(find.byKey(const ValueKey('petition-assignee')));
            await tap(find.byKey(ValueKey('petition-person-$personId')));
            final text =
                tester
                    .widget<Text>(
                      find.byKey(const ValueKey('petition-success-chance')),
                    )
                    .data!;
            expect(text, isNot(contains('30%')));
          }
          expect(jsonEncode(controller.state!.toJson()), before);
          await tap(find.text('Đọc sau'));
          expect(jsonEncode(controller.state!.toJson()), before);
          await tap(find.byKey(const ValueKey('read-petition-p')));
          await tap(find.byKey(const ValueKey('petition-choice-0')));
          // A new dialog always starts explicitly unassigned.
          expect(find.text('Không giao ai xử lý (mặc định)'), findsOneWidget);
          if (personId.isNotEmpty) {
            await tap(find.byKey(const ValueKey('petition-assignee')));
            await tap(find.byKey(ValueKey('petition-person-$personId')));
          }
          final preview =
              tester
                  .widget<Text>(
                    find.byKey(const ValueKey('petition-success-chance')),
                  )
                  .data!;
          await tap(find.byKey(const ValueKey('confirm-petition')));
          final assigned = controller.state!.pending.single.assignment!;
          expect(assigned.assigneeId, personId);
          expect(preview, contains('${assigned.chance}%'));
          expect(controller.state!.points, 11);
          expect(
            (await live.load()).active!.pending.single.assignment!.toJson(),
            assigned.toJson(),
          );
          await openSection(tester, 'kingdom');
          await tap(find.byKey(const ValueKey('kingdom-open-1')));
          final pending = find.textContaining(
            '${assigned.personLabel} · ${assigned.chance}% thành công',
          );
          await tester.ensureVisible(pending);
          expect(pending, findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
