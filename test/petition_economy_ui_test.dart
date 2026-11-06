import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/imperial_assets.dart';
import 'package:van_tue/game/presentation/widgets/petition_impacts.dart';

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets(
      'economic choices preview net profit, failure and settlement at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final example in [
          (id: 'commerce_01', cost: 30, receipt: '85', profit: '55', ticks: 3),
          (
            id: 'tax_abuse',
            cost: 20,
            receipt: '60–90',
            profit: '40–70',
            ticks: 2,
          ),
        ]) {
          final store = MemoryGameStore();
          final gateway = LocalGameGateway(store);
          await gateway.start(
            name: 'An',
            runId: example.id,
            seed: 42,
            previousRunId: null,
            previousRevision: null,
          );
          await store.update((a) {
            final s = a.active!;
            s.rng = 100;
            s.petitions = [
              Petition(
                id: 'p',
                definitionId: example.id,
                openedWeek: s.week,
                deadline: s.week + 1,
              ),
            ];
          });
          final controller = GameController(gateway);
          await controller.load();
          await tester.pumpWidget(
            GameApp(
              initialRoute: 'court',
              key: ValueKey(example.id),
              controller: controller,
            ),
          );
          await tester.pumpAndSettle();
          final before = controller.state!.copy();
          Future<void> tap(Finder finder) async {
            await tester.ensureVisible(finder);
            await tester.tap(finder);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }

          await tap(find.byKey(const ValueKey('read-petition-p')));
          final preview = find.textContaining(
            'lãi sau vốn ${example.profit} tiền',
          );
          expect(preview, findsNothing);
          final option = find.byKey(const ValueKey('petition-choice-0'));
          final treasuryIcon = find.byWidgetPredicate(
            (widget) => widget is ImperialIcon && widget.name == 'treasury',
          );
          expect(
            find.descendant(of: option, matching: treasuryIcon),
            findsOneWidget,
          );
          await tap(option);
          expect(
            find.descendant(
              of: find.byType(PetitionImpacts),
              matching: treasuryIcon,
            ),
            findsWidgets,
          );
          expect(preview, findsOneWidget);
          final text = tester.widget<Text>(preview).data!;
          expect(text, contains('Vốn/phí ứng ${example.cost} tiền'));
          expect(text, contains('nhận ${example.receipt} tiền'));
          expect(
            text,
            contains(
              'Thất bại: mất ${example.cost} tiền đã ứng, không phạt thêm tiền',
            ),
          );
          expect(
            text,
            contains(
              'Nhận kết quả cuối ${before.date(before.week + example.ticks - 1)}',
            ),
          );
          expect(controller.state!.toJson(), before.toJson());
          await tap(find.byKey(const ValueKey('confirm-petition')));
          final result = controller.state!;
          expect(result.treasury, before.treasury - example.cost);
          expect(result.points, before.points - 1);
          expect(
            result.pending.single.dueWeek,
            before.week + example.ticks - 1,
          );
          expect(result.pending.single.assignment!.succeeded, true);
          if (example.id == 'tax_abuse') {
            expect(result.pending.single.assignment!.auditRecoveryMinimum, 60);
            expect(result.pending.single.assignment!.auditRecoveryMaximum, 90);
          } else {
            expect(result.pending.single.effects['treasury'], 85);
          }
          expect(
            (await gateway.load()).active!.pending.single.toJson(),
            result.pending.single.toJson(),
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}
