import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/harem_rules.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/meeting_scenes.dart';
import 'meeting_actions_ui_test.dart' as meeting;
import 'support/harem_fixture.dart';

Future<void> expandContributions(WidgetTester tester) async {
  final toggle = find.text('Đóng góp hậu cung');
  await tester.ensureVisible(toggle);
  await tester.tap(toggle);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [const Size(1440, 900), const Size(320, 568)]) {
    testWidgets(
      'meeting explains story gates without female ability and reads without mutations at $size',
      (tester) async {
        final c = await meeting.openMeeting(
          tester,
          size: size,
          gold: true,
          rank: 'Phi tần',
          initialAffection: 75,
        );
        expect(find.byKey(const ValueKey('meeting-ability')), findsNothing);
        expect(meeting.action('palace-study'), findsNothing);
        expect(meeting.action('palace-duty'), findsNothing);
        expect(meeting.action('harem-quest'), findsOneWidget);
        final before = c.state!.toJson();
        await expandContributions(tester);
        expect(
          find.textContaining('Chưa hoàn thành câu chuyện cá nhân'),
          findsWidgets,
        );
        expect(find.textContaining('thiện cảm >70'), findsWidgets);
        await expandContributions(tester);
        expect(c.state!.toJson(), before);
        expect((await c.gateway.load()).active!.toJson(), before);
        expect(tester.takeException(), isNull);
      },
    );
  }
  test(
    'public contribution figures use completed stories, new gold cap and pure previews',
    () {
      for (final gold in [true, false]) {
        final s = GameEngine(
          goldEnabled: gold,
        ).start('contributions', 'An', 42);
        final c = s.court.firstWhere((c) => c.id == 'consort_lan');
        c.faction = 'Thế gia';
        c.personalities
          ..clear()
          ..add(Personality.familyFirst);
        c.inHarem = true;
        c.affection = 96;
        s.court.removeWhere((p) => p.isConsort && p.id != c.id);
        completeHaremStory(s, c);
        final before = s.toJson();
        final result = haremMeetingContributions(c, s).single;
        expect(
          result.effect,
          gold
              ? 'Gia sản gia tộc +1.000 lượng vàng/mùa'
              : 'Gia sản gia tộc +10 tiền/mùa',
        );
        expect(result.active, isTrue);
        expect(result.enhancement, isNull);
        expect(s.toJson(), before);
        for (var i = 0; i < 5; i++) {
          final other = Courtier.fromJson({...c.toJson(), 'id': 'aaa-$i'});
          s.court.add(other);
          completeHaremStory(s, other);
        }
        final capped = haremMeetingContributions(c, s).single;
        expect(capped.status, contains('Thực nhận +0'));
        expect(capped.summary, startsWith('Ngân khố +0 '));
        expect(HaremBenefits(s).total(HaremBenefit.treasury), 50);
      }
    },
  );
}
