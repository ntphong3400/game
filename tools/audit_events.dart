import 'dart:convert';
import 'dart:io';

import 'package:van_tue/game/data/content.dart';
import 'package:van_tue/game/data/event_stories.dart';
import 'package:van_tue/game/data/expanded_events.dart';

// Read-only content inventory. Does not load or modify player saves.
void main(List<String> arguments) {
  final packs = {
    for (final p in eventStories.entries)
      p.key: p.value.trim().split('\n').length,
  };
  final choices = events.expand((e) => e.choices).toList();
  final patterns =
      expandedEvents
          .map(
            (e) => jsonEncode([
              for (final c in e.choices)
                {
                  'effects': c.effects,
                  'cost': c.cost,
                  'grainCost': c.grainCost,
                  'points': c.points,
                  'delay': c.delay,
                  'chance': c.successChance,
                  'later': c.laterEffects,
                  'failure': c.laterFailureEffects,
                },
            ]),
          )
          .toSet();
  final report = <String, dynamic>{
    'totalEvents': events.length,
    'originalEvents': baseEvents.length,
    'addedEvents': expandedEvents.length,
    'uniqueIds': events.map((e) => e.id).toSet().length,
    'uniqueTitles': events.map((e) => e.title).toSet().length,
    'uniqueSituations': events.map((e) => e.body).toSet().length,
    'choices': choices.length,
    'newDecisionPatterns': patterns.length,
    'deferredChoices': choices.where((c) => c.laterEffects.isNotEmpty).length,
    'riskyDeferredChoices':
        choices
            .where((c) => c.laterEffects.isNotEmpty && c.successChance < 100)
            .length,
    'urgentVariants': {
      for (final id in urgentEventIds)
        id: events.where((e) => eventTrigger(e) == id).length,
    },
    'newTopicPacks': packs,
  };
  if (events.length != 450 ||
      expandedEvents.length != 405 ||
      packs.length != 15 ||
      packs.values.any((n) => n != 27) ||
      report['uniqueTitles'] != 450 ||
      report['uniqueSituations'] != 450) {
    throw StateError(
      'Event catalog does not match the release contract: $report',
    );
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
  if (arguments.contains('--catalog')) {
    stdout.writeln('\n# Danh mục 450 sự kiện\n');
    for (final e in events) {
      stdout.writeln(
        '## ${e.id} — ${e.title}\n\n${e.category} · Điều kiện: ${e.condition} · Từ tuần ${e.minWeek}\n\n${e.body}\n',
      );
      for (final c in e.choices) {
        stdout.writeln('- ${c.label}: ${c.hint}');
      }
      stdout.writeln();
    }
  }
}
