import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(1280, 720),
    const Size(844, 390),
    const Size(760, 600),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets('court reading, expansion and switching do not save at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store);
      await gateway.start(
        name: 'An',
        runId: 'focus',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((archive) {
        final s = archive.active!;
        s.treasury = 1000;
        s.petitions = [
          Petition(
            id: 'a',
            definitionId: 'finance_02',
            openedWeek: s.week,
            deadline: s.week,
          ),
          Petition(
            id: 'b',
            definitionId: 'community_03',
            openedWeek: s.week,
            deadline: s.week + 1,
          ),
          for (var i = 0; i < 6; i++)
            Petition(
              id: 'overflow-$i',
              definitionId: 'community_03',
              openedWeek: s.week,
              deadline: s.week + 1,
            ),
        ];
      });
      final controller = GameController(gateway);
      await controller.load();
      addTearDown(controller.dispose);
      final before = controller.state!.toJson();
      final initialBody = controller.state!.authoredText(
        eventForState(controller.state!, 'finance_02').body,
      );
      await tester.pumpWidget(
        GameApp(initialRoute: 'court', controller: controller),
      );
      await tester.pumpAndSettle();
      expect(find.text('Việc vua hôm nay'), findsNothing);
      expect(find.text('Vừa được ghi vào sử'), findsNothing);
      expect(find.text('Mỗi ý chỉ đều được ghi vào sử.'), findsNothing);
      expect(find.byKey(const ValueKey('reign-situation')), findsNothing);
      expect(find.byKey(const ValueKey('open-finance')), findsNothing);
      final overview = find.byKey(const ValueKey('court-overview'));
      final header = find.byKey(const ValueKey('court-petition-header'));
      final count = find.byKey(const ValueKey('court-petition-count'));
      final overviewRect = tester.getRect(overview);
      final headerRect = tester.getRect(header);
      final countRect = tester.getRect(count);
      expect(find.text('8 CHỜ'), findsOneWidget);
      expect(find.byKey(const ValueKey('neglect-warning')), findsNothing);
      expect(find.textContaining('trình đầy đủ ngay đầu mùa'), findsNothing);
      for (final unit in [
        'tạ',
        'lượng vàng',
        'điểm',
        'điểm quân lực',
        'người',
        'tiền',
      ]) {
        expect(
          find.descendant(of: overview, matching: find.text(unit)),
          findsNothing,
        );
      }
      final firstCard = find.byKey(const ValueKey('petition-card-a'));
      final originalTop = tester.getTopLeft(firstCard).dy;
      final listPane = find.byKey(const ValueKey('court-petition-scroll'));
      await tester.drag(listPane, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(firstCard).dy, lessThan(originalTop));
      expect(tester.getRect(overview), overviewRect);
      expect(tester.getRect(header), headerRect);
      expect(tester.getRect(count), countRect);
      final scrollable = find.descendant(
        of: listPane,
        matching: find.byType(Scrollable),
      );
      tester.state<ScrollableState>(scrollable).position.jumpTo(0);
      await tester.pumpAndSettle();

      final inline =
          find.byKey(const ValueKey('petition-desk')).evaluate().isNotEmpty;
      if (inline) {
        final list = find.byKey(const ValueKey('petition-card-a'));
        final reading = find.byKey(const ValueKey('court-reading'));
        expect(
          tester.getRect(list).right,
          lessThan(tester.getRect(reading).left),
        );
        // The story appears once, in the reading region, never repeated in the list.
        expect(find.text(initialBody), findsOneWidget);
      } else {
        expect(find.text(initialBody), findsNothing);
      }
      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      Future<void> open(String id) async {
        await tap(find.byKey(ValueKey('read-petition-$id')));
        expect(find.byKey(const ValueKey('petition-details-0')), findsNothing);
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const ValueKey('confirm-petition')),
              )
              .onPressed,
          isNull,
        );
      }

      await open('a');
      final petitionOverview = find.byKey(const ValueKey('petition-overview'));
      if (inline) {
        expect(petitionOverview, findsNothing);
      } else {
        final frame = find.byKey(const ValueKey('imperial-dialog-frame'));
        expect(
          tester.getBottomLeft(petitionOverview).dy,
          lessThan(tester.getTopLeft(frame).dy),
        );
        expect(
          find.descendant(of: petitionOverview, matching: find.byType(Tooltip)),
          findsNWidgets(8),
        );
        expect(
          find.descendant(of: petitionOverview, matching: find.text('1K')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: petitionOverview,
            matching: find.text('${controller.state!.authority}'),
          ),
          findsOneWidget,
        );
        final authority = find.byKey(const ValueKey('petition-stat-authority'));
        final population = find.byKey(
          const ValueKey('petition-stat-population'),
        );
        final authorityTop = tester.getTopLeft(authority).dy;
        final populationTop = tester.getTopLeft(population).dy;
        if (size.width == 320) expect(populationTop, greaterThan(authorityTop));
        if (size.width == 390) expect(populationTop, authorityTop);
        await tap(find.byKey(const ValueKey('petition-stat-food')));
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                widget.textSpan?.toPlainText() == 'Lương thực',
          ),
          findsOneWidget,
        );
      }
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('petition-card-a')),
          matching: find.byType(ButtonStyleButton),
        ),
        findsNothing,
      );
      final event = eventForState(controller.state!, 'finance_02');
      for (var i = 0; i < event.choices.length; i++) {
        final labels = find.descendant(
          of: find.byKey(ValueKey('petition-choice-$i')),
          matching: find.byType(Text),
        );
        expect(labels, findsOneWidget);
        expect(tester.widget<Text>(labels).data, event.choices[i].label);
      }
      expect(
        find.byKey(const ValueKey('petition-expiry-warning')),
        findsOneWidget,
      );
      await tap(find.byKey(const ValueKey('petition-choice-0')));
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('petition-impact-points')))
            .data,
        '−1',
      );
      await tap(find.byKey(const ValueKey('petition-assignee')));
      await tap(find.byKey(const ValueKey('petition-person-chancellor')));
      final assignedPreview =
          tester
              .widget<Text>(
                find.byKey(const ValueKey('petition-success-chance')),
              )
              .data;
      expect(assignedPreview, isNotNull);
      // Switching choices closes the old detail and drops its selected assignee.
      await tap(find.byKey(const ValueKey('petition-choice-1')));
      expect(find.byKey(const ValueKey('petition-details-0')), findsNothing);
      expect(find.byKey(const ValueKey('petition-details-1')), findsOneWidget);
      await tap(find.byKey(const ValueKey('petition-choice-0')));
      expect(find.text('Không giao ai xử lý (mặc định)'), findsOneWidget);
      if (!inline) {
        await tap(find.text('Đọc sau'));
        expect(petitionOverview, findsNothing);
        expect(tester.getRect(overview), overviewRect);
      }
      await open('b');
      await tap(find.byKey(const ValueKey('petition-choice-0')));
      if (!inline) await tap(find.text('Đọc sau'));
      await open('a');
      expect(find.byKey(const ValueKey('petition-assignee')), findsNothing);
      expect(controller.state!.toJson(), before);
      expect((await gateway.load()).active!.toJson(), before);
      expect(tester.takeException(), isNull);
    });
  }
}
