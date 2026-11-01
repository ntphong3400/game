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
import 'package:van_tue/game/presentation/widgets/court_grade_badge.dart';
import 'package:van_tue/game/presentation/widgets/imperial_widgets.dart';

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    for (final mode in ['eligible', 'blocked', 'highest']) {
      testWidgets('direct promotion popup $mode at $size', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (const bool.fromEnvironment('COURT_PROMOTION_PREVIEWS')) {
          for (final (family, path) in [
            ('Lora', 'assets/fonts/Lora.ttf'),
            ('BeVietnam', 'assets/fonts/BeVietnamPro-Regular.ttf'),
            ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
          ]) {
            await (FontLoader(family)..addFont(rootBundle.load(path))).load();
          }
        }
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store);
        await gateway.start(
          name: 'Thiên Hòa',
          runId: 'promotion-popup',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        var id = '';
        await store.update((a) {
          final s = a.active!;
          s.nextCourtPersonnelTurn = 100000;
          final seat = s.courtOffices.firstWhere((o) => o.role == 'Thư lại');
          final c = courtOfficeHolder(s, seat)!;
          id = c.id;
          c
            ..grade = mode == 'highest' ? 1 : 9
            ..merit = mode == 'blocked' ? 0 : 5
            ..ability = 60
            ..affection = 40
            ..discontent = 20;
        });
        final controller = GameController(gateway);
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
        Future<void> tap(Finder f) async {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        final card = find.byKey(ValueKey('court-card-$id'));
        await tap(
          mode == 'eligible'
              ? find.descendant(
                of: card,
                matching: find.byType(CharacterPortrait),
              )
              : mode == 'blocked'
              ? find.descendant(
                of: card,
                matching: find.text(courtPerson(controller.state!, id)!.name),
              )
              : find.byKey(ValueKey('court-grade-$id')),
        );
        expect(find.byKey(const ValueKey('meeting-profile')), findsNothing);
        expect(find.text('Hồ sơ & chức vụ'), findsNothing);
        expect(
          tester
              .widget<CourtGradeBadge>(
                find.byKey(const ValueKey('meeting-grade')),
              )
              .grade,
          mode == 'highest' ? 1 : 9,
        );
        final shortcut = find.byKey(const ValueKey('meeting-promotion'));
        expect(find.text('Thăng phẩm'), findsOneWidget);
        await tap(shortcut);
        expect(
          find.byKey(const ValueKey('court-promotion-dialog')),
          findsOneWidget,
        );
        final confirm = find.byKey(const ValueKey('confirm-promotion'));
        if (mode == 'highest') {
          expect(
            find.byKey(const ValueKey('promotion-highest')),
            findsOneWidget,
          );
          expect(confirm, findsNothing);
          await tap(find.byKey(const ValueKey('close-imperial-dialog')));
          expect(controller.state!.toJson(), before);
          return;
        }
        for (var grade = 8; grade >= 1; grade--) {
          final option = find.byKey(ValueKey('promotion-option-$grade'));
          final tile = tester.widget<RadioListTile<int>>(option);
          expect(tile.onChanged != null, mode == 'eligible' && grade >= 7);
          if (mode == 'blocked' || grade < 7) {
            expect(
              find.byKey(ValueKey('promotion-blocked-$grade')),
              findsOneWidget,
            );
          }
        }
        if (mode == 'blocked') {
          expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
          await tap(find.text('Hủy'));
          expect(controller.state!.toJson(), before);
          return;
        }
        await tap(find.byKey(const ValueKey('promotion-option-7')));
        var quote =
            tester
                .widget<Text>(find.byKey(const ValueKey('promotion-quote')))
                .data!;
        expect(quote, contains('1.800'));
        expect(quote, contains('Sử dụng 5'));
        expect(quote, contains('Thiện cảm +5'));
        expect(quote, contains('Bất mãn −10'));
        final locked = find.byKey(const ValueKey('promotion-option-6'));
        await tap(locked);
        expect(tester.widget<RadioListTile<int>>(locked).groupValue, 7);
        expect(controller.state!.toJson(), before);
        if (size.width == 1440) {
          // An external state refresh invalidates the selected rank immediately.
          await store.update((a) {
            courtPerson(a.active!, id)!.merit = 0;
          });
          await controller.load();
          await tester.pumpAndSettle();
          expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
          expect(find.byKey(const ValueKey('promotion-quote')), findsNothing);
          await store.update((a) {
            courtPerson(a.active!, id)!.merit = 5;
          });
          await controller.load();
          await tester.pumpAndSettle();
          expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
          await tap(find.byKey(const ValueKey('promotion-option-7')));
        }
        if (const bool.fromEnvironment('COURT_PROMOTION_PREVIEWS')) {
          final context = tester.element(find.byType(GameApp));
          await tester.runAsync(() async {
            for (final asset in [
              'parchment',
              'panel',
              'ivory',
              'crimson',
              'icons',
              'jade-texture',
            ]) {
              await precacheImage(
                AssetImage('assets/images/imperial/$asset.webp'),
                context,
              );
            }
          });
          final scrollable =
              find
                  .descendant(
                    of: find.byKey(const ValueKey('court-promotion-dialog')),
                    matching: find.byType(Scrollable),
                  )
                  .first;
          tester.state<ScrollableState>(scrollable).position.jumpTo(0);
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final image = await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory(
              'output/court-promotion-popup',
            ).create(recursive: true);
            await File(
              'output/court-promotion-popup/promotion-${size.width.toInt()}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tap(find.text('Hủy'));
        expect(controller.state!.toJson(), before);
        await tap(shortcut);
        await tap(find.byKey(const ValueKey('promotion-option-7')));
        await tap(confirm);
        final current = controller.state!,
            promoted = courtPerson(controller.state!, id)!;
        expect(promoted.grade, 7);
        expect(
          tester
              .widget<CourtGradeBadge>(
                find.byKey(const ValueKey('meeting-grade')),
              )
              .grade,
          7,
        );
        expect(promoted.merit, 0);
        expect(promoted.affection, 45);
        expect(promoted.discontent, 10);
        expect(current.points, 11);
        expect(current.treasury, 48200);
        expect(
          current.courtOffices.firstWhere((o) => o.holderId == id).grade,
          9,
        );
        expect(
          find.byKey(const ValueKey('court-promotion-dialog')),
          findsNothing,
        );
        expect((await gateway.load()).active!.toJson(), current.toJson());
        expect(tester.takeException(), isNull);
      });
    }
  }
}
