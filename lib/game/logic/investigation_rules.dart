import '../models/game_state.dart';
import 'court_rules.dart';
import 'currency_rules.dart';
import 'personnel_rules.dart';

const covertFunding = [20, 40, 80];
int covertCost(GameState s, int funding) => money(s, funding);
int spyGradeBonus(Courtier spy) => switch (spy.grade) {
  1 => 12,
  2 || 3 => 9,
  4 || 5 => 6,
  6 || 7 => 3,
  _ => 0,
};
int investigationDifficulty(Courtier target) =>
    target.isConsort
        ? (target.queen
            ? 25
            : target.inHarem
            ? 15
            : 5)
        : switch (target.grade) {
          1 => 25,
          2 || 3 => 20,
          4 || 5 => 15,
          6 || 7 => 10,
          8 || 9 => 5,
          _ => 0,
        };
int investigationDeathRisk(Courtier target) =>
    target.isConsort
        ? (target.queen
            ? 12
            : target.inHarem
            ? 4
            : 1)
        : switch (target.grade) {
          1 => 12,
          2 || 3 => 9,
          4 || 5 => 6,
          6 || 7 => 4,
          8 || 9 => 2,
          _ => 1,
        };
int covertChance(Courtier spy, Courtier target, int funding) => (50 +
        .6 * (spy.abilityScore - 50) +
        spyGradeBonus(spy) -
        investigationDifficulty(target) +
        covertFunding.indexOf(funding) * 10)
    .round()
    .clamp(10, 95);

String? covertSpyBlocked(GameState s, Courtier spy, Courtier target) {
  if (!spy.available ||
      spy.dead ||
      spy.imprisoned ||
      spy.retired ||
      spy.age < 18 ||
      spy.role != 'Mật thám' ||
      (s.hasCourtSystem && courtOfficeFor(s, spy.id)?.role != 'Mật thám')) {
    return 'Cần người đang giữ chức Mật thám, trưởng thành và còn hiện diện.';
  }
  if (spy.id == target.id) return 'Không thể tự điều tra chính mình.';
  if (officerBusy(s, spy.id)) return 'Mật thám đang bận nhiệm vụ.';
  return null;
}

List<Courtier> covertSpies(GameState s, Courtier target) =>
    s.court.where((c) => covertSpyBlocked(s, c, target) == null).toList()
      ..sort((a, b) => b.abilityScore.compareTo(a.abilityScore));

String? covertBlocked(
  GameState s,
  Courtier target,
  Courtier? spy,
  int funding,
) {
  if (s.ended) return 'Triều đại đã kết thúc.';
  if (!target.available || target.dead || target.imprisoned) {
    return 'Mục tiêu không còn hiện diện.';
  }
  if (s.pending.any((p) => p.kind == 'investigate' && p.target == target.id)) {
    return 'Cuộc điều tra đang được tiến hành.';
  }
  if (!covertFunding.contains(funding)) return 'Mức kinh phí không hợp lệ.';
  if (spy == null) return 'Hãy chọn mật thám.';
  final blocked = covertSpyBlocked(s, spy, target);
  if (blocked != null) return blocked;
  if (s.points < 1) return 'Cần 1 hành động.';
  if (s.treasury < covertCost(s, funding)) return 'Ngân khố không đủ.';
  return null;
}

int evidenceLifetime(GameState s) => s.seasonal ? 4 : 52;
int evidenceExpires(GameState s, Courtier c) =>
    c.evidenceTurn + evidenceLifetime(s);
String? evidenceBlocked(GameState s, Courtier c, int threshold) {
  if (s.ended) return 'Triều đại đã kết thúc.';
  if (!c.available || c.dead || c.imprisoned) {
    return 'Nhân vật không còn hiện diện.';
  }
  if (c.evidenceTurn == 0 || c.lastInvestigation == null) {
    return 'Cần báo cáo điều tra kín thành công.';
  }
  if (s.week < c.evidenceTurn || s.week >= evidenceExpires(s, c)) {
    return 'Bằng chứng đã hết hạn một năm; cần điều tra kín lại.';
  }
  if (c.lastInvestigation!.plot <= threshold) {
    return 'Cần âm mưu đã xác minh >$threshold%.';
  }
  if (s.points < 1) return 'Cần 1 hành động.';
  return null;
}

String? courtDemotionBlocked(GameState s, Courtier c, int steps) {
  if (!s.hasCourtSystem || c.isConsort) {
    return 'Giáng phẩm chỉ áp dụng cho triều thần có phẩm vị.';
  }
  if (steps != 1 && steps != 2) return 'Chỉ giáng một hoặc hai phẩm.';
  final blocked = evidenceBlocked(s, c, steps == 1 ? 50 : 60);
  if (blocked != null) return blocked;
  if (c.grade < 1 || c.grade + steps > 9) {
    return 'Không thể giáng quá Cửu phẩm.';
  }
  return null;
}
