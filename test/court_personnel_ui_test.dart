import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/court_rules.dart';
import 'package:van_tue/game/logic/court_personnel_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/petition_decision.dart';

void main() {
  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets('reform picker only offers qualified replacements at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final s = GameEngine().start('reform-ui', 'An', 42);
      s.authority = 95;
      for (final c in [...s.court, ...s.officialsPool]) {
        c.ability = 20;
        c.affection = 40;
      }
      final office = s.courtOffices.firstWhere((o) => o.role == 'Đại tướng');
      final courtCandidate =
          courtOfficeHolder(
            s,
            s.courtOffices.firstWhere((o) => o.role == 'Thư lại'),
          )!;
      final poolCandidate = s.officialsPool.first;
      final unqualified = s.officialsPool[1];
      for (final c in [courtCandidate, poolCandidate]) {
        c
          ..grade = 1
          ..ability = 90
          ..affection = 80
          ..specialty = specialtyForRole(office.role);
      }
      // Ordinarily appointable, but below this office's passive threshold.
      unqualified
        ..grade = 1
        ..ability = 89
        ..affection = 80
        ..specialty = specialtyForRole(office.role);
      final matter = CourtPersonnelMatter(
        id: 'reform-ui',
        kind: 'reform',
        personId: poolCandidate.id,
        sponsorId: courtCandidate.id,
        openedTurn: s.week,
        officeId: office.id,
        holderId: office.holderId,
      );
      s.courtPersonnelMatters.add(matter);
      final petition = Petition(
        id: matter.id,
        definitionId: matter.eventId,
        openedWeek: s.week,
        deadline: s.week + 1,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PetitionDecision(
                state: s,
                petition: petition,
                pickAssignee: (_, __) async => null,
                onConfirm: (_, __) async => true,
                onReadLater: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Bồi dưỡng'), findsNothing);
      expect(find.byKey(const ValueKey('petition-choice-3')), findsNothing);
      expect(find.text('Bác đề nghị'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('petition-choice-1')));
      await tester.pumpAndSettle();
      final picker = find.byKey(const ValueKey('personnel-nominee-picker'));
      await tester.ensureVisible(picker);
      await tester.tap(picker);
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(
        find.byKey(ValueKey('personnel-candidate-${courtCandidate.id}')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('personnel-candidate-${poolCandidate.id}')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('personnel-candidate-${unqualified.id}')),
        findsNothing,
      );
      expect(
        find.byKey(ValueKey('personnel-candidate-${office.holderId}')),
        findsNothing,
      );
      await tester.tap(
        find.byKey(ValueKey('personnel-candidate-${courtCandidate.id}')),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('confirm-petition')),
            )
            .onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    });
    for (final kind in ['nominate', 'patronage', 'authority']) {
      testWidgets('$kind personnel preview and confirmed action at $size', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (const bool.fromEnvironment('COURT_PERSONNEL_PREVIEWS')) {
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
          runId: 'personnel-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        var candidateId = '', officeId = '';
        await store.update((a) {
          final s = a.active!;
          s.authority = kind == 'authority' ? 80 : 95;
          s.nextCourtPersonnelTurn = 100000;
          s.petitions.clear();
          final office = s.courtOffices.firstWhere((o) => o.role == 'Thư lại');
          officeId = office.id;
          final c = courtOfficeHolder(s, office)!;
          if (kind == 'nominate') {
            s.court.remove(c);
            c.role = 'Chờ bổ nhiệm';
            s.officialsPool.add(c);
            office.holderId = '';
            s.officialsPool[0]
              ..grade = 9
              ..ability = 90;
            s.officialsPool[1]
              ..grade = 9
              ..ability = 99;
            candidateId = s.officialsPool[1].id;
          } else {
            c
              ..ability = 20
              ..merit = 5;
            candidateId = c.id;
          }
          if (kind != 'authority') {
            final m = CourtPersonnelMatter(
              id: 'personnel-ui',
              kind: kind,
              personId: kind == 'nominate' ? s.officialsPool.first.id : c.id,
              sponsorId:
                  s.court.firstWhere((p) => !p.isConsort && p.id != c.id).id,
              openedTurn: s.week,
              officeId: kind == 'nominate' ? office.id : '',
              targetGrade: kind == 'patronage' ? 8 : 0,
            );
            s.courtPersonnelMatters.add(m);
            s.petitions.add(
              Petition(
                id: m.id,
                definitionId: m.eventId,
                openedWeek: s.week,
                deadline: s.week + 1,
              ),
            );
          }
        });
        final controller = GameController(gateway);
        await controller.load();
        addTearDown(controller.dispose);
        final before = controller.state!.toJson();
        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: GameApp(
              controller: controller,
              initialRoute: kind == 'authority' ? 'people' : 'court',
            ),
          ),
        );
        await tester.pumpAndSettle();
        Future<void> tap(Finder f) async {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        if (kind == 'authority') {
          await tap(find.byKey(const ValueKey('open-court-government')));
          final general = controller.state!.courtOffices.firstWhere(
            (o) => o.role == 'Đại tướng',
          );
          final button = find.byKey(
            ValueKey('government-dismiss-${general.id}'),
          );
          expect(tester.widget<TextButton>(button).onPressed, isNull);
          expect(
            find.byTooltip('Đại tướng: cần uy quyền trên 80 · Hiện tại 80.'),
            findsOneWidget,
          );
          expect(find.text('Cắt chức'), findsNothing);
          expect(controller.state!.toJson(), before);
        } else {
          await tap(find.byKey(const ValueKey('read-petition-personnel-ui')));
          await tap(
            find.byKey(
              ValueKey('petition-choice-${kind == 'nominate' ? 1 : 0}'),
            ),
          );
          if (kind == 'nominate') {
            expect(
              tester
                  .widget<FilledButton>(
                    find.byKey(const ValueKey('confirm-petition')),
                  )
                  .onPressed,
              isNull,
            );
            await tap(find.byKey(const ValueKey('personnel-nominee-picker')));
            await tap(find.byKey(ValueKey('personnel-candidate-$candidateId')));
          }
          expect(find.byKey(const ValueKey('petition-assignee')), findsNothing);
          expect(controller.state!.toJson(), before);
        }
        if (const bool.fromEnvironment('COURT_PERSONNEL_PREVIEWS')) {
          final context = tester.element(find.byType(GameApp));
          await tester.runAsync(() async {
            for (final asset in [
              'parchment',
              'panel',
              'ivory',
              'crimson',
              'jade-texture',
              'icons',
            ]) {
              await precacheImage(
                AssetImage('assets/images/imperial/$asset.webp'),
                context,
              );
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
            await Directory(
              'output/court-personnel-upgrade',
            ).create(recursive: true);
            await File(
              'output/court-personnel-upgrade/$kind-${size.width.toInt()}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        if (kind == 'authority') {
          final doctor = controller.state!.courtOffices.firstWhere(
            (o) => o.role == 'Ngự y' && o.grade == 4,
          );
          await tap(find.byKey(ValueKey('government-dismiss-${doctor.id}')));
          expect(find.textContaining('Ổn định triều đình −5;'), findsOneWidget);
          expect(
            find.text('Yêu cầu uy quyền trên 50 · Hiện tại 80.'),
            findsOneWidget,
          );
          await tap(find.text('Hủy'));
          expect(controller.state!.toJson(), before);
        } else {
          final initial = controller.state!;
          final expectedFee =
              kind == 'nominate'
                  ? vacancyPromotion(
                    initial,
                    courtPerson(initial, candidateId)!,
                    initial.courtOffices.firstWhere((o) => o.id == officeId),
                  ).cost
                  : CourtPromotion(
                    initial,
                    courtPerson(initial, candidateId)!,
                    8,
                  ).cost;
          await tap(find.byKey(const ValueKey('confirm-petition')));
          expect(controller.state!.points, initial.points - 1);
          expect(controller.state!.treasury, initial.treasury - expectedFee);
          if (kind == 'nominate') {
            expect(
              courtOfficeFor(controller.state!, candidateId)!.id,
              officeId,
            );
            expect(
              controller.state!.courtPersonnelMatters.last.status,
              'watching',
            );
          } else {
            expect(courtPerson(controller.state!, candidateId)!.grade, 8);
            expect(courtPerson(controller.state!, candidateId)!.merit, 3);
            expect(controller.state!.authority, initial.authority - 2);
          }
          expect(
            (await gateway.load()).active!.toJson(),
            controller.state!.toJson(),
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
