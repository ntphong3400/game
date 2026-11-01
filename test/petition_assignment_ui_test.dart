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
            contains('50%'),
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
            expect(text, isNot(contains('50%')));
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
          await tap(find.text('Quốc sự').first);
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
