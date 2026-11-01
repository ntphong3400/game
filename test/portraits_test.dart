import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/data/content.dart';
import 'support/legacy_engine.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/presentation/widgets/imperial_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final engine = GameEngine();
  GameState fresh() => engine.start('portraits', 'Thiên Hòa', 42);
  List<Courtier> people(GameState s) => [...s.court, ...s.officialsPool];
  Courtier arrival(Courtier template, String id) => Courtier.fromJson({
    ...template.toJson(),
    'id': id,
    'portraitId': null,
    'available': true,
  });

  test(
    '91 identities provide 273 age portraits and bundled WebP assets',
    () async {
      final ids = [
        emperorPortraitId,
        ...officialPortraitIds,
        ...haremPortraitIds,
      ];
      expect(ids.toSet(), hasLength(91));
      expect(ids.length * PortraitAge.values.length, 273);
      for (final id in ids) {
        expect(File(portraitAsset(id)).existsSync(), true, reason: id);
        final data = await rootBundle.load(portraitAsset(id));
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        final frame = await codec.getNextFrame();
        expect(frame.image.width, 1536, reason: id);
        expect(frame.image.height, 512, reason: id);
        frame.image.dispose();
        codec.dispose();
      }
      final authored = initialCourt();
      expect(authored, hasLength(45));
      expect(
        authored.map((c) => initialPortraits[c.id]).toSet(),
        hasLength(45),
      );
      expect(authored.every((c) => initialPortraits.containsKey(c.id)), true);
    },
  );

  test('age changes precisely at 35 and 55 with the same identity', () {
    final c = fresh().court.first;
    final id = c.resolvedPortraitId;
    for (final (age, expected) in [
      (18, PortraitAge.young),
      (34, PortraitAge.young),
      (35, PortraitAge.middle),
      (54, PortraitAge.middle),
      (55, PortraitAge.elder),
      (90, PortraitAge.elder),
    ]) {
      c.age = age;
      expect(c.portraitAge, expected);
      expect(c.resolvedPortraitId, id);
    }
  });

  test('all 57 starting people have distinct appropriate persistent faces', () {
    final s = fresh();
    expect(people(s), hasLength(57));
    expect(people(s).map((c) => c.portraitId).toSet(), hasLength(57));
    for (final c in people(s)) {
      expect(validCharacterPortrait(c.portraitId, harem: c.isConsort), true);
    }
    expect(s.copy().toJson(), s.toJson());
    final again = engine.start('other-run', 'Khác', 99);
    for (final c in s.court) {
      expect(
        again.court.firstWhere((p) => p.id == c.id).portraitId,
        c.portraitId,
      );
    }
  });

  test(
    'old saves migrate deterministically without changing gameplay values',
    () {
      final s = fresh();
      final raw = object(jsonDecode(jsonEncode(s.toJson())));
      for (final key in ['court', 'officialsPool']) {
        for (final c in raw[key] as List) {
          (c as Map).remove('portraitId');
        }
      }
      final restored = GameState.fromJson(raw);
      final twice = GameState.fromJson(raw);
      expect(restored.rng, s.rng);
      expect(restored.revision, s.revision);
      expect(restored.treasury, s.treasury);
      expect(restored.points, s.points);
      expect(
        restored.financialWeeks.map((w) => w.toJson()),
        s.financialWeeks.map((w) => w.toJson()),
      );
      expect(people(restored).map((c) => c.portraitId).toSet(), hasLength(57));
      expect(twice.toJson(), restored.toJson());
      expect(restored.copy().toJson(), restored.toJson());
    },
  );

  test(
    'new arrivals use all 60 faces before sharing and can reuse departed faces',
    () {
      final s = fresh();
      final template = s.officialsPool.first;
      final before = {for (final c in people(s)) c.id: c.portraitId};
      for (var i = 0; i < 13; i++) {
        s.officialsPool.add(arrival(template, 'new-official-$i'));
      }
      s.ensurePortraits();
      final officials = people(s).where((c) => !c.isConsort).toList();
      expect(officials, hasLength(60));
      expect(officials.map((c) => c.portraitId).toSet(), hasLength(60));
      for (final c in people(s).where((c) => before.containsKey(c.id))) {
        expect(c.portraitId, before[c.id]);
      }
      final departed = s.officialsPool.removeLast()..available = false;
      s.court.add(departed);
      final next = arrival(template, 'after-retirement');
      s.officialsPool.add(next);
      s.ensurePortraits();
      expect(next.portraitId, departed.portraitId);
      expect(
        people(s)
            .where((c) => c.available && !c.isConsort)
            .map((c) => c.portraitId)
            .toSet(),
        hasLength(60),
      );
      final overflow = arrival(template, 'after-capacity');
      s.officialsPool.add(overflow);
      s.ensurePortraits();
      expect(validCharacterPortrait(overflow.portraitId, harem: false), true);
      expect(
        people(s)
            .where((c) => c.available && !c.isConsort)
            .map((c) => c.portraitId)
            .toSet(),
        hasLength(60),
      );
    },
  );

  test(
    'harem arrivals fill 30 identities then share without borrowing male faces',
    () {
      final s = fresh();
      final template = s.court.firstWhere((c) => c.isConsort);
      for (var i = 0; i < 20; i++) {
        s.court.add(arrival(template, 'new-harem-$i'));
      }
      s.ensurePortraits();
      expect(
        s.court.where((c) => c.isConsort).map((c) => c.portraitId).toSet(),
        hasLength(30),
      );
      s.court.add(arrival(template, 'harem-overflow'));
      s.ensurePortraits();
      for (final c in s.court.where((c) => c.isConsort)) {
        expect(haremPortraitIds, contains(c.portraitId));
      }
    },
  );

  test(
    'appointment retains the candidate face and gives the replacement a free face',
    () {
      final s = fresh();
      final candidate = s.officialsPool.first;
      final face = candidate.portraitId;
      final next = engine.execute(
        s,
        GameCommand(
          id: 'appoint-face',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'appoint',
          target: 'general',
          option: candidate.id,
        ),
      );
      expect(
        next.court.firstWhere((c) => c.id == candidate.id).portraitId,
        face,
      );
      final living = people(next).where((c) => c.available).toList();
      expect(living.map((c) => c.portraitId).toSet(), hasLength(living.length));
      expect(next.copy().toJson(), next.toJson());
    },
  );

  test(
    'annual aging changes the stage while seasonal recruitment assigns a new face',
    () {
      var s = fresh();
      s.completedWeeks = 3;
      s.court.firstWhere((c) => c.id == 'chancellor').age = 34;
      final original =
          s.court.firstWhere((c) => c.id == 'chancellor').portraitId;
      s = engine.execute(
        s,
        GameCommand(
          id: 'annual-age',
          runId: s.runId,
          expectedRevision: s.revision,
          type: 'endWeek',
        ),
      );
      final minister = s.court.firstWhere((c) => c.id == 'chancellor');
      expect(minister.age, 35);
      expect(minister.portraitAge, PortraitAge.middle);
      expect(minister.portraitId, original);
      final newWomen = s.court.where(
        (c) => c.isConsort && !initialPortraits.containsKey(c.id),
      );
      expect(newWomen, isNotEmpty);
      final women = s.court.where((c) => c.available && c.isConsort).toList();
      expect(women.map((c) => c.portraitId).toSet(), hasLength(women.length));
    },
  );

  test(
    'bad IDs and cross-group IDs are repaired without changing valid faces',
    () {
      final s = fresh();
      final valid = s.court[2].portraitId;
      s.court.first.portraitId = '../bad-path';
      s.court[1].portraitId = 'harem-001';
      s.court.firstWhere((c) => c.isConsort).portraitId = 'official-001';
      final restored = s.copy();
      for (final c in people(restored)) {
        expect(validCharacterPortrait(c.portraitId, harem: c.isConsort), true);
      }
      expect(restored.court[2].portraitId, valid);
    },
  );

  testWidgets('portraits render the correct age cell for people and emperor', (
    tester,
  ) async {
    final c = fresh().court.firstWhere((c) => c.id == 'chancellor');
    Future<void> show(Widget child) async {
      await tester.pumpWidget(MaterialApp(home: Center(child: child)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    c.age = 34;
    await show(CharacterPortrait(person: c));
    expect(find.byKey(ValueKey('${c.portraitId}-young')), findsOneWidget);
    c.age = 35;
    await show(CharacterPortrait(person: c));
    expect(find.byKey(ValueKey('${c.portraitId}-middle')), findsOneWidget);
    await show(const CharacterPortrait(emperor: true, emperorAge: 55));
    expect(find.byKey(const ValueKey('emperor-elder')), findsOneWidget);
  });
}
