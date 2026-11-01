import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/country_hub.dart';
import 'package:van_tue/game/presentation/widgets/country_routes.dart';
import 'support/legacy_gateway.dart' as legacy;

Future<GameController> setup(
  WidgetTester tester,
  Size size, {
  String route = 'citadel',
  bool oldSave = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  if (const bool.fromEnvironment('COUNTRY_PREVIEWS')) {
    for (final (family, path) in [
      ('Lora', 'assets/fonts/Lora.ttf'),
      ('BeVietnam', 'assets/fonts/BeVietnamPro-Regular.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(path))).load();
    }
  }
  final store = MemoryGameStore();
  final GameGateway gateway =
      oldSave ? legacy.LocalGameGateway(store) : LocalGameGateway(store);
  await gateway.start(
    name: 'Thiên Hòa',
    runId: 'country-ui',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  final c = GameController(gateway);
  await c.load();
  addTearDown(c.dispose);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey('country-canvas'),
      child: GameApp(controller: c, initialRoute: route),
    ),
  );
  await tester.pumpAndSettle();
  return c;
}

Future<void> click(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      180,
      scrollable:
          find
              .descendant(
                of: find.byType(ListView).first,
                matching: find.byType(Scrollable),
              )
              .first,
      maxScrolls: 30,
    );
  }
  final key = tester.widget(finder).key;
  final nationalMap =
      key is ValueKey<String> && key.value.startsWith('giang-son-');
  // Align national map labels to the left so southern labels stay clear of
  // the fixed end-season button on a 320px viewport.
  await Scrollable.ensureVisible(
    tester.element(finder),
    alignment: nationalMap ? 0 : .5,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('COUNTRY_PREVIEWS')) return;
  final context = tester.element(find.byType(GameApp));
  await tester.runAsync(() async {
    for (final asset in [
      ...countryBackgroundAssets.values,
      'assets/images/imperial/parchment.webp',
      'assets/images/imperial/icons.webp',
      'assets/images/imperial/jade-texture.webp',
      'assets/images/imperial/panel.webp',
      'assets/images/imperial/ivory.webp',
      'assets/images/imperial/jade.webp',
      'assets/images/imperial/crimson.webp',
    ]) {
      await precacheImage(AssetImage(asset), context);
    }
  });
  await tester.pumpAndSettle();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('country-canvas')),
  );
  await tester.runAsync(() async {
    await Directory('output/country-implementation').create(recursive: true);
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      'output/country-implementation/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  for (final country in countryNames.keys) {
    for (final size in [
      const Size(1440, 900),
      const Size(1024, 768),
      const Size(390, 844),
      const Size(320, 568),
      const Size(844, 390),
    ]) {
      testWidgets(
        '$country country and three destinations work at $size without save changes',
        (tester) async {
          final c = await setup(tester, size);
          final before = jsonEncode(c.state!.toJson());
          await click(tester, find.byKey(ValueKey('giang-son-$country')));
          expect(find.byType(CountryHub), findsOneWidget);
          expect(
            find.text(countryNames[country]!.toUpperCase()),
            findsOneWidget,
          );
          final background = tester.widget<Image>(
            find.byKey(ValueKey('country-background-$country')),
          );
          expect(
            (background.image as AssetImage).assetName,
            countryBackgroundAssets[country],
          );
          final destinations = find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key as ValueKey<String>).value.startsWith(
                  'country-location-',
                ),
          );
          expect(destinations, findsNWidgets(3));
          await capture(tester, '$country-${size.width.toInt()}');
          for (final place in countryPlaceNames.keys) {
            await click(
              tester,
              find.byKey(ValueKey('country-location-$place')),
            );
            expect(
              find.byKey(ValueKey('country-panel-$country-$place')),
              findsOneWidget,
            );
            for (final other in countryNames.keys.where(
              (id) => id != country,
            )) {
              expect(find.textContaining(countryNames[other]!), findsNothing);
            }
            if (place == 'palace') {
              if (find.text('Giao hảo').evaluate().isEmpty) {
                await tester.scrollUntilVisible(
                  find.text('Giao hảo'),
                  180,
                  scrollable:
                      find
                          .descendant(
                            of: find.byKey(
                              ValueKey('country-panel-$country-$place'),
                            ),
                            matching: find.byType(Scrollable),
                          )
                          .first,
                );
                await tester.pumpAndSettle();
              }
              expect(find.text('Giao hảo'), findsOneWidget);
              expect(find.text('Hòa đàm và hòa ước'), findsNothing);
            }
            if (place == 'embassy') expect(find.text('Giao hảo'), findsNothing);
            expect(tester.takeException(), isNull);
            if (country == 'south') {
              await capture(tester, '$country-$place-${size.width.toInt()}');
            }
            await tester.tap(find.byKey(const ValueKey('section-back')));
            await tester.pumpAndSettle();
          }
          expect(jsonEncode(c.state!.toJson()), before);
          expect(jsonEncode((await c.gateway.load()).active!.toJson()), before);
          await tester.tap(find.byKey(const ValueKey('section-back')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('giang-son-map-scroll')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'palace envoy cancellation is read only; confirmation updates only chosen country and persists',
    (tester) async {
      final c = await setup(
        tester,
        const Size(390, 844),
        route: 'country-north-palace',
      );
      final before = jsonEncode(c.state!.toJson());
      final relation = c.state!.warfare!.neighbors.first.relation;
      final others =
          c.state!.warfare!.neighbors
              .skip(1)
              .map((n) => jsonEncode(n.toJson()))
              .toList();
      final gold = c.state!.treasury, points = c.state!.points;
      await click(tester, find.text('Giao hảo'));
      await tester.tap(find.text('Để sau'));
      await tester.pumpAndSettle();
      expect(jsonEncode(c.state!.toJson()), before);
      await click(tester, find.text('Giao hảo'));
      await tester.tap(find.text('Xác nhận'));
      await tester.pumpAndSettle();
      expect(c.state!.warfare!.neighbors.first.relation, relation + 12);
      expect(
        c.state!.warfare!.neighbors
            .skip(1)
            .map((n) => jsonEncode(n.toJson()))
            .toList(),
        others,
      );
      expect(c.state!.treasury, gold - 1000);
      expect(c.state!.points, points - 1);
      expect((await c.gateway.load()).active!.toJson(), c.state!.toJson());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'embassy owns war negotiations and treaty debt; border filters reports and routes to matching pass',
    (tester) async {
      final c = await setup(
        tester,
        const Size(390, 844),
        route: 'country-west-embassy',
      );
      final store = (c.gateway as LocalGameGateway).store;
      await store.update((a) {
        final n = a.active!.warfare!.neighbors[1];
        n.status = 'war';
        n.advantage = 70;
        a.active!.warfare!.reports = [
          {
            'countryId': 'west',
            'week': 1,
            'title': 'Tin riêng phía Tây',
            'detail': 'Tây tăng viện',
          },
          {
            'countryId': 'north',
            'week': 1,
            'title': 'Tin riêng phía Bắc',
            'detail': 'Bắc tăng viện',
          },
        ];
      });
      await c.load();
      await tester.pumpAndSettle();
      expect(find.textContaining('Đình chiến ('), findsOneWidget);
      expect(find.text('Tuyên chiến'), findsNothing);
      await capture(tester, 'west-war-embassy-390');
      await store.update((a) {
        final n = a.active!.warfare!.neighbors[1];
        n.status = 'treaty';
        n.treaty = TributeTreaty(
          tier: 'light',
          receiving: false,
          annualGold: 5000,
          signed: 1,
          installments: 2,
        )..arrears = 1000;
      });
      await c.load();
      await tester.pumpAndSettle();
      await click(tester, find.text('Trả bù'));
      expect(find.text('Xác nhận'), findsOneWidget);
      await tester.tap(find.text('Để sau'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('section-back')));
      await tester.pumpAndSettle();
      await click(
        tester,
        find.byKey(const ValueKey('country-location-border')),
      );
      await click(tester, find.textContaining('Tin riêng phía Tây'));
      expect(find.textContaining('Tin riêng phía Bắc'), findsNothing);
      await click(tester, find.byKey(const ValueKey('country-to-frontier')));
      expect(find.byKey(const ValueKey('frontier-page')), findsOneWidget);
      expect(find.text('TÂY ẢI'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'legacy country pages explain missing diplomacy and return safely',
    (tester) async {
      final c = await setup(tester, const Size(320, 568), oldSave: true);
      final before = jsonEncode(c.state!.toJson());
      await click(tester, find.byKey(const ValueKey('giang-son-south')));
      expect(find.byType(CountryHub), findsOneWidget);
      await click(
        tester,
        find.byKey(const ValueKey('country-location-embassy')),
      );
      expect(find.text('Đến Quốc sự'), findsOneWidget);
      await click(tester, find.text('Đến Quốc sự'));
      expect(jsonEncode(c.state!.toJson()), before);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'season control is absent and overtime is disabled while saving',
    (tester) async {
      final c = await setup(tester, const Size(320, 568));
      c.state!.points = 0;
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryHub(
              state: c.state!,
              countryId: 'south',
              busy: true,
              onNavigate: (_) {},
              onEndTurn: () => calls++,
              onOvertime: () => calls++,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const ValueKey('country-end-turn')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('country-overtime')));
      expect(calls, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
