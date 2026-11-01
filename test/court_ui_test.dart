import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/court_rules.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/imperial_widgets.dart';
import 'package:van_tue/game/presentation/widgets/court_grade_badge.dart';

void main() {
  testWidgets(
    'promotion from separate profile previews and commits Cuu to That exactly once',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final realGateway = LocalGameGateway(store);
      await realGateway.start(
        name: 'An',
        runId: 'promotion-ui',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      var id = '';
      await store.update((a) {
        final s = a.active!;
        final office = s.courtOffices.firstWhere((o) => o.role == 'Thư lại');
        id = office.holderId;
        final c = courtOfficeHolder(s, office)!;
        c.merit = 5;
        c.ability = 60;
        c.affection = 40;
        c.discontent = 20;
      });
      final controller = GameController(realGateway);
      await controller.load();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        GameApp(controller: controller, initialRoute: 'people'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('court-group-Văn ban')));
      await tester.pumpAndSettle();
      final summon = find.byKey(ValueKey('court-ability-$id'));
      await tester.ensureVisible(summon);
      await tester.tap(summon);
      await tester.pumpAndSettle();
      final promotion = find.byKey(const ValueKey('meeting-promotion'));
      await tester.ensureVisible(promotion);
      await tester.tap(promotion);
      await tester.pumpAndSettle();
      final option = find.byKey(const ValueKey('promotion-option-7'));
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
      final quote =
          tester
              .widget<Text>(find.byKey(const ValueKey('promotion-quote')))
              .data!;
      expect(quote, contains('1.800'));
      expect(quote, contains('Sử dụng 5'));
      expect(quote, contains('Thiện cảm +5'));
      await tester.tap(find.byKey(const ValueKey('confirm-promotion')));
      await tester.pumpAndSettle();
      final s = controller.state!, c = courtPerson(controller.state!, id)!;
      expect(c.grade, 7);
      expect(c.merit, 0);
      expect(c.affection, 45);
      expect(c.discontent, 10);
      expect(s.points, 11);
      expect(s.treasury, 48200);
      expect(courtOfficeFor(s, id)!.grade, 9);
      expect((await realGateway.load()).active!.toJson(), s.toJson());
      expect(tester.takeException(), isNull);
    },
  );
  for (final size in [
    const Size(1440, 900),
    const Size(1024, 768),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets(
      'court cards, grade badge, filters and separate profiles at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (const bool.fromEnvironment('COURT_PREVIEWS')) {
          for (final (family, path) in [
            ('Lora', 'assets/fonts/Lora.ttf'),
            ('BeVietnam', 'assets/fonts/BeVietnamPro-Regular.ttf'),
            ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
          ]) {
            await (FontLoader(family)..addFont(rootBundle.load(path))).load();
          }
        }
        final store = MemoryGameStore();
        final realGateway = LocalGameGateway(store);
        await realGateway.start(
          name: 'Thiên Hòa',
          runId: 'court-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((a) {
          final s = a.active!;
          courtOfficeHolder(
              s,
              s.courtOffices.firstWhere((o) => o.role == 'Tể tướng'),
            )!
            ..ability = 92
            ..affection = 84;
          courtOfficeHolder(
              s,
              s.courtOffices.firstWhere((o) => o.role == 'Đại tướng'),
            )!
            ..ability = 68
            ..affection = 82;
          courtOfficeHolder(
              s,
              s.courtOffices.firstWhere((o) => o.role == 'Phó tướng'),
            )!
            ..ability = 86
            ..affection = 74;
        });
        final controller = GameController(realGateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.toJson();
        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: GameApp(controller: controller, initialRoute: 'people'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('people-search-false')), findsNothing);
        expect(
          find.byKey(const ValueKey('character-profile-false')),
          findsNothing,
        );
        expect(find.text('Passive'), findsNothing);
        if (size.width < 760) {
          await tester.ensureVisible(find.text('Bộ lọc'));
          await tester.tap(find.text('Bộ lọc'));
          await tester.pumpAndSettle();
        }
        expect(
          find.byKey(const ValueKey('court-grade-filter')),
          findsOneWidget,
        );
        if (size.width < 760) {
          await tester.ensureVisible(find.text('Bộ lọc'));
          await tester.tap(find.text('Bộ lọc'));
          await tester.pumpAndSettle();
        }
        final s = controller.state!;
        final officials =
            s.court.where((c) => c.available && !c.isConsort).toList();
        expect(officials.length, greaterThan(12));
        final cardHeight =
            tester
                .getSize(
                  find.byKey(ValueKey('court-card-${officials.first.id}')),
                )
                .height;
        for (final c in officials) {
          final item = find.byKey(ValueKey('court-card-${c.id}'));
          expect(item, findsOneWidget);
          final gradeBadge = find.descendant(
            of: item,
            matching: find.byType(CourtGradeBadge),
          );
          expect(tester.widget<CourtGradeBadge>(gradeBadge).grade, c.grade);
          expect(
            tester
                .getBottomLeft(
                  find.descendant(of: item, matching: find.text(c.name)),
                )
                .dy,
            lessThan(tester.getTopLeft(gradeBadge).dy),
          );
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
        final general =
            courtOfficeHolder(
              s,
              s.courtOffices.firstWhere((o) => o.role == 'Đại tướng'),
            )!;
        final card = find.byKey(ValueKey('court-card-${general.id}'));
        final name = find.descendant(
          of: card,
          matching: find.text(general.name),
        );
        final badge = find.descendant(
          of: card,
          matching: find.text('Nhất phẩm'),
        );
        expect(
          tester.getTopLeft(badge).dy,
          greaterThan(tester.getBottomLeft(name).dy),
        );
        expect(
          find.descendant(of: card, matching: find.text('Năng lực 68')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: card, matching: find.text('Thiện cảm 82')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('roster-passives-${general.id}')),
          findsOneWidget,
        );
        if (const bool.fromEnvironment('COURT_PREVIEWS')) {
          tester
              .state<ScrollableState>(
                find
                    .descendant(
                      of: find.byKey(const ValueKey('court-roster-scroll')),
                      matching: find.byType(Scrollable),
                    )
                    .first,
              )
              .position
              .jumpTo(0);
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(GameApp));
          await tester.runAsync(() async {
            for (final c in s.court.where(
              (c) => !c.isConsort && c.grade <= 3,
            )) {
              await precacheImage(
                AssetImage(
                  'assets/images/portraits/${c.resolvedPortraitId}.webp',
                ),
                context,
              );
            }
            for (final asset in [
              'people-interior.webp',
              'imperial/parchment.webp',
              'imperial/panel.webp',
              'imperial/ivory.webp',
              'imperial/icons.webp',
              'imperial/jade-texture.webp',
            ]) {
              await precacheImage(AssetImage('assets/images/$asset'), context);
            }
          });
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final image = await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory('output/court-personnel').create(recursive: true);
            await File(
              'output/court-personnel/people-${size.width.toInt()}x${size.height.toInt()}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        if (size.width < 760) {
          final picker = find.byKey(const ValueKey('court-group-picker'));
          await tester.ensureVisible(picker);
          await tester.tap(picker);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Nội đình (8)').last);
        } else {
          final group = find.byKey(const ValueKey('court-group-Nội đình'));
          await tester.ensureVisible(group);
          await tester.tap(group);
        }
        await tester.pumpAndSettle();
        expect(find.text('8 người phù hợp'), findsOneWidget);
        expect(find.byKey(ValueKey('court-card-${general.id}')), findsNothing);
        final doctors = s.court.where((c) => c.role == 'Ngự y').toList();
        expect(doctors.map((c) => c.grade).toSet(), {4, 7});
        for (final c in doctors) {
          expect(find.byKey(ValueKey('roster-passives-${c.id}')), findsNothing);
        }
        final summon = find.byKey(ValueKey('meet-person-${doctors.first.id}'));
        await tester.ensureVisible(summon);
        await tester.tap(summon);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('character-meeting-page')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('meeting-grade')), findsOneWidget);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('meeting-ability')))
              .data,
          '${doctors.first.ability}',
        );
        expect(controller.state!.toJson(), before);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('harem cards show current numbers and capped passive summaries', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MemoryGameStore();
    final realGateway = LocalGameGateway(store);
    await realGateway.start(
      name: 'An',
      runId: 'harem-cards',
      seed: 42,
      previousRunId: null,
      previousRevision: null,
    );
    await store.update((a) {
      final c = a.active!.court.firstWhere((c) => c.id == 'consort_lan');
      c.inHarem = true;
      c.ability = 84;
      c.affection = 82;
    });
    final controller = GameController(realGateway);
    await controller.load();
    addTearDown(controller.dispose);
    final before = controller.state!.toJson();
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: GameApp(controller: controller, initialRoute: 'harem'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Thiện cảm 82'), findsOneWidget);
    expect(find.text('Thiện cảm 82/100'), findsNothing);
    expect(
      find.byKey(const ValueKey('roster-passives-consort_lan')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('roster-passives-consort_mai')),
      findsOneWidget,
    );
    expect(controller.state!.toJson(), before);
    expect(tester.takeException(), isNull);
    if (const bool.fromEnvironment('COURT_PREVIEWS')) {
      final context = tester.element(find.byType(GameApp));
      await tester.runAsync(() async {
        for (final c in controller.state!.court.where((c) => c.isConsort)) {
          await precacheImage(
            AssetImage('assets/images/portraits/${c.resolvedPortraitId}.webp'),
            context,
          );
        }
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final image = await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'output/court-personnel/harem-1440x900.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
  });
}
