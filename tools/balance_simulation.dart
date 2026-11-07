import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/chain_settlement_rules.dart';
import 'package:van_tue/game/logic/court_personnel_rules.dart';
import 'package:van_tue/game/logic/finance_rules.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/petition_assignment_rules.dart';
import 'package:van_tue/game/logic/population_rules.dart';
import 'package:van_tue/game/logic/warfare_rules.dart';
import 'package:van_tue/game/logic/frontier_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

/// Deterministic, public-information heuristic, not an optimal player.
/// Never peeks at RNG, plots, loyalty, hidden qualities or committed outcomes.
/// Every state transition goes through a real command, including end-of-season.
class BalancePlayer {
  BalancePlayer(
    this.seed,
    this.policy, {
    bool baseline = false,
    bool previousFood = false,
  }) : engine = GameEngine(
         challengeBalance: !baseline,
         foodBalance: !previousFood,
       );
  final int seed;
  final String policy;
  final GameEngine engine;
  late GameState s = engine.start('balance-$seed', 'Balance', seed);
  final rejected = <String, int>{};
  int minimumCash = 50000, peakDebt = 0, completedChains = 0;
  int minimumFood = 4000000, shortageSeasons = 0, lowReserveSeasons = 0;
  int harvested = 0, foodPurchases = 0, agricultureUpgrades = 0;
  int deployed = 0, resupplied = 0, warSeasons = 0;
  final foodTrace = <Map<String, dynamic>>[];
  bool send(String type, String target, String option, {String assignee = ''}) {
    try {
      s = engine.execute(
        s,
        GameCommand(
          id: '${s.revision}',
          runId: s.runId,
          expectedRevision: s.revision,
          type: type,
          target: target,
          option: option,
          assigneeId: assignee,
        ),
      );
      minimumCash = math.min(minimumCash, s.treasury);
      peakDebt = math.max(peakDebt, s.debt);
      minimumFood = math.min(minimumFood, s.grain);
      if (type == 'action' && target == 'buy_grain') foodPurchases++;
      if (type == 'action' && target == 'upgrade_farm') agricultureUpgrades++;
      if (type == 'endWeek') {
        if (s.warfare?.active != null) warSeasons++;
        if (s.journal.any(
          (j) =>
              j.week == s.week - (s.ended ? 0 : 1) &&
              j.title == 'Thiếu khẩu phần',
        )) {
          shortageSeasons++;
        }
        if (foodDays(s) < 90) lowReserveSeasons++;
        if (s.lastHarvestYear > 0 &&
            s.lastHarvestYear * 4 - 1 == s.week - (s.ended ? 0 : 1)) {
          harvested += s.lastHarvestAmount;
        }
        foodTrace.add({
          'turn': s.completedWeeks,
          'food': s.grain,
          'days': foodDays(s),
          'farmLevel': s.agricultureLevel,
          'population': s.population!.population,
          'war': s.war,
        });
      }
      return true;
    } on GameRuleException catch (e) {
      rejected.update('$type:$target:$e', (v) => v + 1, ifAbsent: () => 1);
      return false;
    }
  }

  double effects(Map<String, int> values) => values.entries.fold(0.0, (sum, e) {
    final weight = switch (e.key) {
      'gold' => policy == 'extractive' ? .0015 : .00065,
      'treasury' => policy == 'extractive' ? .15 : .065,
      'goldDebt' => -.0009,
      'debt' => -.09,
      'food' => foodDays(s) < 120 ? .00005 : .000012,
      'grain' => .2,
      'people' =>
        s.people < 35
            ? 3.5
            : s.people < 60
            ? 1.6
            : .7,
      'authority' =>
        s.authority < 35
            ? 4.0
            : s.authority < 65
            ? 2.0
            : .8,
      'stability' =>
        s.stability < 35
            ? 4.0
            : s.stability < 65
            ? 2.0
            : .8,
      'health' => s.health < 45 ? 3.0 : .5,
      'levee' => s.levee < 60 ? 1.1 : .4,
      'training' || 'morale' => .5,
      'equipment' => s.population!.equipmentPercent < 75 ? .001 : .0002,
      'fatigue' || 'stress' => -.3,
      'illness' => -.8,
      'war' => -6.0,
      'plotReduce' => 1.0,
      'rest' => 3.0,
      'settlers' || 'refugees' || 'returnees' => .0003,
      'disease' => -10.0,
      'displaced' => -.001,
      _ when e.key.startsWith('faction:') =>
        (s.factions[e.key.substring(8)] ?? 50) < 40 ? 1.3 : .3,
      _ => 0.0,
    };
    return sum + e.value * weight;
  });

  Courtier? worker(String task) {
    final pool = taskOfficers(s, task).toList();
    if (pool.isEmpty) return null;
    pool.sort(
      (a, b) => TaskAssessment.forSpecialty(
        task,
        b,
        taskSpecialties[task]!,
        s,
        knownOnly: true,
      ).successChance.compareTo(
        TaskAssessment.forSpecialty(
          task,
          a,
          taskSpecialties[task]!,
          s,
          knownOnly: true,
        ).successChance,
      ),
    );
    return pool.first;
  }

  bool action(String task) {
    final a = actions.firstWhere((a) => a.id == task);
    if (s.treasury < actionCost(s, a) || s.grain < actionGrainCost(s, a)) {
      return false;
    }
    if (revenueTaskBlocked(s, task) != null) return false;
    if (task == 'security' && securityBlocked(s) != null) return false;
    var c = taskSpecialties.containsKey(task) ? worker(task) : null;
    if (developmentTasks.contains(task)) {
      final pool =
          taskOfficers(s, task)
              .where((c) => developmentOfficerBlocked(s, task, c) == null)
              .toList();
      pool.sort((a, b) => b.ability.compareTo(a.ability));
      c = pool.firstOrNull;
    }
    if (taskSpecialties.containsKey(task) && c == null) return false;
    return send('action', task, c?.id ?? '');
  }

  bool petition() {
    final list =
        s.petitions.toList()..sort(
          (a, b) => (a.storyKind == 'major' ? -1 : a.deadline).compareTo(
            b.storyKind == 'major' ? -1 : b.deadline,
          ),
        );
    for (final p in list) {
      if (policy == 'neglect' && p.storyKind == 'major') continue;
      final matter = courtMatterForEvent(s, p.definitionId);
      if (matter != null) {
        final last = courtMatterLastChoice(matter);
        // Keep existing personnel; this benchmark does not guess at nominees.
        if (courtPersonnelChoiceBlocked(s, matter, last) == null &&
            send('petition', p.id, '$last')) {
          return true;
        }
        continue;
      }
      final e = eventForState(s, p.definitionId);
      final arc = s.chains.where((a) => a.id == p.storyId).firstOrNull;
      final candidates = <({int index, double value, String assignee})>[];
      for (var i = 0; i < e.choices.length; i++) {
        final c = e.choices[i];
        if (petitionPoints(s, c) > s.points ||
            c.cost > s.treasury ||
            c.grainCost > s.grain ||
            c.effects.containsKey('warMission') ||
            c.effects.containsKey('repair') &&
                s.projects.any((p) => p.kind == 'repair')) {
          continue;
        }
        if (arc != null && chainSettlementChoiceBlocked(s, arc, i) != null) {
          continue;
        }
        Courtier? person;
        if (petitionCanAssign(s, c)) {
          final pool = petitionAssignees(s, e, c);
          person = pool.firstOrNull;
        }
        final chance =
            petitionCanAssign(s, c)
                ? petitionChance(s, e, c, person) / 100
                : 1.0;
        var score =
            effects(c.effects) +
            chance * effects(c.laterEffects) +
            (1 - chance) * effects(c.laterFailureEffects) -
            c.cost * (policy == 'extractive' ? .0003 : .00065) -
            c.grainCost * (foodDays(s) < 100 ? .00005 : .000012);
        final budget = BudgetProjection(s);
        final reserve = math.max(
          4000,
          (budget.requiredExpense - budget.totalIncome) * 3 + 4000,
        );
        final closing = s.treasury - c.cost + (c.effects['gold'] ?? 0);
        score -= math.max(0, reserve - closing) * .001;
        if (c.followup == 'audit') score += chance * 4;
        if (c.followup == 'security') score += chance * 5;
        if (c.followup == 'trade') score += chance * 6;
        if (c.effects.containsKey('repair')) score += s.levee < 65 ? 20 : 5;
        if (arc != null) {
          score +=
              chainChoiceAbandons(arc, i) ? -8 : 10 + arc.completedSteps * 2;
          if (s.treasury - c.cost < 6000 && c.cost > 0) score -= 20;
        }
        // Full protection has no positive stat effect: compare it to the losses
        // avoided, then favor it only when enough working capital remains.
        if (p.storyKind == 'major' && i == 0 && s.treasury - c.cost > 5000) {
          score += 3;
        }
        candidates.add((index: i, value: score, assignee: person?.id ?? ''));
      }
      candidates.sort((a, b) => b.value.compareTo(a.value));
      for (final c in candidates) {
        if (send('petition', p.id, '${c.index}', assignee: c.assignee)) {
          return true;
        }
      }
    }
    return false;
  }

  bool campaign() {
    final active = s.warfare?.active;
    if (active == null) {
      if (s.treasury < 15000) return false;
      final enemy =
          s.warfare!.neighbors
              .where((n) => n.status != 'treaty' && n.cooldownUntil <= s.week)
              .firstOrNull;
      return enemy != null &&
          send('war', enemy.id, jsonEncode({'action': 'declare'}));
    }
    for (final m in s.warfare!.missions.where(
      (m) => m.status == 'deployed' && m.intervention,
    )) {
      if (s.grain >= warMissionFood(m.troops, s, m) && s.treasury >= 1000) {
        if (send('war', m.id, jsonEncode({'action': 'intervene'}))) {
          resupplied++;
          return true;
        }
      }
    }
    final leaders = warOfficers(s);
    for (final m in s.warfare!.missions.where((m) => m.status == 'open')) {
      for (final ratio in warTroopRatios(m).reversed) {
        final troops = warTroops(m, ratio);
        if (troops > missionAvailable(s, m) ||
            s.grain <
                warMissionFood(troops, s, m) + populationFoodConsumption(s)) {
          continue;
        }
        for (final leader in leaders) {
          if (warDeployBlocked(s, m, ratio, leader, null) != null) continue;
          if (send(
            'war',
            m.id,
            jsonEncode({'action': 'deploy', 'ratio': ratio}),
            assignee: leader.id,
          )) {
            deployed++;
            return true;
          }
        }
      }
    }
    return false;
  }

  GameState run(int cap) {
    while (!s.ended && s.completedWeeks < cap) {
      if (policy != 'idle') {
        var steps = 0;
        var diplomacyAttempted = false;
        while (s.points > 0 && !s.ended && steps++ < 12) {
          if (s.restThisWeek == 0 &&
              (s.points <= 1 || s.health < 45 || s.fatigue > 55)) {
            if (action('rest')) continue;
          }
          if (s.population!.diseaseLevel > 0 &&
              populationActionBlocked(s, 'public_health') == null &&
              send('population', 'public_health', '')) {
            continue;
          }
          final lowMood = s.factions.values.reduce(math.min);
          if (lowMood < 45 &&
              !s.actionCounts.containsKey('mediate') &&
              s.treasury > 5000 &&
              action('mediate')) {
            continue;
          }
          if (s.court.any((c) => c.available && c.discontent >= 65) &&
              securityBlocked(s) == null &&
              s.treasury > 10000 &&
              action('security')) {
            continue;
          }
          final enemy = s.warfare?.active;
          if (policy == 'campaign' && campaign()) continue;
          if (policy != 'campaign' &&
              enemy != null &&
              !diplomacyAttempted &&
              s.treasury > 2500 &&
              send(
                'war',
                enemy.id,
                jsonEncode({'action': 'negotiate', 'tier': 'armistice'}),
              )) {
            // One attempt per season, counted locally rather than editing state.
            diplomacyAttempted = true;
            continue;
          }
          if (s.illness > 8 && s.treasury > 3500 && action('treat')) continue;
          if (policy != 'no-maintenance' &&
              s.levee < 65 &&
              !s.actionCounts.containsKey('maintain_levee') &&
              s.treasury > 4500 &&
              action('maintain_levee')) {
            continue;
          }
          if (foodDays(s) < 100 && s.treasury > 5000 && action('buy_grain')) {
            continue;
          }
          final daysUntilHarvest = math.max(
            180,
            (s.nextTaxTurn - s.week) * 90 + 90,
          );
          if (foodDays(s) > daysUntilHarvest + 30 &&
              s.treasury < 18000 &&
              revenueTaskBlocked(s, 'sell_surplus') == null &&
              action('sell_surplus')) {
            continue;
          }
          // Set a tax rate deliberately, once, using the ordinary command.
          if (policy == 'extractive' && s.tax != 2 && send('tax', '', '2')) {
            continue;
          }
          if (policy != 'extractive' && s.tax == 2 && send('tax', '', '1')) {
            continue;
          }
          if (petition()) continue;
          if (s.treasury < 10000 &&
              revenueTaskBlocked(s, 'collect_arrears') == null &&
              action('collect_arrears')) {
            continue;
          }
          if (s.people < 50 && s.treasury > 4500 && action('relief')) continue;
          if (s.authority < 65 && action('govern')) continue;
          if (s.stability < 65 &&
              !s.actionCounts.containsKey('mediate') &&
              s.treasury > 4500 &&
              action('mediate')) {
            continue;
          }
          if (policy != 'no-maintenance' &&
              s.agricultureLevel < 3 &&
              foodDays(s) < 210 &&
              s.treasury > 22000 &&
              developmentBlocked(s, 'upgrade_farm') == null &&
              action('upgrade_farm')) {
            continue;
          }
          if (s.treasury > 13000 &&
              !s.projects.any((p) => p.kind == 'commerce') &&
              action('commerce')) {
            continue;
          }
          if (!action('rest')) break;
        }
      }
      if (!s.ended && !send('endWeek', '', '')) {
        throw StateError('Season did not close');
      }
    }
    return s;
  }
}

void main(List<String> args) {
  int arg(String name, int fallback) =>
      int.tryParse(
        args
                .where((x) => x.startsWith('--$name='))
                .firstOrNull
                ?.split('=')
                .last ??
            '',
      ) ??
      fallback;
  final count = arg('seeds', 100),
      cap = arg('cap', 80),
      start = arg('start', 1);
  final selected =
      args
          .where((a) => a.startsWith('--policy='))
          .map((a) => a.split('=').last)
          .toList();
  final policies =
      selected.isEmpty
          ? ['prudent', 'extractive', 'no-maintenance', 'neglect', 'idle']
          : selected;
  for (final policy in policies) {
    if (![
      'prudent',
      'extractive',
      'no-maintenance',
      'neglect',
      'idle',
      'campaign',
    ].contains(policy)) {
      throw ArgumentError(policy);
    }
    final players = [
      for (var seed = start; seed < start + count; seed++)
        BalancePlayer(
          seed,
          policy,
          baseline: args.contains('--baseline'),
          previousFood: args.contains('--previous-food'),
        ),
    ];
    final runs = [for (final p in players) p.run(cap)];
    final seasons = runs.map((s) => s.completedWeeks).toList()..sort();
    final endings = <String, int>{};
    for (final s in runs) {
      endings.update(s.endKind ?? 'alive', (v) => v + 1, ifAbsent: () => 1);
    }
    final report = {
      'profile':
          args.contains('--baseline')
              ? '0.26'
              : (runs.first.foodPressureEnabled ? '0.28' : '0.27'),
      'policy': policy,
      'seeds': count,
      'startSeed': start,
      'capSeasons': cap,
      'min': seasons.first,
      'median': seasons[(count - 1) ~/ 2],
      'p90': seasons[((count - 1) * .9).floor()],
      'max': seasons.last,
      'survive20': runs.where((s) => s.completedWeeks >= 20).length,
      'survive40': runs.where((s) => s.completedWeeks >= 40).length,
      'endings': endings,
      'runsWithDebt': players.where((p) => p.peakDebt > 0).length,
      'majorsResolved': runs.fold(0, (n, s) => n + s.majorHistory.length),
      'fullMajorResponses': runs.fold(
        0,
        (n, s) => n + s.majorHistory.where((m) => m.achieved == 4).length,
      ),
      'rejectedCommands': players.fold(
        0,
        (n, p) => n + p.rejected.values.fold(0, (n, v) => n + v),
      ),
      'rejectionExamples':
          players.expand((p) => p.rejected.keys).toSet().take(5).toList(),
      'shortageSeasons': players.fold(0, (n, p) => n + p.shortageSeasons),
      'runsWithShortage': players.where((p) => p.shortageSeasons > 0).length,
      'lowReserveSeasons': players.fold(0, (n, p) => n + p.lowReserveSeasons),
      'foodPurchases': players.fold(0, (n, p) => n + p.foodPurchases),
      'deployments': players.fold(0, (n, p) => n + p.deployed),
      'resupplyPayments': players.fold(0, (n, p) => n + p.resupplied),
      'warSeasons': players.fold(0, (n, p) => n + p.warSeasons),
      'agricultureUpgrades': players.fold(
        0,
        (n, p) => n + p.agricultureUpgrades,
      ),
      'totalHarvested': players.fold(0, (n, p) => n + p.harvested),
      'medianMinimumFood':
          (players.map((p) => p.minimumFood).toList()
            ..sort())[(count - 1) ~/ 2],
      'medianFinalFood':
          (runs.map((s) => s.grain).toList()..sort())[(count - 1) ~/ 2],
      if (args.contains('--runs'))
        'runs': [
          for (var i = 0; i < players.length; i++)
            {
              'seed': players[i].seed,
              'seasons': runs[i].completedWeeks,
              'end': runs[i].endKind,
              'shortageSeasons': players[i].shortageSeasons,
              'trace': players[i].foodTrace,
            },
        ],
    };
    stdout.writeln(jsonEncode(report));
    if (args.contains('--trace')) {
      final s = runs.first;
      for (final j in s.journal.reversed) {
        stdout.writeln('${j.week} ${j.title}: ${j.text}');
      }
    }
  }
}
