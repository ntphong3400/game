import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/food_pressure_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets(
      'continuing relief is previewed, cancelled and paid only on confirmation at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final s = GameEngine().start('food-ui', 'An', 42)..petitions.clear();
        s.foodDisruptions.add(
          FoodDisruption(
            id: 'ui',
            title: 'Lũ lụt',
            percent: 25,
            start: 0,
            until: 2,
          ),
        );
        final store = MemoryGameStore();
        await store.update((a) => a.active = s);
        final gateway = LocalGameGateway(store);
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.copy();
        final p = before.petitions.singleWhere(
          (p) => isFoodRecoveryEvent(p.definitionId),
        );
        final quote = foodRecoveryEvent(before, p.definitionId)!;
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

        final open = find.byKey(ValueKey('read-petition-${p.id}'));
        await tap(open);
        await tap(find.text('Đọc sau'));
        expect(controller.state!.toJson(), before.toJson());
        await tap(open);
        await tap(find.byKey(const ValueKey('petition-choice-0')));
        expect(find.textContaining('281.250 tạ'), findsWidgets);
        expect(controller.state!.grain, before.grain);
        await tap(find.byKey(const ValueKey('confirm-petition')));
        expect(
          controller.state!.grain,
          before.grain - quote.choices.first.grainCost,
        );
        expect(controller.state!.population!.foodCredit, 225000);
        expect(controller.state!.foodDisruptions.single.percent, 0);
        expect((await gateway.load()).active!.grain, controller.state!.grain);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
