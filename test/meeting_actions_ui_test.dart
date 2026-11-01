import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/currency_rules.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/harem_rank_badge.dart';
import 'support/legacy_gateway.dart';

Future<GameController> openMeeting(
  WidgetTester tester, {
  required Size size,
  bool seasonal = true,
  int treasury = 1000,
  int points = 12,
  String rank = 'Tú nữ',
  int initialPlot = 0,
  int? initialDiscontent,
  int? initialAffection,
  int? initialAbility,
  bool gold = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final store = MemoryGameStore();
  final gateway = LocalGameGateway(
    store,
    seasonal: seasonal,
    engine: gold ? GameEngine(seasonal: seasonal) : null,
  );
  await gateway.start(
    name: 'An',
    runId: 'meeting-actions',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  await store.update((a) {
    a.active!.treasury = treasury;
    a.active!.points = points;
    final person = a.active!.court.firstWhere((c) => c.id == 'consort_lan');
    person.inHarem = rank != 'Tú nữ';
    person.queen = rank == 'Hoàng hậu';
    person.plot = initialPlot;
    if (initialAffection != null) person.affection = initialAffection;
    if (initialAbility != null) person.ability = initialAbility;
    if (initialDiscontent != null) person.discontent = initialDiscontent;
    if (points == 0) a.active!.overtime = 1;
  });
  final controller = GameController(gateway);
  await controller.load();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    GameApp(controller: controller, initialRoute: 'harem'),
  );
  await tester.pumpAndSettle();
  final meet = find.byKey(const ValueKey('meet-person-consort_lan'));
  await tester.ensureVisible(meet);
  await tester.tap(meet);
  await tester.pumpAndSettle();
  return controller;
}

Finder action(String id) => find.byKey(ValueKey('meeting-action-$id'));
Courtier lan(GameController controller) =>
    controller.state!.court.firstWhere((c) => c.id == 'consort_lan');

Future<void> tapAction(WidgetTester tester, String id) async {
  await tester.ensureVisible(action(id));
  await tester.tap(action(id));
  await tester.pumpAndSettle();
  expect(
    find.byKey(const ValueKey('meeting-action-confirmation')),
    findsOneWidget,
  );
  await tester.tap(find.byKey(const ValueKey('meeting-action-confirm')));
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [const Size(1440, 900), const Size(390, 844)]) {
    testWidgets(
      'investigation bars show saved intelligence instead of live values at $size',
      (tester) async {
        final controller = await openMeeting(
          tester,
          size: size,
          initialPlot: 43,
          initialDiscontent: 67,
        );
        String value(String id) =>
            tester.widget<Text>(find.byKey(ValueKey('meeting-$id'))).data!;
        expect(value('plot'), 'Chưa rõ');
        expect(value('discontent'), 'Chưa rõ');
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('meeting-plot'))).dy,
          greaterThan(
            tester
                .getTopLeft(find.byKey(const ValueKey('meeting-affection')))
                .dy,
          ),
        );
        final store = (controller.gateway as LocalGameGateway).store;
        Future<void> closeSeason() async {
          await store.update((a) {
            a.active!.petitions.clear();
            a.active!.nextMajorWeek = a.active!.nextChainWeek = 10000;
          });
          await controller.load();
          expect(await controller.act('endWeek'), true);
          await tester.pumpAndSettle();
        }

        await tapAction(tester, 'investigate');
        expect(value('plot'), 'Chưa rõ');
        expect(value('discontent'), 'Chưa rõ');
        await tapAction(tester, 'reward');
        expect(lan(controller).discontent, lessThan(67));
        expect(value('discontent'), 'Chưa rõ');
        await controller.load();
        await tester.pumpAndSettle();
        expect(value('plot'), 'Chưa rõ');
        expect(value('discontent'), 'Chưa rõ');
        await store.update((a) {
          final person = a.active!.court.firstWhere(
            (c) => c.id == 'consort_lan',
          );
          person.plot = 18;
          person.discontent = 35;
        });
        await closeSeason();
        expect(value('plot'), 'Chưa rõ');
        expect(value('discontent'), 'Chưa rõ');
        await closeSeason();
        expect(value('plot'), '43/100');
        expect(value('discontent'), '67/100');
        expect(
          find.textContaining('Chỉ cập nhật khi điều tra tiếp theo hoàn tất.'),
          findsOneWidget,
        );
        await store.update((a) {
          final person = a.active!.court.firstWhere(
            (c) => c.id == 'consort_lan',
          );
          person.plot = 18;
          person.discontent = 35;
        });
        await controller.load();
        await tester.pumpAndSettle();
        await tapAction(tester, 'investigate');
        expect(value('plot'), '43/100');
        expect(value('discontent'), '67/100');
        await closeSeason();
        expect(value('plot'), '43/100');
        expect(value('discontent'), '67/100');
        await closeSeason();
        expect(value('plot'), '18/100');
        expect(value('discontent'), '35/100');
        await controller.load();
        await tester.pumpAndSettle();
        expect(value('plot'), '18/100');
        expect(value('discontent'), '35/100');
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in [
    const Size(1440, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    for (final rank in ['Tú nữ', 'Phi tần', 'Hoàng hậu']) {
      testWidgets(
        'discipline $rank requires confirmation and refreshes roster at $size',
        (tester) async {
          final controller = await openMeeting(
            tester,
            size: size,
            rank: rank,
            treasury: 0,
          );
          final before = controller.state!.copy();
          final person = before.court.firstWhere((c) => c.id == 'consort_lan');
          expect(
            tester.widget<OutlinedButton>(action('expel')).onPressed,
            rank == 'Tú nữ' ? isNotNull : isNull,
          );
          expect(
            tester.widget<OutlinedButton>(action('demote')).onPressed,
            rank == 'Tú nữ' ? isNull : isNotNull,
          );
          final id = rank == 'Tú nữ' ? 'expel' : 'demote';
          await tester.ensureVisible(action(id));
          await tester.tap(action(id));
          await tester.pumpAndSettle();
          final popup = find.byKey(
            const ValueKey('meeting-action-confirmation'),
          );
          expect(
            find.descendant(of: popup, matching: find.text('1 hành động')),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: popup,
              matching: find.textContaining(
                rank == 'Hoàng hậu'
                    ? 'Ổn định triều đình −8'
                    : 'Ổn định triều đình không đổi',
              ),
            ),
            findsOneWidget,
          );
          if (rank == 'Hoàng hậu') {
            expect(
              find.textContaining('Thiện cảm −30, bất mãn +30'),
              findsOneWidget,
            );
          } else if (rank == 'Tú nữ') {
            expect(
              find.textContaining('Không thể tuyển lại nhân vật này.'),
              findsOneWidget,
            );
            expect(find.textContaining('−2;'), findsOneWidget);
          }
          expect(controller.state!.toJson(), before.toJson());
          await tester.tap(find.byKey(const ValueKey('meeting-action-cancel')));
          await tester.pumpAndSettle();
          expect(controller.state!.toJson(), before.toJson());
          expect(
            (await controller.gateway.load()).active!.toJson(),
            before.toJson(),
          );

          await tapAction(tester, id);
          expect(controller.state!.treasury, 0);
          expect(controller.state!.points, before.points - 1);
          expect(controller.state!.revision, before.revision + 1);
          expect(
            controller.state!.stability,
            rank == 'Hoàng hậu' ? before.stability - 8 : before.stability,
          );
          if (rank != 'Tú nữ') {
            final loss = rank == 'Hoàng hậu' ? 30 : 20;
            expect(
              lan(controller).displayRole,
              rank == 'Hoàng hậu' ? 'Phi tần' : 'Tú nữ',
            );
            expect(
              lan(controller).affection,
              (person.affection - loss).clamp(0, 100),
            );
            expect(
              lan(controller).discontent,
              (person.discontent + loss).clamp(0, 100),
            );
            expect(find.text('${person.age} tuổi'), findsOneWidget);
            expect(
              tester
                  .widget<HaremRankBadge>(
                    find.byKey(const ValueKey('meeting-harem-rank')),
                  )
                  .rank,
              lan(controller).displayRole,
            );
            expect(
              tester.widget<OutlinedButton>(action('invite')).onPressed,
              isNull,
            );
            if (rank == 'Hoàng hậu') {
              // A second explicit confirmation is needed to reach Tú nữ.
              expect(
                tester.widget<OutlinedButton>(action('expel')).onPressed,
                isNull,
              );
              await tapAction(tester, 'demote');
              expect(lan(controller).displayRole, 'Tú nữ');
            }
            expect(
              tester.widget<OutlinedButton>(action('demote')).onPressed,
              isNull,
            );
            await tapAction(tester, 'expel');
          }
          expect(lan(controller).available, isFalse);
          expect(
            find.byKey(const ValueKey('character-meeting-page')),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('scene-header-harem')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('meet-person-consort_lan')),
            findsNothing,
          );
          expect(controller.state!.treasury, 0);
          final committed = controller.state!.toJson();
          await controller.load();
          await tester.pumpAndSettle();
          expect(controller.state!.toJson(), committed);
          expect((await controller.gateway.load()).active!.toJson(), committed);
          expect(
            find.byKey(const ValueKey('meet-person-consort_lan')),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final size in [
    const Size(1440, 900),
    const Size(844, 390),
    const Size(320, 568),
  ]) {
    testWidgets(
      'meeting confirmation previews and cancellation preserve save at $size',
      (tester) async {
        final controller = await openMeeting(tester, size: size);
        final before = controller.state!.toJson();
        for (final id in ['audience', 'reward', 'investigate', 'invite']) {
          await tester.ensureVisible(action(id));
          await tester.tap(action(id));
          await tester.pumpAndSettle();
          final popup = find.byKey(
            const ValueKey('meeting-action-confirmation'),
          );
          expect(popup, findsOneWidget);
          expect(
            find.descendant(of: popup, matching: find.text('Lợi ích')),
            findsOneWidget,
          );
          expect(
            find.descendant(of: popup, matching: find.text('Chi phí')),
            findsOneWidget,
          );
          expect(
            find.descendant(of: popup, matching: find.text('Lưu ý')),
            findsOneWidget,
          );
          expect(find.text('Bỏ qua'), findsOneWidget);
          expect(find.text('Thực hiện'), findsOneWidget);
          expect(controller.state!.toJson(), before);
          expect((await controller.gateway.load()).active!.toJson(), before);
          // Exercise each supported dismissal path without committing an action.
          if (id == 'reward') {
            await tester.tap(
              find.byKey(const ValueKey('close-imperial-dialog')),
            );
          } else if (id == 'investigate') {
            await tester.binding.handlePopRoute();
          } else {
            await tester.tap(
              find.byKey(const ValueKey('meeting-action-cancel')),
            );
          }
          await tester.pumpAndSettle();
          expect(popup, findsNothing);
          expect(controller.state!.toJson(), before);
          expect((await controller.gateway.load()).active!.toJson(), before);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  for (final seasonal in [true, false]) {
    for (final size in [const Size(1440, 900), const Size(390, 844)]) {
      testWidgets(
        'four meeting actions commit once and refresh the open page at $size seasonal=$seasonal',
        (tester) async {
          final controller = await openMeeting(
            tester,
            size: size,
            seasonal: seasonal,
          );
          final original = controller.state!.copy();
          final originalDescription =
              tester
                  .widget<Text>(
                    find.byKey(const ValueKey('meeting-description')),
                  )
                  .data;
          var affection = lan(controller).affection;
          await tapAction(tester, 'audience');
          expect(controller.state!.points, original.points - 1);
          expect(controller.state!.revision, original.revision + 1);
          expect(controller.state!.treasury, original.treasury);
          expect(lan(controller).affection, greaterThan(affection));
          expect(
            tester
                .widget<Text>(find.byKey(const ValueKey('meeting-affection')))
                .data,
            '${lan(controller).affection}',
          );

          affection = lan(controller).affection;
          await tapAction(tester, 'reward');
          expect(controller.state!.points, original.points - 2);
          expect(controller.state!.revision, original.revision + 2);
          expect(
            controller.state!.treasury,
            original.treasury - money(original, 20),
          );
          expect(lan(controller).affection, greaterThan(affection));
          expect(
            tester
                .widget<Text>(find.byKey(const ValueKey('meeting-affection')))
                .data,
            '${lan(controller).affection}',
          );

          await tapAction(tester, 'investigate');
          expect(controller.state!.points, original.points - 3);
          expect(
            controller.state!.pending.where(
              (p) => p.kind == 'investigate' && p.target == lan(controller).id,
            ),
            hasLength(1),
          );
          expect(
            tester.widget<OutlinedButton>(action('investigate')).onPressed,
            isNull,
          );
          expect(find.text('Đang điều tra'), findsOneWidget);

          await tapAction(tester, 'invite');
          expect(controller.state!.points, original.points - 4);
          expect(controller.state!.revision, original.revision + 4);
          expect(
            controller.state!.treasury,
            original.treasury -
                money(original, 20) -
                investigationCost(original) -
                money(original, 35),
          );
          expect(lan(controller).inHarem, isTrue);
          expect(find.text('${lan(controller).age} tuổi'), findsOneWidget);
          expect(
            tester.widget<OutlinedButton>(action('invite')).onPressed,
            isNull,
          );
          expect(find.text('Đã nhập cung'), findsOneWidget);
          expect(
            tester
                .widget<Text>(find.byKey(const ValueKey('meeting-description')))
                .data,
            originalDescription,
          );
          expect(
            (await controller.gateway.load()).active!.toJson(),
            controller.state!.toJson(),
          );
          await controller.load();
          await tester.pumpAndSettle();
          expect(find.text('${lan(controller).age} tuổi'), findsOneWidget);
          expect(
            tester.widget<OutlinedButton>(action('invite')).onPressed,
            isNull,
          );
          await tester.tap(find.byKey(const ValueKey('meeting-back')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('scene-header-harem')),
            findsOneWidget,
          );
          expect(find.text('${lan(controller).age} tuổi'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final points in [0, 1]) {
    testWidgets('meeting disables unaffordable actions with $points points', (
      tester,
    ) async {
      final controller = await openMeeting(
        tester,
        size: const Size(390, 844),
        treasury: 0,
        points: points,
      );
      final before = controller.state!.toJson();
      expect(
        tester.widget<OutlinedButton>(action('audience')).onPressed,
        points == 0 ? isNull : isNotNull,
      );
      for (final id in ['reward', 'investigate', 'invite']) {
        expect(tester.widget<OutlinedButton>(action(id)).onPressed, isNull);
      }
      expect(
        tester.widget<OutlinedButton>(action('expel')).onPressed,
        points == 0 ? isNull : isNotNull,
      );
      expect(tester.widget<OutlinedButton>(action('demote')).onPressed, isNull);
      expect(controller.state!.toJson(), before);
      expect(tester.takeException(), isNull);
    });
  }
}
