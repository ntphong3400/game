import 'game/models/number_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/game_controller.dart';
import 'game/data/store_factory.dart';
import 'game/logic/game_gateway.dart';
import 'game/presentation/game_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  try {
    final store = await openGameStore();
    final controller = GameController(LocalGameGateway(store));
    runApp(GameApp(controller: controller));
    await controller.load();
  } catch (error) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: SelectableText(
                formatGameNumbers(
                  'Không thể mở kho lưu trữ local.\n$error\n\nHãy cho phép dữ liệu trang web rồi tải lại.',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
