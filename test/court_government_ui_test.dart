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

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets(
      'government shows all offices in descending seniority and supports confirmed dismissal at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (const bool.fromEnvironment('COURT_GOVERNMENT_PREVIEWS')) {
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
          runId: 'government-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((a) {
          final s = a.active!;
          s.authority = 92;
          final office = s.courtOffices.firstWhere((o) => o.role == 'Tể tướng');
          courtOfficeHolder(s, office)!
            ..ability = 92
            ..affection = 84
            ..merit = 7;
          final clerk = s.courtOffices.firstWhere((o) => o.role == 'Thư lại');
          courtOfficeHolder(s, clerk)!.grade = 1;
        });
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final initial = controller.state!, before = initial.toJson();
        final office = initial.courtOffices.firstWhere(
          (o) => o.role == 'Tể tướng',
        );
        final holder = courtOfficeHolder(initial, office)!;
        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: GameApp(controller: controller, initialRoute: 'people'),
          ),
        );
        await tester.pumpAndSettle();
        final open = find.byKey(const ValueKey('open-court-government'));
        await tester.ensureVisible(open);
        await tester.tap(open);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('court-government')), findsOneWidget);
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey('court-government-count')),
              )
              .data,
          '53 vị trí quan chức · 0 vị trí đang trống',
        );
        for (final o in initial.courtOffices) {
          expect(
            tester
                .widget<TextButton>(
                  find.byKey(ValueKey('government-appoint-${o.id}')),
                )
                .onPressed,
            isNull,
          );
          expect(
            find.byKey(ValueKey('government-office-${o.id}')),
            findsOneWidget,
          );
        }
        final byId = {for (final o in initial.courtOffices) o.id: o};
        final displayed =
            find
                .byWidgetPredicate(
                  (w) =>
                      w.key is ValueKey<String> &&
                      (w.key as ValueKey<String>).value.startsWith(
                        'government-office-',
                      ),
                )
                .evaluate()
                .map(
                  (e) =>
                      byId[(e.widget.key as ValueKey<String>).value.substring(
                        'government-office-'.length,
                      )]!,
                )
                .toList();
        expect(displayed, hasLength(53));
        final grades = displayed.map((o) => o.grade).toList();
        expect(grades, orderedEquals(grades.toList()..sort()));
        expect(displayed.first.grade, 1);
        expect(displayed.last.grade, 9);
        final juniorDoctor = initial.courtOffices.firstWhere(
          (o) => o.role == 'Ngự y' && o.grade == 7,
        );
        final lowerCard = find.byKey(
          ValueKey('government-office-${juniorDoctor.id}'),
        );
        expect(
          find.descendant(
            of: lowerCard,
            matching: find.text('Không có passive chức vụ'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: lowerCard,
            matching: find.textContaining('Kích hoạt:'),
          ),
          findsNothing,
        );
        expect(
          tester
              .widget<Text>(
                find.byKey(ValueKey('government-holder-${office.id}')),
              )
              .data,
          holder.name,
        );
        final listHeader = find.byKey(const ValueKey('government-list-header'));
        expect(listHeader, size.width >= 1200 ? findsOneWidget : findsNothing);
        if (size.width >= 1200) {
          final row = find.byKey(ValueKey('government-office-${office.id}'));
          expect(tester.getSize(row).height, lessThanOrEqualTo(86));
          for (final label in [
            'Chức vụ',
            'Phẩm yêu cầu',
            'Người đang giữ chức',
            'Trạng thái passive',
            'Bổ nhiệm / hồi hương',
          ]) {
            expect(
              find.descendant(of: listHeader, matching: find.text(label)),
              findsOneWidget,
            );
          }
          // Every office occupies its own row, including offices with the same grade.
          for (var i = 1; i < displayed.length; i++) {
            final previous = tester.getRect(
              find.byKey(ValueKey('government-office-${displayed[i - 1].id}')),
            );
            final next = tester.getRect(
              find.byKey(ValueKey('government-office-${displayed[i].id}')),
            );
            expect(next.top, greaterThanOrEqualTo(previous.bottom));
          }
        }
        expect(tester.takeException(), isNull);
        expect(controller.state!.toJson(), before);
        final cut = find.byKey(ValueKey('government-dismiss-${office.id}'));
        await tester.ensureVisible(cut);
        await tester.tap(cut);
        await tester.pumpAndSettle();
        final penalty =
            tester
                .widget<Text>(
                  find.byKey(const ValueKey('court-dismiss-penalty')),
                )
                .data!;
        expect(penalty, contains('Ổn định triều đình −1/mùa'));
        expect(penalty, contains('Uy quyền −1/mùa'));
        await tester.tap(find.text('Hủy'));
        await tester.pumpAndSettle();
        expect(controller.state!.toJson(), before);
        await tester.ensureVisible(cut);
        await tester.tap(cut);
        await tester.pumpAndSettle();
        final confirm = find.byKey(const ValueKey('confirm-court-dismissal'));
        await tester.ensureVisible(confirm);
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        final current = controller.state!;
        expect(current.points, initial.points - 1);
        expect(current.treasury, initial.treasury);
        final former = current.officialsPool.firstWhere(
          (c) => c.id == holder.id,
        );
        expect(former.merit, 7);
        expect(former.grade, 1);
        expect(
          find.byKey(ValueKey('government-vacant-${office.id}')),
          findsOneWidget,
        );
        expect(
          tester
              .widget<Text>(
                find.byKey(
                  ValueKey('government-effect-${office.id}-authority'),
                ),
              )
              .data,
          'Uy quyền −1/mùa',
        );
        expect(
          tester
              .widget<Text>(
                find.byKey(const ValueKey('court-government-count')),
              )
              .data,
          '53 vị trí quan chức · 1 vị trí đang trống',
        );
        expect(
          tester
              .widget<TextButton>(
                find.byKey(ValueKey('government-appoint-${office.id}')),
              )
              .onPressed,
          isNotNull,
        );
        expect((await gateway.load()).active!.toJson(), current.toJson());
        if (const bool.fromEnvironment('COURT_GOVERNMENT_PREVIEWS')) {
          ScaffoldMessenger.of(
            tester.element(find.byType(Scaffold).last),
          ).hideCurrentSnackBar();
          await tester.pumpAndSettle();
          tester
              .state<ScrollableState>(
                find
                    .descendant(
                      of: find.byKey(const ValueKey('court-government')),
                      matching: find.byType(Scrollable),
                    )
                    .first,
              )
              .position
              .jumpTo(0);
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(GameApp));
          await tester.runAsync(() async {
            for (final asset in [
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
            await Directory('output/court-government').create(recursive: true);
            await File(
              'output/court-government/government-${size.width.toInt()}x${size.height.toInt()}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        if (size.width == 1440) {
          final appoint = find.byKey(
            ValueKey('government-appoint-${office.id}'),
          );
          await tester.ensureVisible(appoint);
          await tester.tap(appoint);
          await tester.pumpAndSettle();
          final candidate = find.text('${holder.name} · Nhất phẩm');
          await tester.ensureVisible(candidate);
          await tester.tap(candidate);
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(FilledButton, 'Bổ nhiệm'));
          await tester.pumpAndSettle();
          expect(courtOfficeFor(controller.state!, holder.id)!.id, office.id);
          expect(tester.widget<TextButton>(appoint).onPressed, isNull);
          expect(
            find.byKey(ValueKey('government-vacant-${office.id}')),
            findsNothing,
          );
          expect(
            courtOfficeDirection(
              controller.state!,
              controller.state!.courtOffices.firstWhere(
                (o) => o.id == office.id,
              ),
            ),
            0,
          );
        }
        final back = find.byKey(const ValueKey('section-back'));
        await tester.ensureVisible(back);
        await tester.tap(back);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('open-court-government')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
