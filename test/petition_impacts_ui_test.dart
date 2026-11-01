import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets(
      'illustrated impacts match the committed agricultural decision at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store);
        await gateway.start(
          name: 'An',
          runId: 'real-impacts',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        final event = events.firstWhere(
          (e) => e.title == 'Ruộng trũng nuôi cá',
        );
        await store.update((a) {
          a.active!.petitions = [
            Petition(
              id: 'agriculture',
              definitionId: event.id,
              openedWeek: 1,
              deadline: 2,
            ),
          ];
        });
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.copy();
        await tester.pumpWidget(
          GameApp(controller: controller, initialRoute: 'court'),
        );
        await tester.pumpAndSettle();
        Future<void> tap(Finder f) async {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        await tap(find.byKey(const ValueKey('read-petition-agriculture')));
        expect(
          find.byKey(const ValueKey('petition-impact-people')),
          findsNothing,
        );
        await tap(find.byKey(const ValueKey('petition-choice-1')));
        expect(
          find.byKey(const ValueKey('petition-impact-people')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('petition-impact-grain')),
          findsOneWidget,
        );
        final preview = <String, int>{};
        for (final stat in ['points', 'people', 'grain']) {
          final text =
              tester
                  .widget<Text>(find.byKey(ValueKey('petition-impact-$stat')))
                  .data!;
          preview[stat] = int.parse(text.replaceAll('−', '-'));
        }
        // The list and preview are read-only until the explicit confirmation.
        expect((await gateway.load()).active!.toJson(), before.toJson());
        await tap(find.byKey(const ValueKey('confirm-petition')));
        final after = controller.state!;
        expect(after.points - before.points, preview['points']);
        expect(after.people - before.people, preview['people']);
        expect(after.grain - before.grain, preview['grain']);
        expect(after.history.single['option'], '1');
        expect((await gateway.load()).active!.toJson(), after.toJson());
      },
    );
  }
}
