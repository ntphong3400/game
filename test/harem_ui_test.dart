import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/capital_hub.dart';
import 'package:van_tue/game/presentation/widgets/imperial_widgets.dart';

void main() {
  for (final seasonal in [true, false]) {
    for (final size in [
      const Size(1440, 1000),
      const Size(1024, 768),
      const Size(844, 390),
      const Size(390, 844),
      const Size(320, 568),
    ]) {
      testWidgets(
        'harem portraits, full-body meeting and capital return at $size seasonal=$seasonal',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final store = MemoryGameStore();
          final gateway = LocalGameGateway(store, seasonal: seasonal);
          await gateway.start(
            name: 'An',
            runId: 'harem-ui',
            seed: 42,
            previousRunId: null,
            previousRevision: null,
          );
          await store.update((a) {
            final s = a.active!;
            final c = s.court.firstWhere((c) => c.id == 'consort_mai');
            c.ability = 91;
            c.affection = 96;
          });
          final controller = GameController(gateway);
          await controller.load();
          addTearDown(controller.dispose);
          final before = controller.state!.toJson();
          await tester.pumpWidget(
            GameApp(initialRoute: 'capital', controller: controller),
          );
          await tester.pumpAndSettle();
          final entrance = find.byKey(const ValueKey('citadel-location-harem'));
          await Scrollable.ensureVisible(
            tester.element(entrance),
            alignment: .5,
          );
          await tester.tap(entrance);
          await tester.pumpAndSettle();
          expect(find.byType(NavigationRail), findsNothing);
          expect(find.byType(Drawer), findsNothing);
          expect(find.byTooltip('Mở danh mục'), findsNothing);
          expect(
            find.byKey(const ValueKey('people-search-true')),
            findsNothing,
          );
          expect(find.byKey(const ValueKey('roster-cards-true')), findsNothing);
          expect(find.byKey(const ValueKey('roster-list-true')), findsNothing);
          expect(
            find.byKey(const ValueKey('character-profile-true')),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('catalog-true-Tú nữ')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('faction-filter-true')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('availability-filter-true')),
            findsOneWidget,
          );

          final consorts =
              controller.state!.court
                  .where((c) => c.available && c.isConsort)
                  .toList();
          final cardHeight =
              tester
                  .getSize(
                    find.byKey(ValueKey('select-person-${consorts.first.id}')),
                  )
                  .height;
          for (final c in consorts) {
            final item = find.byKey(ValueKey('select-person-${c.id}'));
            expect(item, findsOneWidget);
            expect(tester.getSize(item).height, closeTo(cardHeight, .01));
            final avatar = find.descendant(
              of: item,
              matching: find.byType(CharacterPortrait),
            );
            final avatarSize = tester.getSize(avatar);
            expect(avatarSize.width, closeTo(avatarSize.height, .01));
            final status = find.byKey(ValueKey('roster-status-${c.id}'));
            final action = find.byKey(ValueKey('meet-person-${c.id}'));
            final name = find.descendant(of: item, matching: find.text(c.name));
            expect(
              tester.getTopLeft(status).dy - tester.getBottomLeft(avatar).dy,
              closeTo(8, .01),
            );
            expect(
              tester.getBottomLeft(status).dy,
              lessThan(tester.getTopLeft(name).dy),
            );
            expect(
              tester.getBottomLeft(item).dy - tester.getBottomLeft(action).dy,
              closeTo(16, .01),
            );
          }
          expect(find.byTooltip('Trang trước'), findsNothing);
          expect(find.byTooltip('Trang sau'), findsNothing);

          // The two measures belong to each portrait, with no profile actions.
          const personId = 'consort_mai';
          final portrait = find.byKey(
            const ValueKey('select-person-$personId'),
          );
          expect(
            find.descendant(of: portrait, matching: find.text('Thiện cảm 96')),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: portrait,
              matching: find.byKey(const ValueKey('harem-ability-consort_mai')),
            ),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('profile-action-$personId-audience')),
            findsNothing,
          );
          final meet = find.descendant(
            of: portrait,
            matching: find.text(
              controller.state!.court.firstWhere((c) => c.id == personId).name,
            ),
          );
          await tester.ensureVisible(meet);
          await tester.tap(meet);
          await tester.pumpAndSettle();
          final page = find.byKey(const ValueKey('character-meeting-page'));
          expect(page, findsOneWidget);
          expect(
            find.byKey(const ValueKey('meeting-action-cut-office')),
            findsNothing,
          );
          final sprite = tester.widget<Image>(
            find.byKey(const ValueKey('meeting-fullbody')),
          );
          expect(
            (sprite.image as AssetImage).assetName,
            'assets/images/meetings/thanh-mai-fullbody-v2.png',
          );
          expect(
            (tester
                        .widget<Image>(
                          find.byKey(const ValueKey('meeting-background')),
                        )
                        .image
                    as AssetImage)
                .assetName,
            'assets/images/harem-interior.webp',
          );
          expect(find.byType(AlertDialog), findsNothing);
          expect(find.text('Đặng Thanh Mai'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('meeting-action-invite')),
            findsOneWidget,
          );
          expect(controller.state!.toJson(), before);
          expect(tester.takeException(), isNull);
          await tester.tap(find.byKey(const ValueKey('meeting-back')));
          await tester.pumpAndSettle();
          expect(page, findsNothing);
          expect(portrait, findsOneWidget);
          expect(
            find.byKey(const ValueKey('character-profile-true')),
            findsNothing,
          );

          final back = find.byKey(const ValueKey('section-back'));
          await tester.ensureVisible(back);
          await tester.tap(back);
          await tester.pumpAndSettle();
          expect(find.byType(CapitalHub), findsOneWidget);
          expect(controller.state!.toJson(), before);
          expect((await gateway.load()).active!.toJson(), before);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
