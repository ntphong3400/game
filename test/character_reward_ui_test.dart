import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'meeting_actions_ui_test.dart' as meeting;

void main() {
  for (final size in [const Size(1440, 900), const Size(320, 568)]) {
    for (final amount in [20, 40, 80]) {
      testWidgets('reward picker commits chosen tier $amount at $size', (
        tester,
      ) async {
        final controller = await meeting.openMeeting(
          tester,
          size: size,
          treasury: 20000,
          gold: true,
          initialAffection: 99,
          initialDiscontent: 30,
        );
        final before = controller.state!;
        await tester.ensureVisible(meeting.action('reward'));
        await tester.tap(meeting.action('reward'));
        await tester.pumpAndSettle();
        for (final label in [
          '2.000 lượng vàng',
          '4.000 lượng vàng',
          '8.000 lượng vàng',
        ]) {
          expect(find.text(label), findsOneWidget);
        }
        final choice = find.byKey(ValueKey('reward-choice-reward:$amount'));
        await tester.ensureVisible(choice);
        await tester.tap(choice);
        await tester.pumpAndSettle();
        expect(
          tester.widget<RadioListTile<String>>(choice).groupValue,
          'reward:$amount',
        );
        expect(
          find.text(
            '1 hành động · ${amount == 20
                ? '2.000'
                : amount == 40
                ? '4.000'
                : '8.000'} lượng vàng',
          ),
          findsOneWidget,
        );
        expect(controller.state!.toJson(), before.toJson());
        await tester.tap(find.byKey(const ValueKey('meeting-action-confirm')));
        await tester.pumpAndSettle();
        expect(controller.state!.treasury, before.treasury - amount * 100);
        expect(controller.state!.points, before.points - 1);
        expect(controller.state!.revision, before.revision + 1);
        expect(meeting.lan(controller).affection, amount == 80 ? 100 : 99);
        expect(meeting.lan(controller).discontent, amount == 80 ? 29 : 30);
        expect(
          (await controller.gateway.load()).active!.toJson(),
          controller.state!.toJson(),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'unaffordable tiers are disabled and closing after selection spends nothing',
    (tester) async {
      final controller = await meeting.openMeeting(
        tester,
        size: const Size(390, 844),
        treasury: 2500,
        gold: true,
      );
      final before = controller.state!.toJson();
      await tester.ensureVisible(meeting.action('reward'));
      await tester.tap(meeting.action('reward'));
      await tester.pumpAndSettle();
      for (final amount in [40, 80]) {
        final tile = tester.widget<RadioListTile<String>>(
          find.byKey(ValueKey('reward-choice-reward:$amount')),
        );
        expect(tile.onChanged, isNull);
      }
      await tester.tap(find.byKey(const ValueKey('meeting-action-cancel')));
      await tester.pumpAndSettle();
      expect(controller.state!.toJson(), before);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'official profile uses the reward picker and commits its selection',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store);
      await gateway.start(
        name: 'An',
        runId: 'official-reward',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((a) {
        a.active!.court.firstWhere((c) => c.id == 'chancellor').affection = 40;
      });
      final controller = GameController(gateway);
      addTearDown(controller.dispose);
      await controller.load();
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'people'),
      );
      await tester.pumpAndSettle();
      final before = controller.state!;
      await tester.tap(find.byKey(const ValueKey('court-group-Văn ban')));
      await tester.pumpAndSettle();
      final summon = find.byKey(const ValueKey('meet-person-chancellor'));
      await tester.ensureVisible(summon);
      await tester.tap(summon);
      await tester.pumpAndSettle();
      final action = find.byKey(const ValueKey('meeting-action-reward'));
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();
      final choice = find.byKey(const ValueKey('reward-choice-reward:40'));
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('meeting-action-confirm')));
      await tester.pumpAndSettle();
      expect(
        controller.state!.court
            .firstWhere((c) => c.id == 'chancellor')
            .affection,
        44,
      );
      expect(controller.state!.treasury, before.treasury - 4000);
      expect(controller.state!.points, before.points - 1);
      expect(tester.takeException(), isNull);
    },
  );
}
