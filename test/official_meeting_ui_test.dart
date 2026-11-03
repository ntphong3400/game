import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/meeting_scenes.dart';

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    for (final target in ['general', 'doctor', 'replacement']) {
      testWidgets(
        'official $target has full-body details, confirmed actions and return at $size',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final store = MemoryGameStore();
          final gateway = LocalGameGateway(store);
          await gateway.start(
            name: 'An',
            runId: 'official-meeting',
            seed: 42,
            previousRunId: null,
            previousRevision: null,
          );
          await store.update((archive) {
            final state = archive.active!;
            final person =
                target == 'replacement'
                    ? state.officialsPool.first
                    : state.court.firstWhere((c) => c.id == target);
            if (target == 'replacement') {
              state.officialsPool.remove(person);
              person.role = 'Hộ bộ';
              final office = state.courtOffices.firstWhere(
                (o) => o.role == 'Hộ bộ',
              );
              office.holderId = person.id;
            }
            state.court
              ..clear()
              ..add(person);
            person.plot = 73;
            person.lastInvestigation = null;
          });
          final controller = GameController(gateway);
          await controller.load();
          addTearDown(controller.dispose);
          final person = controller.state!.court.single;
          final before = controller.state!.toJson();
          await tester.pumpWidget(
            GameApp(controller: controller, initialRoute: 'people'),
          );
          await tester.pumpAndSettle();
          final summon = find.byKey(ValueKey('meet-person-${person.id}'));
          await tester.ensureVisible(summon);
          await tester.tap(summon);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('character-meeting-page')),
            findsOneWidget,
          );
          expect(find.text(person.name), findsOneWidget);
          final sprite = tester.widget<Image>(
            find.byKey(const ValueKey('meeting-fullbody')),
          );
          expect(
            (sprite.image as AssetImage).assetName,
            meetingCharacterAsset(person),
          );
          expect(
            sprite.fit,
            size.height > size.width ? BoxFit.fitHeight : BoxFit.contain,
          );
          expect(
            find.byKey(const ValueKey('meeting-action-invite')),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('meeting-contributions')),
            meetingSceneFor(
                  person,
                  state: controller.state!,
                ).contributions.isEmpty
                ? findsNothing
                : findsOneWidget,
          );
          expect(
            tester
                .widget<Text>(find.byKey(const ValueKey('meeting-plot')))
                .data,
            'Chưa rõ',
          );
          expect(controller.state!.toJson(), before);
          final reward = find.byKey(const ValueKey('meeting-action-reward'));
          await tester.ensureVisible(reward);
          await tester.tap(reward);
          await tester.pumpAndSettle();
          expect(controller.state!.toJson(), before);
          await tester.tap(find.byKey(const ValueKey('meeting-action-cancel')));
          await tester.pumpAndSettle();
          expect(controller.state!.toJson(), before);
          await tester.tap(reward);
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('meeting-action-confirm')),
          );
          await tester.pumpAndSettle();
          expect(controller.state!.points, (before['points'] as int) - 1);
          expect(
            controller.state!.treasury,
            (before['treasury'] as int) - 2000,
          );
          final after = controller.state!.toJson();
          await controller.load();
          await tester.pumpAndSettle();
          expect(controller.state!.toJson(), after);
          final profile = find.byKey(const ValueKey('meeting-promotion'));
          await tester.ensureVisible(profile);
          await tester.tap(profile);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('court-promotion-dialog')),
            findsOneWidget,
          );
          expect(find.text('Hồ sơ & chức vụ'), findsNothing);
          if (person.grade == 1) {
            expect(
              find.byKey(const ValueKey('promotion-highest')),
              findsOneWidget,
            );
          } else {
            expect(
              tester
                  .widget<FilledButton>(
                    find.byKey(const ValueKey('confirm-promotion')),
                  )
                  .onPressed,
              isNull,
            );
          }
          await tester.tap(find.byKey(const ValueKey('close-imperial-dialog')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('meeting-back')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('character-meeting-page')),
            findsNothing,
          );
          expect(
            find.byKey(ValueKey('meet-person-${person.id}')),
            findsOneWidget,
          );
          expect(controller.state!.toJson(), after);
          expect((await gateway.load()).active!.toJson(), after);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
