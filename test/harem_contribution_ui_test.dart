import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/logic/harem_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/meeting_scenes.dart';
import 'meeting_actions_ui_test.dart' as meeting;

Future<void> expandContributions(WidgetTester tester) async {
  final toggle = find.text('Đóng góp hậu cung');
  await tester.ensureVisible(toggle);
  await tester.tap(toggle);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [const Size(1440, 900), const Size(320, 568)]) {
    testWidgets(
      'contribution preview and status follow admission and demotion at $size',
      (tester) async {
        final controller = await meeting.openMeeting(
          tester,
          size: size,
          gold: true,
          treasury: 20000,
          initialAffection: 65,
          initialAbility: 61,
        );
        final block = find.byKey(const ValueKey('meeting-contributions'));
        await tester.ensureVisible(block);
        expect(find.text('Đóng góp hậu cung'), findsOneWidget);
        final collapsed = tester.getSize(block).height;
        expect(
          find.byKey(const ValueKey('meeting-contributions-details')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('meeting-contribution-summary-0')),
          findsOneWidget,
        );
        expect(
          find.text('Kích hoạt sau khi trở thành Phi tần'),
          findsOneWidget,
        );
        final beforeReading = controller.state!.toJson();
        await expandContributions(tester);
        expect(tester.getSize(block).height, greaterThan(collapsed * 1.5));
        expect(
          find.byKey(const ValueKey('meeting-contributions-details')),
          findsOneWidget,
        );
        expect(controller.state!.toJson(), beforeReading);
        await expandContributions(tester);
        expect(tester.getSize(block).height, collapsed);
        expect(
          (await controller.gateway.load()).active!.toJson(),
          beforeReading,
        );
        await expandContributions(tester);

        expect(
          find.text('Có thể kích hoạt sau khi trở thành Phi tần'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Điều kiện chung: đã nhập cung, thiện cảm >70 và năng lực >60.',
          ),
          findsOneWidget,
        );
        expect(
          tester.getTopLeft(block).dy,
          greaterThan(
            tester
                .getTopLeft(
                  find.byKey(const ValueKey('meeting-investigation-date')),
                )
                .dy,
          ),
        );
        expect(
          tester.getTopLeft(block).dy,
          lessThan(
            tester
                .getTopLeft(find.byKey(const ValueKey('meeting-description')))
                .dy,
          ),
        );
        final before = controller.state!.toJson();
        await tester.ensureVisible(meeting.action('invite'));
        await tester.tap(meeting.action('invite'));
        await tester.pumpAndSettle();
        final preview = haremPassivePreview(
          meeting.lan(controller),
          state: controller.state!,
        );
        expect(
          find.textContaining(
            'Đóng góp hậu cung sau khi trở thành Phi tần:\n$preview',
          ),
          findsOneWidget,
        );
        expect(controller.state!.toJson(), before);
        await tester.tap(find.byKey(const ValueKey('meeting-action-cancel')));
        await tester.pumpAndSettle();
        expect((await controller.gateway.load()).active!.toJson(), before);
        await meeting.tapAction(tester, 'invite');
        await tester.ensureVisible(block);
        expect(find.text('Đang hoạt động'), findsOneWidget);
        expect(
          find.text('Có thể kích hoạt sau khi trở thành Phi tần'),
          findsNothing,
        );
        expect(meeting.lan(controller).affection, 73);
        await controller.load();
        await tester.pumpAndSettle();
        expect(find.text('Đang hoạt động'), findsOneWidget);
        await meeting.tapAction(tester, 'demote');
        await tester.ensureVisible(block);
        expect(
          find.text('Có thể kích hoạt sau khi trở thành Phi tần'),
          findsOneWidget,
        );
        expect(find.text('Đang hoạt động'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'inactive contribution lists both missing conditions and updates when eligible',
    (tester) async {
      final controller = await meeting.openMeeting(
        tester,
        size: const Size(390, 844),
        rank: 'Phi tần',
        initialAffection: 70,
        initialAbility: 60,
      );
      await expandContributions(tester);
      expect(
        find.text('Chưa kích hoạt · cần thiện cảm >70, cần năng lực >60'),
        findsOneWidget,
      );
      final store = (controller.gateway as LocalGameGateway).store;
      await store.update((a) {
        final c = a.active!.court.firstWhere((c) => c.id == 'consort_lan');
        c
          ..affection = 71
          ..ability = 61;
      });
      await controller.load();
      await tester.pumpAndSettle();
      expect(find.text('Đang hoạt động'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'queen has a separate additional contribution and strict ability requirement',
    (tester) async {
      final controller = await meeting.openMeeting(
        tester,
        size: const Size(390, 844),
        rank: 'Hoàng hậu',
        initialAffection: 96,
        initialAbility: 90,
      );
      expect(
        find.byKey(const ValueKey('meeting-contribution-summary-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('meeting-contribution-summary-1')),
        findsOneWidget,
      );
      expect(find.text('Đóng góp bổ sung của Hoàng hậu'), findsNothing);
      await expandContributions(tester);
      expect(find.text('Đóng góp bổ sung của Hoàng hậu'), findsOneWidget);
      expect(find.text('Đang hoạt động'), findsOneWidget);
      expect(find.text('Chưa kích hoạt · cần năng lực >90'), findsOneWidget);
      expect(
        find.text('Điều kiện riêng: Hoàng hậu và năng lực >90.'),
        findsOneWidget,
      );
      final store = (controller.gateway as LocalGameGateway).store;
      await store.update((a) {
        a.active!.court.firstWhere((c) => c.id == 'consort_lan').ability = 91;
      });
      await controller.load();
      await tester.pumpAndSettle();
      expect(find.text('Đang hoạt động'), findsNWidgets(2));
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('meeting-contribution-effect-1')),
            )
            .data,
        endsWith('+2/mùa'),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('weekly games do not advertise seasonal contributions', (
    tester,
  ) async {
    await meeting.openMeeting(
      tester,
      size: const Size(390, 844),
      seasonal: false,
    );
    expect(find.byKey(const ValueKey('meeting-contributions')), findsNothing);
    await tester.ensureVisible(meeting.action('invite'));
    await tester.tap(meeting.action('invite'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Đóng góp hậu cung sau khi trở thành Phi tần'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  test(
    'public contribution figures respect currency and explain the shared cap without changing state',
    () {
      for (final gold in [true, false]) {
        final s = GameEngine(
          goldEnabled: gold,
        ).start('contributions', 'An', 42);
        final c = s.court.firstWhere((c) => c.id == 'consort_lan');
        c
          ..faction = 'Thế gia'
          ..personalities.clear();
        c.personalities.add(Personality.familyFirst);
        c
          ..inHarem = true
          ..ability = 80
          ..affection = 96;
        s.court.removeWhere((p) => p.isConsort && p.id != c.id);
        final before = s.toJson();
        final result = haremMeetingContributions(c, s).single;
        expect(
          result.effect,
          gold
              ? 'Gia sản gia tộc +1.000 lượng vàng/mùa'
              : 'Gia sản gia tộc +10 tiền/mùa',
        );
        expect(result.active, true);
        expect(result.enhancement, isNull);
        expect(s.toJson(), before);
        for (final id in ['aaa', 'aab']) {
          s.court.add(Courtier.fromJson({...c.toJson(), 'id': id}));
        }
        final capped = haremMeetingContributions(c, s).single;
        expect(capped.status, contains('Thực nhận +0'));
        expect(capped.summary, startsWith('Ngân khố +0 '));
        expect(capped.effect, contains(gold ? '+1.000 ' : '+10 '));
        expect(capped.status, contains('giới hạn toàn hậu cung'));
      }
    },
  );
}
