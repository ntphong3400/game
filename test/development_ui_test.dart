import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets(
      'development quote, qualified officers and confirmation at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store);
        await gateway.start(
          name: 'An',
          runId: 'development-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((a) {
          final s = a.active!;
          for (final c in s.court) {
            c.ability = 20;
          }
          final treasurer = s.court.firstWhere((c) => c.id == 'treasurer');
          treasurer.ability = 70;
          treasurer.specialty = 'Kinh tế';
          final works = s.court.firstWhere((c) => c.id == 'works');
          works.ability = 95;
          works.specialty = 'Công trình';
        });
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          GameApp(controller: controller, initialRoute: 'treasury'),
        );
        await tester.pumpAndSettle();
        Future<void> tap(Finder f) async {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        await tap(find.byKey(const ValueKey('treasury-open-2')));
        expect(find.textContaining('Kinh tế cấp 1/5'), findsOneWidget);
        final before = controller.state!.toJson();
        await tap(find.byKey(const ValueKey('action-upgrade_economy')));
        expect(find.textContaining('năng lực ≥60'), findsWidgets);
        expect(
          find.byKey(const ValueKey('assign-upgrade_economy-works')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('assign-upgrade_economy-chancellor')),
          findsNothing,
        );
        await tap(
          find.byKey(const ValueKey('assign-upgrade_economy-treasurer')),
        );
        expect(find.textContaining('ước tính thành công'), findsOneWidget);
        expect(
          find.textContaining('Thành công tăng đúng 1 cấp'),
          findsOneWidget,
        );
        expect(controller.state!.toJson(), before);
        await tap(find.text('Cân nhắc lại'));
        expect(controller.state!.toJson(), before);
        await tap(find.byKey(const ValueKey('action-upgrade_economy')));
        await tap(
          find.byKey(const ValueKey('assign-upgrade_economy-treasurer')),
        );
        await tap(find.text('Xác nhận giao việc'));
        expect(controller.state!.economyLevel, 1);
        expect(controller.state!.treasury, (before['treasury'] as int) - 80);
        expect(controller.state!.projects.single.targetLevel, 2);
        expect((await gateway.load()).active!.projects.single.targetLevel, 2);
        expect(
          tester
              .widget<OutlinedButton>(
                find.byKey(const ValueKey('action-upgrade_economy')),
              )
              .onPressed,
          isNull,
        );

        await tap(find.byKey(const ValueKey('section-back')));
        await tap(find.byKey(const ValueKey('treasury-open-3')));
        expect(
          find.byKey(const ValueKey('agriculture-harvest-plan')),
          findsOneWidget,
        );
        expect(find.textContaining('95–100: 120%'), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const ValueKey('action-upgrade_levee')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.byKey(const ValueKey('action-upgrade_farm')),
          findsOneWidget,
        );
        await tap(find.byKey(const ValueKey('section-back')));
        await tap(find.byKey(const ValueKey('treasury-open-4')));
        expect(find.textContaining('Ước tính'), findsOneWidget);
        expect(find.textContaining('0/1 kỳ · dự kiến cuối'), findsOneWidget);
      },
    );
  }
}
