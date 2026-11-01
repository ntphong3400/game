import '../models/game_state.dart';
import 'personality_rules.dart';
import 'population_rules.dart';
import 'currency_rules.dart';

const developmentTasks = ['upgrade_economy', 'upgrade_farm', 'upgrade_levee'];
const developmentSpecialties = {
  'upgrade_economy': 'Kinh tế',
  'upgrade_farm': 'Kinh tế',
  'upgrade_levee': 'Công trình',
};
const developmentNames = {
  'upgrade_economy': 'Phát triển kinh tế',
  'upgrade_farm': 'Phát triển nông nghiệp',
  'upgrade_levee': 'Nâng cấp đê điều',
};
const economyAnnualBonuses = [0, 0, 20, 45, 75, 110];
const agricultureBaseYields = [0, 60, 80, 100, 120, 140];
const leveeWearReductions = [0, 0, 15, 30, 45, 60];
const developmentPrices = {
  'upgrade_economy': [0, 0, 80, 150, 240, 360],
  'upgrade_farm': [0, 0, 70, 130, 210, 320],
  'upgrade_levee': [0, 0, 100, 180, 280, 400],
};
const seasonalLeveeWear = {'Xuân': 3, 'Hạ': 8, 'Thu': 4, 'Đông': 3};

int developmentLevel(GameState s, String task) => switch (task) {
  'upgrade_economy' => s.economyLevel,
  'upgrade_farm' => s.agricultureLevel,
  'upgrade_levee' => s.leveeLevel,
  _ => 1,
};
WorkOrder? developmentProject(GameState s, String task) =>
    s.projects.where((p) => p.kind == task).firstOrNull;
bool developmentNeedsOfficer(GameState s, WorkOrder p) =>
    p.paused || !s.court.any((c) => c.id == p.officerId && c.available);
int developmentTarget(GameState s, String task) =>
    developmentProject(s, task)?.targetLevel ?? developmentLevel(s, task) + 1;
int developmentRequiredAbility(int targetLevel) => 40 + targetLevel * 10;
int developmentDuration(GameState s, int targetLevel) =>
    (targetLevel - 1) * (s.seasonal ? 1 : 13);
int developmentCost(GameState s, String task) {
  final p = developmentProject(s, task);
  if (p != null && developmentNeedsOfficer(s, p)) return 0;
  return money(
    s,
    developmentPrices[task]![developmentTarget(s, task).clamp(2, 5)],
  );
}

String? developmentBlocked(GameState s, String task) {
  if (!developmentTasks.contains(task)) return null;
  if (!s.seasonal) return 'Nâng cấp dài hạn chỉ dành cho chế độ theo mùa.';
  final p = developmentProject(s, task);
  if (p != null && !developmentNeedsOfficer(s, p)) {
    return 'Công trình đang thực hiện; hãy chờ hoàn tất.';
  }
  if (developmentLevel(s, task) >= 5) return 'Đã đạt cấp tối đa 5.';
  return null;
}

String? developmentOfficerBlocked(GameState s, String task, Courtier c) {
  final target = developmentTarget(s, task);
  if (c.specialty != developmentSpecialties[task]) {
    return 'Cần đúng chuyên môn ${developmentSpecialties[task]}.';
  }
  final required = developmentRequiredAbility(target);
  if (c.ability < required) return 'Cấp $target cần năng lực ≥$required.';
  return null;
}

/// Freeze this probability at assignment. Hidden qualities affect execution;
/// public estimates use only discovered traits and investigated qualities.
int developmentSuccessChance(
  GameState s,
  String task,
  Courtier c, {
  bool preview = false,
  int? targetLevel,
}) {
  final target = targetLevel ?? developmentTarget(s, task);
  final p = PersonalityAssessment(c, s, knownOnly: preview);
  final assessmentTask = switch (task) {
    'upgrade_economy' => 'commerce',
    'upgrade_farm' => 'farm',
    'upgrade_levee' => 'repair',
    _ => task,
  };
  return (80 -
          (target - 2) * 5 +
          (c.ability - developmentRequiredAbility(target)) * .8 -
          c.strain / 8 +
          p.successModifier(assessmentTask, 100) * .5 -
          p.sabotageChance -
          p.corruptionChance * .2)
      .round()
      .clamp(10, 95);
}

String developmentBenefit(
  GameState s,
  String task,
  int level,
) => switch (task) {
  'upgrade_economy' =>
    'Thuế nền tăng tổng cộng ${economyAnnualBonuses[level]} tiền/năm, thu vào vụ Thu; không đổi mức thuế.',
  'upgrade_farm' =>
    'Sản lượng nền ${agricultureBaseYields[level]} thóc/năm trước hệ số đê và thời tiết.',
  'upgrade_levee' =>
    'Giảm ${leveeWearReductions[level]}% hao mòn thường lệ; không tự phục hồi tình trạng đê.',
  _ => '',
};

String developmentDescription(GameState s, String task) {
  if (developmentLevel(s, task) >= 5) return 'Đã đạt cấp tối đa 5.';
  final target = developmentTarget(s, task);
  final p = developmentProject(s, task);
  final resuming = p != null && developmentNeedsOfficer(s, p);
  final duration =
      p == null ? developmentDuration(s, target) : p.duration - p.progress;
  return '${resuming ? 'Bổ nhiệm người thay, không cấp lại vốn' : 'Nâng cấp ${target - 1} lên $target, chi ${developmentCost(s, task)} ${moneyUnit(s)}'}; '
      '${resuming ? 'còn' : 'thi công'} $duration ${s.periodName}. '
      'Cần ${developmentSpecialties[task]}, năng lực ≥${developmentRequiredAbility(target)}. '
      '${developmentBenefit(s, task, target)} '
      'Xét thành công khi hoàn tất; thất bại giữ nguyên cấp, không hoàn vốn. '
      'Lợi ích cấp mới áp dụng từ mùa sau khi hoàn thành.';
}

/// Piecewise interpolation through the agreed anchors; 95–100 stays at 120%.
double leveeYieldPercent(num condition) {
  final x = condition.clamp(0, 100).toDouble();
  const anchors = [(0, 30), (30, 60), (60, 100), (80, 110), (95, 120)];
  for (var i = 1; i < anchors.length; i++) {
    final a = anchors[i - 1], b = anchors[i];
    if (x <= b.$1) {
      return a.$2 + (b.$2 - a.$2) * (x - a.$1) / (b.$1 - a.$1);
    }
  }
  return 120;
}

int economyAnnualBonus(GameState s) =>
    s.seasonal ? economyAnnualBonuses[s.economyLevel] : 0;
int agricultureBaseYield(GameState s) =>
    s.population == null
        ? agricultureBaseYields[s.agricultureLevel]
        : foodAmount(4500000 * agricultureBaseYields[s.agricultureLevel] / 60);
int grainConsumption(GameState s) =>
    s.population != null
        ? remainingFoodConsumption(s)
        : s.seasonal
        ? (s.war > 0 ? 20 : 12)
        : (s.war > 0 ? 3 : 1);
double leveeWear(GameState s) =>
    seasonalLeveeWear[s.season]! *
    (100 - leveeWearReductions[s.leveeLevel]) /
    100;
int leveeWearThisSeason(GameState s) =>
    ((leveeWear(s) * 100).round() + s.leveeWearRemainder) ~/ 100;

double harvestLeveePercent(GameState s, {num? autumnCondition}) {
  final currentYear = s.cropYear == s.year;
  final baseline = currentYear ? s.cropBaselineLevee : s.levee;
  final spring = currentYear ? s.springLeveePercent : null;
  final summer = currentYear ? s.summerLeveePercent : null;
  return .2 * (spring ?? leveeYieldPercent(baseline)) +
      .5 * (summer ?? leveeYieldPercent(baseline)) +
      .3 * leveeYieldPercent(autumnCondition ?? s.levee);
}

String harvestPlan(GameState s) =>
    'Nông nghiệp cấp ${s.agricultureLevel}/5: nền ${agricultureBaseYield(s)} thóc/năm. '
    'Đê Xuân 20% · Hạ 50% · Thu 30%; hệ số cả vụ tạm tính '
    '${harvestLeveePercent(s).toStringAsFixed(1)}%. '
    'Mùa chưa chốt tạm dùng tình trạng đê đầu vụ; thời tiết khi gặt dao động 90–110%. '
    'Thu hoạch tự động cuối Thu; tiêu hao ${grainConsumption(s)} ${foodUnit(s)}/${s.periodName}.';
