import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/logic/game_gateway.dart' as current;
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/citadel_hub.dart';
import 'package:van_tue/game/presentation/widgets/capital_hub.dart';
import 'package:van_tue/game/presentation/widgets/locality_hub.dart';

Future<GameController> _controller({bool seasonal = true}) async {
  final gateway = LocalGameGateway(MemoryGameStore(), seasonal: seasonal);
  await gateway.start(
    name: 'Hoàng đế Thiên Hòa Trường An',
    runId: 'citadel',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  final controller = GameController(gateway);
  await controller.load();
  return controller;
}

void _viewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(1024, 768),
    const Size(844, 390),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets(
      'Giang Sơn landmarks and palace navigate without changing state at $size',
      (tester) async {
        _viewport(tester, size);
        final controller = await _controller();
        final before = controller.state!.toJson();
        final routes = <String>[];
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CitadelHub(
                state: controller.state!,
                busy: false,
                onNavigate: routes.add,
                onEndTurn: () {},
                onOvertime: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey('giang-son-capital')), findsNothing);
        expect(find.text('Kinh thành'), findsOneWidget);
        expect(find.text('Địa phương'), findsOneWidget);
        final capital = find.byKey(const ValueKey('giang-son-palace'));
        final locality = find.byKey(const ValueKey('giang-son-farms'));
        expect(tester.getSize(capital), tester.getSize(locality));
        expect(tester.getSize(capital).height, greaterThanOrEqualTo(62));
        expect(
          tester.getCenter(find.text('Kinh thành')).dy,
          closeTo(tester.getCenter(find.text('Địa phương')).dy, 0.1),
        );
        final count = controller.state!.petitions.length;
        expect(
          find.descendant(
            of: capital,
            matching: find.text(size.width >= 484 ? '$count tấu sớ' : '$count'),
          ),
          findsOneWidget,
        );
        await tester.ensureVisible(capital);
        await tester.tap(capital);
        await tester.pumpAndSettle();
        expect(routes.last, 'capital');
        expect(find.byType(BottomSheet), findsNothing);
        expect(find.byKey(const ValueKey('nav-citadel')), findsNothing);
        expect(find.byKey(const ValueKey('nav-scores')), findsNothing);
        final artwork = <ImageProvider>{};
        for (final (region, destinations) in [
          ('interior', [('palace', 'capital'), ('farms', 'locality')]),
          (
            'frontier',
            [
              ('north-pass', 'kingdom'),
              ('west-pass', 'kingdom'),
              ('south-pass', 'kingdom'),
            ],
          ),
          (
            'neighbors',
            [
              ('north', 'country-north'),
              ('west', 'country-west'),
              ('south', 'country-south'),
            ],
          ),
        ]) {
          if (region != 'interior') {
            await tester.tap(find.byKey(ValueKey('giang-son-region-$region')));
            await tester.pumpAndSettle();
          }
          final first = find.byKey(
            ValueKey('giang-son-${destinations.first.$1}'),
          );
          for (final (landmark, route) in destinations) {
            final target = find.byKey(ValueKey('giang-son-$landmark'));
            expect(tester.getSize(target), tester.getSize(first));
            expect(tester.getTopLeft(target).dy, tester.getTopLeft(first).dy);
            final thumbnail = find.descendant(
              of: target,
              matching: find.byType(Image),
            );
            expect(artwork.add(tester.widget<Image>(thumbnail).image), isTrue);
            if (region != 'interior' && size.width <= 390) {
              final label = find.descendant(
                of: target,
                matching: find.byType(Text),
              );
              expect(
                tester.getBottomRight(thumbnail).dy,
                lessThan(tester.getTopLeft(label).dy),
              );
            }
            await tester.ensureVisible(target);
            await tester.tap(target);
            await tester.pumpAndSettle();
            expect(routes.last, route);
            expect(tester.takeException(), isNull);
          }
        }
        final end = find.byKey(const ValueKey('citadel-end-turn'));
        expect(find.text('Khóa mùa'), findsOneWidget);
        expect(tester.getBottomRight(end).dx, closeTo(size.width - 16, 1));
        expect(
          tester.getBottomRight(end).dy,
          closeTo(
            tester
                    .getTopLeft(find.byKey(const ValueKey('giang-son-regions')))
                    .dy -
                12,
            1,
          ),
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('giang-son-map')),
            matching: find.byType(OutlinedButton),
          ),
          findsNothing,
        );
        expect(controller.state!.toJson(), before);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final (size, singleRow) in [
    (const Size(1440, 900), true),
    (const Size(1024, 768), true),
    (const Size(844, 390), false),
    (const Size(390, 844), false),
    (const Size(320, 568), false),
  ]) {
    testWidgets('capital opens all destinations and returns at $size', (
      tester,
    ) async {
      _viewport(tester, size);
      final controller = await _controller();
      final before = controller.state!.toJson();
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'citadel'),
      );
      await tester.pumpAndSettle();
      const destinations = [
        ('court', 'Điện Vĩnh An'),
        ('treasury', 'Ngân khố'),
        ('people', 'Phủ Bá Quan'),
        ('harem', 'Cung Ngọc Hoa'),
        ('health', 'Điện Dưỡng Tâm'),
        ('journal', 'Viện Quốc Sử'),
        ('scores', 'Vọng Thiên Các'),
      ];
      for (final (route, label) in destinations) {
        await tester.ensureVisible(
          find.byKey(const ValueKey('giang-son-palace')),
        );
        await tester.tap(find.byKey(const ValueKey('giang-son-palace')));
        await tester.pumpAndSettle();
        expect(find.byType(CapitalHub), findsOneWidget);
        if (route == 'court') {
          expect(find.text('Kinh Thành'), findsOneWidget);
          expect(find.text('KINH THÀNH'), findsNothing);
          final court = tester.getRect(
            find.byKey(const ValueKey('citadel-location-court')),
          );
          for (final (id, _) in destinations) {
            final card = find.byKey(ValueKey('citadel-location-$id'));
            expect(card.hitTestable(), findsOneWidget);
            final rect = tester.getRect(card);
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(size.width + .01));
            expect(rect.bottom, lessThanOrEqualTo(size.height));
            if (singleRow) {
              expect(rect.top, court.top);
              expect(rect.width, closeTo(court.width, .01));
              expect(size.height - rect.bottom, closeTo(10, .01));
              if (id == 'court') expect(rect.left, closeTo(10, .01));
              if (id == 'scores')
                expect(size.width - rect.right, closeTo(10, .01));
            } else if (id != 'court') {
              expect(rect.top, greaterThan(court.bottom));
              expect(rect.width, lessThan(court.width));
            }
          }
        }
        expect(find.text('Khóa mùa'), findsNothing);
        expect(find.byType(BottomSheet), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(ValueKey('citadel-location-$route')),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
        expect(find.text('Quốc sự'), findsNothing);
        expect(
          find.byKey(const ValueKey('citadel-location-kingdom')),
          findsNothing,
        );
        final location = find.byKey(ValueKey('citadel-location-$route'));
        await tester.tap(location);
        await tester.pumpAndSettle();
        expect(find.byType(CapitalHub), findsNothing);
        expect(find.textContaining('Khép lại mùa'), findsNothing);
        expect(find.text('Khóa mùa'), findsNothing);
        expect(tester.takeException(), isNull);
        if (route == 'scores') {
          await tester.ensureVisible(find.text('Tiếp tục trị vì'));
          await tester.tap(find.text('Tiếp tục trị vì'));
        } else {
          final back = find.byKey(const ValueKey('section-back'));
          await tester.ensureVisible(back);
          await tester.tap(back);
          await tester.pumpAndSettle();
          expect(find.byType(CapitalHub), findsOneWidget);
          expect(find.text('Khóa mùa'), findsNothing);
          await tester.tap(find.byKey(const ValueKey('section-back')));
        }
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const ValueKey('giang-son-palace')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('section-back')));
      await tester.pumpAndSettle();
      expect(find.byType(CitadelHub), findsOneWidget);
      expect(controller.state!.toJson(), before);
      expect((await controller.gateway.load()).active!.toJson(), before);
      expect(tester.takeException(), isNull);
    });
  }

  for (final seasonal in [true, false]) {
    testWidgets(
      'existing ${seasonal ? 'seasonal' : 'weekly'} save opens locality and returns to citadel',
      (tester) async {
        _viewport(tester, const Size(1440, 900));
        final controller = await _controller(seasonal: seasonal);
        final before = controller.state!.toJson();
        await tester.pumpWidget(
          GameApp(controller: controller, initialRoute: 'citadel'),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CitadelHub), findsOneWidget);
        expect(
          find.text('Còn ${controller.state!.points} hành động'),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('giang-son-farms')));
        await tester.pumpAndSettle();
        expect(find.byType(LocalityHub), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('section-back')));
        await tester.pumpAndSettle();
        expect(find.byType(CitadelHub), findsOneWidget);
        expect(controller.state!.toJson(), before);
        expect((await controller.gateway.load()).active!.toJson(), before);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'current reign opens local and border routes without spending actions',
    (tester) async {
      _viewport(tester, const Size(1440, 900));
      final gateway = current.LocalGameGateway(MemoryGameStore());
      await gateway.start(
        name: 'Thiên Hòa',
        runId: 'giang-son-current',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      final controller = GameController(gateway);
      await controller.load();
      final before = controller.state!.toJson();
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'citadel'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('giang-son-region-neighbors')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hàn Kỳ'), findsOneWidget);
      expect(find.text('Xích Lĩnh'), findsOneWidget);
      expect(find.text('Bích Trạch'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('giang-son-region-interior')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('giang-son-farms')));
      await tester.pumpAndSettle();
      expect(find.byType(LocalityHub), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('section-back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('giang-son-region-frontier')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('giang-son-north-pass')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('frontier-page')), findsOneWidget);
      expect(find.text('Bắc Ải'), findsOneWidget);
      expect(controller.state!.toJson(), before);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'end season keeps the existing expiry confirmation and does not spend actions when cancelled',
    (tester) async {
      _viewport(tester, const Size(1440, 900));
      final controller = await _controller();
      controller.state!.petitions.first.deadline = controller.state!.week;
      final before = controller.state!.toJson();
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'citadel'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('citadel-end-turn')));
      await tester.pumpAndSettle();
      expect(find.text('Còn tấu chương tới hạn'), findsOneWidget);
      await tester.tap(find.text('Quay lại xử lý'));
      await tester.pumpAndSettle();
      expect(controller.state!.toJson(), before);
      expect(find.byType(CitadelHub), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('closing a season from citadel persists exactly one turn', (
    tester,
  ) async {
    _viewport(tester, const Size(1440, 900));
    final controller = await _controller();
    await (controller.gateway as LocalGameGateway).store.update((archive) {
      archive.active!.petitions.clear();
      archive.active!.affairsThisWeek = 1;
    });
    await controller.load();
    final before = controller.state!.completedWeeks;
    await tester.pumpWidget(
      GameApp(controller: controller, initialRoute: 'citadel'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('citadel-end-turn')));
    await tester.pumpAndSettle();
    expect(controller.state!.completedWeeks, before + 1);
    expect(
      (await controller.gateway.load()).active!.toJson(),
      controller.state!.toJson(),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'continue from the scoreboard returns to citadel without a command',
    (tester) async {
      _viewport(tester, const Size(1440, 900));
      final controller = await _controller();
      final before = controller.state!.toJson();
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'citadel'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('giang-son-palace')));
      await tester.pumpAndSettle();
      final scores = find.byKey(const ValueKey('citadel-location-scores'));
      await tester.ensureVisible(scores);
      await tester.tap(scores);
      await tester.pumpAndSettle();
      final resume = find.text('Tiếp tục trị vì');
      await tester.ensureVisible(resume);
      await tester.tap(resume);
      await tester.pumpAndSettle();
      expect(find.byType(CitadelHub), findsOneWidget);
      expect(controller.state!.toJson(), before);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('end turn and overtime are disabled while saving', (
    tester,
  ) async {
    _viewport(tester, const Size(844, 390));
    final controller = await _controller();
    final s = controller.state!..points = 0;
    var end = 0, overtime = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CitadelHub(
            state: s,
            busy: true,
            onNavigate: (_) {},
            onEndTurn: () => end++,
            onOvertime: () => overtime++,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('citadel-end-turn')));

    expect(end, 0);
    expect(overtime, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CapitalHub(
            state: s,
            busy: true,
            onNavigate: (_) {},
            onEndTurn: () => end++,
            onOvertime: () => overtime++,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('capital-end-turn')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('capital-overtime')));
    await tester.pump();
    expect(end, 0);
    expect(overtime, 0);
    expect(tester.takeException(), isNull);
  });
}
