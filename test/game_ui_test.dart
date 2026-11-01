import 'support/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'support/legacy_gateway.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/data/content.dart';

void main() {
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets(
      'revenue work previews cash, commits and locks repeats at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final task in revenueTasks) {
          final store = MemoryGameStore();
          final gateway = LocalGameGateway(store, seasonal: false);
          await gateway.start(
            name: 'An',
            runId: 'revenue-$task',
            seed: 42,
            previousRunId: null,
            previousRevision: null,
          );
          await store.update((archive) {
            archive.active!.rng = 100;
          });
          final controller = GameController(gateway);
          await controller.load();
          final before = controller.state!.copy();
          final official = before.court.firstWhere((c) => c.id == 'treasurer');
          await tester.pumpWidget(
            GameApp(
              initialRoute: 'court',
              key: ValueKey(task),
              controller: controller,
            ),
          );
          await tester.pumpAndSettle();
          await openSection(tester, 'treasury');
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('treasury-open-2')));
          await tester.pumpAndSettle();
          expect(find.text('Việc tăng thu'), findsWidgets);
          final button = find.byKey(ValueKey('action-$task'));
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pumpAndSettle();
          final assign = find.byKey(ValueKey('assign-$task-treasurer'));
          await tester.ensureVisible(assign);
          await tester.tap(assign);
          await tester.pumpAndSettle();
          expect(
            find.textContaining(revenueRewardPreview(task, official)),
            findsOneWidget,
          );
          expect(controller.state!.toJson(), before.toJson());
          await tester.tap(find.text('Xác nhận giao việc'));
          await tester.pumpAndSettle();
          final after = controller.state!;
          expect(after.points, 2);
          expect(
            after.treasury,
            task == 'commerce'
                ? before.treasury - 40
                : before.treasury +
                    TaskAssessment(
                      task,
                      official,
                    ).reward(revenueBaseReturns[task]!),
          );
          if (task == 'commerce') {
            expect(after.projects.single.kind, 'commerce');
          }
          if (task == 'sell_surplus') expect(after.grain, before.grain - 40);
          expect(tester.widget<OutlinedButton>(button).onPressed, isNull);
          if (task == 'commerce') {
            await tester.tap(find.byKey(const ValueKey('section-back')));
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const ValueKey('treasury-open-4')));
            await tester.pumpAndSettle();
            expect(
              find.text('Đoàn thương mại · ${official.name}'),
              findsOneWidget,
            );
          }
          expect((await gateway.load()).active!.toJson(), after.toJson());
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'expanded event previews risks and saves deferred result at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryGameStore();
        final gateway = LocalGameGateway(store, seasonal: false);
        await gateway.start(
          name: 'An',
          runId: 'event-ui',
          seed: 42,
          previousRunId: null,
          previousRevision: null,
        );
        final event = eventById('finance_02');
        await store.update((archive) {
          final s = archive.active!;
          s.petitions = [
            Petition(
              id: 'expanded',
              definitionId: event.id,
              openedWeek: s.week,
              deadline: s.week + 1,
            ),
          ];
        });
        final controller = GameController(gateway);
        await controller.load();
        await tester.pumpWidget(
          GameApp(initialRoute: 'court', controller: controller),
        );
        await tester.pumpAndSettle();
        final open = find.byKey(const ValueKey('read-petition-expanded'));
        await tester.ensureVisible(open);
        await tester.tap(open);
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of:
                size.width < 700
                    ? find.byType(AlertDialog)
                    : find.byKey(const ValueKey('petition-desk')),
            matching: find.text(event.body),
          ),
          findsOneWidget,
        );
        expect(find.textContaining('75% thành công'), findsNothing);
        expect(find.textContaining('Nếu thất bại'), findsNothing);
        final choice = find.text(event.choices.first.label);
        await tester.ensureVisible(choice);
        await tester.tap(choice);
        await tester.pumpAndSettle();
        expect(find.textContaining('75% thành công'), findsOneWidget);
        expect(find.textContaining('Nếu thất bại'), findsOneWidget);
        expect(controller.state!.pending, isEmpty);
        await tester.ensureVisible(
          find.byKey(const ValueKey('confirm-petition')),
        );
        await tester.tap(find.byKey(const ValueKey('confirm-petition')));
        await tester.pumpAndSettle();
        final pending = controller.state!.pending.single;
        expect(pending.kind, 'eventOutcome');
        expect(pending.title, event.title);
        expect(pending.dueWeek, 2);
        expect(
          (await gateway.load()).active!.pending.single.toJson(),
          pending.toJson(),
        );
        await tester.tap(find.text('Quốc sự').first);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('kingdom-open-1')));
        await tester.pumpAndSettle();
        expect(
          find.text('${event.title} · dự kiến cuối tuần 2'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('ability help and paid choice of successor work at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store, seasonal: false);
      await gateway.start(
        name: 'An',
        runId: 'personnel-ui',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      final controller = GameController(gateway);
      await controller.load();
      final before = controller.state!.copy();
      final candidate = before.officialsPool.reduce(
        (a, b) => a.ability > b.ability ? a : b,
      );
      await tester.pumpWidget(
        GameApp(initialRoute: 'court', controller: controller),
      );
      await tester.pumpAndSettle();
      await openSection(tester, 'Triều thần');
      await tester.pumpAndSettle();
      final card = find.byKey(const ValueKey('select-person-treasurer'));
      final summon = find.descendant(
        of: card,
        matching: find.text('Triệu kiến'),
      );
      await tester.ensureVisible(summon);
      await tester.tap(summon);
      await tester.pumpAndSettle();
      final profile = find.byKey(const ValueKey('meeting-profile'));
      await tester.ensureVisible(profile);
      await tester.tap(profile);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('person-ability-help')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.textContaining('Chuyên môn: Kinh tế'),
        ),
        findsOneWidget,
      );
      final dismiss = find.text('Điều chỉnh nhân sự');
      await tester.ensureVisible(dismiss);
      await tester.tap(dismiss);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Chọn người tiếp nhận chức Hộ bộ'),
        findsOneWidget,
      );
      expect(controller.state!.revision, before.revision);
      expect(find.textContaining('chức vụ tiếp nhận: bậc 3/4'), findsOneWidget);
      final choice = find.byKey(ValueKey('appoint-candidate-${candidate.id}'));
      await tester.ensureVisible(choice);
      expect(
        find.descendant(
          of: choice,
          matching: find.textContaining(
            'Địa vị: ảnh hưởng ${candidate.influence}/100',
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(choice);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Tiếp nhận chức Hộ bộ (bậc 3/4)'),
        findsOneWidget,
      );
      final confirm = find.text(
        'Bổ nhiệm · ${appointmentCost(candidate, 'Hộ bộ')} tiền',
      );
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(
        controller.state!.court.firstWhere((c) => c.id == candidate.id).role,
        'Hộ bộ',
      );
      expect(
        controller.state!.court
            .firstWhere((c) => c.id == 'treasurer')
            .available,
        false,
      );
      expect(
        controller.state!.treasury,
        before.treasury - appointmentCost(candidate, 'Hộ bộ'),
      );
      expect(controller.state!.points, 2);
      expect(
        (await gateway.load()).active!.officialsPool.any(
          (c) => c.id == candidate.id,
        ),
        false,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'national work shows fit, chance, reward and risk before committing',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store, seasonal: false);
      await gateway.start(
        name: 'An',
        runId: 'assignment-ui',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      final controller = GameController(gateway);
      await controller.load();
      await tester.pumpWidget(
        GameApp(initialRoute: 'kingdom', controller: controller),
      );
      await tester.pumpAndSettle();
      final work = find.byTooltip('Chấn chỉnh triều chính');
      await tester.ensureVisible(work);
      await tester.tap(work);
      await tester.pumpAndSettle();
      final officer = find.byKey(const ValueKey('assign-govern-chancellor'));
      await tester.ensureVisible(officer);
      expect(
        find.descendant(
          of: officer,
          matching: find.textContaining('thành công'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: officer,
          matching: find.textContaining('Đúng chuyên môn'),
        ),
        findsOneWidget,
      );
      await tester.tap(officer);
      await tester.pumpAndSettle();
      expect(find.textContaining('Kinh phí không hoàn lại'), findsOneWidget);
      expect(controller.state!.points, 3);
      await tester.tap(find.text('Cân nhắc lại'));
      await tester.pumpAndSettle();
      expect(controller.state!.revision, 0);
      await tester.tap(work);
      await tester.pumpAndSettle();
      await tester.ensureVisible(officer);
      await tester.tap(officer);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xác nhận giao việc'));
      await tester.pumpAndSettle();
      expect(controller.state!.points, 2);
      expect(controller.state!.history.single['option'], 'chancellor');
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    testWidgets('all screens render without overflow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = GameController(
        LocalGameGateway(MemoryGameStore(), seasonal: false),
      );
      await controller.load();
      await tester.pumpWidget(
        GameApp(initialRoute: 'home', controller: controller),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mười tám tuổi.\nMột giang sơn.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Bắt đầu trị vì   →'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Người thử');
      await tester.tap(find.text('Nhận ngọc tỷ'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('giang-son-map')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('giang-son-palace')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('citadel-location-court')),
      );
      await tester.tap(find.byKey(const ValueKey('citadel-location-court')));
      await tester.pumpAndSettle();
      expect(find.text('Giang sơn trong tay người'), findsOneWidget);
      expect(find.byKey(const ValueKey('neglect-warning')), findsOneWidget);
      expect(tester.takeException(), isNull);
      for (final label in [
        'Quốc sự',
        'Ngân khố',
        'Triều thần',
        'Hậu cung',
        'Long thể',
        'Sử ký',
        'Bảng xếp hạng',
      ]) {
        await openSection(tester, label);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: label);
        if (label == 'Triều thần') {
          final category = find.byKey(const ValueKey('catalog-false-Võ ban'));
          await tester.ensureVisible(category);
          await tester.tap(category);
          await tester.pumpAndSettle();
          expect(find.text('Lê Trọng Uy'), findsOneWidget);
          expect(find.text('Trần Văn Chính'), findsNothing);
          final search = find.byKey(const ValueKey('people-search-false'));
          await tester.enterText(search, 'Đô đốc');
          await tester.pumpAndSettle();
          expect(find.text('Trần Hải Nam'), findsOneWidget);
          expect(find.text('Lê Trọng Uy'), findsNothing);
          await tester.enterText(search, 'Không có người này');
          await tester.pumpAndSettle();
          expect(
            find.textContaining('Không có nhân vật phù hợp.'),
            findsOneWidget,
          );
          await tester.enterText(search, '');
          final regional = find.byKey(
            const ValueKey('catalog-false-Địa phương'),
          );
          await tester.ensureVisible(regional);
          await tester.tap(regional);
          await tester.pumpAndSettle();
          expect(find.text('Địa phương (10)'), findsOneWidget);
          expect(find.text('Đang xem 10/35 người'), findsOneWidget);
          expect(find.text('Phan Nhật Quang'), findsOneWidget);
          expect(find.text('Hồ Đức Lâm'), findsOneWidget);
          expect(find.text('Ngô Khắc Nông'), findsOneWidget);
          await tester.enterText(search, 'Tri phủ');
          await tester.pumpAndSettle();
          expect(find.text('Đang xem 4/35 người'), findsOneWidget);
          await tester.enterText(search, 'Quan điền');
          await tester.pumpAndSettle();
          expect(find.text('Đang xem 3/35 người'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        if (label == 'Hậu cung') {
          expect(
            find.byKey(const ValueKey('catalog-true-Tú nữ')),
            findsOneWidget,
          );
          expect(find.text('Nguyễn Ngọc Lan'), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('catalog-true-Phi tần')));
          await tester.pumpAndSettle();
          expect(find.text('Nguyễn Ngọc Lan'), findsNothing);
          expect(
            find.textContaining('Không có nhân vật phù hợp.'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          final back = find.byKey(const ValueKey('section-back'));
          await tester.ensureVisible(back);
          await tester.tap(back);
          await tester.pumpAndSettle();
          final court = find.byKey(const ValueKey('citadel-location-court'));
          await Scrollable.ensureVisible(tester.element(court), alignment: .5);
          await tester.tap(court);
          await tester.pumpAndSettle();
        }
      }
    });
  }

  testWidgets('complete a run, show score and recover ending from storage', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MemoryGameStore();
    final gateway = LocalGameGateway(store, seasonal: false);
    await gateway.start(
      name: 'An',
      runId: 'test',
      seed: 42,
      previousRunId: null,
      previousRevision: null,
    );
    await store.update((archive) {
      archive.active!.health = 1;
      archive.active!.illness = 100;
    });
    final controller = GameController(gateway);
    await controller.load();
    await tester.pumpWidget(
      GameApp(initialRoute: 'court', controller: controller),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sang tuần tiếp theo   →'));
    await tester.pumpAndSettle();
    expect(find.text('Nguyên nhân kết thúc'), findsOneWidget);
    expect(find.text(controller.state!.endReason!), findsOneWidget);
    expect(find.text('Bạn đã trị vì được'), findsNothing);
    await tester.tap(find.text('Xem thời gian trị vì  →'));
    await tester.pumpAndSettle();
    expect(find.text('Bạn đã trị vì được'), findsOneWidget);
    expect(find.text('0 năm 0 tuần'), findsOneWidget);
    expect(controller.archive.scores, hasLength(1));
    await tester.tap(find.text('Xem scoreboard'));
    await tester.pumpAndSettle();
    expect(find.text('Những triều đại dài nhất'), findsOneWidget);
    expect(find.text('0 năm 0 tuần'), findsOneWidget);
    final recovered = GameController(LocalGameGateway(store, seasonal: false));
    await recovered.load();
    expect(recovered.state!.ended, true);
    expect(recovered.archive.scores, hasLength(1));
    // A page reload must still explain an already-ended saved reign.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      GameApp(initialRoute: 'court', controller: recovered),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nguyên nhân kết thúc'), findsOneWidget);
    expect(find.text(recovered.state!.endReason!), findsOneWidget);
    await tester.tap(find.text('Xem thời gian trị vì  →'));
    await tester.pumpAndSettle();
    expect(find.text('Bạn đã trị vì được'), findsOneWidget);
    expect(recovered.archive.scores, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'old rules scores remain viewable separately from current scores',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store, seasonal: false);
      await gateway.start(
        name: 'An',
        runId: 'score-view',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((archive) {
        archive.scores = [
          ScoreEntry('current', 'Vua mới', 5),
          ScoreEntry('old-04', 'Vua 0.4', 29, rules: 'mvp-0.4.0'),
          ScoreEntry('previous', 'Vua 0.3', 23, rules: 'mvp-0.3.0'),
          ScoreEntry('oldest', 'Vua 0.2', 52, rules: 'mvp-0.2.0'),
        ];
      });
      final controller = GameController(gateway);
      await controller.load();
      await tester.pumpWidget(
        GameApp(initialRoute: 'court', controller: controller),
      );
      await tester.pumpAndSettle();
      await openSection(tester, 'Bảng xếp hạng');
      await tester.pumpAndSettle();
      expect(find.text('Vua mới'), findsOneWidget);
      expect(find.text('Vua 0.3'), findsNothing);
      await tester.tap(find.text('Luật 0.4 (cũ)'));
      await tester.pumpAndSettle();
      expect(find.text('Vua 0.4'), findsOneWidget);
      expect(find.text('Vua mới'), findsNothing);
      await tester.tap(find.text('Luật 0.3 (cũ)'));
      await tester.pumpAndSettle();
      expect(find.text('Vua 0.3'), findsOneWidget);
      expect(find.text('Vua mới'), findsNothing);
      await tester.tap(find.text('Luật 0.2 (cũ)'));
      await tester.pumpAndSettle();
      expect(find.text('Vua 0.2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'critical court warning leads to a saved collapse ending on mobile',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store, seasonal: false);
      await gateway.start(
        name: 'An',
        runId: 'court-collapse',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((archive) {
        archive.active!.stability = 2;
        archive.active!.authority = 100;
        archive.active!.army = 100;
      });
      final controller = GameController(gateway);
      await controller.load();
      await tester.pumpWidget(
        GameApp(initialRoute: 'court', controller: controller),
      );
      await tester.pumpAndSettle();
      final warning = find.byKey(const ValueKey('court-collapse-warning'));
      await tester.ensureVisible(warning);
      expect(warning, findsOneWidget);
      expect(find.text('Ổn định triều đình nguy cấp'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Sang tuần  →'));
      await tester.pumpAndSettle();
      expect(find.text('Triều đình tan rã'), findsOneWidget);
      expect(
        find.textContaining('Ổn định triều đình đã giảm về 0'),
        findsOneWidget,
      );
      expect(find.text('Bạn đã trị vì được'), findsNothing);
      expect(controller.state!.stability, 0);
      expect(controller.archive.scores.single.weeks, 0);
      final restored = await gateway.load();
      expect(restored.active!.endKind, 'courtCollapse');
      expect(restored.scores, hasLength(1));
      await tester.tap(find.text('Xem thời gian trị vì  →'));
      await tester.pumpAndSettle();
      expect(find.text('0 năm 0 tuần'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('authority warning leads to a saved puppet ending on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MemoryGameStore();
    final gateway = LocalGameGateway(store);
    await gateway.start(
      name: 'An',
      runId: 'puppet-ending',
      seed: 42,
      previousRunId: null,
      previousRevision: null,
    );
    await store.update((archive) {
      archive.active!.authority = 1;
      archive.active!.stability = 100;
      archive.active!.petitions.clear();
    });
    final controller = GameController(gateway);
    await controller.load();
    await tester.pumpWidget(
      GameApp(initialRoute: 'court', controller: controller),
    );
    await tester.pumpAndSettle();
    final warning = find.byKey(const ValueKey('authority-zero-warning'));
    await tester.ensureVisible(warning);
    expect(warning, findsOneWidget);
    expect(find.text('Uy quyền nguy cấp'), findsOneWidget);
    expect(find.textContaining('Khép lại mùa'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('section-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('section-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('citadel-end-turn')));
    await tester.pumpAndSettle();
    expect(find.text('Vua trở thành bù nhìn'), findsOneWidget);
    expect(find.textContaining('Uy quyền đã giảm về 0'), findsOneWidget);
    expect(controller.state!.stability, greaterThan(25));
    expect(controller.archive.scores.single.weeks, 0);
    await controller.load();
    await tester.pumpAndSettle();
    expect(find.text('Vua trở thành bù nhìn'), findsOneWidget);
    expect(controller.state!.endKind, 'puppet');
    expect(controller.archive.scores, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'all five zero-stat warnings fit on mobile while recovery remains possible',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store, seasonal: false);
      await gateway.start(
        name: 'An',
        runId: 'critical-stats',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((archive) {
        final s = archive.active!;
        s.stability = 20;
        s.authority = 20;
        s.people = 20;
        s.army = 20;
        s.health = 20;
      });
      final controller = GameController(gateway);
      await controller.load();
      await tester.pumpWidget(
        GameApp(initialRoute: 'court', controller: controller),
      );
      await tester.pumpAndSettle();
      for (final key in [
        'court-collapse-warning',
        'authority-zero-warning',
        'people-zero-warning',
        'army-zero-warning',
        'health-zero-warning',
      ]) {
        final warning = find.byKey(ValueKey(key));
        await tester.ensureVisible(warning);
        expect(warning, findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      expect(find.text('5 chỉ số nguy cấp'), findsOneWidget);
      expect(controller.state!.ended, false);
      expect(controller.archive.scores, isEmpty);
    },
  );

  testWidgets(
    'long assassination explanation fits mobile before the time summary',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store, seasonal: false);
      await gateway.start(
        name: 'An',
        runId: 'mobile-ending',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      await store.update((archive) {
        archive.active!.endReason =
            'Vũ Thanh Liêm (phe Văn thần) đã bỏ độc nhà vua. Cấm vệ không ngăn kịp, ngự y không cứu được; nhà vua băng hà vì bị mưu sát.';
        archive.active!.endKind = 'poisoning';
        archive.active!.health = 0;
      });
      final controller = GameController(gateway);
      await controller.load();
      await tester.pumpWidget(
        GameApp(initialRoute: 'court', controller: controller),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bị mưu sát'), findsOneWidget);
      expect(find.byKey(const ValueKey('ending-reason')), findsOneWidget);
      expect(find.text('Bạn đã trị vì được'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Xem thời gian trị vì  →'));
      await tester.tap(find.text('Xem thời gian trị vì  →'));
      await tester.pumpAndSettle();
      expect(find.text('Bạn đã trị vì được'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'seasonal recommendation accepts the named tú nữ without palace admission',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryGameStore();
      final gateway = LocalGameGateway(store, seasonal: false);
      var archive = await gateway.start(
        name: 'An',
        runId: 'recruit-ui',
        seed: 42,
        previousRunId: null,
        previousRevision: null,
      );
      for (var i = 0; i < 3; i++) {
        final s = archive.active!;
        archive = await gateway.dispatch(
          GameCommand(
            id: 'week-$i',
            runId: s.runId,
            expectedRevision: s.revision,
            type: 'endWeek',
          ),
        );
      }
      final petition = archive.active!.petitions.singleWhere(
        (p) => p.definitionId == 'consort_recommendation',
      );
      final controller = GameController(gateway);
      await controller.load();
      await tester.pumpWidget(
        GameApp(initialRoute: 'court', controller: controller),
      );
      await tester.pumpAndSettle();
      final button = find.byKey(ValueKey('read-petition-${petition.id}'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Khước từ tiến cử'), findsOneWidget);
      expect(find.text('Giữ lại danh sách ứng viên'), findsNothing);
      expect(find.text('Chưa xét việc nạp phi'), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('court-reading')),
          matching: find.textContaining(
            archive.active!.court
                .firstWhere((c) => c.id == petition.targetId)
                .name,
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Nhận làm tú nữ'));
      await tester.pumpAndSettle();
      expect(
        controller.state!.court
            .firstWhere((c) => c.id == petition.targetId)
            .inHarem,
        false,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('confirm-petition')),
      );
      await tester.tap(find.byKey(const ValueKey('confirm-petition')));
      await tester.pumpAndSettle();
      expect(
        controller.state!.court
            .firstWhere((c) => c.id == petition.targetId)
            .inHarem,
        false,
      );
      final restored = await gateway.load();
      expect(
        restored.active!.court
            .firstWhere((c) => c.id == petition.targetId)
            .inHarem,
        false,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
