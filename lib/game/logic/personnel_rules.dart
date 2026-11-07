import 'dart:math' as math;
import '../models/game_state.dart';
import 'personality_rules.dart';
import 'development_rules.dart';
import 'population_rules.dart';
import 'currency_rules.dart';
import 'officer_fatigue_rules.dart';
export 'officer_fatigue_rules.dart';
export 'development_rules.dart';
export 'personality_rules.dart';
export '../models/court_politics.dart' show appointmentRanks;

const taskSpecialties = {
  ...developmentSpecialties,
  'maintain_levee': 'Công trình',
  'govern': 'Dân chính',
  'relief': 'Dân chính',
  'mediate': 'Dân chính',
  'buy_grain': 'Kinh tế',
  'farm': 'Kinh tế',
  'repair': 'Công trình',
  'train': 'Quân sự',
  'security': 'An ninh',
  'diplomacy': 'Ngoại giao',
  'collect_arrears': 'Kinh tế',
  'sell_surplus': 'Kinh tế',
  'commerce': 'Kinh tế',
};

const revenueTasks = ['collect_arrears', 'sell_surplus', 'commerce'];
const revenueBaseReturns = {
  'collect_arrears': 45,
  'sell_surplus': 28,
  'commerce': 110,
};
const longTasks = ['repair', 'farm', 'commerce', ...developmentTasks];

int commerceDuration(GameState s) => s.seasonal ? 5 : 4;
int investigationCost(GameState s) => money(s, 20);
int investigationDuration(GameState s) => 2;

enum CharacterReward {
  small(20),
  medium(40),
  large(80);

  const CharacterReward(this.baseCost);
  final int baseCost;
  String get option => 'reward:$baseCost';
  int cost(GameState s) => money(s, baseCost);

  int affectionGain(int affection) {
    final gains = switch (affection) {
      <= 30 => [3, 5, 8],
      <= 50 => [2, 4, 6],
      <= 65 => [2, 3, 4],
      <= 80 => [1, 2, 3],
      <= 90 => [0, 1, 2],
      _ => [0, 0, 1],
    };
    return gains[index].clamp(0, 100 - affection);
  }
}

int investigationChance(GameState s, Courtier? spy, Courtier target) {
  final base = spy == null ? 35 : roleEffect(spy, 'An ninh', spy.ability);
  return s.seasonal
      ? (base - target.plot ~/ 4 - target.influence ~/ 10).clamp(10, 90)
      : base;
}

String? securityBlocked(GameState s) =>
    s.seasonal && (s.cooldowns['task:security'] ?? 0) > s.week
        ? 'Cấm vệ đang chỉnh đốn; có thể huy động lại từ ${s.date(s.cooldowns['task:security']!)}. Trong lúc chờ cần xử lý trung thành và phe phái.'
        : null;

String? seasonalActionDescription(GameState s, String task) =>
    !s.seasonal
        ? null
        : switch (task) {
          'commerce' =>
            'Ứng ${moneyText(s, money(s, 40))} vốn; qua Hạ–Thu–Đông nếu mở ở Xuân, nhận doanh thu cuối Xuân năm sau. Quan bận đến lúc về; có thể mất vốn.',
          'collect_arrears' =>
            'Thuế tồn giảm dần ${moneyText(s, money(s, 45))} → ${moneyText(s, money(s, 15))}; tiền chuyển vào kho cuối mùa sau. Lòng dân −2, mệt +4, căng thẳng +3; chờ 2 mùa giữa các lần truy thu.',
          'sell_surplus' =>
            'Xuất 40 thóc, giữ lại 25; đối soát và nhận tiền khi khép mùa. Mệt +2, chỉ 1 lần/mùa; có rủi ro mất hàng.',
          'security' =>
            'Chi 55; cơ bản giảm 7 tiến độ mỗi âm mưu, căng thẳng +3. Chờ 3 mùa giữa hai lần huy động, kể cả thất bại; hiệu quả tùy người giỏi An ninh.',
          'maintain_levee' =>
            'Chi ${moneyText(s, money(s, 20))}; phục hồi cơ bản 12 tình trạng đê ngay khi thành công. Chỉ bảo dưỡng 1 lần/mùa; không tăng cấp công trình.',
          'repair' =>
            'Chi ${moneyText(s, money(s, 80))}; tu bổ trong ${s.workTurns(4)} mùa, '
                'cơ bản phục hồi 30 tình trạng đê khi thành công; không tăng cấp công trình.',
          'farm' =>
            'Chi 55; canh tác bổ sung trong 2 mùa, cơ bản +35 thóc và +4 lòng dân một lần. Muốn tăng sản lượng hằng năm, chọn Phát triển nông nghiệp.',
          _ =>
            developmentTasks.contains(task)
                ? developmentDescription(s, task)
                : null,
        };

String projectTitle(String kind) => switch (kind) {
  'upgrade_economy' => 'Phát triển kinh tế',
  'upgrade_farm' => 'Phát triển nông nghiệp',
  'upgrade_levee' => 'Nâng cấp đê điều',
  'repair' => 'Tu bổ đê',
  'farm' => 'Khai khẩn ruộng',
  'commerce' => 'Đoàn thương mại',
  _ => kind,
};

/// Shared by command validation and UI. A failed attempt also uses the quota.
String? revenueTaskBlocked(GameState s, String task) {
  if (task == 'collect_arrears' &&
      (s.cooldowns['task:collect_arrears'] ?? 0) > s.week) {
    return 'Thuế tồn đang được đối chiếu; có thể truy thu lại từ ${s.date(s.cooldowns['task:collect_arrears']!)}.';
  }
  if (task == 'sell_surplus') {
    if (s.population != null &&
        s.grain < 100000 + populationFoodConsumption(s)) {
      return 'Cần giữ đủ khẩu phần một mùa sau khi bán 100.000 tạ.';
    }
    if ((s.actionCounts[task] ?? 0) > 0) {
      return 'Chỉ bán lương dư một lần mỗi ${s.periodName}.';
    }
    if (s.grain < 65) {
      return 'Cần ít nhất 65 lương thực: bán 40 và giữ lại tối thiểu 25.';
    }
  }
  if (task == 'commerce' && s.projects.any((p) => p.kind == task)) {
    return 'Đoàn thương mại đang trên đường; hãy chờ hoàn tất.';
  }
  return null;
}

int arrearsBase(GameState s) => (45 - s.arrearsUses * 6).clamp(15, 45);

String revenueRewardPreview(String task, Courtier officer, [GameState? state]) {
  final base =
      task == 'collect_arrears' && state != null
          ? arrearsBase(state)
          : task == 'sell_surplus' && state?.population != null
          ? 25
          : revenueBaseReturns[task];
  if (base == null) return '';
  final assessment = TaskAssessment.preview(task, officer, state);
  final gain =
      state?.goldStandard == true
          ? money(state!, base * assessment.rewardPercent / 100)
          : assessment.reward(base);
  if (task == 'commerce') {
    return 'Ước tính khi thành công ${state?.seasonal == true ? 'cuối ${state!.date(state.week + commerceDuration(state) - 1)}' : 'sau 4 tuần'}: nhận $gain ngân khố trước thất thoát. Đây là doanh thu, chưa trừ ${state == null ? 40 : money(state, 40)} ${state == null ? 'tiền' : moneyUnit(state)} vốn đã chi; phẩm chất chưa rõ có thể đổi kết quả.';
  }
  final foodDetail =
      state?.population != null
          ? 'Xuất 100.000 tạ, giữ đủ khẩu phần một mùa'
          : 'Xuất 40 lương thực, giữ lại ít nhất 25';
  return 'Ước tính khi thành công: ngân khố +$gain ${state?.seasonal == true ? (task == 'collect_arrears' ? 'cuối mùa sau' : 'khi khép mùa') : 'ngay'}, trước thất thoát. ${task == 'collect_arrears' ? 'Dù thành công hay thất bại: lòng dân −2, mệt +4, căng thẳng +3; chờ ${state?.seasonal == true ? 2 : 4} ${state?.periodName ?? 'tuần'} mới được truy thu tiếp.' : '$foodDetail; mệt +2. Thóc đã xuất không được hoàn nếu thất bại; chỉ làm 1 lần/${state?.periodName ?? 'tuần'}.'}';
}

int specialtyFit(String specialty, String wanted) {
  if (specialty == wanted) return 100;
  const related = {
    'Dân chính': ['Ngoại giao', 'Cung đình'],
    'Kinh tế': ['Công trình', 'Dân chính'],
    'Công trình': ['Kinh tế'],
    'Quân sự': ['An ninh'],
    'An ninh': ['Quân sự', 'Dân chính'],
    'Ngoại giao': ['Dân chính', 'Kinh tế'],
    'Y thuật': ['Cung đình'],
    'Cung đình': ['Dân chính'],
  };
  return related[wanted]?.contains(specialty) == true ? 65 : 20;
}

String fitLabel(int fit) =>
    fit == 100
        ? 'Đúng chuyên môn'
        : fit == 65
        ? 'Chuyên môn liên quan'
        : 'Trái chuyên môn';

class TaskAssessment {
  TaskAssessment(this.task, this.officer, [this.state])
    : fit = specialtyFit(officer.specialty, taskSpecialties[task]!),
      ability = officer.isConsort ? officer.affection : officer.abilityScore,
      strain = officer.strain,
      personality = PersonalityAssessment(officer, state);
  TaskAssessment.preview(this.task, this.officer, [this.state])
    : fit = specialtyFit(officer.specialty, taskSpecialties[task]!),
      ability = officer.isConsort ? officer.affection : officer.abilityScore,
      strain = officer.strain,
      personality = PersonalityAssessment(officer, state, knownOnly: true);
  TaskAssessment.forSpecialty(
    this.task,
    this.officer,
    String specialty,
    this.state, {
    bool knownOnly = false,
  }) : fit = specialtyFit(officer.specialty, specialty),
       ability = officer.isConsort ? officer.affection : officer.abilityScore,
       strain = officer.strain,
       personality = PersonalityAssessment(
         officer,
         state,
         knownOnly: knownOnly,
       );
  final String task;
  final Courtier officer;
  final GameState? state;
  final PersonalityAssessment personality;
  final int fit, strain;
  final num ability;
  int get successChance => (20 +
          ability * .6 +
          fit * .25 -
          officerFatiguePenalty(strain) +
          personality.successModifier(task, fit) -
          personality.sabotageChance)
      .round()
      .clamp(5, 95);
  int get rewardPercent => (45 +
          ability * .6 +
          fit * .3 -
          strain ~/ 5 +
          personality.rewardModifier(task))
      .round()
      .clamp(10, 180);
  int reward(int base) =>
      base <= 0 ? base : math.max(1, (base * rewardPercent / 100).round());
}

int appointmentRank(String destinationRole) =>
    appointmentRanks[destinationRole] ?? 2;

/// 10–20% of the former talent-based fee, rounded to whole currency.
/// Rank belongs to the destination office, standing belongs to the candidate.
int appointmentCost(
  Courtier candidate,
  String destinationRole, [
  GameState? state,
]) {
  final ability = candidate.ability.clamp(0, 100);
  final standing = (candidate.influence.clamp(0, 100) / 25).ceil();
  final rate = 10 + 2 * (appointmentRank(destinationRole) - 1) + standing;
  final talentBasis = 20 + ability + ability * ability ~/ 100;
  final base = (talentBasis * rate / 100).round();
  return state == null ? base : money(state, base);
}

int replacementDisruption(Courtier outgoing) =>
    (outgoing.influence ~/ 12).clamp(2, 8);

int roleEffect(Courtier c, String specialty, int base) =>
    (base * specialtyFit(c.specialty, specialty) / 100).round().clamp(1, 100);

bool officerBusy(GameState s, String id) =>
    s.pending.any((p) => p.covertMission?.spyId == id) ||
    s.courtPersonnelMatters.any(
      (m) => m.status == 'training' && m.personId == id,
    ) ||
    (s.population?.deployments.any(
          (d) => (d.officerId == id || d.deputyId == id),
        ) ??
        false) ||
    (s.population?.orders.any((o) => o.officerId == id) ?? false) ||
    s.projects.any((p) => p.officerId == id) ||
    s.pending.any((p) => p.assignment?.assigneeId == id) ||
    s.pending.any((p) => p.kind == 'envoy' && p.target == id) ||
    (s.major?.objectives.any((o) => o.working && o.officerId == id) ?? false);

List<Courtier> taskOfficers(GameState s, String task) {
  final people =
      s.court
          .where(
            (c) =>
                c.available &&
                !c.isConsort &&
                !officerBusy(s, c.id) &&
                (!developmentTasks.contains(task) ||
                    developmentOfficerBlocked(s, task, c) == null),
          )
          .toList();
  people.sort((a, b) {
    if (developmentTasks.contains(task)) {
      return developmentSuccessChance(
        s,
        task,
        b,
        preview: true,
      ).compareTo(developmentSuccessChance(s, task, a, preview: true));
    }
    final chance = TaskAssessment.preview(
      task,
      b,
      s,
    ).successChance.compareTo(TaskAssessment.preview(task, a, s).successChance);
    return chance != 0
        ? chance
        : TaskAssessment.preview(task, b, s).rewardPercent.compareTo(
          TaskAssessment.preview(task, a, s).rewardPercent,
        );
  });
  return people;
}

String abilityExplanation(Courtier c) =>
    c.isConsort
        ? 'Nhân vật hậu cung không có chỉ số năng lực. Thiện cảm và câu chuyện quyết định đóng góp; tấu chương xét thiện cảm, chuyên môn và tính cách đã biết.'
        : 'Năng lực ${c.ability} thể hiện khả năng làm việc. Chuyên môn: ${c.specialty}. Đúng chuyên môn và năng lực cao giúp tăng xác suất thành công và mức thu được. Giao trái chuyên môn hoặc năng lực thấp dễ thất bại, có thể làm giảm các chỉ số quốc gia. Chuyên môn không tự đổi khi được bổ nhiệm chức vụ mới.';

int actionSuccessChance(GameState s, String task, Courtier c) =>
    developmentTasks.contains(task)
        ? developmentSuccessChance(s, task, c, preview: true)
        : TaskAssessment.preview(task, c, s).successChance;

String actionRewardDescription(GameState s, String task, Courtier c) =>
    developmentTasks.contains(task)
        ? 'Thành công tăng đúng 1 cấp. ${developmentBenefit(s, task, developmentTarget(s, task))}'
        : 'Mức thu khi thành công: ${TaskAssessment.preview(task, c, s).rewardPercent}% cơ bản; thành quả có thể bị thất thoát tùy liêm chính.';

String roleAbilityExplanation(Courtier c, [GameState? state]) {
  if (state?.population != null &&
      ['Đại tướng', 'Phó tướng', 'Đô đốc'].contains(c.role)) {
    if (state!.hasCourtSystem) {
      return 'Hiệu quả chỉ huy ${commanderEffect(state, c.role).toStringAsFixed(1)}, theo năng lực, chuyên môn và mệt công vụ. Đại tướng/Phó tướng đóng góp 70/30 vào chỉ huy trên bộ.';
    }
    return 'Hiệu quả chỉ huy ${commanderEffect(state, c.role).toStringAsFixed(1)}/100, theo năng lực, chuyên môn và mệt công vụ. Đại tướng/Phó tướng chiếm 70/30 ở trận bộ; Đại tướng/Phó tướng/Đô đốc chiếm 20/20/60 ở thủy chiến.';
  }
  return switch (c.role) {
    'Ngự y' =>
      'Chữa trị giảm ${roleEffect(c, 'Y thuật', 8 + c.ability ~/ 10)} điểm bệnh mỗi lần, ngoài 2 sức khỏe cơ bản; tính cả độ phù hợp Y thuật.',
    'Mật thám' =>
      'Điều tra thành công ${roleEffect(c, 'An ninh', c.ability)}%, tính cả độ phù hợp An ninh.',
    'Ngự sử' =>
      'Kiểm toán thành công ${roleEffect(c, 'Dân chính', c.ability)}%, tính cả độ phù hợp Dân chính.',
    'Đại tướng' =>
      'Đóng góp ${roleEffect(c, 'Quân sự', c.ability ~/ 3)} điểm sức phòng thủ, tính cả độ phù hợp Quân sự.',
    'Tiểu thư' =>
      'Mở câu chuyện ở thiện cảm ≥60; hoàn thành và thiện cảm >70 để đóng góp. Hoàng hậu có tuyến riêng ở thiện cảm ≥85.',
    _ =>
      'Khi giao quốc sự, hãy xem chuyên môn và dự báo kết quả trong danh sách người phụ trách.',
  };
}

String taskFailureHint(String task, [GameState? state]) => switch (task) {
  'upgrade_economy' || 'upgrade_farm' || 'upgrade_levee' =>
    'Khi hết thời gian thi công mới xét thành công. Thất bại giữ nguyên cấp, vốn đã chi không hoàn lại. Quan rời triều thì dự án tạm dừng, có thể bổ nhiệm người thay.',
  'maintain_levee' =>
    'Bảo dưỡng có thể thất bại: mất kinh phí và đê hư thêm 2 điểm.',
  'collect_arrears' =>
    'Thất bại không thu được tiền, giảm uy quyền/lòng dân; thất bại nặng còn mất '
        '${state == null ? '10 ngân khố' : moneyText(state, money(state, 10))} và 2 Ổn định triều đình.',
  'sell_surplus' =>
    'Thất bại mất ${state?.population == null ? '40 thóc' : '100.000 tạ'} đã xuất mà không thu được tiền, '
        'giảm uy quyền/lòng dân; thất bại nặng mất thêm '
        '${state == null ? '8 ngân khố' : moneyText(state, money(state, 8))}.',
  'commerce' =>
    'Thất bại không có doanh thu, mất ${state == null ? '40' : moneyText(state, money(state, 40))} vốn '
        'và thêm ${state == null ? '10 ngân khố' : moneyText(state, money(state, 10))}/1 uy quyền; '
        'thất bại nặng mất thêm ${state == null ? '20 ngân khố' : moneyText(state, money(state, 20))}/2 uy quyền/2 lòng dân.',
  'train' => 'Thất bại mất quân lực/uy quyền; thất bại nặng còn tốn ngân khố.',
  'repair' =>
    'Thất bại làm đê yếu, mất lòng dân; thất bại nặng mất thêm uy quyền/ngân khố.',
  'farm' || 'relief' =>
    'Thất bại mất lòng dân/lương thực; thất bại nặng mất thêm uy quyền/ngân khố.',
  'buy_grain' =>
    'Thất bại không bổ sung được kho; thất bại nặng mất thêm ngân khố/uy quyền.',
  'security' =>
    'Thất bại làm âm mưu tiến triển, giảm uy quyền; thất bại nặng làm triều đình chia rẽ.',
  'diplomacy' =>
    'Thất bại tăng áp lực chiến tranh, giảm uy quyền; thất bại nặng tốn thêm ngân khố.',
  _ =>
    'Thất bại làm giảm uy quyền/Ổn định triều đình; thất bại nặng còn giảm lòng dân.',
};
