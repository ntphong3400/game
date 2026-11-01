import 'dart:convert';
import 'dart:io';
import 'package:van_tue/game/data/reign_content.dart';
import 'package:van_tue/game/logic/game_engine.dart';
import 'package:van_tue/game/logic/reign_rules.dart';
import 'package:van_tue/game/models/game_state.dart';

void main() {
  final source = File('docs/major-scenarios-review-60.md').readAsStringSync();
  final rows =
      RegExp(
        r'^\| \*\*(DB-\d\d)\*\* \| (.*?) \| (.*?) \| (.*?) \|$',
        multiLine: true,
      ).allMatches(source).toList();
  if (rows.length != 60 || majorDefinitions.length != 66) {
    throw StateError('Expected 60 approved + 6 original scenarios');
  }
  final ids = <String>{}, titles = <String>{};
  var objectiveCount = 0;
  for (final d in majorDefinitions) {
    if (!ids.add(d.id) || !titles.add(d.title)) {
      throw StateError('Duplicate major: ${d.id}');
    }
    if (d.objectives.length != 4 ||
        d.objectives.map((o) => o.key).toSet().length != 4) {
      throw StateError('Bad goals: ${d.id}');
    }
    objectiveCount += d.objectives.length;
  }
  for (final row in rows) {
    final d = majorDefinition(row[1]!.toLowerCase());
    final story = RegExp(r'^\*\*(.*?)\*\* (.*)$').firstMatch(row[2]!)!;
    if (d.code != row[1] ||
        d.title != story[1]!.replaceFirst(RegExp(r'\.$'), '') ||
        d.body != story[2]) {
      throw StateError('Narrative drift: ${d.id}');
    }
    final goals =
        row[3]!
            .split(RegExp('[①②③④]'))
            .skip(1)
            .map((s) => s.trim().replaceFirst(RegExp(r'[;。\.]+$'), ''))
            .toList();
    for (var i = 0; i < 4; i++) {
      if (d.objectives[i].title != goals[i]) {
        throw StateError('Goal drift: ${d.id}/$i');
      }
    }
    final outcomes =
        RegExp(r'^\*\*Đủ:\*\* (.*?) \*\*0:\*\* (.*)$').firstMatch(row[4]!)!;
    if (d.successText != outcomes[1] || d.failureText != outcomes[2]) {
      throw StateError('Outcome drift: ${d.id}');
    }
    final s =
        GameEngine().start('audit', 'Audit', 42)
          ..people = 40
          ..stability = 40
          ..army = 40
          ..authority = 40;
    final m = MajorMission(
      id: d.id,
      kind: d.id,
      openedWeek: 1,
      deadline: 6,
      severity: 1,
      preparedness: 0,
      objectives:
          d.objectives.map((o) => MissionObjective(key: o.key)).toList(),
    );
    if (missionTerminalRisks(s, m).isEmpty) {
      throw StateError('Insufficient major penalty at medium stats: ${d.id}');
    }
  }
  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert({
      'totalMajors': majorDefinitions.length,
      'reviewScenarios': rows.length,
      'objectives': objectiveCount,
      'groups': {
        for (final group in majorGroupNames.keys)
          group: majorDefinitions.where((d) => d.group == group).length,
      },
      'approvedNarrativesMatch': true,
      'allNewFailuresThreatenMediumStats': true,
      'recurringIncomeScenarios':
          majorDefinitions
              .where((d) => (d.agreement?.income ?? 0) > 0)
              .map((d) => d.code)
              .toList(),
      'costlyCommitments':
          majorDefinitions
              .where((d) => (d.agreement?.amount ?? 0) > 0)
              .map((d) => d.code.isEmpty ? d.id : d.code)
              .toList(),
    }),
  );
}
