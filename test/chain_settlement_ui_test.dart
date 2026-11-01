import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'chain_settlement_test.dart' show settlementState;

Future<void> openSettlement(
  WidgetTester tester,
  GameController controller,
) async {
  final p = controller.state!.petitions.singleWhere((p) => p.storyId == 'arc');
  final open = find.byKey(ValueKey('read-petition-${p.id}'));
  await tester.ensureVisible(open);
  await tester.tap(open);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    for (final scenario in ['fund', 'settle', 'political', 'stop', 'blocked']) {
      testWidgets('chain $scenario previews and commits once at $size', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final harem = scenario == 'political' || scenario == 'stop';
        final s = settlementState(harem ? 'haremHarmony' : 'market');
        if (scenario == 'settle') {
          final arc = s.chains.single;
          arc.stage = arc.completedSteps = 3;
          arc.investedValue = arc.cashSpent = 150;
          arc.decisions = [1, 1, 1];
          s.petitions.single.storyStage = 3;
          s.petitions.single.definitionId = 'chain:market:3';
        }
        if (scenario == 'stop') {
          final arc = s.chains.single;
          arc.stage = arc.completedSteps = 2;
          arc.investedValue = arc.cashSpent = 50;
          arc.decisions = [2, 2];
          s.petitions.single.storyStage = 2;
          s.petitions.single.definitionId = 'chain:haremHarmony:2';
        }
        if (scenario == 'blocked') s.people = 5;
        final store = MemoryGameStore();
        await store.update((a) => a.active = s);
        final gateway = LocalGameGateway(store);
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.copy();
        await tester.pumpWidget(
          GameApp(initialRoute: 'court', controller: controller),
        );
        await tester.pumpAndSettle();
        await openSettlement(tester, controller);
        final dialog =
            size.width < 700
                ? find.byType(AlertDialog)
                : find.byKey(const ValueKey('court-reading'));
        final summary = find.descendant(
          of: dialog,
          matching: find.textContaining('Đã hoàn thành'),
        );
        expect(summary, findsOneWidget);
        expect(
          tester.widget<Text>(summary).data,
          contains('Chỉ nhận phần thưởng khi dừng hoặc hoàn thành'),
        );
        await tester.ensureVisible(find.text('Đọc sau'));
        await tester.tap(find.text('Đọc sau'));
        await tester.pumpAndSettle();
        expect(controller.state!.toJson(), before.toJson());
        await openSettlement(tester, controller);
        Finder option;
        if (scenario == 'stop') {
          option = find.byKey(const ValueKey('chain-stop'));
          expect(
            find.byKey(const ValueKey('petition-choice-0')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('petition-choice-2')),
            findsOneWidget,
          );
        } else {
          option = find.byKey(
            ValueKey('petition-choice-${scenario == 'political' ? 0 : 1}'),
          );
        }
        if (scenario == 'blocked') {
          final blocked = find.byKey(const ValueKey('petition-choice-2'));
          expect(tester.widget<OutlinedButton>(blocked).onPressed, isNull);
          expect(
            find.textContaining('Không đủ chỉ số để trả đầy đủ'),
            findsWidgets,
          );
        }
        await tester.ensureVisible(option);
        await tester.tap(option);
        await tester.pumpAndSettle();
        expect(controller.state!.toJson(), before.toJson());
        await tester.ensureVisible(
          find.byKey(const ValueKey('confirm-petition')),
        );
        await tester.tap(find.byKey(const ValueKey('confirm-petition')));
        await tester.pumpAndSettle();
        final after = controller.state!;
        expect(after.points, before.points - 1);
        if (scenario == 'settle') {
          expect(after.treasury, before.treasury - 70 + 550);
          expect(after.chains, isEmpty);
          expect(after.outcomes.last.title, 'Quyết toán: Bến chợ Đông Hà');
          expect(after.outcomes.last.detail, contains('Hệ số nhận lại 250%'));
        } else if (scenario == 'stop') {
          expect(after.chains, isEmpty);
          expect(after.treasury, before.treasury);
          expect(after.stability, before.stability + 1);
          expect(after.outcomes.last.detail, contains('Từ bỏ ở 2/4'));
        } else if (scenario == 'political') {
          final factions = before.chains.single.participantFactions;
          expect(
            after.factions[factions[0]],
            before.factions[factions[0]]! + 3,
          );
          expect(
            after.factions[factions[1]],
            before.factions[factions[1]]! - 5,
          );
          expect(after.treasury, before.treasury);
          expect(after.chains.single.completedSteps, 1);
        } else {
          expect(after.treasury, before.treasury - 40);
          expect(after.chains.single.completedSteps, 1);
          expect(after.chains.single.investedValue, 40);
        }
        expect((await gateway.load()).active!.toJson(), after.toJson());
        expect(tester.takeException(), isNull);
      });
    }
  }
}
