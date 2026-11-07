import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/imperial_assets.dart';
import 'package:van_tue/game/presentation/widgets/petition_impacts.dart';

void main() {
  testWidgets(
    'impact groups keep long costs beside their labels across widths and larger text',
    (tester) async {
      final state = GameState(
        runId: 'impact-layout',
        playerName: 'An',
        seed: 42,
        rng: 42,
        court: [],
      );
      const choice = EventChoice(
        'Xuất lương',
        '',
        {'people': 3, 'illness': -1, 'faction:Văn thần': 2},
        cost: 1200000,
        grainCost: 202500,
        points: 1,
      );
      for (final scenario in [
        (width: 220.0, scale: 1.0),
        (width: 320.0, scale: 1.6),
        (width: 500.0, scale: 1.0),
        (width: 760.0, scale: 1.0),
        (width: 760.0, scale: 1.6),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(scenario.scale),
                ),
                child: SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: scenario.width,
                      child: PetitionImpacts(state: state, choice: choice),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final amount = find.byKey(const ValueKey('petition-impact-grainCost'));
        expect(tester.widget<Text>(amount).data, '−202.500');
        final paragraph = tester.renderObject<RenderParagraph>(amount);
        expect(
          paragraph.getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 8),
          ),
          hasLength(1),
        );
        expect(
          tester.getCenter(amount).dy,
          closeTo(tester.getCenter(find.text('Xuất lương')).dy, .5),
        );
        for (final key in [
          'points',
          'cost',
          'people',
          'illness',
          'faction:Văn thần',
        ]) {
          final row = find.byKey(ValueKey('petition-impact-row-$key'));
          expect(
            tester.getSize(row).width,
            scenario.width == 760 && scenario.scale == 1
                ? lessThanOrEqualTo(320 * scenario.scale)
                : closeTo(scenario.width, .5),
          );
          expect(
            tester
                .getBottomRight(find.byKey(ValueKey('petition-impact-$key')))
                .dx,
            closeTo(tester.getBottomRight(row).dx - 11, .5),
          );
        }
        final rows = find.byWidgetPredicate(
          (widget) =>
              widget.key is ValueKey<String> &&
              (widget.key as ValueKey<String>).value.startsWith(
                'petition-impact-row-',
              ),
        );
        final columnPositions =
            rows
                .evaluate()
                .map(
                  (element) =>
                      tester.getTopLeft(find.byWidget(element.widget)).dx,
                )
                .toSet();
        expect(
          columnPositions,
          hasLength(scenario.width == 760 && scenario.scale == 1 ? 2 : 1),
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

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
        final icons = find.descendant(
          of: find.byType(PetitionImpacts),
          matching: find.byType(ImperialIcon),
        );
        expect(
          tester.widgetList<ImperialIcon>(icons).map((icon) => icon.name),
          unorderedEquals(['action', 'people', 'grain', 'fatigue']),
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
