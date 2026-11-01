import 'currency_rules.dart';
import '../data/reign_content.dart';
import '../models/game_state.dart';
import 'personnel_rules.dart';
import 'population_rules.dart';

const firstDifficultyWeek = 8;
const seasonalStageStarts = [0, 1, 4, 20, 60, 120];
const seasonalStageNames = [
  'Đăng cơ',
  'Thử thách đầu triều',
  'Tranh quyền',
  'Sóng gió',
  'Ngoại ưu nội hoạn',
  'Giữ vững cơ nghiệp',
];

int reignStage(GameState s) =>
    s.seasonal
        ? seasonalStageStarts.lastIndexWhere(
          (start) => s.completedWeeks >= start,
        )
        : s.completedWeeks >= 52
        ? 2
        : s.completedWeeks >= firstDifficultyWeek - 1
        ? 1
        : 0;
String reignStageName(GameState s) =>
    s.seasonal
        ? seasonalStageNames[reignStage(s)]
        : ['Đăng cơ', 'Tranh quyền', 'Sóng gió'][reignStage(s)];
String reignStageHint(GameState s) {
  if (s.seasonal) {
    final stage = reignStage(s);
    final next =
        stage + 1 < seasonalStageStarts.length
            ? ' Mốc tiếp theo: ${s.date(seasonalStageStarts[stage + 1] + 1)}.'
            : '';
    return 'Chi điều hành +${money(s, stage * 8)}${s.goldStandard ? ' lượng vàng' : ''}/mùa; đại biến cố mức ${stage + 1}. '
        'Tăng khó vào Hạ năm 1, Xuân năm 2, 6, 16 và 31.$next';
  }
  return switch (reignStage(s)) {
    0 =>
      'Từ tuần $firstDifficultyWeek: chi điều hành +2/tuần, đại biến cố mức 2. Từ tuần 53: +4/tuần, đại biến cố mức 3.',
    1 =>
      'Chi điều hành +2/tuần. Từ tuần 53: +4/tuần, đại biến cố mức 3; phe phái phân hóa gây thêm áp lực.',
    _ =>
      'Chi điều hành +4/tuần; đại biến cố mức 3. Dự phòng nguồn lực và cân bằng các phe.',
  };
}

String majorSeasonHint(String season) => switch (season) {
  'Xuân' => 'Gieo trồng, giống lúa, dịch gia súc, lễ nghi và bang giao',
  'Hạ' => 'Hạn hán, vỡ đê, sạt lở, dịch bệnh và bão biển',
  'Thu' => 'Châu chấu, mùa gặt, thuế khóa, vận lương và thương mại',
  _ => 'Thiếu lương, rét, quân nhu, biên cương và tranh quyền',
};

Set<String> majorPreferredSeasons(MajorDefinition d) => switch (d.id) {
  'flood' ||
  'db-21' ||
  'db-24' ||
  'db-25' ||
  'db-27' ||
  'db-52' ||
  'db-53' => {'Hạ'},
  'locust' => {'Hạ', 'Thu'},
  'db-22' || 'db-17' => {'Xuân', 'Hạ'},
  'db-23' || 'db-28' || 'db-29' || 'db-30' => {'Xuân'},
  'invasion' || 'db-02' || 'db-05' || 'db-06' => {'Thu', 'Đông'},
  'marriage' || 'db-60' => {'Xuân', 'Thu'},
  _ => switch (d.group) {
    'economy' => {'Thu', 'Đông'},
    'military' => {'Thu', 'Đông'},
    'politics' => {'Đông', 'Xuân'},
    'disaster' => {'Hạ', 'Thu'},
    _ => {'Xuân', 'Hạ', 'Thu', 'Đông'},
  },
};
int majorDuration(GameState s, MajorDefinition d) =>
    s.seasonal ? d.objectives.length : 6;
int majorGap(GameState s, int random) =>
    s.seasonal ? 3 + random % 3 : 4 + random % 21;
const crisisNames = {
  'hunger': 'Thiếu lương',
  'border': 'Biên phòng suy yếu',
  'plot': 'Âm mưu đang lớn',
};
const crisisRemedies = {
  'hunger': 'Mua thóc, cứu tế, hoàn thành khai khẩn hoặc nhiệm vụ vận lương.',
  'border': 'Luyện quân, hoàn thành hòa đàm hoặc nhiệm vụ phòng thủ.',
  'plot': 'Tăng an ninh hoặc hoàn tất điều tra có kết quả.',
};
Set<String> activeCrises(GameState s) => {
  if (s.population == null ? s.grain < 25 : foodDays(s) < 90) 'hunger',
  if (s.war > 0 || armyCondition(s) < 35) 'border',
  if (s.court.any(
    (c) => c.available && (!c.isConsort || c.inHarem) && c.plot >= 30,
  ))
    'plot',
};
int missionDuration(ObjectiveDefinition d, Courtier c) =>
    d.duration +
    (specialtyFit(c.specialty, d.specialty) == 20 ? 1 : 0) +
    (c.strain >= 60 ? 1 : 0) +
    (c.ability < 50 ? 1 : 0);
String missionTask(ObjectiveDefinition d) => switch (d.specialty) {
  'Kinh tế' => 'farm',
  'Công trình' => 'repair',
  'Quân sự' => 'train',
  'An ninh' => 'security',
  'Ngoại giao' => 'diplomacy',
  _ => 'relief',
};
TaskAssessment missionAssessment(
  GameState s,
  ObjectiveDefinition d,
  Courtier c, {
  bool knownOnly = false,
}) => TaskAssessment.forSpecialty(
  missionTask(d),
  c,
  d.specialty,
  s,
  knownOnly: knownOnly,
);
int missionRemainingCost(int base, MissionObjective o) =>
    (base * (100 - o.delivered) / 100).ceil();
int missionCost(MajorMission m, ObjectiveDefinition d) =>
    m.demanding ? (d.cost * (1.75 + (m.severity - 1) * .15)).ceil() : d.cost;
int missionGrain(MajorMission m, ObjectiveDefinition d) =>
    m.demanding ? (d.grain * 1.25).ceil() : d.grain;
int missionMinimumAbility(MajorMission m) =>
    m.demanding ? (60 + (m.severity - 1) * 3).clamp(60, 75) : 0;
String? missionOfficerBlocked(
  MajorMission m,
  ObjectiveDefinition d,
  Courtier c,
) {
  if (!m.demanding) return null;
  if (c.ability < missionMinimumAbility(m)) {
    return 'Cần năng lực ít nhất ${missionMinimumAbility(m)}/100.';
  }
  if (specialtyFit(c.specialty, d.specialty) < 65) {
    return 'Cần chuyên môn ${d.specialty} hoặc chuyên môn liên quan.';
  }
  return null;
}

List<Courtier> missionOfficers(GameState s, ObjectiveDefinition d) {
  final list =
      s.court
          .where(
            (c) =>
                c.available &&
                !c.isConsort &&
                !officerBusy(s, c.id) &&
                (s.major == null ||
                    missionOfficerBlocked(s.major!, d, c) == null),
          )
          .toList();
  list.sort((a, b) {
    final duration = missionDuration(d, a).compareTo(missionDuration(d, b));
    return duration != 0 ? duration : b.ability.compareTo(a.ability);
  });
  return list;
}

String missionResultLabel(int achieved) =>
    [
      'Thảm họa nghiêm trọng',
      'Ứng phó yếu',
      'Ứng phó một phần',
      'Cơ bản kiểm soát',
      'Ứng phó toàn diện',
    ][achieved];

/// Shared exact preview/settlement. Each unprotected objective contributes only
/// its own loss; thresholds are monotonic for any subset of completed goals.
Map<String, int> missionEffects(MajorMission m) {
  if (m.petitionDriven) {
    // Stage losses have already passed through the ledger exactly once.
    return m.stage >= m.objectives.length && m.achieved == m.objectives.length
        ? Map.of(majorDefinition(m.kind).rewards)
        : {};
  }
  if (m.achieved == 4) return Map.of(majorDefinition(m.kind).rewards);
  // Major crises can end a weakened reign; completed goals still remove
  // their own loss entirely. No artificial survival floor is applied.
  final factor = [10, 7, 4, 2][m.achieved];
  final multiplier =
      factor * (1 + (m.severity - 1) * .2) * (1 - m.preparedness * .1);
  final result = <String, int>{};
  final defs = majorDefinition(m.kind).objectives;
  for (final o in m.objectives.where((o) => !o.done)) {
    for (final e in defs.firstWhere((d) => d.key == o.key).damage.entries) {
      final value = (e.value * multiplier).round();
      result.update(e.key, (v) => v + value, ifAbsent: () => value);
    }
  }
  return result;
}

Map<String, int> majorPetitionDamage(
  MajorMission m,
  ObjectiveDefinition goal,
  int coverage,
) {
  final factor =
      (3 + m.severity * .6) * (1 - m.preparedness * .1) * (1 - coverage / 100);
  return {
    for (final e in goal.damage.entries)
      if ((e.value * factor).round() != 0) e.key: (e.value * factor).round(),
  };
}

/// A forecast against current stats; weekly costs and other events may make
/// the actual end-of-week situation worse. Uses the same settlement effects.
List<String> missionTerminalRisks(GameState s, MajorMission m) {
  final effects = missionEffects(m);
  return [
    if (s.health + (effects['health'] ?? 0) <= 0) 'Sức khỏe về 0',
    if (s.stability + (effects['stability'] ?? 0) <= 0)
      'Ổn định triều đình về 0',
    if (s.people + (effects['people'] ?? 0) <= 0) 'Lòng dân về 0',
    if (s.population == null && s.army + (effects['army'] ?? 0) <= 0)
      'Quân lực về 0',
    if (s.authority + (effects['authority'] ?? 0) <= 0)
      'Uy quyền về 0, vua trở thành bù nhìn',
  ];
}

String officerWorkHint(Courtier c, [GameState? state]) =>
    'Mệt ${c.strain}/100 · công trạng ${c.merit}${state?.hasCourtSystem == true ? ' khả dụng · ${c.majorMerits} thành tích lớn' : '/100'} · '
    'giảm ${c.strain ~/ 8} điểm % thành công, ${c.strain ~/ 5} điểm % hiệu quả. '
    'Nhận việc +12 mệt; rảnh hồi 8 mỗi ${state?.periodName ?? 'tuần'}, đang bận hồi 3. Mỗi 3 lần lập công tăng 3 ảnh hưởng, xin ${state?.seasonal == true ? 8 : 4} tiền/${state?.periodName ?? 'tuần'} × ${state?.seasonal == true ? 2 : 4} ${state?.periodName ?? 'tuần'}; trả thiếu làm phe −1/kỳ.';
const emergencyHints = {
  'borrow':
      'Nhận 120 tiền · 1 hành động. Từ cuối tuần sau trả 15/tuần × 10 tuần (tổng 150). Thế gia +5, uy quyền −2. Chỉ một khoản vay đang chạy.',
  'levy':
      'Quân lực +14 · chi 15 · 1 hành động · lòng dân −4. Từ tuần sau, thiếu lao động làm mất 2 thóc/tuần × 6 tuần. Không huy động tiếp khi nghĩa vụ này còn hiệu lực.',
  'peace':
      'Giảm chiến tranh 2 · chi 20 · 1 hành động · uy quyền −3. Từ tuần sau cống 6/tuần × 8 tuần (tổng 48). Cần đang chiến tranh và chưa có nghĩa vụ cống nạp.',
};
const emergencyNames = {
  'borrow': 'Vay thế gia',
  'levy': 'Tuyển quân khẩn cấp',
  'peace': 'Cầu hòa có cống nạp',
  'early_labor': 'Hạ tuổi lao động',
};
String emergencyHint(GameState s, String kind) {
  if (s.warfare?.active != null && kind == 'peace') {
    final n = s.warfare!.active!;
    final amount =
        n.advantage <= -70
            ? 17000
            : n.advantage <= -30
            ? 10000
            : 5000;
    final years = amount == 5000 ? 2 : 3;
    return 'Chi 2.000 lượng vàng, 1 hành động để cầu hòa với ${n.name}; nộp $amount lượng vàng/năm × $years năm. Kỳ đầu sau 4 mùa. Quân đang xuất chinh trở về theo lịch.';
  }
  if (s.goldStandard && kind == 'borrow') {
    return 'Nhận 12.000 lượng vàng, 1 hành động. Từ mùa sau trả 5.000 lượng vàng/mùa × 3 mùa (tổng 15.000 lượng vàng). Thế gia +5, uy quyền −2; một khoản vay mỗi lúc.';
  }
  if (s.goldStandard && kind == 'peace') {
    return 'Giảm chiến tranh 2, chi 2.000 lượng vàng, 1 hành động, uy quyền −3. Từ mùa sau cống 1.600 lượng vàng/mùa × 3 mùa (tổng 4.800 lượng vàng).';
  }
  return authoredMoneyText(s, _baseEmergencyHint(s, kind));
}

String _baseEmergencyHint(GameState s, String kind) {
  if (s.population != null && kind == 'early_labor') {
    return '1 hành động; bổ sung ngay 1% lao động dân sự, lòng dân −8, ổn định −5. Khấu trừ nguồn người hai mùa sau; dùng lại sau 4 mùa. Người huy động sớm chưa được tuyển quân.';
  }
  if (s.population != null && kind == 'levy') {
    return 'Chi 15 tiền, 1.500 tạ, 1 hành động; lòng dân −4. Bắt buộc giao một triều thần. Thành công nhận 10.000 × tỷ lệ thành công, làm tròn lên hàng chục; thất bại nhận 1.000 quân. Chi phí không đổi. Đợt tuyển tạo nghĩa vụ 2 mùa.';
  }
  if (!s.seasonal) return emergencyHints[kind]!;
  return switch (kind) {
    'borrow' =>
      'Nhận 120 tiền · 1 hành động. Từ cuối mùa sau trả 50/mùa × 3 mùa (tổng 150). Thế gia +5, uy quyền −2; một khoản vay mỗi lúc.',
    'levy' =>
      'Quân lực +14 · chi 15 · 1 hành động · lòng dân −4. Từ mùa sau mất 6 thóc/mùa × 2 mùa; chờ hết nghĩa vụ mới huy động tiếp.',
    _ =>
      'Giảm chiến tranh 2 · chi 20 · 1 hành động · uy quyền −3. Từ mùa sau cống 16/mùa × 3 mùa (tổng 48); cần đang chiến tranh.',
  };
}

String? emergencyBlocked(GameState s, String kind) {
  if (kind == 'early_labor') {
    final p = s.population;
    if (p == null) return 'Chỉ có trong lượt chơi theo luật dân số mới.';
    if (p.earlyDebt > 0) {
      return 'Chưa khấu trừ xong nguồn lao động huy động sớm.';
    }
    if (s.week < p.earlyAvailable) {
      return 'Có thể dùng lại từ ${s.date(p.earlyAvailable)}.';
    }
    return s.points < 1 ? 'Cần 1 hành động.' : null;
  }
  if (!emergencyHints.containsKey(kind)) return 'Lệnh không tồn tại.';
  if (kind == 'levy' && s.population != null) {
    if (s.population!.recruitable < 10000) {
      return 'Cần 10.000 lao động có thể tuyển.';
    }
    if (s.grain < 1500) return 'Cần 1.500 tạ lương thực.';
    if (taskOfficers(s, 'train').isEmpty) {
      return 'Cần một triều thần đang rảnh.';
    }
  }
  if (s.obligations.any((o) => o.kind == kind)) {
    return 'Nghĩa vụ trước vẫn còn hiệu lực.';
  }
  if (kind == 'peace' && s.war <= 0) return 'Chỉ cầu hòa khi đang chiến tranh.';
  if (s.points < 1) return 'Cần 1 hành động.';
  if (s.treasury <
      money(
        s,
        kind == 'levy'
            ? 15
            : kind == 'peace'
            ? 20
            : 0,
      )) {
    return 'Không đủ ngân khố.';
  }
  return null;
}

const majorGroupNames = {
  'military': 'Quân sự và biên cương',
  'diplomacy': 'Ngoại giao',
  'disaster': 'Thiên tai và nông nghiệp',
  'economy': 'Ngân khố và vận tải',
  'politics': 'Triều chính và pháp luật',
  'society': 'Dân sinh và kế vị',
};

List<Courtier> heirCandidates(GameState s) =>
    s.court
        .where(
          (c) =>
              c.available &&
              c.age >= 18 &&
              c.faction == 'Hoàng tộc' &&
              [
                'Thân vương',
                'Quận vương',
                'Tông chính',
                'Quốc công',
              ].contains(c.role),
        )
        .toList();

bool majorEligible(GameState s, MajorDefinition d) {
  if (s.week < (s.seasonal ? s.cooldownTurns(d.minWeek) : d.minWeek)) {
    return false;
  }
  return switch (d.condition) {
    'any' => true,
    'war' => s.war > 0,
    'peace' => s.war == 0,
    'summer' => s.season == 'Hạ',
    'spring' => s.season == 'Xuân',
    'growing' =>
      s.season == 'Xuân' ||
          s.season == 'Hạ' ||
          (s.seasonal && s.season == 'Thu'),
    'debt' => s.debt > 0 || s.obligations.any((o) => o.amount > 0),
    'heir' => heirCandidates(s).isNotEmpty,
    _ => false,
  };
}

/// Eligibility first; unseen eligible scenarios beat repeats, then group variety.
/// History is the persisted source of counts, including saves from content 7.
List<MajorDefinition> majorDrawPool(GameState s) {
  final last =
      s.lastMajorKind.isNotEmpty
          ? s.lastMajorKind
          : s.majorHistory.lastOrNull?.kind;
  var pool =
      majorDefinitions
          .where((d) => majorEligible(s, d) && d.id != last)
          .toList();
  if (pool.isEmpty) return pool;
  final counts = <String, int>{};
  for (final m in s.majorHistory) {
    counts.update(m.kind, (n) => n + 1, ifAbsent: () => 1);
  }
  final least = pool
      .map((d) => counts[d.id] ?? 0)
      .reduce((a, b) => a < b ? a : b);
  pool = pool.where((d) => (counts[d.id] ?? 0) == least).toList();
  final recentGroups =
      s.majorHistory.reversed
          .take(2)
          .map((m) => majorDefinition(m.kind).group)
          .toSet();
  final varied = pool.where((d) => !recentGroups.contains(d.group)).toList();
  return varied.isNotEmpty ? varied : pool;
}

int majorWeight(GameState s, MajorDefinition d) =>
    (s.seasonal && majorPreferredSeasons(d).contains(s.season) ? 3 : 1) *
    switch (d.group) {
      'military' when s.war > 0 || armyCondition(s) < 45 => 3,
      'disaster'
          when (s.population == null ? s.grain < 50 : foodDays(s) < 120) ||
              (s.season == 'Hạ' && s.levee < 60) =>
        3,
      'economy' when s.treasury < money(s, 120) || s.debt > 0 => 3,
      'politics' when s.authority < 40 || s.stability < 45 => 3,
      'society'
          when s.people < 45 ||
              (s.population == null ? s.grain < 35 : foodDays(s) < 90) =>
        3,
      'diplomacy' when s.war > 0 => 2,
      _ => 1,
    };

int majorPreparation(GameState s, MajorDefinition d) => switch (d.id) {
  'flood' =>
    (s.levee >= 70 ? 1 : 0) +
        ((s.population == null ? s.grain >= 80 : foodDays(s) >= 180) ? 1 : 0),
  'invasion' =>
    (armyCondition(s) >= 65 ? 1 : 0) +
        ((s.population == null ? s.grain >= 80 : foodDays(s) >= 180) ? 1 : 0),
  'rumor' => (s.authority >= 65 ? 1 : 0) + (s.stability >= 65 ? 1 : 0),
  'marriage' =>
    (s.stability >= 65 ? 1 : 0) + (s.treasury >= money(s, 250) ? 1 : 0),
  'db-55' =>
    (s.court.any((c) => c.available && c.role == 'Ngự y' && c.ability >= 75)
            ? 1
            : 0) +
        (s.stability >= 65 ? 1 : 0),
  _ => switch (d.group) {
    'military' =>
      (armyCondition(s) >= 65 ? 1 : 0) +
          ((s.population == null ? s.grain >= 80 : foodDays(s) >= 180) ? 1 : 0),
    'diplomacy' || 'economy' =>
      (s.stability >= 65 ? 1 : 0) + (s.treasury >= money(s, 250) ? 1 : 0),
    'politics' => (s.authority >= 65 ? 1 : 0) + (s.stability >= 65 ? 1 : 0),
    _ =>
      ((s.population == null ? s.grain >= 80 : foodDays(s) >= 180) ? 1 : 0) +
          (s.treasury >= money(s, 250) ? 1 : 0),
  },
};

Map<String, int> majorAftermath(MajorMission m) {
  final d = majorDefinition(m.kind);
  if (d.code.isNotEmpty) {
    final effects = <String, int>{};
    for (final o in m.objectives.where((o) => !o.done)) {
      for (final e
          in d.objectives.firstWhere((g) => g.key == o.key).aftermath.entries) {
        effects.update(
          e.key,
          (v) => v < e.value ? v : e.value,
          ifAbsent: () => e.value,
        );
      }
    }
    return effects;
  }
  final missing = m.objectives.where((o) => !o.done).map((o) => o.key).toSet();
  return {
    if (missing.intersection({'food', 'reserve', 'supply', 'seeds'}).isNotEmpty)
      'grain': -2,
    if (missing.intersection({
      'evacuate',
      'rescue',
      'medicine',
      'relief',
    }).isNotEmpty)
      'people': -1,
    if (missing.intersection({'source', 'court', 'consensus'}).isNotEmpty)
      'authority': -1,
    if (missing.intersection({'troops', 'defense', 'treaty'}).isNotEmpty)
      'army': -1,
  };
}

String majorCommitmentHint(MajorDefinition d, [GameState? state]) {
  final a = d.agreement;
  if (a == null) return '';
  final trigger =
      a.goal.isEmpty
          ? 'Hoàn thành đủ 4 mục tiêu'
          : 'Hoàn thành “${d.objectives.firstWhere((o) => o.key == a.goal).title}”, kể cả kết quả một phần';
  if (state?.seasonal == true) {
    final turns = state!.workTurns(a.weeks);
    final amount = money(
      state,
      ((a.income > 0 ? a.income : a.amount) * a.weeks / turns).ceil(),
    );
    return '$trigger: ${a.title}; ${a.income > 0 ? 'thu thêm' : 'chi'} $amount ${moneyUnit(state)}/mùa × $turns mùa, ${a.income > 0 ? 'qua 3 mùa chuẩn bị, thu lần đầu ở cùng mùa năm sau tổng kết' : 'bắt đầu từ mùa sau tổng kết'}.';
  }
  return '$trigger: ${a.title}; ${a.income > 0 ? 'thu thêm ${a.income}' : 'chi ${a.amount}'} tiền/tuần × ${a.weeks} tuần, bắt đầu từ tuần sau tổng kết.';
}

String heirConditionLabel(String condition) => switch (condition) {
  'critical' => 'đang trọng bệnh',
  'care' => 'đang được chăm sóc',
  'stable' => 'đã ổn định',
  'deceased' => 'đã qua đời',
  'withdrawn' => 'không còn đủ điều kiện kế vị',
  _ => 'chưa có vấn đề sức khỏe được ghi nhận',
};

String majorBody(GameState s, MajorMission m) {
  final d = majorDefinition(m.kind);
  final subject = s.court.where((c) => c.id == m.subjectId).firstOrNull;
  return '${d.body}${subject == null ? '' : '\nNgười kế vị được chỉ định: ${subject.name} (${subject.role}, ${subject.age} tuổi); ${heirConditionLabel(s.heirCondition)}.'}';
}

String? majorGoalUnavailable(
  GameState s,
  MajorMission m,
  ObjectiveDefinition d,
) {
  if (m.kind == 'db-55' &&
      m.subjectId.isNotEmpty &&
      ['goal1', 'goal2'].contains(d.key) &&
      !s.court.any((c) => c.id == m.subjectId && c.available)) {
    return '${s.heirCondition == 'deceased' ? 'Người kế vị đã qua đời' : 'Người kế vị không còn đủ điều kiện tại chức'}; mục tiêu chăm sóc không thể hoàn thành. Các mục tiêu ổn định kế vị còn lại vẫn có thể thực hiện.';
  }
  return null;
}

String majorOutcomeNarrative(GameState s, MajorMission m) {
  final d = majorDefinition(m.kind);
  if (m.achieved == 4 &&
      m.subjectId.isNotEmpty &&
      !s.court.any((c) => c.id == m.subjectId && c.available)) {
    return '${s.heirCondition == 'deceased' ? 'Người kế vị đã qua đời sau các công việc đã hoàn tất' : 'Người kế vị không còn đủ điều kiện tại chức'}. Hồ sơ và phương án dự phòng đã được làm rõ; cần chỉ định lại người kế vị. Kết quả không hồi sinh hoặc bổ nhiệm lại nhân vật.';
  }
  if (m.achieved == 4) return d.successText;
  if (m.responseScore == 0) return d.failureText;
  return 'Chưa bảo vệ: ${m.objectives.where((o) => !o.done).map((o) => d.objectives.firstWhere((g) => g.key == o.key).title).join('; ')}.';
}
