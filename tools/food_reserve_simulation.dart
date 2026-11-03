import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/development_rules.dart';
import 'package:van_tue/game/logic/population_rules.dart';
import 'package:van_tue/game/logic/warfare_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

/// Isolated reserve-flow experiment, NOT a full-game bot. Population and army
/// are fixed at 1m/50k, no purchases, immigration, politics or paid actions.
/// Maintenance is assumed available for the maintained profiles. Shared
/// production, wear, capacity, ration and expedition rules are used directly.
/// Weather uses an independent seed; shortages do not change future weather.
Map<String, dynamic> run(int seed, int level, String scenario, bool previous) {
  final s = GameEngine(
    foodBalance: !previous,
  ).start('reserve-$seed', 'Reserve', seed);
  s.agricultureLevel = level;
  final war = scenario.startsWith('war');
  final maintained = scenario != 'unmaintained';
  final crisis = scenario == 'war-crisis';
  if (war) {
    s.warfare!.neighbors.first
      ..status = 'war'
      ..warStarted = 1;
    s.war = 1;
  }
  var rng = seed, firstShortage = 0, shortages = 0, minFood = s.grain;
  for (var turn = 0; turn < 120; turn++) {
    s.completedWeeks = turn;
    if (maintained) s.levee = 100;
    if (s.season == 'Xuân') {
      s.cropYear = s.year;
      s.cropBaselineLevee = s.levee;
      s.springLeveePercent = s.summerLeveePercent = null;
    }
    s.foodDisruptions.removeWhere((e) => e.until < s.week);
    if (crisis && s.season == 'Hạ') {
      s.foodDisruptions.add(
        FoodDisruption(
          id: 'crisis-${s.year}',
          title: 'Khủng hoảng bỏ mặc',
          percent: 25,
          start: s.week,
          until: s.week + 1,
        ),
      );
    }
    s.population!.campaignWorkers = war ? 10000 : 0;
    s.population!.yearlyFarmLabor += farmLaborFactor(s);
    s.population!.yearlyLaborSamples++;
    var paymentShortage = false;
    if (war) {
      final supply = warMissionFood(10000, s);
      paymentShortage = s.grain < supply;
      s.grain = math.max(0, s.grain - supply);
    }
    final wear = (leveeWear(s) * 100).round() + s.leveeWearRemainder;
    s.levee = (s.levee - wear ~/ 100).clamp(0, 100);
    s.leveeWearRemainder = wear % 100;
    if (s.season == 'Xuân') s.springLeveePercent = leveeYieldPercent(s.levee);
    if (s.season == 'Hạ') s.summerLeveePercent = leveeYieldPercent(s.levee);
    if (s.season == 'Thu') {
      rng = rng * 48271 % 2147483647;
      final weather = 90 + rng % 21;
      final harvest = foodAmount(
        agricultureBaseYield(s) *
            harvestLeveePercent(s) /
            100 *
            weather /
            100 *
            annualFarmLaborFactor(s),
      );
      s.grain = math.min(foodCapacity(s), s.grain + harvest);
      s.population!.yearlyFarmLabor = 0;
      s.population!.yearlyLaborSamples = 0;
    }
    final need =
        populationFoodConsumption(s) - (war ? warFoodCredit(10000, s) : 0);
    if (s.grain < need || paymentShortage) {
      shortages++;
      if (firstShortage == 0) firstShortage = s.week;
    }
    s.grain = math.max(0, s.grain - need);
    minFood = math.min(minFood, s.grain);
  }
  return {
    'seed': seed,
    'firstShortage': firstShortage,
    'shortageSeasons': shortages,
    'minimumFood': minFood,
    'finalFood': s.grain,
  };
}

void main() {
  for (final previous in [true, false]) {
    for (final level in [1, 3, 5]) {
      for (final scenario in [
        'maintained',
        'unmaintained',
        'war-maintained',
        'war-crisis',
      ]) {
        final runs = [
          for (var seed = 1; seed <= 100; seed++)
            run(seed, level, scenario, previous),
        ];
        final affected =
            runs.where((r) => (r['firstShortage'] as int) > 0).toList();
        final firsts =
            affected.map((r) => r['firstShortage'] as int).toList()..sort();
        final stocks = runs.map((r) => r['finalFood'] as int).toList()..sort();
        stdout.writeln(
          jsonEncode({
            'model': 'isolated fixed-population reserve flow',
            'profile': previous ? '0.27' : '0.28',
            'farmLevel': level,
            'scenario': scenario,
            'seeds': 100,
            'capSeasons': 120,
            'runsWithShortage': affected.length,
            'medianFirstShortageAmongAffected':
                firsts.isEmpty ? null : firsts[(firsts.length - 1) ~/ 2],
            'medianFinalFood': stocks[49],
            'runs': runs,
          }),
        );
      }
    }
  }
}
