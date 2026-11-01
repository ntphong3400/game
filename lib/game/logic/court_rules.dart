import '../models/game_state.dart';
import 'currency_rules.dart';
import 'management_rules.dart';
import 'personnel_rules.dart' show officerBusy;

const promotionMerit = {8: 2, 7: 3, 6: 4, 5: 6, 4: 8, 3: 10, 2: 13, 1: 16};
const promotionFees = {8: 8, 7: 10, 6: 12, 5: 16, 4: 20, 3: 25, 2: 32, 1: 40};
const promotionAbility = {
  8: 45,
  7: 50,
  6: 55,
  5: 60,
  4: 68,
  3: 76,
  2: 84,
  1: 90,
};

CourtOffice? courtOfficeFor(GameState s, String personId) =>
    s.courtOffices.where((o) => o.holderId == personId).firstOrNull;
Courtier? courtOfficeHolder(GameState s, CourtOffice office) =>
    s.court.where((c) => c.available && c.id == office.holderId).firstOrNull;
Courtier? courtPerson(GameState s, String id) =>
    [
      ...s.court,
      ...s.officialsPool,
    ].where((c) => c.id == id && c.available && !c.isConsort).firstOrNull;

class CourtPromotion {
  CourtPromotion(GameState s, Courtier c, this.target) {
    if (target < 1 || target >= c.grade || c.grade > 9) return;
    for (var grade = c.grade - 1; grade >= target; grade--) {
      merit += promotionMerit[grade]!;
      cost += money(s, promotionFees[grade]!);
      affection += 10 - grade;
      discontent += 2 * (10 - grade);
      influence += 3;
    }
  }
  final int target;
  int merit = 0, cost = 0, affection = 0, discontent = 0, influence = 0;
  int actualAffection(Courtier c) => affection.clamp(0, 100 - c.affection);
  int actualDiscontent(Courtier c) => discontent.clamp(0, c.discontent);
}

String? courtPromotionBlocked(
  GameState s,
  Courtier c,
  int target, {
  bool exceptional = false,
}) {
  if (!s.hasCourtSystem) return 'Lượt này dùng bộ luật phẩm hàm cũ.';
  if (s.ended) return 'Triều đại đã kết thúc.';
  if (!c.available || c.isConsort || c.age < 18) {
    return 'Cần quan trưởng thành, còn hiện diện.';
  }
  if (target < 1 || target >= c.grade || c.grade > 9) {
    return 'Hãy chọn phẩm cao hơn phẩm hiện tại.';
  }
  if (officerBusy(s, c.id)) {
    return 'Quan đang bận công vụ; cần hoàn tất trước khi sắc phong.';
  }
  final quote = CourtPromotion(s, c, target);
  if (c.merit < quote.merit) {
    return 'Cần ${quote.merit} công trạng, hiện có ${c.merit}.';
  }
  if (!exceptional && c.ability < promotionAbility[target]!) {
    return 'Cần năng lực ≥${promotionAbility[target]}.';
  }
  final majors = target <= 3 ? 4 - target : 0;
  if (c.majorMerits < majors) {
    return 'Cần $majors thành tích lớn, hiện có ${c.majorMerits}.';
  }
  if (s.points < 1) return 'Không đủ hành động.';
  if (s.treasury < quote.cost) return 'Ngân khố không đủ.';
  return null;
}

int courtAppointmentCost(GameState s, Courtier c, CourtOffice office) {
  if (managementPost(office.id) != null) return 1000;
  final tier =
      office.grade <= 2
          ? 4
          : office.grade <= 4
          ? 3
          : office.grade <= 6
          ? 2
          : 1;
  final a = c.ability.clamp(0, 100);
  final standing = (c.influence.clamp(0, 100) / 25).ceil();
  return money(
    s,
    ((20 + a + a * a ~/ 100) * (10 + 2 * (tier - 1) + standing) / 100).round(),
  );
}

/// Both political permission and disruption follow the office, not its holder.
int courtOfficeDisruption(CourtOffice office) => (9 - office.grade).clamp(1, 8);
int courtOfficeAuthority(CourtOffice office) => switch (office.grade) {
  1 => 80,
  2 => 70,
  3 => 60,
  4 => 50,
  _ => 0,
};
String? courtRemovalBlocked(GameState s, CourtOffice office) {
  final threshold = courtOfficeAuthority(office);
  if (threshold > 0 && s.authority <= threshold) {
    return '${office.role}: cần uy quyền trên $threshold · Hiện tại ${s.authority}.';
  }
  return null;
}

int courtAppointmentDisruption(GameState s, Courtier c, CourtOffice office) {
  if (managementPost(office.id) != null) return 0;
  final source = courtOfficeFor(s, c.id);
  return (courtOfficeHolder(s, office) == null
          ? 0
          : courtOfficeDisruption(office)) +
      (source == null ? 0 : courtOfficeDisruption(source));
}

String? courtAppointmentBlocked(GameState s, Courtier c, CourtOffice office) {
  final post = managementPost(office.id);
  if (post != null) return managementCandidateBlocked(s, c, post);
  if (!c.available || c.isConsort || c.age < 18) {
    return 'Cần quan trưởng thành, còn hiện diện.';
  }
  if (c.id == office.holderId) return 'Đang giữ chức vụ này.';
  if (c.grade < 1 || c.grade > office.grade) {
    return 'Chức vụ cần ${courtGradeName(office.grade)} trở lên.';
  }
  if (office.royalOnly && !c.royalEligible) {
    return 'Tước vị cần thân phận hoàng thân/quý tộc hợp lệ.';
  }
  if (officerBusy(s, c.id)) return 'Người được chọn đang bận công vụ.';
  final outgoing = courtOfficeHolder(s, office);
  if (outgoing != null && officerBusy(s, outgoing.id)) {
    return 'Người đương nhiệm đang bận công vụ.';
  }
  if (outgoing != null) {
    final reason = courtRemovalBlocked(s, office);
    if (reason != null) return reason;
  }
  final source = courtOfficeFor(s, c.id);
  if (source != null) return courtRemovalBlocked(s, source);
  return null;
}

String? courtDismissalBlocked(GameState s, CourtOffice office) {
  if (!s.hasCourtSystem) return 'Lượt này dùng bộ luật nhân sự cũ.';
  final holder = courtOfficeHolder(s, office);
  if (holder == null) return 'Chức vụ đang bỏ trống.';
  if (officerBusy(s, holder.id)) {
    return 'Quan đang bận công vụ; cần hoàn tất trước khi hồi hương.';
  }
  final authority = courtRemovalBlocked(s, office);
  if (authority != null) return authority;
  if (s.ended) return 'Triều đại đã kết thúc.';
  if (s.points < 1) return 'Không đủ hành động.';
  return null;
}

enum CourtBenefit {
  stability('Ổn định triều đình'),
  authority('Uy quyền'),
  morale('Sĩ khí'),
  training('Huấn luyện'),
  logistics('Hậu cần'),
  fatigue('Mệt mỏi của vua'),
  tax('Thưởng thuế vụ Thu'),
  royalMood('Thái độ phe Hoàng tộc');

  const CourtBenefit(this.label);
  final String label;
  String get effect =>
      this == tax
          ? '+0,75%/mùa đủ điều kiện (tối đa 3%/năm)'
          : this == fatigue
          ? '−1/mùa'
          : '+1/mùa';
  String get vacancyEffect =>
      this == tax
          ? '−0,75%/mùa bỏ trống (tối đa −3%/vụ thuế)'
          : this == fatigue
          ? '+1/mùa'
          : '−1/mùa';
}

List<CourtBenefit> courtPassives(CourtOffice office) => switch ((
  office.role,
  office.grade,
)) {
  ('Tể tướng', 1) => [CourtBenefit.stability, CourtBenefit.authority],
  ('Đại tướng', 1) => [CourtBenefit.morale, CourtBenefit.training],
  ('Thân vương', 1) => [CourtBenefit.authority, CourtBenefit.royalMood],
  ('Thái sư', 2) => [CourtBenefit.fatigue],
  ('Hộ bộ', 2) => [CourtBenefit.tax],
  ('Phó tướng', 2) => [CourtBenefit.training],
  ('Đại tư mã', 2) => [CourtBenefit.logistics],
  ('Quận vương', 2) => [CourtBenefit.stability],
  _ => [],
};

String? courtPassiveBlocked(
  GameState s,
  CourtOffice office, {
  bool settlement = false,
}) {
  if (!s.hasCourtSystem || !s.seasonal) {
    return 'Passive chỉ dùng trong lượt 9 phẩm theo mùa.';
  }
  final post = managementPost(office.id);
  if (post != null) {
    final holder = managementHolder(s, post);
    if (holder == null) return 'Vị trí đang bỏ trống.';
    if (holder.abilityScore <= post.abilityThreshold) {
      return 'Cần năng lực >${post.abilityThreshold}.';
    }
    if (holder.affection <= post.affectionThreshold) {
      return 'Cần thiện cảm >${post.affectionThreshold}.';
    }
    return null;
  }
  if (courtPassives(office).isEmpty) return 'Chức vụ không có passive.';
  final c = courtOfficeHolder(s, office);
  if (c == null) return 'Chức vụ đang bỏ trống.';
  if (c.grade < 1 || c.grade > office.grade) return 'Chưa đủ phẩm của chức vụ.';
  final ability = office.grade == 1 ? 90 : 80;
  final affection = office.grade == 1 ? 80 : 70;
  if (c.ability < ability) return 'Cần năng lực ≥$ability (hiện ${c.ability}).';
  if (c.affection < affection) {
    return 'Cần thiện cảm ≥$affection (hiện ${c.affection}).';
  }
  if (office.appointedTurn >= s.week) {
    return 'Nhận đóng góp từ ${s.date(s.week + 1)} sau một mùa giữ chức đầy đủ.';
  }
  if (settlement && s.lastCourtPassiveTurn >= s.week) {
    return 'Đã quyết toán mùa này.';
  }
  return null;
}

/// Vacant offices invert their effects; an unqualified holder contributes zero.
int courtOfficeDirection(GameState s, CourtOffice office) {
  final post = managementPost(office.id);
  if (post != null) return managementDirection(s, post);
  if (!s.hasCourtSystem || !s.seasonal || courtPassives(office).isEmpty) {
    return 0;
  }
  if (courtOfficeHolder(s, office) == null) return -1;
  return courtPassiveBlocked(s, office) == null ? 1 : 0;
}

String courtVacancyEffects(CourtOffice office) =>
    managementPost(office.id)?.effect(vacant: true) ??
    courtPassives(
      office,
    ).map((benefit) => '${benefit.label} ${benefit.vacancyEffect}').join(' · ');

int courtTaxYear(GameState s) => s.season == 'Đông' ? s.year + 1 : s.year;
int courtTaxSeasonCount(GameState s, {int? year}) {
  if (!s.hasCourtSystem) return 0;
  final target = year ?? s.year;
  var count = s.courtTaxSeasons['$target'] ?? 0;
  if (target == courtTaxYear(s) && s.lastCourtPassiveTurn < s.week) {
    for (final office in s.courtOffices.where(
      (o) => courtPassives(o).contains(CourtBenefit.tax),
    )) {
      count += courtOfficeDirection(s, office);
    }
  }
  return count.clamp(-4, 4);
}
