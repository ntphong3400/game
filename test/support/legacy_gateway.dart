import 'package:van_tue/game/logic/game_engine.dart' as current;
import 'package:van_tue/game/logic/game_gateway.dart' as current_gateway;
export 'package:van_tue/game/logic/game_gateway.dart' hide LocalGameGateway;

class LocalGameGateway extends current_gateway.LocalGameGateway {
  LocalGameGateway(
    super.store, {
    current.GameEngine? engine,
    bool seasonal = true,
  }) : super(
         engine:
             engine ??
             current.GameEngine(seasonal: seasonal, populationEnabled: false),
       );
}
