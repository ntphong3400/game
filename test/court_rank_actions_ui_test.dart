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
import 'package:van_tue/game/presentation/meeting_scenes.dart';
import 'package:van_tue/game/presentation/widgets/court_grade_badge.dart';

void main() {
  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets(
      'occupied office locks appointment and meeting retirement confirms at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (const bool.fromEnvironment('COURT_RANK_ACTION_PREVIEWS')) {
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
          runId: 'rank-actions',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        await store.update((a) {
          a.active!.authority = 80;
        });
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final office = controller.state!.courtOffices.firstWhere(
          (o) => o.role == 'Đại tướng',
        );
        final person = courtOfficeHolder(controller.state!, office)!;
        final before = controller.state!.toJson();
        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: GameApp(controller: controller, initialRoute: 'people'),
          ),
        );
        await tester.pumpAndSettle();
        Future<void> tap(Finder finder) async {
          await tester.ensureVisible(finder);
          await tester.tap(finder);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        await tap(find.byKey(const ValueKey('open-court-government')));
        final appoint = find.byKey(ValueKey('government-appoint-${office.id}'));
        expect(tester.widget<TextButton>(appoint).onPressed, isNull);
        expect(
          find.byTooltip(
            'Chức vụ đã có người giữ. Cho quan hồi hương trước khi bổ nhiệm tại đây.',
          ),
          findsWidgets,
        );
        await tap(find.byKey(ValueKey('government-meet-${office.id}')));
        final retirement = find.byKey(
          const ValueKey('meeting-action-cut-office'),
        );
        expect(tester.widget<OutlinedButton>(retirement).onPressed, isNull);
        expect(find.textContaining('cần uy quyền trên 80'), findsOneWidget);
        expect(controller.state!.toJson(), before);
        await store.update((a) {
          a.active!.authority = 95;
        });
        await controller.load();
        await tester.pumpAndSettle();
        final permitted = controller.state!;
        final permittedJson = permitted.toJson();
        expect(tester.widget<OutlinedButton>(retirement).onPressed, isNotNull);
        await tap(retirement);
        expect(
          find.byKey(const ValueKey('meeting-action-confirmation')),
          findsOneWidget,
        );
        expect(
          find.text('1 hành động · Ổn định −8 · Không chi vàng'),
          findsWidgets,
        );
        expect(
          find.textContaining('Mỗi mùa ghế trống: Sĩ khí −1/mùa'),
          findsOneWidget,
        );
        await tap(find.byKey(const ValueKey('meeting-action-cancel')));
        expect(controller.state!.toJson(), permittedJson);
        await tap(retirement);
        await tap(find.byKey(const ValueKey('meeting-action-confirm')));
        final after = controller.state!;
        expect(after.points, permitted.points - 1);
        expect(after.treasury, permitted.treasury);
        expect(after.stability, permitted.stability - 8);
        expect(courtPerson(after, person.id)!.retired, isTrue);
        expect(
          courtPerson(after, person.id)!.resolvedPortraitId,
          person.resolvedPortraitId,
        );
        expect(
          after.courtOffices.firstWhere((o) => o.id == office.id).holderId,
          isEmpty,
        );
        expect(tester.widget<OutlinedButton>(retirement).onPressed, isNull);
        expect(find.text('Đã hồi hương'), findsWidgets);
        expect((await gateway.load()).active!.toJson(), after.toJson());
        if (const bool.fromEnvironment('COURT_RANK_ACTION_PREVIEWS')) {
          final context = tester.element(find.byType(GameApp));
          await tester.runAsync(() async {
            for (final asset in [
              'assets/images/people-interior.webp',
              meetingCharacterAsset(person),
              'assets/images/imperial/panel.webp',
              'assets/images/imperial/parchment.webp',
            ]) {
              await precacheImage(AssetImage(asset), context);
            }
          });
          await tester.pumpAndSettle();
          await tester.ensureVisible(retirement);
          await tester.pumpAndSettle();
          await capture(tester, boundary, 'retirement-${size.width.toInt()}');
        }
        await tap(find.byKey(const ValueKey('meeting-back')));
        expect(tester.widget<TextButton>(appoint).onPressed, isNotNull);
        if (const bool.fromEnvironment('COURT_RANK_ACTION_PREVIEWS') &&
            size.width == 1440) {
          final gallery = GlobalKey();
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(fontFamily: 'BeVietnam'),
              home: Scaffold(
                body: Center(
                  child: RepaintBoundary(
                    key: gallery,
                    child: Container(
                      width: 688,
                      color: parchment,
                      padding: const EdgeInsets.all(24),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          for (var grade = 1; grade <= 9; grade++)
                            SizedBox(
                              width: 200,
                              child: Center(child: CourtGradeBadge(grade)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (var grade = 1; grade <= 9; grade++) {
            expect(
              find.byKey(ValueKey('court-grade-seal-$grade')),
              findsOneWidget,
            );
          }
          await capture(tester, gallery, 'nine-grade-badges');
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}

Future<void> capture(WidgetTester tester, GlobalKey boundary, String name) =>
    tester.runAsync(() async {
      final image = await (boundary.currentContext!.findRenderObject()
              as RenderRepaintBoundary)
          .toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('output/court-rank-actions').create(recursive: true);
      await File(
        'output/court-rank-actions/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
