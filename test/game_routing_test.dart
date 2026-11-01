import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/game_routes.dart';
import 'package:van_tue/game/presentation/widgets/character_meeting_page.dart';
import 'package:van_tue/game/presentation/widgets/court_government_panel.dart';
import 'package:van_tue/game/presentation/widgets/palace_panel.dart';

Future<GameController> savedController({bool load = true}) async {
  final gateway = LocalGameGateway(MemoryGameStore());
  await gateway.start(
    name: 'An',
    runId: 'routing',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  final controller = GameController(gateway);
  if (load) await controller.load();
  addTearDown(controller.dispose);
  return controller;
}

GoRouter routerOf(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(GameShell)));

void initialUrl(WidgetTester tester, String path) {
  tester.platformDispatcher.defaultRouteNameTestValue = path;
  addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  test(
    'every section has one unique URL and round trips to its internal key',
    () {
      expect(
        GameLocation.sectionPaths.values.toSet().length,
        GameLocation.sectionPaths.length,
      );
      for (final entry in GameLocation.sectionPaths.entries) {
        final location = GameLocation.parse(Uri.parse(entry.value))!;
        expect(location.section, entry.key);
        expect(location.uri.path, entry.value);
      }
      for (final section in ['people', 'harem']) {
        final location = GameLocation(
          section,
          characterId: 'id with dấu',
          returnTo: '/locality/administration',
        );
        final parsed = GameLocation.parse(location.uri)!;
        expect(parsed.characterId, 'id with dấu');
        expect(parsed.backPath, '/locality/administration');
      }
      expect(GameLocation.parse(Uri.parse('/country/invalid')), isNull);
      expect(GameLocation.parse(Uri.parse('/locality/invalid')), isNull);
      expect(
        GameLocation.parse(Uri.parse('/people/meet/treasurer/'))!.characterId,
        'treasurer',
      );
      expect(
        GameLocation.parse(
          Uri.parse('/harem?from=https://example.com'),
        )!.returnTo,
        isNull,
      );
      expect(
        GameLocation.afterStart(
          Uri.parse('/?continue=https://example.com/people'),
        ),
        '/citadel',
      );
    },
  );

  testWidgets('base URL remains the introduction with an existing save', (
    tester,
  ) async {
    initialUrl(tester, '/');
    final controller = await savedController();
    await tester.pumpWidget(GameApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('Bắt đầu trị vì   →'), findsOneWidget);
    expect(routerOf(tester).routeInformationProvider.value.uri.path, '/');
    await tester.tap(find.textContaining('Tiếp tục ·'));
    await tester.pumpAndSettle();
    expect(
      routerOf(tester).routeInformationProvider.value.uri.path,
      '/citadel',
    );
    expect(find.byKey(const ValueKey('giang-son-map')), findsOneWidget);
  });

  for (final section in ['people', 'harem']) {
    final id = section == 'harem' ? 'consort_lan' : 'treasurer';
    testWidgets(
      '$section character deep link waits for the saved game and can return',
      (tester) async {
        final updates = <Map<dynamic, dynamic>>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation,
          (call) async {
            if (call.method == 'routeInformationUpdated') {
              updates.add(call.arguments as Map);
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.navigation,
            null,
          ),
        );
        initialUrl(tester, '/$section/meet/$id');
        final controller = await savedController(load: false);
        await tester.pumpWidget(GameApp(controller: controller));
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsWidgets);
        expect(
          routerOf(tester).routeInformationProvider.value.uri.path,
          '/$section/meet/$id',
        );
        await controller.load();
        await tester.pumpAndSettle();
        final before = controller.state!.toJson();
        final publicId =
            controller.state!.court.firstWhere((p) => p.id == id).publicId!;
        expect(
          routerOf(tester).routeInformationProvider.value.uri.path,
          '/$section/meet/$publicId',
        );
        expect(
          updates.lastWhere(
            (u) => u['uri'] == '/$section/meet/$publicId',
          )['replace'],
          isTrue,
          reason: 'Canonicalizing the loaded alias must not add history',
        );
        expect(find.byType(CharacterMeetingPage), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('meeting-back')));
        await tester.pumpAndSettle();
        expect(
          routerOf(tester).routeInformationProvider.value.uri.path,
          '/$section',
        );
        expect(find.byType(CharacterMeetingPage), findsNothing);
        expect(controller.state!.toJson(), before);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('$section UUID opens directly and is used by roster links', (
      tester,
    ) async {
      final controller = await savedController();
      final person = controller.state!.court.firstWhere((p) => p.id == id);
      final path = '/$section/meet/${person.publicId}';
      initialUrl(tester, path);
      await tester.pumpWidget(GameApp(controller: controller));
      await tester.pumpAndSettle();
      final before = controller.state!.toJson();
      expect(find.byType(CharacterMeetingPage), findsOneWidget);
      expect(routerOf(tester).routeInformationProvider.value.uri.path, path);
      await tester.tap(find.byKey(const ValueKey('meeting-back')));
      await tester.pumpAndSettle();
      final meet = find.byKey(ValueKey('meet-person-$id'));
      await tester.ensureVisible(meet);
      await tester.tap(meet);
      await tester.pumpAndSettle();
      expect(routerOf(tester).routeInformationProvider.value.uri.path, path);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(GameApp(controller: controller));
      await tester.pumpAndSettle();
      expect(find.byType(CharacterMeetingPage), findsOneWidget);
      expect(routerOf(tester).routeInformationProvider.value.uri.path, path);
      expect(controller.state!.toJson(), before);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'subpages open directly and router navigation does not mutate the save',
    (tester) async {
      initialUrl(tester, '/people/government');
      final controller = await savedController();
      await tester.pumpWidget(GameApp(controller: controller));
      await tester.pumpAndSettle();
      final before = controller.state!.toJson();
      final router = routerOf(tester);
      expect(find.byType(CourtGovernmentPanel), findsOneWidget);
      router.go('/harem/management');
      await tester.pumpAndSettle();
      expect(find.byType(PalacePanel), findsOneWidget);
      for (final path in [
        '/locality/granary',
        '/frontier/north/gate',
        '/country/west/embassy',
        '/treasury',
        '/journal',
      ]) {
        router.go(path);
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, path);
        expect(find.text('Không tìm thấy trang này.'), findsNothing);
        expect(tester.takeException(), isNull);
      }
      expect(controller.state!.toJson(), before);
    },
  );

  testWidgets('a regional character URL restores its origin after remounting', (
    tester,
  ) async {
    initialUrl(
      tester,
      '/people/meet/treasurer?from=%2Flocality%2Fadministration',
    );
    final controller = await savedController();
    await tester.pumpWidget(GameApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('Phủ nha'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('meeting-back')));
    await tester.pumpAndSettle();
    expect(
      routerOf(tester).routeInformationProvider.value.uri.path,
      '/locality/administration',
    );
    expect(
      find.byKey(const ValueKey('locality-panel-administration')),
      findsOneWidget,
    );
  });

  testWidgets(
    'no save returns to intro and resumes the requested page after starting',
    (tester) async {
      initialUrl(tester, '/locality/commerce');
      final controller = GameController(LocalGameGateway(MemoryGameStore()));
      addTearDown(controller.dispose);
      await controller.load();
      await tester.pumpWidget(GameApp(controller: controller));
      await tester.pumpAndSettle();
      expect(routerOf(tester).routeInformationProvider.value.uri.path, '/');
      expect(
        routerOf(
          tester,
        ).routeInformationProvider.value.uri.queryParameters['continue'],
        '/locality/commerce',
      );
      await tester.tap(find.text('Bắt đầu trị vì   →'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'An');
      await tester.tap(find.text('Nhận ngọc tỷ'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        routerOf(tester).routeInformationProvider.value.uri.path,
        '/locality/commerce',
      );
      expect(
        find.byKey(const ValueKey('locality-panel-commerce')),
        findsOneWidget,
      );
    },
  );

  testWidgets('missing and wrong-roster characters resolve safely', (
    tester,
  ) async {
    initialUrl(tester, '/people/meet/consort_lan');
    final controller = await savedController();
    await tester.pumpWidget(GameApp(controller: controller));
    await tester.pumpAndSettle();
    final router = routerOf(tester);
    expect(
      router.routeInformationProvider.value.uri.path,
      '/harem/meet/${controller.state!.court.firstWhere((p) => p.id == 'consort_lan').publicId}',
    );
    expect(find.byType(CharacterMeetingPage), findsOneWidget);
    router.go('/people/meet/nonexistent');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/people');
    expect(find.byType(CharacterMeetingPage), findsNothing);
    router.go('/people/meet/550e8400-e29b-41d4-a716-446655440000');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/people');
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown routes show a recoverable not-found screen', (
    tester,
  ) async {
    initialUrl(tester, '/not-a-page');
    final controller = await savedController();
    await tester.pumpWidget(GameApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy trang này.'), findsOneWidget);
    await tester.tap(find.text('Về trang giới thiệu'));
    await tester.pumpAndSettle();
    expect(routerOf(tester).routeInformationProvider.value.uri.path, '/');
  });

  testWidgets('changing the URL dismisses the old page dialog', (tester) async {
    initialUrl(tester, '/');
    final controller = await savedController();
    await tester.pumpWidget(GameApp(controller: controller));
    await tester.pumpAndSettle();
    final router = routerOf(tester);
    await tester.tap(find.text('Bắt đầu trị vì   →'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsOneWidget);
    router.go('/scores');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TextFormField), findsNothing);
    expect(router.routeInformationProvider.value.uri.path, '/scores');
    expect(tester.takeException(), isNull);
  });
}
