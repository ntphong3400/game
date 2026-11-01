import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/character_meeting_page.dart';
import 'support/legacy_gateway.dart';

void viewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(844, 390),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets(
      'Ngoc Lan introduction and return preserve game state at $size',
      (tester) async {
        viewport(tester, size);
        final gateway = LocalGameGateway(MemoryGameStore());
        await gateway.start(
          name: 'An',
          runId: 'meeting-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.toJson();
        final person = controller.state!.court.firstWhere(
          (c) => c.id == 'consort_lan',
        );
        await tester.pumpWidget(
          GameApp(controller: controller, initialRoute: 'harem'),
        );
        await tester.pumpAndSettle();
        final meet = find.byKey(const ValueKey('meet-person-consort_lan'));
        await tester.ensureVisible(meet);
        await tester.tap(meet);
        await tester.pumpAndSettle();
        expect(find.byType(CharacterMeetingPage), findsOneWidget);
        expect(find.byKey(const ValueKey('harem-meeting-page')), findsNothing);
        expect(find.text(person.name), findsOneWidget);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('meeting-affection')))
              .data,
          '${person.affection}',
        );
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('meeting-ability')))
              .data,
          '${person.ability}',
        );
        final sprite = tester.widget<Image>(
          find.byKey(const ValueKey('meeting-fullbody')),
        );
        expect(sprite.fit, BoxFit.contain);
        expect(
          (sprite.image as AssetImage).assetName,
          contains('ngoc-lan-fullbody'),
        );
        // Scenery and the whole figure render in distinct layers.
        final figureRect = tester.getRect(
          find.byKey(const ValueKey('meeting-fullbody')),
        );
        final pageRect = tester.getRect(find.byType(CharacterMeetingPage));
        expect(pageRect.contains(figureRect.topLeft), isTrue);
        expect(pageRect.contains(figureRect.bottomRight), isTrue);
        expect(tester.takeException(), isNull);
        expect(find.text('GẶP GỠ'), findsNothing);
        expect(find.text('Hỏi thăm'), findsNothing);
        expect(find.text('Nghe tâm sự'), findsNothing);
        expect(
          find.byKey(const ValueKey('meeting-description')),
          findsOneWidget,
        );
        for (final id in ['audience', 'reward', 'investigate', 'invite']) {
          expect(find.byKey(ValueKey('meeting-action-$id')), findsOneWidget);
        }
        await tester.tap(find.byKey(const ValueKey('meeting-back')));
        await tester.pumpAndSettle();
        expect(find.byType(CharacterMeetingPage), findsNothing);
        expect(
          find.byKey(const ValueKey('scene-header-harem')),
          findsOneWidget,
        );
        expect(controller.state!.toJson(), before);
        expect((await gateway.load()).active!.toJson(), before);
      },
    );
  }

  testWidgets('scene content and actions can be replaced for an official', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 900));
    const first = MeetingScene(
      backgroundAsset: 'assets/images/harem-interior.webp',
      characterAsset: 'assets/images/meetings/ngoc-lan-fullbody-v1.png',
      name: 'Nguyễn Ngọc Lan',
      role: 'Tú nữ',
      age: 21,
      affection: 72,
      ability: 84,
      location: 'Cung Ngọc Hoa',
      description: 'Giới thiệu Ngọc Lan',
    );
    const second = MeetingScene(
      backgroundAsset: 'assets/images/people-interior.webp',
      // Substitute art is a fixture; no official full-body art is shipped yet.
      characterAsset: 'assets/images/portraits/official-001.webp',
      name: 'Trần Văn Chính',
      role: 'Tể tướng',
      age: 52,
      affection: 61,
      ability: 93,
      location: 'Phủ Bá Quan',
      description: 'Giới thiệu Tể tướng',
    );
    final selected = <String>[];
    Widget page(MeetingScene scene) => MaterialApp(
      home: CharacterMeetingPage(
        scene: scene,
        backLabel: 'Quay lại',
        actions: const [
          MeetingAction(
            id: 'work',
            label: 'Giao việc',
            description: 'Chọn công việc',
            costLabel: '1 hành động',
          ),
        ],
        onAction: (id) async {
          selected.add(id);
          return null;
        },
      ),
    );
    await tester.pumpWidget(page(first));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('meeting-action-work')));
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
    await tester.tap(find.byKey(const ValueKey('meeting-action-confirm')));
    await tester.pumpAndSettle();
    expect(selected, ['work']);
    expect(find.text('Giới thiệu Ngọc Lan'), findsOneWidget);
    await tester.pumpWidget(page(second));
    await tester.pumpAndSettle();
    expect(find.text('Trần Văn Chính'), findsOneWidget);
    expect(find.text('Tể tướng · 52 tuổi'), findsOneWidget);
    expect(find.text('Giới thiệu Tể tướng'), findsOneWidget);
    expect(find.text('Giới thiệu Ngọc Lan'), findsNothing);
    expect(find.text('61'), findsOneWidget);
    expect(find.text('93'), findsOneWidget);
    expect(
      (tester
                  .widget<Image>(
                    find.byKey(const ValueKey('meeting-background')),
                  )
                  .image
              as AssetImage)
          .assetName,
      second.backgroundAsset,
    );
    expect(
      (tester
                  .widget<Image>(find.byKey(const ValueKey('meeting-fullbody')))
                  .image
              as AssetImage)
          .assetName,
      second.characterAsset,
    );
    expect(tester.takeException(), isNull);
  });
}
