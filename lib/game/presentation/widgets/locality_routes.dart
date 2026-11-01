import '../../data/content.dart';
import '../../models/game_state.dart';

/// Presentation-only groupings; the same commands and save data serve every hub.
enum LocalityPlace {
  administration('Phủ nha', 'Điều hành địa phương'),
  agriculture('Đồng ruộng', 'Nông nghiệp'),
  irrigation('Đê điều', 'Trị thủy'),
  granary('Kho lương', 'Lương thực & Cứu tế'),
  commerce('Chợ quê', 'Thương chính'),
  village('Thôn làng', 'Dân cư & Lao động');

  const LocalityPlace(this.landmark, this.title);
  final String landmark, title;
  String get route => 'local-$name';
  static LocalityPlace? fromRoute(String route) =>
      values.where((p) => p.route == route).firstOrNull;

  List<String> get tasks => switch (this) {
    administration => [
      ...agriculture.tasks,
      ...irrigation.tasks,
      ...granary.tasks,
      ...commerce.tasks,
      ...village.tasks,
    ],
    agriculture => ['farm', 'upgrade_farm'],
    irrigation => ['maintain_levee', 'repair', 'upgrade_levee'],
    granary => ['buy_grain', 'relief', 'sell_surplus'],
    commerce => ['commerce', 'collect_arrears', 'upgrade_economy'],
    village => ['settle', 'refugees', 'return', 'public_health'],
  };

  List<ActionDefinition> actionsFor(GameState state) =>
      actions
          .where((a) => tasks.contains(a.id))
          .where((a) => state.seasonal || !a.id.startsWith('upgrade_'))
          .where((a) => state.population != null || a.icon != 'population')
          .toList();

  bool includesPetition(GameState state, Petition petition) {
    if (this == administration) {
      return values
          .where((p) => p != administration)
          .any((p) => p.includesPetition(state, petition));
    }
    final e = eventForState(state, petition.definitionId);
    final text = '${e.title} ${e.body}'.toLowerCase();
    // Classify by subject, not generic effects such as lòng dân or ngân khố,
    // which also appear on court and palace petitions.
    return switch (this) {
      agriculture =>
        e.category == 'Nông nghiệp' ||
            ['mùa vụ', 'mất mùa', 'ruộng', 'hạn hán'].any(text.contains),
      irrigation => [
        'đê điều',
        'tuyến đê',
        'đê ',
        'lũ',
        'lụt',
        'trị thủy',
      ].any(text.contains),
      granary => [
        'kho lương',
        'cứu tế',
        'cứu đói',
        'thiếu lương',
        'thóc',
      ].any(text.contains),
      commerce =>
        e.category == 'Thương mại' ||
            [
              'thương nhân',
              'thương lái',
              'thuế',
              'giao thương',
            ].any(text.contains),
      village => ['Dân cư', 'Dân sinh'].contains(e.category),
      administration => false,
    };
  }

  bool includesConsequence(GameState state, Consequence consequence) {
    final assignment = consequence.assignment;
    if (assignment != null) {
      final source = Petition(
        id: '',
        definitionId: assignment.eventId,
        openedWeek: 0,
        deadline: 0,
      );
      return includesPetition(state, source);
    }
    if (consequence.kind == 'eventOutcome') {
      final action =
          actions.where((a) => a.title == consequence.title).firstOrNull;
      if (action != null) return tasks.contains(action.id);
      final event =
          events.where((e) => e.title == consequence.title).firstOrNull;
      if (event != null) {
        return includesPetition(
          state,
          Petition(id: '', definitionId: event.id, openedWeek: 0, deadline: 0),
        );
      }
    }
    return tasks.contains(consequence.kind) ||
        switch (consequence.kind) {
          'trade' || 'arrears' => this == commerce || this == administration,
          _ => false,
        };
  }

  List<Petition> petitionsFor(GameState state) =>
      state.petitions.where((p) => includesPetition(state, p)).toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));
}
