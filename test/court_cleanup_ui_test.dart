import 'support/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/outcome_read_store.dart';

void main() {
  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets(
      'clean court keeps unread reports and routes to their proper rooms at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store);
        await gateway.start(
          name: 'An',
          runId: 'clean-court',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((archive) {
          final s = archive.active!;
          s.petitions.clear();
          s.affairsThisWeek = 1;
          s.outcomes = [
            const OutcomeReport(
              id: 'a',
              week: 1,
              title: 'Báo cáo A',
              status: 'success',
              detail: 'Đã xong A',
              changes: {},
            ),
            const OutcomeReport(
              id: 'b',
              week: 1,
              title: 'Báo cáo B',
              status: 'failure',
              detail: 'Đã xong B',
              changes: {},
            ),
          ];
        });
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.toJson();
        final readState = OutcomeReadStore();
        Future<void> mount() async {
          await tester.pumpWidget(
            GameApp(
              initialRoute: 'court',
              controller: controller,
              outcomeReadStore: readState,
            ),
          );
          await tester.pumpAndSettle();
        }

        Future<void> tap(Finder finder) async {
          await tester.ensureVisible(finder);
          await tester.tap(finder);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        Future<void> navigate(String room) async {
          await openSection(tester, room);
        }

        await mount();
        expect(find.byKey(const ValueKey('court-complete')), findsOneWidget);
        expect(find.text('Kết quả mới (2)'), findsOneWidget);
        expect(find.byKey(const ValueKey('reign-situation')), findsNothing);
        expect(find.text('Việc vua hôm nay'), findsNothing);
        expect(find.text('Long thể & nhịp sống'), findsNothing);
        expect(find.text('Vừa được ghi vào sử'), findsNothing);
        await tap(find.byKey(const ValueKey('open-outcomes')));
        expect(find.text('Báo cáo A'), findsOneWidget);
        expect(find.text('Báo cáo B'), findsOneWidget);
        await tap(find.byKey(const ValueKey('close-outcome-dialog')));
        expect(find.byKey(const ValueKey('open-outcomes')), findsNothing);
        // Recreate the UI from the same archive: acknowledged reports stay read.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await controller.load();
        await mount();
        expect(find.byKey(const ValueKey('open-outcomes')), findsNothing);
        await tap(find.byKey(const ValueKey('court-to-kingdom')));
        expect(find.byKey(const ValueKey('action-govern')), findsOneWidget);
        expect(find.byKey(const ValueKey('action-relief')), findsOneWidget);
        expect(find.byKey(const ValueKey('action-rest')), findsNothing);
        expect(find.byKey(const ValueKey('major-catalog-size')), findsNothing);
        expect(find.byKey(const ValueKey('reign-rules-help')), findsNothing);
        await navigate('health');
        expect(find.byKey(const ValueKey('action-rest')), findsOneWidget);
        expect(find.byKey(const ValueKey('action-revel')), findsOneWidget);
        await navigate('court');
        await tap(find.byKey(const ValueKey('court-to-citadel')));
        expect(find.byKey(const ValueKey('giang-son-map')), findsOneWidget);
        expect(controller.state!.toJson(), before);
        expect((await gateway.load()).active!.toJson(), before);
      },
    );
  }
}
