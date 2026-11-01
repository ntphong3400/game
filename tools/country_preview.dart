// Isolated in-memory preview: never reads or overwrites a player's save.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:van_tue/app/game_controller.dart';
import 'package:van_tue/game/data/game_store.dart';
import 'package:van_tue/game/logic/game_gateway.dart';
import 'package:van_tue/game/presentation/game_app.dart';
import 'package:van_tue/game/presentation/widgets/country_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final params = Uri.base.queryParameters;
  final country =
      countryNames.containsKey(params['country'])
          ? params['country']!
          : 'north';
  final gateway = LocalGameGateway(MemoryGameStore());
  await gateway.start(
    name: 'Thiên Hòa',
    runId: 'country-preview',
    seed: 42,
    previousRunId: null,
    previousRevision: null,
  );
  final controller = GameController(gateway);
  await controller.load();
  if (params['scenario'] == 'war') {
    await controller.act(
      'war',
      target: country,
      option: jsonEncode({'action': 'declare'}),
    );
  }
  final place =
      countryPlaceNames.containsKey(params['place']) ? params['place'] : null;
  runApp(
    GameApp(controller: controller, initialRoute: countryRoute(country, place)),
  );
}
