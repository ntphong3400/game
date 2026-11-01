// A separate in-memory preview; never reads or overwrites the player's save.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = MemoryGameStore();
  final gateway = LocalGameGateway(store);
  final country =
      ['north', 'west', 'south'].contains(Uri.base.queryParameters['front'])
          ? Uri.base.queryParameters['front']!
          : 'south';
  final place = Uri.base.queryParameters['place'];
  final scenario = Uri.base.queryParameters['scenario'];
  await gateway.start(
    name: 'Thiên Hòa',
    runId: 'frontier-preview',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  final controller = GameController(gateway);
  await controller.load();
  if (scenario == 'war' || scenario == 'weak') {
    await controller.act(
      'war',
      target: country,
      option: jsonEncode({'action': 'declare'}),
    );
  }
  if (scenario == 'weak') {
    await controller.act(
      'transfer',
      target: 'capital',
      option: jsonEncode({'from': country, 'count': 5000}),
    );
  }
  final route =
      'frontier-$country${['camp', 'command', 'gate'].contains(place) ? '-$place' : ''}';
  runApp(GameApp(controller: controller, initialRoute: route));
}
