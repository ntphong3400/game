import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/reign_content.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/widgets/reign_panel.dart';

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    for (final seasonal in [false, true]) {
      testWidgets(
        'affairs hides world and story panels while retaining ongoing obligations at $size, seasonal=$seasonal',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final state = GameEngine(seasonal: seasonal).start('ui', 'An', 42);
          state.major = MajorMission(
            id: 'active',
            kind: 'flood',
            openedWeek: 1,
            deadline: 6,
            severity: 1,
            preparedness: 0,
            petitionDriven: seasonal,
            objectives:
                majorDefinition(
                  'flood',
                ).objectives.map((o) => MissionObjective(key: o.key)).toList(),
          );
          state.majorHistory = [
            MajorMission.fromJson(state.major!.toJson())..resolvedWeek = 1,
          ];
          state.chains = [
            StoryArc(
              settlementVersion: 0,
              id: 'arc',
              kind: 'granary',
              dueWeek: 1,
            ),
          ];
          state.obligations = [
            Obligation(
              id: 'payment',
              kind: 'borrow',
              title: 'Khoản vay thế gia',
              nextWeek: 2,
              remaining: 3,
              amount: 50,
            ),
            Obligation(
              id: 'income',
              kind: 'income',
              title: 'Nguồn thu thương mại',
              nextWeek: 2,
              remaining: 2,
              income: 5,
            ),
            Obligation(
              id: 'effect',
              kind: 'aftermath',
              title: 'Ảnh hưởng đang kéo dài',
              nextWeek: 2,
              remaining: 2,
              effects: {'people': -2},
            ),
          ];
          final before = state.toJson();
          final commands = <String>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ReignPanel(
                    state: state,
                    busy: false,
                    send: (type, target, option) async {
                      commands.add(type);
                    },
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (final text in [
            'Thế cục',
            'Đại biến cố',
            'Chuỗi',
            'Luật thế cục',
          ]) {
            expect(find.textContaining(text), findsNothing);
          }
          expect(
            find.text('Nghĩa vụ và ảnh hưởng đang hiệu lực'),
            findsOneWidget,
          );
          expect(
            find.textContaining('chi 50 tiền/kỳ (tổng còn 150)'),
            findsOneWidget,
          );
          expect(
            find.textContaining('thu +5 tiền/kỳ (tổng còn 10)'),
            findsOneWidget,
          );
          expect(find.textContaining('Mỗi kỳ: lòng dân -2'), findsOneWidget);
          expect(
            find.textContaining('Từ cuối ${state.date(2)}'),
            findsNWidgets(3),
          );
          expect(find.text('Đối sách khẩn cấp'), findsOneWidget);
          final borrow = find.byKey(const ValueKey('emergency-borrow'));
          expect(tester.widget<OutlinedButton>(borrow).onPressed, isNull);
          final peace = find.byKey(const ValueKey('emergency-peace'));
          expect(tester.widget<OutlinedButton>(peace).onPressed, isNull);
          expect(commands, isEmpty);
          expect(state.toJson(), before);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'emergency cancellation does not commit, confirmation adds a visible obligation',
    (tester) async {
      final engine = GameEngine(seasonal: false);
      var state = engine.start('ui', 'An', 42);
      state.chains = [
        StoryArc(settlementVersion: 0, id: 'arc', kind: 'granary', dueWeek: 1),
      ];
      final commands = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder:
                  (context, refresh) => SingleChildScrollView(
                    child: ReignPanel(
                      state: state,
                      busy: false,
                      send: (type, target, option) async {
                        commands.add(type);
                        refresh(() {
                          state = engine.execute(
                            state,
                            GameCommand(
                              id: 'ui-${state.revision}',
                              runId: state.runId,
                              expectedRevision: state.revision,
                              type: type,
                              target: target,
                              option: option,
                            ),
                          );
                        });
                      },
                    ),
                  ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final borrow = find.byKey(const ValueKey('emergency-borrow'));
      await tester.ensureVisible(borrow);
      await tester.tap(borrow);
      await tester.pumpAndSettle();
      expect(find.textContaining('tổng 150'), findsWidgets);
      expect(state.obligations, isEmpty);
      final before = state.toJson();
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(commands, isEmpty);
      expect(state.toJson(), before);
      await tester.tap(borrow);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-emergency')));
      await tester.pumpAndSettle();
      expect(commands, ['emergency']);
      expect(state.obligations.single.kind, 'borrow');
      expect(find.textContaining('tổng còn 150'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
