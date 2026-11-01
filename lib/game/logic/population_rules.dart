import 'dart:math' as math;
import '../models/game_state.dart';
import '../models/number_format.dart';
import 'currency_rules.dart';
import 'management_rules.dart' show managementEquipmentBonus;

const populationPolicies = {
  'economy': 'Ưu tiên kinh tế',
  'army': 'Ưu tiên quân đội',
  'balanced': 'Cân bằng',
};
const initialFood = 4000000;
const foodCapacity = 8000000;

/// Every positive food receipt/payment rounds UP exactly once, in tạ.
int foodAmount(num value) => math.max(0, value.ceil());
int roundTroops(num value) => (math.max(0, value) / 10).ceil() * 10;
String whole(num value) => formatWholeNumber(value);
String foodUnit(GameState s) => s.population == null ? 'thóc' : 'tạ';

double commanderEffect(GameState s, String role) {
  final c = s.court.where((c) => c.available && c.role == role).firstOrNull;
  if (c == null) return 0;
  final fit = c.specialty == 'Quân sự' ? 1.0 : .75;
  return (c.abilityScore * fit - c.strain / 5).clamp(0, 100).toDouble();
}

double commandScore(GameState s, {bool naval = false}) =>
    naval && !s.hasCourtSystem
        ? .2 * commanderEffect(s, 'Đại tướng') +
            .2 * commanderEffect(s, 'Phó tướng') +
            .6 * commanderEffect(s, 'Đô đốc')
        : .7 * commanderEffect(s, 'Đại tướng') +
            .3 * commanderEffect(s, 'Phó tướng');
double commandMultiplier(GameState s, {bool naval = false}) =>
    .8 + .004 * commandScore(s, naval: naval);
int militaryStrength(GameState s, {bool naval = false, int? troops}) {
  final p = s.population;
  if (p == null) return s.army;
  return ((troops ?? p.soldiers) *
          p.readiness /
          100 *
          commandMultiplier(s, naval: naval))
      .round();
}

int armyCondition(GameState s) => s.population?.readiness.round() ?? s.army;

double farmLaborFactor(GameState s) {
  final p = s.population;
  if (p == null) return 1;
  final capacity = 650000 * (1 + (s.agricultureLevel - 1) * .25);
  return math.min(p.productiveCivilians * .6, capacity) / 570000;
}

double economicLaborFactor(GameState s) {
  final p = s.population;
  if (p == null) return 1;
  final capacity = 325000 * (1 + (s.economyLevel - 1) * .25);
  return math.min(p.productiveCivilians * .3, capacity) /
      285000 *
      (1 - p.militaryAllocation) /
      .8;
}

double annualFarmLaborFactor(GameState s) {
  final p = s.population;
  return p == null || p.yearlyLaborSamples == 0
      ? farmLaborFactor(s)
      : p.yearlyFarmLabor / p.yearlyLaborSamples;
}

double annualEconomicLaborFactor(GameState s) {
  final p = s.population;
  return p == null || p.yearlyLaborSamples == 0
      ? economicLaborFactor(s)
      : p.yearlyEconomicLabor / p.yearlyLaborSamples;
}

int manufacturedEquipment(GameState s) {
  final p = s.population;
  if (p == null) return 0;
  return math.max(
    0,
    (2000 *
                math.min(
                  p.productiveCivilians * .3,
                  325000 * (1 + (s.economyLevel - 1) * .25),
                ) /
                285000 *
                p.militaryAllocation /
                .2 *
                (1 + (s.economyLevel - 1) * .15))
            .floor() +
        managementEquipmentBonus(s),
  );
}

int populationFoodConsumption(GameState s) {
  final p = s.population!;
  // Service already performed cannot be erased by demobilizing just before
  // settlement. The civilian ration is counted once for everyone.
  return foodAmount((p.population * 90 + p.serviceSoldiers * 45) / 100);
}

int remainingFoodConsumption(GameState s) =>
    s.population == null
        ? 0
        : math.max(0, populationFoodConsumption(s) - s.population!.foodCredit);
int foodDays(GameState s) =>
    s.population == null
        ? 0
        : (s.grain * 90 / math.max(1, populationFoodConsumption(s))).floor();
double populationGrowthRate(GameState s) {
  if (foodDays(s) < 30 || s.stability < 20) return .001;
  if (foodDays(s) < 90 || s.stability < 40 || s.people < 30) return .004;
  if (foodDays(s) >= 180 && s.people >= 70 && s.stability >= 60 && s.war == 0) {
    return .009;
  }
  return .007;
}

double diseaseRate(GameState s) => switch (s.population?.diseaseLevel ?? 0) {
  1 => .004,
  2 => .012,
  3 => .025,
  _ => .001,
};

const populationActionNames = {
  'public_health': 'Tổ chức phòng dịch',
  'settle': 'Chiêu dân lập ấp',
  'refugees': 'Tiếp nhận người tị nạn',
  'return': 'Kêu gọi dân lưu tán trở về',
  'recruit': 'Tuyển quân thường lệ',
  'demobilize': 'Giải ngũ 5.000 quân',
  'equipment': 'Rèn thêm quân khí',
  'reward_army': 'Thưởng quân',
  'supply_army': 'Tổ chức tiếp tế',
};
int populationActionMoney(String kind) => switch (kind) {
  'public_health' => 35,
  'settle' => 40,
  'refugees' => 50,
  'return' => 30,
  'recruit' => 25,
  'equipment' => 40,
  'reward_army' => 25,
  'supply_army' => 20,
  _ => 0,
};
int populationActionFood(String kind) => switch (kind) {
  'public_health' => 5000,
  'settle' => 7000,
  'refugees' => 10000,
  'return' => 4000,
  'supply_army' => 20000,
  _ => 0,
};
String populationActionHint(
  GameState s,
  String kind,
) => authoredMoneyText(s, switch (kind) {
  'public_health' =>
    'Chi 35 tiền, 5.000 tạ, 1 hành động. Mức dịch bệnh giảm 1, lòng dân +1; một lần mỗi mùa.',
  'settle' =>
    'Chi 40 tiền, 7.000 tạ, 1 hành động. Nhận 5.000 lao động sau 2 mùa.',
  'refugees' =>
    'Chi 50 tiền, 10.000 tạ, 1 hành động. Tiếp nhận 10.000 lao động sau 1 mùa; cần có đoàn người xin vào.',
  'return' =>
    'Chi 30 tiền, 4.000 tạ, 1 hành động. Sau 1 mùa nhận lại tối đa 10.000 dân lưu tán; không vượt số còn chưa hồi hương.',
  'recruit' =>
    'Chi 25 tiền, 1 hành động. Sau 1 mùa chuyển 5.000 lao động dân sự thành tân binh, huấn luyện 20; không tăng tổng dân số.',
  'demobilize' =>
    '1 hành động. Chuyển 5.000 quân đang rảnh về dân sự. Lao động đóng góp sản xuất từ mùa sau.',
  'equipment' => 'Chi 40 tiền, 1 hành động. Nhận 5.000 bộ quân khí sau 1 mùa.',
  'reward_army' =>
    'Chi 25 tiền, 1 hành động. Sĩ khí +8; lặp trong mùa giảm hiệu quả.',
  'supply_army' =>
    'Chi 20 tiền, chuyển trước 20.000 tạ vào khẩu phần quân đội; không trừ lại phần này khi khép mùa.',
  _ => '',
});

String? populationActionBlocked(GameState s, String kind) {
  final p = s.population;
  if (p == null) return 'Chỉ có trong lượt chơi theo bộ luật dân số mới.';
  if (!populationActionNames.containsKey(kind)) return 'Lệnh không tồn tại.';
  if (s.points < 1) return 'Cần 1 hành động.';
  if (s.treasury < money(s, populationActionMoney(kind))) {
    return 'Ngân khố không đủ.';
  }
  if (s.grain < populationActionFood(kind)) return 'Kho lương không đủ.';
  if (kind == 'public_health' &&
      ((s.actionCounts[kind] ?? 0) > 0 || p.diseaseLevel == 0)) {
    return 'Chỉ phòng dịch khi có dịch; một lần mỗi mùa.';
  }
  if (p.orders.any((o) => o.kind == kind)) {
    return 'Đã có một đợt đang thực hiện.';
  }
  if (['settle', 'refugees', 'return'].contains(kind) &&
      (s.war >= 3 || s.stability < 30 || foodDays(s) < 90)) {
    return 'Cần an ninh, ổn định ≥30 và dự trữ ít nhất 90 ngày.';
  }
  if (kind == 'refugees' &&
      !s.petitions.any((x) => x.definitionId == 'population_refugees')) {
    return 'Chưa có đoàn người xin tị nạn; chờ tấu chương.';
  }
  if (kind == 'return' && p.displaced <= 0) {
    return 'Không còn dân lưu tán để gọi về.';
  }
  if (kind == 'recruit' &&
      p.recruitable -
              p.orders
                  .where((o) => o.kind == 'recruit')
                  .fold<int>(0, (n, o) => n + o.count) <
          5000) {
    return 'Không đủ 5.000 lao động có thể tuyển.';
  }
  if (kind == 'demobilize' && p.availableSoldiers <= 5000) {
    return 'Cần giữ lực lượng bảo vệ; không đủ quân rảnh.';
  }
  if (kind == 'supply_army' &&
      p.foodCredit + 20000 > populationFoodConsumption(s)) {
    return 'Khẩu phần mùa này đã được cấp đủ.';
  }
  return null;
}

int emergencyRecruitmentCount(num chance, bool succeeded) =>
    succeeded ? roundTroops(10000 * chance / 100).clamp(0, 10000) : 1000;

/// Re-author legacy food by purpose (not a global conversion of old units).
int authoredFood(int value, {String context = '', bool challenging = false}) {
  if (value == 0) return 0;
  final factor =
      context.contains('relief') || context.contains('hunger')
          ? 4000
          : context.contains('military') || context.contains('border')
          ? 400
          : 1500;
  // Supplies should matter beside ~0.9 million tạ consumed each season.
  // Military supplies feed a detachment; civilian programmes cover more people.
  final calibrated =
      context == 'farm'
          ? 10000
          : context.contains('military') || context.contains('border')
          ? 1600
          : 6000;
  return foodAmount(value.abs() * (challenging ? calibrated : factor)) *
      value.sign;
}

Map<String, int> populationEffects(
  Map<String, int> effects, {
  String context = '',
  bool challenging = false,
}) {
  final result = <String, int>{};
  for (final e in effects.entries) {
    var key = e.key, value = e.value;
    if (key == 'grain') {
      key = 'food';
      value = authoredFood(value, context: context, challenging: challenging);
    }
    if (key == 'army') {
      if (context.contains('weapons') ||
          context.contains('craftsmen') ||
          context.contains('quân khí')) {
        key = 'equipment';
        value *= 1000;
      } else {
        key = 'training';
      }
    }
    result.update(key, (n) => n + value, ifAbsent: () => value);
  }
  return result;
}

String? populationActionDescription(GameState s, String task) {
  if (s.population == null) return null;
  if (populationActionNames.containsKey(task)) {
    return populationActionHint(s, task);
  }
  final text = switch (task) {
    'buy_grain' =>
      'Chi 45 tiền, 1 hành động; cơ bản nhận 200.000 tạ, tùy người phụ trách và rủi ro thực hiện.',
    'sell_surplus' =>
      'Xuất 100.000 tạ, giữ đủ khẩu phần một mùa; cơ bản nhận 25 tiền khi khép mùa, tùy người phụ trách.',
    'relief' => 'Chi 20 tiền, 100.000 tạ; tăng lòng dân tùy người phụ trách.',
    'farm' =>
      'Chi 55 tiền; canh tác bổ sung trong 2 mùa, cơ bản nhận ${s.challengingEconomy ? '350.000' : '52.500'} tạ và lòng dân +4.',
    'train' =>
      'Chi 35 tiền; cơ bản huấn luyện +10 cho 50.000 quân. Hiệu quả tùy quy mô và triều thần; thất bại có thể giảm huấn luyện.',
    _ => null,
  };
  return text == null ? null : authoredMoneyText(s, text);
}
