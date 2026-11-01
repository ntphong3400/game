import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/meeting_scenes.dart';

void main() {
  test('all 90 saved identities have distinct, bundled full-body assets', () {
    final paths = <String>{};
    for (final id in [...haremPortraitIds, ...officialPortraitIds]) {
      final person = initialCourt().firstWhere(
        (c) => c.isConsort == id.startsWith('harem'),
      );
      person.portraitId = id;
      final path = meetingCharacterAsset(person);
      expect(File(path).existsSync(), isTrue, reason: id);
      expect(paths.add(path), isTrue, reason: id);
    }
    expect(paths, hasLength(90));
  });

  test(
    'scenes cover court and replacement pool without mutating saved data',
    () {
      final state = GameEngine().start('meetings', 'An', 42);
      final before = state.toJson();
      for (final person in [...state.court, ...state.officialsPool]) {
        final scene = meetingSceneFor(person, state: state);
        expect(scene.name, person.name);
        expect(scene.role, person.displayRole);
        expect(scene.age, person.age);
        expect(scene.affection, person.affection);
        expect(scene.ability, person.ability);
        expect(
          scene.backgroundAsset,
          person.isConsort
              ? 'assets/images/harem-interior.webp'
              : 'assets/images/people-interior.webp',
        );
        expect(scene.characterAsset, meetingCharacterAsset(person));
        if (!person.isConsort) {
          expect(
            scene.contributions.map((c) => (c.title, c.summary, c.active)),
            personMeetingContributions(
              person,
              state,
            ).map((c) => (c.title, c.summary, c.active)),
          );
        }
      }
      expect(state.toJson(), before);
    },
  );

  test(
    'a recruited official keeps their saved face after appointment and reload',
    () {
      final state = GameEngine().start('meetings', 'An', 42);
      final person = state.officialsPool.first;
      final art = meetingCharacterAsset(person);
      person.role = 'Tể tướng';
      expect(meetingSceneFor(person).characterAsset, art);
      final restored = Courtier.fromJson(person.toJson());
      expect(restored.role, 'Tể tướng');
      expect(meetingCharacterAsset(restored), art);
      expect(restored.portraitId, person.portraitId);
    },
  );

  test('uninvestigated live values are never disclosed by a meeting scene', () {
    final person = initialCourt().first;
    person.plot = 87;
    person.discontent = 93;
    final scene = meetingSceneFor(person);
    expect(scene.investigatedPlot, isNull);
    expect(scene.investigatedDiscontent, isNull);
    expect(scene.investigatedAt, isNull);
  });
}
