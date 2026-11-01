import '../models/game_state.dart';
import '../models/management_post.dart';
export '../models/management_post.dart';

CourtOffice? managementOffice(GameState s, ManagementPost post) =>
    s.courtOffices.where((o) => o.id == post.id).firstOrNull;

Courtier? managementHolder(GameState s, ManagementPost post) {
  final id = managementOffice(s, post)?.holderId;
  return s.court
      .where((c) => c.id == id && c.available && !c.retired)
      .firstOrNull;
}

int managementDirection(GameState s, ManagementPost post) {
  if (s.managementVersion == 0) return 0;
  final holder = managementHolder(s, post);
  if (holder == null) return -1;
  return holder.abilityScore > post.abilityThreshold &&
          holder.affection > post.affectionThreshold
      ? 1
      : 0;
}

String? managementCandidateBlocked(
  GameState s,
  Courtier c,
  ManagementPost post,
) {
  if (!c.available || c.retired || c.isConsort || c.age < 18) {
    return 'Cần quan trưởng thành, còn hiện diện.';
  }
  if (c.category != post.group) return 'Vị trí dành cho ${post.group}.';
  if (post.senior && (c.grade < 1 || c.grade > 6)) {
    return 'Cần Lục phẩm trở lên.';
  }
  if (managementHolder(s, post)?.id == c.id) return 'Đang quản lý vị trí này.';
  return null;
}

int managementEquipmentBonus(GameState s) => managementPosts
    .where((p) => p.benefit == 'equipment')
    .fold(0, (sum, p) => sum + managementDirection(s, p) * p.amount);

/// Runs once for a new reign or pre-management save, without consuming RNG.
void initializeManagement(GameState s, {bool newReign = false}) {
  if (s.managementVersion > 0 ||
      !s.hasCourtSystem ||
      !s.seasonal ||
      s.population == null ||
      s.warfare == null) {
    return;
  }
  final previous = <String, List<CourtOffice>>{
    for (final role in ['Trấn thủ', 'Tri phủ'])
      role: s.courtOffices.where((o) => o.role == role).toList(),
  };
  final spares =
      previous['Tri phủ']!.length > 3
          ? previous['Tri phủ']!.sublist(3)
          : <CourtOffice>[];
  if (previous['Tri phủ']!.length > 3) {
    previous['Tri phủ']!.removeRange(3, previous['Tri phủ']!.length);
  }
  final used = <String>{};
  final remapped = <String, String>{};
  var index = 0;
  const names = [
    'Lê Quang Hạo',
    'Nguyễn Đình Kiên',
    'Phạm Văn Dực',
    'Trần Bá Nghiêm',
    'Đỗ Đức Tín',
    'Vũ Minh Thành',
    'Ngô Hữu Chính',
    'Hoàng Văn Lễ',
    'Bùi Quang Khải',
    'Tạ Đức Phúc',
    'Đinh Văn Thuận',
    'Cao Minh Khang',
  ];
  for (final post in managementPosts) {
    final old =
        post.kind == 'assistant' && spares.isNotEmpty
            ? spares.removeAt(0)
            : post.senior && previous[post.role]!.isNotEmpty
            ? previous[post.role]!.removeAt(0)
            : null;
    final holderId = old?.holderId ?? 'manager-${post.kind}-${post.area}';
    var holder =
        [
          ...s.court,
          ...s.officialsPool,
        ].where((c) => c.id == holderId).firstOrNull;
    if (old == null) {
      holder = Courtier(
        id: holderId,
        name: names[index],
        role: post.role,
        faction: post.frontier ? 'Võ tướng' : 'Văn thần',
        trait: 'Phụ trách ${post.areaName}, trưởng thành qua công vụ.',
        age: 28 + index,
        ability: post.senior ? 71 : 55,
        loyalty: 70,
        ambition: 35,
        integrity: 70,
        influence: 35,
        affection: 65,
        grade: post.senior ? 6 : 9,
        courtGroup: post.group,
        specialty: post.frontier ? 'Quân sự' : 'Dân chính',
      );
      s.court.add(holder);
    }
    if (holder != null) {
      holder.courtGroup = post.group;
      holder.role = post.role;
      holder.royalEligible = false;
      // Historical personal ranks survive migration. New Trấn thủ start at VI.
      if (newReign && post.kind == 'command') holder.grade = 6;
      used.add(holder.id);
    }
    if (old != null) {
      s.courtOffices.remove(old);
      remapped[old.id] = post.id;
    }
    s.courtOffices.add(
      CourtOffice(
        id: post.id,
        role: post.role,
        group: post.group,
        grade: post.senior ? 6 : 9,
        holderId: holderId,
        appointedTurn: old?.appointedTurn ?? 0,
      ),
    );
    index++;
  }
  // Preserve any additional historical officeholders in the waiting roster.
  // The fourth authored prefect is reused as a local assistant above.
  for (final extra in previous.values.expand((offices) => offices)) {
    s.courtOffices.remove(extra);
    final person = s.court.where((c) => c.id == extra.holderId).firstOrNull;
    if (person != null && !used.contains(person.id)) {
      s.court.remove(person);
      person.role = 'Chờ bổ nhiệm';
      s.officialsPool.add(person);
    }
  }
  s.courtPersonnelMatters =
      s.courtPersonnelMatters.map((matter) {
        final id = remapped[matter.officeId];
        if (id == null) return matter;
        return CourtPersonnelMatter.fromJson({
          ...matter.toJson(),
          'officeId': id,
        });
      }).toList();
  s.courtPersonnelRewarded =
      s.courtPersonnelRewarded.map((key) {
        for (final entry in remapped.entries) {
          if (key.endsWith(':${entry.key}')) {
            return '${key.substring(0, key.length - entry.key.length)}${entry.value}';
          }
        }
        return key;
      }).toSet();
  s.managementVersion = 1;
  s.lastManagementTurn = s.completedWeeks;
}
