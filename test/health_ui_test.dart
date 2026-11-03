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
    testWidgets('treatment previews current recovery and herbal fee at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final scenario in ['normal', 'herbs', 'no-doctor']) {
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store);
        await gateway.start(
          name: 'An',
          runId: 'treat-$scenario',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((archive) {
          final s = archive.active!;
          s.health = 60;
          s.illness = 40;
          s.fatigue = 30;
          s.workThisWeek = 2;
          final doctor = s.court.firstWhere((c) => c.id == 'doctor');
          if (scenario == 'no-doctor') doctor.available = false;
          if (scenario == 'herbs') {
            doctor.ability = 90;
            doctor.specialty = 'Cung đình';
            s.palaceEffects.add(
              PalaceEffect(
                kind: 'herbs',
                personId: doctor.id,
                startsTurn: s.week,
                endsTurn: s.week + 5,
                amount: 10,
                uses: 1,
              ),
            );
          }
        });
        final recovery =
            scenario == 'normal'
                ? 16
                : scenario == 'herbs'
                ? 11
                : 5;
        const cost = 25;
        final controller = GameController(gateway);
        await controller.load();
        await tester.pumpWidget(
          GameApp(
            initialRoute: 'court',
            key: ValueKey('treat-$scenario'),
            controller: controller,
          ),
        );
        await tester.pumpAndSettle();
        await openSection(tester, 'health');
        await tester.pumpAndSettle();
        final preview = find.textContaining(
          'mức bệnh −$recovery · mệt mỏi −12',
        );
        expect(preview, findsOneWidget);
        final text = tester.widget<Text>(preview).data!;
        expect(text, contains('Chi $cost tiền'));
        expect(text, contains('sức khỏe +2'));
        expect(text, contains('Hiệu quả áp dụng ngay'));
        if (scenario == 'herbs') {
          expect(text, isNot(contains('dược liệu giảm')));
        }
        final before = controller.state!.copy();
        final button = find.byKey(const ValueKey('action-treat'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        final result = controller.state!;
        expect(result.health, 62);
        expect(result.illness, 40 - recovery);
        expect(result.fatigue, 18);
        expect(result.workThisWeek, 2);
        expect(result.points, before.points - 1);
        expect(result.treasury, before.treasury - cost);
        expect((await gateway.load()).active!.fatigue, 18);
        if (scenario == 'herbs') {
          expect(result.palaceEffects, isEmpty);
          expect(tester.widget<Text>(preview).data, contains('Chi 25 tiền'));
        }
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets(
      'care shows deferred recovery and updates repeat cost at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store);
        await gateway.start(
          name: 'An',
          runId: 'health-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        final controller = GameController(gateway);
        await controller.load();
        await tester.pumpWidget(
          GameApp(initialRoute: 'court', controller: controller),
        );
        await tester.pumpAndSettle();
        await openSection(tester, 'health');
        await tester.pumpAndSettle();
        final restText = find.textContaining('mệt mỏi −16 · căng thẳng −8');
        expect(restText, findsOneWidget);
        expect(tester.widget<Text>(restText).data, contains('khi khép mùa'));
        final revelText = find.textContaining('lần 1 mùa này: mệt mỏi −16');
        expect(revelText, findsOneWidget);
        expect(tester.widget<Text>(revelText).data, contains('căng thẳng −16'));
        expect(tester.widget<Text>(revelText).data, contains('khi khép mùa'));
        final before = controller.state!.copy();
        final restButton = find.byKey(const ValueKey('action-rest'));
        await tester.ensureVisible(restButton);
        await tester.tap(restButton);
        await tester.pumpAndSettle();
        final fatigueChanges = ['−16', '−8', '0', '+8', '+16', '+24'];
        final stressChanges = ['−16', '−12', '−8', '−4', '0', '+4'];
        for (var i = 0; i < 6; i++) {
          final preview = find.textContaining('lần ${i + 1} mùa này:');
          expect(preview, findsOneWidget);
          expect(
            tester.widget<Text>(preview).data,
            contains(
              'mệt mỏi ${fatigueChanges[i]} · căng thẳng ${stressChanges[i]}',
            ),
          );
          expect(tester.widget<Text>(preview).data, contains('khi khép mùa'));
          final button = find.byKey(const ValueKey('action-revel'));
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pumpAndSettle();
        }
        expect(controller.state!.fatigue, before.fatigue);
        expect(controller.state!.stress, before.stress);
        expect(controller.state!.points, before.points - 7);
        expect(controller.state!.treasury, before.treasury - 108);
        expect((await gateway.load()).active!.revelThisWeek, 6);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
