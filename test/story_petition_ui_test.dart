import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/reign_panel.dart';
import 'story_petition_test.dart' show storyState, storyMajor;

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    for (final kind in ['chain', 'major']) {
      testWidgets(
        '$kind is read, cancelled and confirmed through ordinary petitions at $size',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final store = MemoryGameStore();
          final s = storyState();
          if (kind == 'chain') {
            s.chains = [
              StoryArc(
                settlementVersion: 0,
                id: 'arc',
                kind: 'border',
                dueWeek: 1,
              ),
            ];
          } else {
            s.major = storyMajor('flood');
          }
          await store.update((a) => a.active = s);
          final gateway = LocalGameGateway(store);
          final controller = GameController(gateway);
          await controller.load();
          final before = controller.state!.copy();
          final p = before.petitions.single;
          final choice = eventForState(before, p.definitionId).choices.first;
          await tester.pumpWidget(
            GameApp(initialRoute: 'court', controller: controller),
          );
          await tester.pumpAndSettle();
          final card = find.byKey(ValueKey('petition-card-${p.id}'));
          expect(card, findsOneWidget);
          final open = find.byKey(ValueKey('read-petition-${p.id}'));
          await tester.ensureVisible(open);
          await tester.tap(open);
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('petition-assignee')), findsNothing);
          await tester.ensureVisible(find.text('Đọc sau'));
          await tester.tap(find.text('Đọc sau'));
          await tester.pumpAndSettle();
          expect(controller.state!.toJson(), before.toJson());
          await tester.tap(open);
          await tester.pumpAndSettle();
          final option = find.byKey(const ValueKey('petition-choice-0'));
          await tester.ensureVisible(option);
          await tester.tap(option);
          await tester.pumpAndSettle();
          expect(controller.state!.toJson(), before.toJson());
          await tester.ensureVisible(
            find.byKey(const ValueKey('confirm-petition')),
          );
          await tester.tap(find.byKey(const ValueKey('confirm-petition')));
          await tester.pumpAndSettle();
          expect(controller.state!.treasury, before.treasury - choice.cost);
          expect(controller.state!.points, before.points - choice.points);
          expect(controller.state!.petitions, isEmpty);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          controller.dispose();
        },
      );
    }
    testWidgets(
      'national affairs hides story summaries and quest controls at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
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
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ReignPanel(
                  state: s,
                  busy: false,
                  send: (_, _, _) async {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('major-petition-summary')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('chain-petition-summary')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('mission-levee')), findsNothing);
        expect(find.byKey(const ValueKey('chain-arc-0')), findsNothing);
        expect(find.text('Đến tấu chương →'), findsNothing);
        expect(find.text('Đối sách khẩn cấp'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
