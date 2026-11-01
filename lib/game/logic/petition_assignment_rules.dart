import '../models/game_state.dart';
import '../models/event_definition.dart';
import 'personnel_rules.dart';
import 'population_rules.dart';
import 'petition_rules.dart' show petitionMoneyPreview;

bool petitionCanAssign(GameState s, EventChoice c) =>
    s.seasonal &&
    ((c.troops > 0) ||
        (c.laterEffects.isNotEmpty && c.successChance < 100) ||
        ['audit', 'security', 'envoy'].contains(c.followup) ||
        c.effects.containsKey('repair'));

String petitionSpecialty(EventDefinition e, EventChoice c) {
  if (c.effects.containsKey('repair')) return 'Công trình';
  if (c.followup == 'audit') return 'Dân chính';
  if (c.followup == 'security') return 'An ninh';
  if (c.followup == 'envoy') return 'Ngoại giao';
  if (e.category == 'Khủng hoảng') {
    final trigger = e.trigger.isEmpty ? e.id : e.trigger;
    if (trigger == 'flood') return 'Công trình';
    if (trigger == 'rebellion_warning') return 'Quân sự';
  }
  return switch (e.category) {
    'Ngân khố' || 'Thương mại' || 'Nông nghiệp' => 'Kinh tế',
    'Công trình' || 'Thiên tai' => 'Công trình',
    'Quân sự' => 'Quân sự',
    'Ngoại giao' => 'Ngoại giao',
    'Pháp luật' || 'An ninh' || 'Âm mưu' => 'An ninh',
    'Sức khỏe' => 'Y thuật',
    'Văn hóa' || 'Cung đình' || 'Hậu cung' => 'Cung đình',
    _ => 'Dân chính',
  };
}

String petitionTask(String specialty) => switch (specialty) {
  'Kinh tế' => 'commerce',
  'Công trình' => 'repair',
  'Quân sự' => 'train',
  'Ngoại giao' => 'diplomacy',
  'An ninh' => 'security',
  _ => 'relief',
};

String? petitionAssigneeBlocked(GameState s, Courtier c) {
  if (!c.available || c.age < 18) {
    return 'Nhân vật phải còn hoạt động và đủ 18 tuổi.';
  }
  if (c.isConsort && !c.inHarem) return 'Nhân vật chưa nhập hậu cung.';
  if (officerBusy(s, c.id)) {
    return 'Đang phụ trách công việc hoặc học tập khác.';
  }
  return null;
}

int petitionBaseChance(EventChoice c) =>
    c.troops > 0
        ? 60
        : c.laterEffects.isNotEmpty && c.successChance < 100
        ? (c.successChance - 25).clamp(20, 60)
        : 35;

/// The same public information drives preview and the committed roll. Hidden
/// qualities cannot leak through the picker or change its advertised chance.
TaskAssessment petitionAssessment(
  GameState s,
  EventDefinition e,
  EventChoice c,
  Courtier person,
) {
  final specialty = petitionSpecialty(e, c);
  return TaskAssessment.forSpecialty(
    petitionTask(specialty),
    person,
    specialty,
    s,
    knownOnly: true,
  );
}

int petitionChance(
  GameState s,
  EventDefinition e,
  EventChoice c, [
  Courtier? person,
]) {
  if (c.troops > 0) {
    final base = person == null ? 60 : actionSuccessChance(s, 'train', person);
    final strength = militaryStrength(s, troops: c.troops, naval: c.naval);
    final ratio = strength / (c.troops * .65);
    return (base + (ratio - 1) * 20).round().clamp(5, 95);
  }
  final base = petitionBaseChance(c);
  if (person == null) return base;
  final boost = (petitionAssessment(s, e, c, person).successChance * .4)
      .round()
      .clamp(5, 35);
  return (base + boost).clamp(5, 95);
}

List<Courtier> petitionAssignees(
  GameState s,
  EventDefinition e,
  EventChoice c,
) {
  final people =
      s.court
          .where(
            (p) =>
                petitionAssigneeBlocked(s, p) == null &&
                (c.troops == 0 || !p.isConsort),
          )
          .toList();
  people.sort(
    (a, b) => petitionChance(s, e, c, b).compareTo(petitionChance(s, e, c, a)),
  );
  return people;
}

String petitionChoiceHint(
  GameState s,
  EventDefinition e,
  EventChoice c, {
  Courtier? person,
}) {
  final money = petitionMoneyPreview(s, c);
  final baseHint = '${c.hint}${money == null ? '' : ' · $money'}';
  if (!petitionCanAssign(s, c)) return s.authoredText(baseHint);
  final oldFixed = '${c.successChance}% thành công';
  final hint = baseHint.replaceAll(
    oldFixed,
    '${petitionChance(s, e, c, person)}% thành công',
  );
  return '${s.authoredText(hint)} · ${person == null ? 'Không giao ai' : person.name}: ${petitionChance(s, e, c, person)}% thành công';
}
