import '../data/harem_quests.dart';
import '../models/game_state.dart';
import 'court_rules.dart';
import 'currency_rules.dart';

const haremLimit = 10;

int haremResidentCount(GameState s) =>
    s.court.where((c) => c.isConsort && c.available && c.inHarem).length;

String? haremAdmissionBlocked(GameState s) =>
    haremResidentCount(s) >= haremLimit
        ? 'Hậu cung đã đủ $haremLimit người, bao gồm Hoàng hậu. Cần đưa một người ra khỏi hậu cung trước.'
        : null;

HaremQuest? haremQuestFor(GameState s, String personId, {bool queen = false}) =>
    s.haremQuests
        .where((q) => q.personId == personId && q.queen == queen)
        .firstOrNull;

int haremConflictPercent(Courtier c, {bool queen = false}) {
  final count =
      c.knownPersonalities
          .where(
            (p) => const {
              Personality.resentful,
              Personality.familyFirst,
              Personality.partisan,
            }.contains(p),
          )
          .length;
  return (queen ? const [0, 35, 50, 60] : const [0, 25, 40, 50])[count.clamp(
    0,
    3,
  )];
}

Courtier? haremQuestPerson(GameState s, String id) =>
    [...s.court, ...s.officialsPool].where((c) => c.id == id).firstOrNull;

bool haremCommitmentMet(GameState s, HaremQuest q) {
  final d = haremQuestDefinition(q.definitionId);
  if (!d.conflict) return true;
  final person = haremQuestPerson(s, q.personId);
  if (person == null) {
    return false;
  }
  final target = haremQuestPerson(s, q.targetId);
  final office = s.courtOffices.where((o) => o.id == q.officeId).firstOrNull;
  final holder = office == null ? null : courtOfficeHolder(s, office);
  return switch (d.objective!) {
    HaremObjective.removeConsort =>
      target != null && (!target.available || !target.inHarem),
    HaremObjective.removeOfficial || HaremObjective.removePower =>
      office != null && office.holderId != q.targetId,
    HaremObjective.familyOffice =>
      holder != null &&
          holder.id != q.targetId &&
          q.familyIds.contains(holder.id),
    HaremObjective.factionOffice =>
      holder != null &&
          holder.id != q.targetId &&
          holder.faction == person.faction,
  };
}

String? haremPassiveBlocked(GameState s, Courtier c, {bool queen = false}) {
  if (!s.seasonal) return 'Đóng góp hậu cung dành cho lượt theo mùa.';
  if (!c.isConsort || !c.available || !c.inHarem) {
    return 'Cần còn hiện diện trong hậu cung.';
  }
  if (c.age < 18) return 'Cần đủ 18 tuổi.';
  if (queen && !c.queen) return 'Cần giữ ngôi Hoàng hậu.';
  final q = haremQuestFor(s, c.id, queen: queen);
  if (q == null || !q.completed) {
    return queen
        ? 'Chưa hoàn thành tuyến Hoàng hậu.'
        : 'Chưa hoàn thành câu chuyện cá nhân.';
  }
  if (queen ? c.affection < 85 : c.affection <= 70) {
    return queen ? 'Cần thiện cảm ≥85.' : 'Cần thiện cảm >70.';
  }
  final d = haremQuestDefinition(q.definitionId);
  if (d.conflict &&
      (!haremCommitmentMet(s, q) || q.verifiedSeasons < d.requiredSeasons)) {
    return 'Cam kết nhân sự chưa được duy trì đủ ${d.requiredSeasons} mùa đầy đủ.';
  }
  return null;
}

int haremChapterCost(GameState s, HaremQuest q, String choice) {
  final d = haremQuestDefinition(q.definitionId);
  final divisor = !d.conflict && choice == 'B' ? 6 : 3;
  return money(s, d.cost / divisor);
}

String haremChoiceConsequence(GameState s, HaremQuest q, String choice) {
  final d = haremQuestDefinition(q.definitionId);
  if (d.conflict) {
    return 'Phải thực hiện mục tiêu nhân sự thật; phí và hậu quả nhân sự tính riêng. '
        'Duy trì ${d.requiredSeasons} mùa đầy đủ trước khi hoàn thành, sau đó tiếp tục giữ cam kết.';
  }
  if (choice == 'A') {
    return 'Không thêm hình phạt chính trị của nhiệm vụ ở chương này.';
  }
  return q.stage < 2
      ? 'Thái độ phe ${q.faction} −${d.factionLoss ~/ 2}.'
      : '${d.stat == 'authority' ? 'Uy quyền' : 'Ổn định triều đình'} −${d.statLoss}.';
}

String? haremChapterBlocked(
  GameState s,
  Courtier c,
  HaremQuest q,
  String choice,
) {
  if (!c.available || !c.inHarem || c.age < 18) {
    return 'Nhân vật không còn trong hậu cung.';
  }
  if (q.queen && !c.queen) {
    return 'Tuyến tạm dừng do không còn giữ ngôi Hoàng hậu.';
  }
  if (q.completed) return 'Tuyến đã hoàn thành.';
  if (s.ended) return 'Lượt trị vì đã kết thúc.';
  if (s.week < q.refusedUntil) {
    return 'Có thể tiếp tục từ ${s.date(q.refusedUntil)}.';
  }
  if (s.haremChapterTurns[c.id] == s.week) {
    return 'Mỗi người tiến tối đa một chương mỗi mùa.';
  }
  if (s.points < 1) return 'Không đủ hành động.';
  final d = haremQuestDefinition(q.definitionId);
  if (d.conflict && choice != 'A') {
    return 'Hãy dùng lựa chọn từ chối để bác yêu cầu.';
  }
  if (d.conflict &&
      q.stage == 2 &&
      (!haremCommitmentMet(s, q) || q.verifiedSeasons < d.requiredSeasons)) {
    return 'Cần hoàn tất mục tiêu và giữ đủ ${d.requiredSeasons} mùa đầy đủ '
        '(đã xác nhận ${q.verifiedSeasons}/${d.requiredSeasons}).';
  }
  if (s.treasury < haremChapterCost(s, q, choice)) return 'Không đủ ngân khố.';
  return null;
}

String haremQuestText(GameState s, Courtier c, HaremQuest q, String text) {
  final target = haremQuestPerson(s, q.targetId);
  final office = s.courtOffices.where((o) => o.id == q.officeId).firstOrNull;
  return text
      .replaceAll('{name}', c.name)
      .replaceAll('{target}', target?.name ?? 'đối tượng đã ghi trong hồ sơ')
      .replaceAll('{office}', office?.role ?? 'vị trí đã ghi trong hồ sơ')
      .replaceAll('{faction}', q.faction)
      .replaceAll('{ownerFaction}', c.faction);
}

String haremQuestGoal(GameState s, Courtier c, HaremQuest q) {
  final d = haremQuestDefinition(q.definitionId);
  if (!d.conflict) {
    return 'Hoàn thành ba chương; ${q.queen ? 'thiện cảm ≥85 và còn ngôi hậu' : 'thiện cảm >70'} để active passive.';
  }
  final family = q.familyIds
      .map((id) => haremQuestPerson(s, id)?.name ?? id)
      .join(', ');
  return '${haremQuestText(s, c, q, d.chapters.last.body)}'
      '${family.isEmpty ? '' : '\nỨng viên gia tộc: $family.'}';
}
