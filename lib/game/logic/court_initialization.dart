import '../models/game_state.dart';

/// Preserves authored identities; office allocation is deterministic for the seed.
void initializeCourt(GameState s, int Function(int) next) {
  s.courtSystemVersion = 1;
  s.court.removeWhere((c) => c.role == 'Đô đốc');
  const additions = [
    (
      'grand-tutor',
      'Nguyễn Trọng Hiền',
      'Thái sư',
      'Văn ban',
      2,
      'Dân chính',
      87,
    ),
    (
      'inspector',
      'Tạ Minh Đức',
      'Giám sát ngự sử',
      'Văn ban',
      7,
      'Dân chính',
      72,
    ),
    ('court-clerk', 'Đỗ Văn Khoa', 'Thư lại', 'Văn ban', 9, 'Dân chính', 64),
    ('war-minister', 'Đặng Quân Bình', 'Đại tư mã', 'Võ ban', 2, 'Quân sự', 90),
    (
      'campaign-general',
      'Trần Võ Nghị',
      'Chinh tướng',
      'Võ ban',
      3,
      'Quân sự',
      79,
    ),
    ('captain', 'Phan Đức Dũng', 'Hiệu úy', 'Võ ban', 6, 'Quân sự', 73),
    (
      'squad-leader',
      'Nguyễn Bá Hùng',
      'Đội trưởng',
      'Võ ban',
      9,
      'Quân sự',
      67,
    ),
    (
      'junior-royal-tutor',
      'Vũ Đình Nho',
      'Thiếu phó',
      'Hoàng thất',
      6,
      'Dân chính',
      78,
    ),
    (
      'palace-chef',
      'Trần Phúc Lộc',
      'Thượng thiện',
      'Nội đình',
      5,
      'Cung đình',
      73,
    ),
    (
      'palace-wardrobe',
      'Nguyễn Công Hòa',
      'Thượng phục',
      'Nội đình',
      6,
      'Cung đình',
      68,
    ),
    ('junior-doctor', 'Lê Y Đức', 'Ngự y', 'Nội đình', 7, 'Y thuật', 75),
    ('junior-spy', 'Phan Minh Sát', 'Mật thám', 'Nội đình', 7, 'An ninh', 69),
  ];
  for (final (id, name, role, group, grade, specialty, ability) in additions) {
    s.court.add(
      Courtier(
        id: id,
        name: name,
        role: role,
        faction: s.factions.keys.elementAt(next(4)),
        trait:
            'Được triều trước bổ nhiệm; cần tìm hiểu qua công vụ và triệu kiến.',
        age: 25 + next(25),
        ability: ability,
        loyalty: 50 + next(36),
        ambition: 25 + next(61),
        integrity: 40 + next(51),
        influence: 30 + next(41),
        grade: grade,
        courtGroup: group,
        specialty: specialty,
      ),
    );
  }
  const grades = {
    'Tể tướng': 1,
    'Thái sư': 2,
    'Hộ bộ': 2,
    'Lại bộ': 3,
    'Ngự sử': 4,
    'Lễ bộ': 5,
    'Công bộ': 5,
    'Hình bộ': 6,
    'Học sĩ': 7,
    'Giám sát ngự sử': 7,
    'Thương chính': 8,
    'Thư lại': 9,
    'Đại tướng': 1,
    'Phó tướng': 2,
    'Đại tư mã': 2,
    'Chinh tướng': 3,
    'Trấn thủ': 6,
    'Biên tướng': 5,
    'Hiệu úy': 6,
    'Cấm vệ': 7,
    'Võ quan': 8,
    'Đội trưởng': 9,
    'Thân vương': 1,
    'Quận vương': 2,
    'Quốc công': 3,
    'Thái phó': 4,
    'Tông chính': 5,
    'Thiếu phó': 6,
    'Tổng quản': 3,
    'Ngự y': 4,
    'Mật thám': 4,
    'Thượng thiện': 5,
    'Thượng phục': 6,
    'Ngự tiền': 8,
    'Tuần phủ': 4,
    'Tri phủ': 6,
    'Quan điền': 9,
  };
  for (final c in s.court.where((c) => !c.isConsort)) {
    if (c.role == 'Thái phó') c.courtGroup = 'Hoàng thất';
    c.courtGroup ??= c.category;
    c.grade = c.grade > 0 ? c.grade : grades[c.role]!;
    c.royalEligible = [
      'Thân vương',
      'Quận vương',
      'Quốc công',
    ].contains(c.role);
    s.courtOffices.add(
      CourtOffice(
        id: 'office-${c.id}',
        role: c.role,
        group: c.category,
        grade: c.grade,
        royalOnly: c.royalEligible,
      ),
    );
  }
  for (final group in s.courtOffices.map((o) => o.group).toSet()) {
    // Titled nobles only exchange inherited titles among eligible nobles.
    for (final royal in [false, true]) {
      final offices =
          s.courtOffices
              .where((o) => o.group == group && o.royalOnly == royal)
              .toList();
      final people =
          s.court
              .where(
                (c) =>
                    !c.isConsort &&
                    c.category == group &&
                    c.royalEligible == royal,
              )
              .toList();
      for (var i = people.length - 1; i > 0; i--) {
        final j = next(i + 1);
        final c = people[i];
        people[i] = people[j];
        people[j] = c;
      }
      for (var i = 0; i < offices.length; i++) {
        final office = offices[i], c = people[i];
        office.holderId = c.id;
        c.role = office.role;
        c.grade = office.grade;
      }
    }
  }
  // New reigns inherit a mixed-quality court, with a viable long-term royal
  // successor instead of a permanently unreachable top royal passive.
  for (final c in s.court.where((c) => !c.isConsort)) {
    c.ability = (c.ability + next(21) - 10).clamp(25, 95);
  }
  final nobles = s.court.where((c) => c.royalEligible).toList();
  if (nobles.isNotEmpty) nobles[next(nobles.length)].ability = 90 + next(6);
}
