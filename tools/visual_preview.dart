// Reproducible visual preview using an isolated, in-memory reign.
// flutter build web -t tools/visual_preview.dart --output build/visual-preview
import 'package:flutter/material.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/models/game_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = MemoryGameStore();
  final gateway = LocalGameGateway(store);
  await gateway.start(
    name: 'Thiên Hòa',
    runId: 'visual-preview',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  if (Uri.base.queryParameters['example'] == 'memorial') {
    await store.update((archive) {
      final s = archive.active!;
      s.affairsThisWeek = 1;
      s.petitions = [
        for (final title in [
          'Ruộng trũng nuôi cá',
          'Vết nứt bên dòng Đại Hà',
          'Đường buôn dọc bờ hồ',
        ])
          Petition(
            id: 'preview-$title',
            definitionId: events.firstWhere((e) => e.title == title).id,
            openedWeek: s.week,
            deadline: s.week,
          ),
      ];
    });
  }
  final controller = GameController(gateway);
  await controller.load();
  runApp(
    GameApp(
      controller: controller,
      initialRoute: Uri.base.queryParameters['room'] ?? 'harem',
    ),
  );
}
