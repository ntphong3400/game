import 'support/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/imperial_dialog.dart';
import 'palace_test.dart' show freshPalace;

Future<GameController> showPalace(
  WidgetTester tester,
  Size size, {
  bool poor = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final store = MemoryGameStore();
  await store.update((a) {
    a.active = freshPalace()..court.removeRange(2, 4);
    if (poor) {
      a.active!.treasury = 10;
      a.active!.grain = 0;
    }
  });
  final controller = GameController(LocalGameGateway(store));
  await controller.load();
  await tester.pumpWidget(
    GameApp(initialRoute: 'court', controller: controller),
  );
  await tester.pumpAndSettle();
  await openSection(tester, 'Hậu cung');
  await tester.pumpAndSettle();
  final before = controller.state!.toJson();
  expect(find.byKey(const ValueKey('palace-panel')), findsNothing);
  await tester.tap(find.byKey(const ValueKey('open-palace-management')));
  await tester.pumpAndSettle();
  expect(controller.state!.toJson(), before);
  expect(find.byKey(const ValueKey('character-profile-true')), findsNothing);
  return controller;
}

Future<void> tapPalace(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets(
      'study and grouped duties charge one action each and survive reload at $size',
      (tester) async {
        final controller = await showPalace(tester, size);
        expect(find.text('Cung vụ & học tập'), findsOneWidget);
        expect(find.text('Kiểm kê kho nội cung'), findsNothing);
        final before = controller.state!.toJson();
        await tapPalace(
          tester,
          find.byKey(const ValueKey('open-palace-study')),
        );
        await tapPalace(
          tester,
          find.byKey(const ValueKey('palace-person-wife-0')),
        );
        expect(find.text('20 tiền · 1 hành động · 2 mùa'), findsOneWidget);
        await tapPalace(tester, find.text('Hủy'));
        expect(controller.state!.toJson(), before);

        await tapPalace(
          tester,
          find.byKey(const ValueKey('open-palace-study')),
        );
        await tapPalace(
          tester,
          find.byKey(const ValueKey('palace-person-wife-0')),
        );
        await tapPalace(
          tester,
          find.byKey(const ValueKey('confirm-palace-study')),
        );
        expect(controller.state!.points, 11);
        expect(controller.state!.treasury, 980);
        expect(
          find.byKey(const ValueKey('palace-active-wife-0')),
          findsOneWidget,
        );

        await tapPalace(
          tester,
          find.byKey(const ValueKey('open-palace-duties')),
        );
        await tapPalace(
          tester,
          find.byKey(const ValueKey('palace-group-Chi tiêu')),
        );
        await tapPalace(
          tester,
          find.byKey(const ValueKey('palace-duty-wardrobe')),
        );
        final busy = tester.widget<ImperialDialogOption>(
          find.byKey(const ValueKey('palace-person-wife-0')),
        );
        expect(busy.onPressed, isNull);
        await tapPalace(
          tester,
          find.byKey(const ValueKey('palace-person-wife-1')),
        );
        expect(
          find.textContaining('8 tiền · 1 hành động · 1 mùa'),
          findsOneWidget,
        );
        await tapPalace(
          tester,
          find.byKey(const ValueKey('confirm-palace-duty')),
        );
        expect(controller.state!.points, 10);
        expect(controller.state!.treasury, 972);
        expect(controller.state!.palaceWorks, hasLength(2));
        await controller.load();
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('palace-active-wife-1')),
          findsOneWidget,
        );
        expect(controller.state!.palaceWorks, hasLength(2));

        for (var i = 0; i < 2; i++) {
          // No UI confirmation is bypassed for assigning work; this only advances time.
          await controller.act('endWeek');
          await tester.pumpAndSettle();
        }
        expect(controller.state!.court.first.palaceCoursesCompleted, 1);
        expect(controller.state!.palaceWorks, isEmpty);
        expect(find.text('Kết quả gần đây'), findsOneWidget);
        await tapPalace(tester, find.text('Kết quả gần đây'));
        expect(find.textContaining('Hoàn thành khóa học'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'insufficient money and grain disable confirmation without mutations at $size',
      (tester) async {
        final controller = await showPalace(tester, size, poor: true);
        final before = controller.state!.toJson();
        await tapPalace(
          tester,
          find.byKey(const ValueKey('open-palace-duties')),
        );
        await tapPalace(
          tester,
          find.byKey(const ValueKey('palace-group-Dân sinh')),
        );
        await tapPalace(
          tester,
          find.byKey(const ValueKey('palace-duty-charity')),
        );
        await tapPalace(
          tester,
          find.byKey(const ValueKey('palace-person-wife-0')),
        );
        final confirm = tester.widget<FilledButton>(
          find.byKey(const ValueKey('confirm-palace-duty')),
        );
        expect(confirm.onPressed, isNull);
        expect(
          find.text('Chưa đủ tiền, thóc hoặc 1 hành động.'),
          findsOneWidget,
        );
        await tapPalace(tester, find.text('Hủy'));
        expect(controller.state!.toJson(), before);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
