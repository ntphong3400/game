import 'package:van_tue/game/logic/game_engine.dart' as current;
export 'package:van_tue/game/logic/game_engine.dart' hide GameEngine;

/// Regression fixtures exercise the historical save contract explicitly.
/// Population tests use the production engine/defaults directly.
class GameEngine extends current.GameEngine {
  GameEngine({super.seasonal = true}) : super(populationEnabled: false);
}
