import '../models/game_state.dart';
import 'court_rules.dart';
import 'management_rules.dart';
import 'personnel_rules.dart';
import 'currency_rules.dart';

bool isCourtPersonnelEvent(String id) => id.startsWith('court-personnel:');
CourtPersonnelMatter? courtMatterForEvent(GameState s, String eventId) =>
    s.courtPersonnelMatters.where((m) => m.eventId == eventId).firstOrNull;
CourtOffice? courtMatterOffice(GameState s, CourtPersonnelMatter m) =>
    s.courtOffices.where((o) => o.id == m.officeId).firstOrNull;
bool courtMatterNeedsNominee(CourtPersonnelMatter m, int index) =>
    index == 1 &&
    (m.kind == 'nominate' ||
        m.kind == 'reform' ||
        (m.kind == 'recruit' && m.verified));
bool courtMatterAppoints(CourtPersonnelMatter m, int index) =>
    ['nominate', 'recruit', 'reform'].contains(m.kind) &&
    (index == 0 || courtMatterNeedsNominee(m, index));
int courtMatterLastChoice(CourtPersonnelMatter m) => 2;
Courtier? courtMatterCandidate(
  GameState s,
  CourtPersonnelMatter m,
  int index,
  String nomineeId,
) => courtPerson(s, courtMatterNeedsNominee(m, index) ? nomineeId : m.personId);

bool courtMatterFillsVacancy(GameState s, CourtPersonnelMatter m, int index) =>
    courtMatterAppoints(m, index) &&
    courtMatterOffice(s, m) != null &&
    courtOfficeHolder(s, courtMatterOffice(s, m)!) == null;

CourtPromotion vacancyPromotion(GameState s, Courtier c, CourtOffice office) =>
    CourtPromotion(s, c, c.grade > office.grade ? office.grade : c.grade);

String? vacancyNominationBlocked(GameState s, Courtier c, CourtOffice office) {
  if (s.ended) return 'Triều đại đã kết thúc.';
  if (courtOfficeHolder(s, office) != null) return 'Chức vụ đã có người giữ.';
  if (!c.available ||
      c.dead ||
      c.imprisoned ||
      c.isConsort ||
      c.age < 18 ||
      c.grade < 1 ||
      c.grade > 9) {
    return 'Cần quan trưởng thành, có phẩm vị và còn hiện diện.';
  }
  if (office.royalOnly && !c.royalEligible) {
    return 'Tước vị cần thân phận hoàng thân/quý tộc hợp lệ.';
  }
  final post = managementPost(office.id);
  if (post != null && c.category != post.group) {
    return 'Vị trí dành cho ${post.group}.';
  }
  if (officerBusy(s, c.id)) return 'Người được tiến cử đang bận công vụ.';
  if (c.grade > office.grade) {
    return courtPromotionBlocked(s, c, office.grade, exceptional: true);
  }
  if (s.points < 1) return 'Cần 1 hành động.';
  return null;
}

String? courtMatterInvalid(GameState s, CourtPersonnelMatter m) {
  final c = courtPerson(s, m.personId);
  if (c == null) return 'Người liên quan không còn hiện diện.';
  if (['promote', 'patronage'].contains(m.kind)) {
    if (c.grade <= m.targetGrade) return 'Đã đạt phẩm được đề nghị.';
    return null;
  }
  final office = courtMatterOffice(s, m);
  if (office == null) return 'Chức vụ không còn tồn tại.';
  if (['nominate', 'recruit'].contains(m.kind) &&
      courtOfficeHolder(s, office) != null) {
    return 'Chức vụ đã có người giữ; đề nghị bổ khuyết được khép lại.';
  }
  if (['retire', 'reform'].contains(m.kind) && office.holderId != m.holderId) {
    return 'Người giữ chức đã thay đổi; đề nghị cũ được khép lại.';
  }
  if (m.kind == 'reform' && c.id == office.holderId) {
    return 'Đề nghị thay thế phải tiến cử người khác với người đương nhiệm.';
  }
  return null;
}

bool courtNomineeQualified(Courtier c, CourtOffice office) {
  final post = managementPost(office.id);
  if (post != null) {
    return c.available &&
        !c.retired &&
        c.category == post.group &&
        (!post.senior || (c.grade >= 1 && c.grade <= 6)) &&
        c.abilityScore > post.abilityThreshold &&
        c.affection > post.affectionThreshold;
  }
  return c.available &&
      !c.retired &&
      c.grade >= 1 &&
      c.grade <= office.grade &&
      c.ability >=
          (office.grade == 1
              ? 90
              : office.grade == 2
              ? 80
              : promotionAbility[office.grade] ?? 40) &&
      specialtyFit(c.specialty, specialtyForRole(office.role)) >= 80 &&
      (courtPassives(office).isEmpty ||
          c.affection >= (office.grade == 1 ? 80 : 70));
}

String? courtReformCandidateBlocked(
  GameState s,
  Courtier c,
  CourtOffice office,
) {
  final blocked = courtAppointmentBlocked(s, c, office);
  if (blocked != null) return blocked;
  if (!courtNomineeQualified(c, office)) {
    return 'Cần đủ năng lực, thiện cảm và chuyên môn của chức vụ để được tiến cử thay thế.';
  }
  return null;
}

String? courtPersonnelChoiceBlocked(
  GameState s,
  CourtPersonnelMatter m,
  int index, {
  String nomineeId = '',
}) {
  if (m.status != 'open') return 'Tấu nhân sự đã được xử lý.';
  if (index < 0 || index > courtMatterLastChoice(m)) {
    return 'Lựa chọn không hợp lệ.';
  }
  if (s.points < 1) return 'Cần 1 hành động để xác nhận.';
  if (index == courtMatterLastChoice(m)) return null;
  final invalid = courtMatterInvalid(s, m);
  if (invalid != null) return invalid;
  final c = courtPerson(s, m.personId)!;
  if (courtMatterAppoints(m, index)) {
    final candidate = courtMatterCandidate(s, m, index, nomineeId);
    if (candidate == null) return 'Hãy chọn người được bổ nhiệm.';
    final office = courtMatterOffice(s, m)!;
    if (courtMatterFillsVacancy(s, m, index)) {
      return vacancyNominationBlocked(s, candidate, office);
    }
    final blocked =
        m.kind == 'reform'
            ? courtReformCandidateBlocked(s, candidate, office)
            : courtAppointmentBlocked(s, candidate, office);
    if (blocked != null) return blocked;
    if (s.treasury < courtAppointmentCost(s, candidate, office)) {
      return 'Ngân khố không đủ phí bổ nhiệm.';
    }
  } else if (m.kind == 'retire' && index == 0) {
    return courtDismissalBlocked(s, courtMatterOffice(s, m)!);
  } else if (['promote', 'patronage'].contains(m.kind) && index == 0) {
    return courtPromotionBlocked(
      s,
      c,
      m.targetGrade,
      exceptional: m.kind == 'patronage',
    );
  } else if (m.kind == 'recruit' && index == 1 && s.treasury < money(s, 5)) {
    return 'Ngân khố không đủ phí khảo hạch.';
  } else if (m.kind == 'retire' && index == 1 && m.verified) {
    return 'Đã đối chiếu công việc; hãy chấp thuận hoặc bác đề nghị.';
  }
  return null;
}
