import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/web_game_hud.dart';

Future<GameController> mount(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final gateway = LocalGameGateway(MemoryGameStore());
  await gateway.start(
    name: 'An',
    runId: 'context-hud',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  final controller = GameController(gateway);
  await controller.load();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    GameApp(controller: controller, initialRoute: 'citadel'),
  );
  await tester.pumpAndSettle();
  return controller;
}

GoRouter routerOf(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(GameShell)));

Future<void> tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets(
      'all pages share a season-only top bar and one back link at $size',
      (tester) async {
        final controller = await mount(tester, size);
        final before = controller.state!.toJson();
        final router = routerOf(tester);
        const counters = [
          'treasury',
          'population',
          'food',
          'military',
          'people',
          'authority',
          'health',
          'stability',
        ];
        const screens = {
          '/citadel': 'Giang Sơn',
          '/capital': 'Kinh Thành',
          '/court': 'Triều chính',
          '/treasury': 'Ngân khố',
          '/people': 'Triều thần',
          '/people/government': 'Bộ máy triều đình',
          '/harem': 'Hậu cung',
          '/harem/management': 'Học tập & cung vụ',
          '/health': 'Long thể',
          '/journal': 'Sử quán',
          '/scores': 'Vọng Thiên Các',
          '/population': 'Dân cư & Lao động',
          '/military': 'Quân sự',
          '/locality': 'Địa phương',
          '/locality/administration': 'Phủ nha',
          '/locality/agriculture': 'Đồng ruộng',
          '/locality/village': 'Thôn làng',
          '/frontier/north': 'Bắc Ải',
          '/frontier/north/camp': 'Doanh Trại',
          '/country/north': 'Hàn Kỳ',
          '/country/north/embassy': 'Sứ quán',
        };
        for (final entry in screens.entries) {
          router.go(entry.key);
          await tester.pumpAndSettle();
          expect(find.byType(WebGameHud), findsOneWidget);
          expect(
            tester
                .widget<Text>(find.byKey(const ValueKey('hud-page-title')))
                .data,
            entry.value,
          );
          expect(
            find.byKey(const ValueKey('section-back')),
            entry.key == '/citadel' ? findsNothing : findsOneWidget,
          );
          for (final counter in counters) {
            expect(
              find.byKey(ValueKey('web-hud-stat-$counter')),
              findsNothing,
              reason: entry.key,
            );
          }
          for (final key in [
            'capital-back',
            'locality-back',
            'frontier-back',
            'country-back',
            'harem-back-to-capital',
            'back-to-harem',
            'court-government-back',
            'locality-personnel-back',
            'locality-detail-back',
            'frontier-detail-back',
            'country-detail-back',
          ]) {
            expect(find.byKey(ValueKey(key)), findsNothing);
          }
          expect(find.byType(Drawer), findsNothing);
          expect(find.byType(NavigationRail), findsNothing);
          expect(find.byTooltip('Mở danh mục'), findsNothing);
          expect(tester.takeException(), isNull, reason: entry.key);
        }
        expect(controller.state!.toJson(), before);
      },
    );

    testWidgets('map entrances and back buttons preserve navigation at $size', (
      tester,
    ) async {
      final controller = await mount(tester, size);
      final before = controller.state!.toJson();
      final router = routerOf(tester);
      await tap(tester, 'giang-son-palace');
      await tap(tester, 'citadel-location-court');
      await tap(tester, 'court-affairs');
      expect(router.routeInformationProvider.value.uri.path, '/kingdom');
      await tap(tester, 'section-back');
      expect(router.routeInformationProvider.value.uri.path, '/court');
      await tap(tester, 'section-back');
      expect(router.routeInformationProvider.value.uri.path, '/capital');
      await tap(tester, 'citadel-location-harem');
      await tap(tester, 'section-back');
      expect(router.routeInformationProvider.value.uri.path, '/capital');
      await tap(tester, 'section-back');
      router.go('/military');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/military');
      await tap(tester, 'section-back');
      expect(router.routeInformationProvider.value.uri.path, '/citadel');
      expect(controller.state!.toJson(), before);
      expect(tester.takeException(), isNull);
    });

    testWidgets('meetings have one top back link to their roster at $size', (
      tester,
    ) async {
      final controller = await mount(tester, size);
      final before = controller.state!.toJson();
      final router = routerOf(tester);
      for (final id in ['war-minister', 'consort_lan']) {
        final person = controller.state!.court.firstWhere((p) => p.id == id);
        final section = person.isConsort ? 'harem' : 'people';
        router.go('/$section/meet/${person.publicId}');
        await tester.pumpAndSettle();
        expect(find.byType(WebGameHud), findsOneWidget);
        expect(find.byKey(const ValueKey('hud-page-title')), findsOneWidget);
        expect(find.byType(Drawer), findsNothing);
        expect(
          find.byKey(const ValueKey('meeting-action-audience')),
          findsOneWidget,
        );
        expect(find.textContaining('1 hành động'), findsWidgets);
        await tap(tester, 'meeting-back');
        expect(router.routeInformationProvider.value.uri.path, '/$section');
        expect(find.byKey(const ValueKey('section-back')), findsOneWidget);
      }
      expect(controller.state!.toJson(), before);
      expect(tester.takeException(), isNull);
    });
  }
}
