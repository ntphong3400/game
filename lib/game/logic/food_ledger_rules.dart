import 'dart:math' as math;
import '../models/game_state.dart';
import 'development_rules.dart';
import 'population_rules.dart';

/// Read-only closing estimate. Harvest is received before seasonal consumption.
/// Weather and other actions/arrivals are not committed by opening this view.
class FoodProjection {
  FoodProjection(GameState s) {
    capacity = foodCapacity(s);
    rationNeed = populationFoodConsumption(s);
    prepaid = math.min(rationNeed, s.population!.foodCredit);
    remainingNeed = math.max(0, rationNeed - prepaid);
    harvestDue = s.seasonal && s.season == 'Thu' && s.lastHarvestYear < s.year;
    if (harvestDue) {
      final condition = (s.levee - leveeWearThisSeason(s)).clamp(0, 100);
      final factor = harvestLeveePercent(s, autumnCondition: condition) / 100;
      final p = s.population!;
      final labor =
          (p.yearlyFarmLabor + farmLaborFactor(s)) / (p.yearlyLaborSamples + 1);
      final base = agricultureBaseYield(s) * factor * labor;
      grossHarvest = foodAmount(base);
      lowHarvest = foodAmount(base * .9);
      highHarvest = foodAmount(base * 1.1);
    }
    final space = math.max(0, capacity - s.grain);
    harvestReceived = math.min(space, grossHarvest);
    overflow = math.max(0, grossHarvest - harvestReceived);
    final available = s.grain + harvestReceived;
    consumption = math.min(available, remainingNeed);
    shortfall = math.max(0, remainingNeed - available);
    closingBalance = available - consumption;
  }
  late final int capacity,
      rationNeed,
      prepaid,
      remainingNeed,
      harvestReceived,
      overflow,
      consumption,
      shortfall,
      closingBalance;
  late final bool harvestDue;
  int grossHarvest = 0, lowHarvest = 0, highHarvest = 0;
  int get net => harvestReceived - consumption;
}
