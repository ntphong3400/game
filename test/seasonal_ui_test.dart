import 'support/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';

void main() {
  testWidgets('scoreboard opens without an active reign', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = GameController(LocalGameGateway(MemoryGameStore()));
    await controller.load();
    await tester.pumpWidget(
      GameApp(initialRoute: 'court', controller: controller),
    );
    await tester.pumpAndSettle();
    final scores = find.byTooltip('Bảng xếp hạng');
    await tester.tap(scores);
    await tester.pumpAndSettle();
    expect(find.text('Những triều đại dài nhất'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets(
      'seasonal dashboard, focused national affairs, all opening petitions work at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final gateway = LocalGameGateway(MemoryGameStore());
        await gateway.start(
          name: 'An',
          runId: 'seasons-ui',
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
        expect(find.text('Mùa Xuân'), findsOneWidget);
        expect(find.text('Thiên Hòa · năm 1'), findsOneWidget);
        expect(find.text('Năm trị vì 1 · 18 tuổi'), findsNothing);
        expect(find.text('12 hành động còn lại'), findsOneWidget);
        expect(find.textContaining('4–6 tấu chương'), findsNothing);
        expect(
          controller.state!.petitions,
          hasLength(controller.state!.seasonPetitionTarget),
        );
        expect(find.textContaining('thêm tin sau'), findsNothing);
        expect(find.textContaining('Một tuần mới'), findsNothing);
        expect(find.text('Tấu chương mùa Xuân'), findsOneWidget);
        expect(find.byKey(const ValueKey('neglect-warning')), findsNothing);
        await openSection(tester, 'kingdom');
        await tester.pumpAndSettle();
        for (final title in [
          'Ban hành công việc',
          'Đang thực hiện',
          'Nghĩa vụ và ảnh hưởng đang hiệu lực',
          'Đối sách khẩn cấp',
          'Kết quả đã nhận',
        ]) {
          final section = find.text(title);
          expect(section, findsOneWidget);
        }
        expect(find.textContaining('Thế cục'), findsNothing);
        expect(find.textContaining('Đại biến cố'), findsNothing);
        expect(find.textContaining('Chuỗi tấu chương'), findsNothing);
        expect(find.text('Luật thế cục'), findsNothing);
        expect(tester.takeException(), isNull);
        await openSection(tester, 'treasury');
        await tester.pumpAndSettle();
        for (final title in [
          'Việc tăng thu',
          'Thuế & ngân sách',
          'Kho lương & đê điều',
          'Sổ ngân khố',
        ]) {
          final section = find.text(title);
          expect(section, findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        final before = controller.state!;
        final initial = before.petitions.length;
        final target = before.seasonPetitionTarget;
        expect(target, inInclusiveRange(4, 6));
        // Real commands pass through the controller/store as they do in UI.
        for (var i = 0; i < 6; i++) {
          await controller.act('action', target: 'rest');
          await tester.pumpAndSettle();
        }
        expect(controller.state!.midSeasonDelivered, true);
        expect(controller.state!.petitions.length, target);
        expect(initial, target);
        expect(find.text('6 hành động còn lại'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(
          (await gateway.load()).active!.toJson(),
          controller.state!.toJson(),
        );
      },
    );
  }
}
