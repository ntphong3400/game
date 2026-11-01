import 'support/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets(
      'personality is hidden until third conversation and survives reload at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store, seasonal: false);
        await gateway.start(
          name: 'An',
          runId: 'personality-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((archive) {
          final s = archive.active!;
          s.court.removeWhere((c) => c.id != 'treasurer');
          s.court.single.personalities
            ..clear()
            ..addAll([
              Personality.disciplined,
              Personality.greedy,
              Personality.resentful,
            ]);
          s.court.single.personalityContacts = 0;
        });
        final controller = GameController(gateway);
        await controller.load();
        await tester.pumpWidget(
          GameApp(initialRoute: 'court', controller: controller),
        );
        await tester.pumpAndSettle();
        await openSection(tester, 'Triều thần');
        await tester.pumpAndSettle();
        for (var contact = 0; contact < 3; contact++) {
          expect(find.textContaining('Đã biết: Kỷ luật'), findsOneWidget);
          expect(find.textContaining('Tham lợi'), findsNothing);
          expect(find.textContaining('Thù dai'), findsNothing);
          final summon = find.text('Triệu kiến');
          await tester.ensureVisible(summon);
          await tester.tap(summon);
          await tester.pumpAndSettle();
          final profile = find.byKey(const ValueKey('meeting-profile'));
          await tester.ensureVisible(profile);
          await tester.pumpAndSettle();
          await tester.tap(profile);
          await tester.pumpAndSettle();
          final details =
              tester
                  .widget<Text>(
                    find.byKey(const ValueKey('personality-details')),
                  )
                  .data!;
          expect(details, contains('$contact/3'));
          expect(details, isNot(contains('Tham lợi')));
          final talk = find.descendant(
            of: find.byType(SimpleDialog),
            matching: find.text('Trò chuyện, lắng nghe'),
          );
          await tester.ensureVisible(talk);
          await tester.tap(talk);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.byKey(const ValueKey('meeting-back')));
          await tester.pumpAndSettle();
        }
        expect(
          find.textContaining('Đã biết: Kỷ luật · Tham lợi'),
          findsOneWidget,
        );
        expect(find.textContaining('Thù dai'), findsNothing);
        final saved = (await gateway.load()).active!.court.single;
        expect(saved.personalityContacts, 3);
        expect(saved.knownPersonalityCount, 2);
        await controller.load();
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Đã biết: Kỷ luật · Tham lợi'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
