import 'package:van_tue/game/logic/chain_settlement_rules.dart';
import 'dart:io';
import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/models/game_state.dart';
import 'package:van_tue/game/logic/personnel_rules.dart';
import 'package:van_tue/game/logic/reign_rules.dart';
import 'package:van_tue/game/data/reign_content.dart';

const spamPolicies = [
  'govern-once',
  'govern-three',
  'govern-rest',
  'audience-once',
  'audience-three',
  'audience-rest',
  'audience-prince-rest',
  'audience-general-rest',
  'audience-hostile-rest',
  'audience-rotate-rest',
  'audience-rotate-three',
  'govern-audience-rest',
  'govern-security-rest',
];

/// A simple, deliberately imperfect policy for manual balance exploration.
/// It uses information a player can see; it never edits state or submits scores.
GameState simulateRun(int seed, {String policy = 'active', int limit = 260}) {
  if (![
    'active',
    'prepared',
    'idle',
    'rest',
    ...spamPolicies,
  ].contains(policy)) {
    throw ArgumentError.value(policy, 'policy', 'Unknown simulation policy');
  }
  final engine = GameEngine();
  var state = engine.start('simulation-$seed', 'Mô phỏng', seed);
  void send(String type, {String target = '', String option = ''}) {
    if (type == 'action' && taskSpecialties.containsKey(target)) {
      final eligible = taskOfficers(state, target);
      if (!eligible.any((c) => c.id == option)) option = eligible.first.id;
    }
    state = engine.execute(
      state,
      GameCommand(
        id: '${state.revision}',
        runId: state.runId,
        expectedRevision: state.revision,
        type: type,
        target: target,
        option: option,
      ),
    );
  }

  for (var week = 0; week < limit && !state.ended; week++) {
    if (policy != 'active' && policy != 'prepared') {
      if (policy == 'rest') {
        for (var i = 0; i < 3; i++) {
          send('action', target: 'rest');
        }
      } else if (spamPolicies.contains(policy)) {
        final officials =
            state.court.where((c) => c.available && !c.isConsort).toList();
        final steps = switch (policy) {
          'govern-once' => ['govern'],
          'govern-three' => ['govern', 'govern', 'govern'],
          'govern-rest' => ['govern', 'rest', 'rest'],
          'audience-once' => ['audience'],
          'audience-three' ||
          'audience-rotate-three' => ['audience', 'audience', 'audience'],
          'govern-audience-rest' => ['govern', 'audience', 'rest'],
          'govern-security-rest' => ['govern', 'security', 'rest'],
          _ => ['audience', 'rest', 'rest'],
        };
        for (var i = 0; i < steps.length && !state.ended; i++) {
          if (steps[i] == 'audience') {
            final target = switch (policy) {
              'audience-prince-rest' => 'prince',
              'audience-general-rest' => 'general',
              'audience-hostile-rest' =>
                officials
                    .firstWhere((c) => c.faction == state.hostileFaction)
                    .id,
              'audience-rotate-rest' || 'audience-rotate-three' =>
                officials[(week * (policy == 'audience-rotate-three' ? 3 : 1) +
                            i) %
                        officials.length]
                    .id,
              _ => 'chancellor',
            };
            send('courtier', target: target, option: 'audience');
          } else {
            final action = actions.firstWhere((a) => a.id == steps[i]);
            // Costly variants must obey the same resource limits as the UI.
            // Use the spare action to rest if security cannot be funded.
            send(
              'action',
              target:
                  actionCost(state, action) <= state.treasury &&
                          action.grainCost <= state.grain
                      ? steps[i]
                      : 'rest',
            );
          }
        }
      }
      if (!state.ended) send('endWeek');
      continue;
    }
    if (policy == 'prepared') {
      if (state.treasury < 90 && emergencyBlocked(state, 'borrow') == null) {
        send('emergency', target: 'borrow');
      }
      // Reserve an action for an unfinished objective while it can still finish.
      final mission = state.major;
      if (mission != null &&
          !mission.petitionDriven &&
          state.points > 0 &&
          state.fatigue < 65) {
        for (final o in mission.objectives.where(
          (o) => !o.done && !o.working,
        )) {
          final d = majorDefinition(
            mission.kind,
          ).objectives.firstWhere((d) => d.key == o.key);
          final officers = missionOfficers(state, d).where(
            (c) => state.week + missionDuration(d, c) - 1 <= mission.deadline,
          );
          if (state.treasury >=
                  missionRemainingCost(missionCost(mission, d), o) + 35 &&
              state.grain >=
                  missionRemainingCost(missionGrain(mission, d), o) &&
              officers.isNotEmpty) {
            send('mission', target: o.key, option: officers.first.id);
            if (state.points <= 3 || state.ended) break;
          }
        }
      }
      for (final arc
          in state.chains
              .where((a) => !state.seasonal && a.dueWeek <= state.week)
              .toList()) {
        final choices = chainDefinitionFor(arc).stages[arc.stage].choices;
        final selected = choices.indexWhere(
          (c) =>
              c.cost <= state.treasury - 40 &&
              c.grainCost <= state.grain &&
              c.points <= state.points,
        );
        if (selected >= 0) send('chain', target: arc.id, option: '$selected');
      }
    }
    for (final p in state.petitions.toList()) {
      if (state.points < 1 || state.ended) break;
      final e = eventForState(state, p.definitionId);
      final arc = state.chains.where((a) => a.id == p.storyId).firstOrNull;
      var best = e.choices.length - 1;
      var value = -double.infinity;
      for (var i = 0; i < e.choices.length; i++) {
        final c = e.choices[i];
        if (arc != null &&
                usesChainSettlement(arc) &&
                chainSettlementChoiceBlocked(state, arc, i) != null ||
            c.cost > state.treasury - 50 ||
            c.grainCost > state.grain ||
            petitionPoints(state, c) > state.points ||
            c.effects.containsKey('repair') &&
                state.projects.any((p) => p.kind == 'repair')) {
          continue;
        }
        final benefit =
            c.effects.entries.fold<double>(0, (sum, effect) {
              final weight = switch (effect.key) {
                'treasury' => .25,
                'people' => state.people < 45 ? 2.0 : .6,
                'army' => state.army < 40 ? 2.0 : .5,
                'grain' => state.grain < 35 ? 1.5 : .2,
                'authority' => state.authority < 40 ? 1.5 : .4,
                'plotReduce' => 1.0,
                'revel' => state.indulgence > 4 ? -6.0 : 1.0,
                'rest' => 2.0,
                'war' => -6.0,
                _ => .5,
              };
              return sum + effect.value * weight;
            }) -
            c.cost * .25 +
            (c.followup == 'trade' ? 20 : 0);
        if (benefit > value) {
          value = benefit;
          best = i;
        }
      }
      if (value == -double.infinity) continue;
      send('petition', target: p.id, option: '$best');
      if (state.ended) break;
    }
    for (var i = 0; i < 3 && state.points > 0 && !state.ended; i++) {
      if (state.week % 9 == 0 &&
          state.treasury >= 25 &&
          !state.favorsThisWeek.containsKey('prince')) {
        send('courtier', target: 'prince', option: 'reward');
      } else {
        final id =
            policy == 'prepared' &&
                    state.treasury < 150 &&
                    revenueTaskBlocked(state, 'collect_arrears') == null
                ? 'collect_arrears'
                : policy == 'prepared' &&
                    state.treasury < 250 &&
                    state.treasury >= 100 &&
                    !state.projects.any((p) => p.kind == 'commerce') &&
                    state.workThisWeek < 2
                ? 'commerce'
                : state.illness > 8 && state.treasury > 30
                ? 'treat'
                : state.fatigue > 35 || state.health < 65
                ? 'rest'
                : state.factions.values.any((m) => m < 30) &&
                    state.treasury > 40 &&
                    !state.actionCounts.containsKey('mediate')
                ? 'mediate'
                : state.people < 55 && state.treasury > 40 && state.grain >= 25
                ? 'relief'
                : state.army < 45 && state.treasury > 40
                ? 'train'
                : state.grain < 35 &&
                    state.treasury > 70 &&
                    !state.projects.any((p) => p.kind == 'farm')
                ? 'farm'
                : state.grain < 25 && state.treasury > 55
                ? 'buy_grain'
                : state.levee < 40 &&
                    state.treasury > 100 &&
                    !state.projects.any((p) => p.kind == 'repair')
                ? 'repair'
                : state.workThisWeek >= 2
                ? 'rest'
                : 'govern';
        send(
          'action',
          target: id,
          option: ['farm', 'repair'].contains(id) ? 'governor' : '',
        );
      }
    }
    if (!state.ended) send('endWeek');
  }
  return state;
}

void main(List<String> args) {
  if (args.contains('--compare') || args.contains('--spam')) {
    final selected =
        args
            .where((arg) => arg.startsWith('--policy='))
            .map((arg) => arg.substring('--policy='.length))
            .toList();
    for (final policy
        in selected.isNotEmpty
            ? selected
            : args.contains('--spam')
            ? spamPolicies
            : ['idle', 'rest', 'active', 'prepared']) {
      final runs = [
        for (var seed = 1; seed <= 100; seed++)
          simulateRun(seed, policy: policy),
      ];
      final weeks = runs.map((s) => s.completedWeeks).toList()..sort();
      final endings = <String, int>{};
      for (final s in runs) {
        endings.update(
          s.endKind ?? (s.ended ? 'legacy' : 'alive'),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      stdout.writeln(
        '$policy (100 seeds, cap 260 mùa): min ${weeks.first}, median ${weeks[49]}, p90 ${weeks[89]}, max ${weeks.last}; $endings',
      );
      final majors = runs.expand((s) => s.majorHistory).toList();
      if (majors.isNotEmpty) {
        stdout.writeln(
          '  Major missions: ${majors.length}; 4/4 ${majors.where((m) => m.achieved == 4).length}; 0/4 ${majors.where((m) => m.achieved == 0).length}; objective total ${majors.fold<int>(0, (sum, m) => sum + m.achieved)}.',
        );
      }
      if (args.contains('--spam')) {
        final longest = runs.reduce(
          (a, b) => a.completedWeeks >= b.completedWeeks ? a : b,
        );
        stdout.writeln(
          '  Longest: seed ${longest.seed - 1}; authority ${longest.authority}, stability ${longest.stability}, people ${longest.people}, army ${longest.army}, grain ${longest.grain}, health ${longest.health}, neglect ${longest.neglectedWeeks}; ${longest.endReason ?? 'alive at cap'}',
        );
      }
    }
    return;
  }
  for (final seed in [7, 42, 73, 123, 2026]) {
    final state = simulateRun(seed);
    stdout.writeln(
      'Seed $seed: ${state.duration}; ${state.endReason ?? 'vẫn giữ ngai'}; ngân khố ${state.treasury}; sức khỏe ${state.health}',
    );
  }
}
