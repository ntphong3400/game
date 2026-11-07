import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/models/number_format.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'support/legacy_gateway.dart';
import 'support/legacy_engine.dart';
import 'story_petition_test.dart'
    show storyState, storyMajor, storyEngine, storySend, nextStorySeason;

GameState majorNarrativeState(int stage) {
  var s =
      storyState()
        ..goldStandard = true
        ..grain = 400000
        ..treasury = 50000
        ..major = storyMajor('flood', severity: 2);
  storyEngine.prepareStoryPetitions(s);
  for (var step = 0; step < stage; step++) {
    final p = s.petitions.singleWhere((p) => p.storyKind == 'major');
    s = storySend(s, 'petition', target: p.id, option: '${[1, 2, 0][step]}');
    s = nextStorySeason(s);
  }
  s.petitions.removeWhere((p) => p.storyKind != 'major');
  return s;
}

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    for (var stage = 0; stage < 4; stage++) {
      testWidgets(
        'major stage $stage is concise and keeps exact impacts at $size',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final s = majorNarrativeState(stage);
          // A historical save keeps its original dated decision wording.
          if (stage > 0) {
            s.major!.decisionLabels[0] =
                'Ứng phó có giới hạn (mùa Xuân · năm 1)';
          }
          final p = s.petitions.single;
          final store = MemoryGameStore();
          await store.update((a) => a.active = s);
          final controller = GameController(LocalGameGateway(store));
          await controller.load();
          addTearDown(controller.dispose);
          final before = controller.state!.toJson();
          await tester.pumpWidget(
            GameApp(initialRoute: 'court', controller: controller),
          );
          await tester.pumpAndSettle();
          final open = find.byKey(ValueKey('read-petition-${p.id}'));
          await tester.ensureVisible(open);
          await tester.tap(open);
          await tester.pumpAndSettle();
          final reading =
              size.width < 700
                  ? find.byType(AlertDialog)
                  : find.byKey(const ValueKey('court-reading'));
          final stageLabel = find.descendant(
            of: reading,
            matching: find.byKey(const ValueKey('major-stage-label')),
          );
          expect(
            tester.widget<Text>(stageLabel).data,
            [
              'Bản tấu đầu',
              'Bản tấu thứ hai',
              'Bản tấu thứ ba',
              'Bản tấu cuối',
            ][stage],
          );
          expect(
            find.descendant(
              of: reading,
              matching: find.text('Hạn: cuối mùa này'),
            ),
            findsOneWidget,
          );
          for (final raw in [
            '/4',
            '· mức',
            'DB-',
            '%',
            'Không thu hoặc trừ lại',
            'Diễn biến cần ngự phê:',
            'Tổn thất đã xảy ra:',
          ]) {
            expect(
              find.descendant(of: reading, matching: find.textContaining(raw)),
              findsNothing,
            );
          }
          if (stage > 0) {
            expect(
              find.byKey(const ValueKey('major-history-entry-0')),
              findsNothing,
            );
            expect(
              find.byKey(const ValueKey('major-history-damage')),
              findsNothing,
            );
            final history = find.descendant(
              of: reading,
              matching: find.text('Xem chỉ dụ trước'),
            );
            await tester.ensureVisible(history);
            await tester.tap(history);
            await tester.pumpAndSettle();
            expect(find.text(s.major!.decisionLabels[0]), findsOneWidget);
            expect(
              find.byKey(const ValueKey('major-history-damage')),
              findsOneWidget,
            );
            expect(controller.state!.toJson(), before);
            await tester.ensureVisible(history);
            await tester.tap(history);
            await tester.pumpAndSettle();
            expect(
              find.byKey(const ValueKey('major-history-damage')),
              findsNothing,
            );
          }
          final c = eventForState(controller.state!, p.definitionId).choices[1];
          final option = find.byKey(const ValueKey('petition-choice-1'));
          await tester.ensureVisible(option);
          await tester.tap(option);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<Text>(
                  find.byKey(const ValueKey('petition-impact-points')),
                )
                .data,
            '−1',
          );
          expect(
            tester
                .widget<Text>(
                  find.byKey(const ValueKey('petition-impact-cost')),
                )
                .data,
            formatGameNumbers('−${c.cost}'),
          );
          if (c.grainCost > 0) {
            expect(
              tester
                  .widget<Text>(
                    find.byKey(const ValueKey('petition-impact-grainCost')),
                  )
                  .data,
              formatGameNumbers('−${c.grainCost}'),
            );
          }
          for (final effect in c.effects.entries) {
            expect(
              tester
                  .widget<Text>(
                    find.byKey(ValueKey('petition-impact-${effect.key}')),
                  )
                  .data,
              formatGameNumbers(
                '${effect.value < 0 ? '−' : '+'}${effect.value.abs()}',
              ),
            );
          }
          expect(
            find.byKey(const ValueKey('petition-choice-detail-1')),
            findsNothing,
          );
          expect(find.textContaining('không đổi chỉ số ngay'), findsNothing);
          expect(
            find.text('Quá hạn sẽ không tổ chức ứng phó phần việc này.'),
            findsOneWidget,
          );
          expect(controller.state!.toJson(), before);
          await tester.ensureVisible(find.text('Đọc sau'));
          await tester.tap(find.text('Đọc sau'));
          await tester.pumpAndSettle();
          expect(controller.state!.toJson(), before);
          expect(tester.takeException(), isNull);
        },
      );
    }
    testWidgets('major season-end warning omits raw choice hints at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final s = majorNarrativeState(2)..affairsThisWeek = 1;
      final store = MemoryGameStore();
      await store.update((a) => a.active = s);
      final controller = GameController(LocalGameGateway(store));
      await controller.load();
      addTearDown(controller.dispose);
      final before = controller.state!.toJson();
      await tester.pumpWidget(
        GameApp(initialRoute: 'citadel', controller: controller),
      );
      await tester.pumpAndSettle();
      final end = find.byKey(const ValueKey('citadel-end-turn'));
      await tester.ensureVisible(end);
      await tester.tap(end);
      await tester.pumpAndSettle();
      final warning = find.byType(AlertDialog);
      expect(warning, findsOneWidget);
      expect(
        find.descendant(
          of: warning,
          matching: find.textContaining(
            'Quá hạn sẽ không tổ chức ứng phó phần việc này.',
          ),
        ),
        findsOneWidget,
      );
      for (final raw in [
        '%',
        'không đổi chỉ số ngay',
        'Bản tấu tiếp theo',
        'tổn thất ngay:',
      ]) {
        expect(
          find.descendant(of: warning, matching: find.textContaining(raw)),
          findsNothing,
        );
      }
      await tester.tap(find.text('Quay lại xử lý'));
      await tester.pumpAndSettle();
      expect(controller.state!.toJson(), before);
      expect(tester.takeException(), isNull);
    });
  }
}
