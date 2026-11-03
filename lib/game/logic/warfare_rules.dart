import 'dart:math' as math;
import '../models/game_state.dart';
import 'currency_rules.dart';
import 'population_rules.dart';
import 'frontier_rules.dart';
import 'personnel_rules.dart' show officerBusy;

const warMissionNames = {
  'scout': 'Trinh sát biên giới',
  'supply': 'Hộ tống quân lương',
  'relieve': 'Giải vây đồn biên giới',
  'defend': 'Giữ cửa ải',
  'raid': 'Tập kích kho quân nhu',
  'battle': 'Hội chiến',
  'siege': 'Công thành',
  'capital': 'Bảo vệ kinh thành',
  'naval': 'Thủy chiến',
};
const warTactics = {
  'defend': 'Thận trọng phòng thủ',
  'balanced': 'Đánh theo kế hoạch',
  'attack': 'Chủ động tiến công',
};
const tributeNames = {
  'light': 'Nhẹ',
  'medium': 'Vừa',
  'heavy': 'Nặng',
  'armistice': 'Đình chiến',
};
int tributeGold(String tier) => switch (tier) {
  'light' => 5000,
  'medium' => 10000,
  'heavy' => 17000,
  _ => 0,
};
int tributeYears(String tier) =>
    tier == 'light'
        ? 2
        : tier == 'armistice'
        ? 1
        : 3;
String neighborStatus(NeighborState n) => switch (n.status) {
  'war' => 'Chiến tranh',
  'treaty' => 'Hòa ước',
  'tension' => 'Căng thẳng',
  _ => 'Hòa bình',
};
List<double> warTroopRatios(WarMission m) =>
    m.kind == 'siege' ? [2, 2.5, 3] : [.8, 1, 1.25];
int warTroops(WarMission m, double ratio) => roundTroops(m.enemyTroops * ratio);
int warMissionCost(GameState s, WarMission m, int troops) =>
    money(s, (m.duration == 2 ? 15 : 8) + troops / 1000);
int warMissionFood(int troops, [GameState? s, WarMission? mission]) =>
    s?.foodPressureEnabled == true
        ? foodAmount(
          troops * 90 * 2 / 100 * (mission?.duration == 2 ? 1.4 : 1.2),
        )
        : foodAmount(troops * 30 * 2 / 100 * 1.1);
int warFoodCredit(int troops, [GameState? s]) =>
    foodAmount(troops * (s?.foodPressureEnabled == true ? 90 : 30) * 1.5 / 100);

String? warOfficerBlocked(GameState s, Courtier c) {
  if (!c.available || c.isConsort || c.age < 18) {
    return 'Cần triều thần trưởng thành, còn hoạt động.';
  }
  if (officerBusy(s, c.id)) return 'Đang làm nhiệm vụ hoặc học tập khác.';
  return null;
}

List<Courtier> warOfficers(GameState s, {bool naval = false}) =>
    s.court.where((c) => warOfficerBlocked(s, c) == null).toList()
      ..sort((a, b) {
        final role = naval ? 'Đô đốc' : 'Đại tướng';
        return ((b.role == role ? 100 : 0) + b.abilityScore).compareTo(
          (a.role == role ? 100 : 0) + a.abilityScore,
        );
      });
double warOfficerAbility(Courtier c, {bool naval = false}) =>
    (c.abilityScore *
                (c.specialty == 'Quân sự' || (naval && c.role == 'Đô đốc')
                    ? 1
                    : .75) -
            c.strain / 5)
        .clamp(0, 100)
        .toDouble();
double warCommand(Courtier leader, Courtier? deputy, {bool naval = false}) =>
    deputy == null
        ? warOfficerAbility(leader, naval: naval)
        : .7 * warOfficerAbility(leader, naval: naval) +
            .3 * warOfficerAbility(deputy, naval: naval);
double warAffection(Courtier leader, Courtier? deputy) =>
    deputy == null
        ? leader.affection.toDouble()
        : .7 * leader.affection + .3 * deputy.affection;
int withdrawalChance(double affection) =>
    affection >= 80
        ? 0
        : affection >= 60
        ? 3
        : affection >= 40
        ? 10
        : affection >= 20
        ? 25
        : 40;
double battleCasualtyBase({
  required int troops,
  required int enemy,
  required double command,
  bool siege = false,
}) =>
    ((50 * enemy / math.max(1, troops) + (50 - command) * .4) *
            (siege ? 1.3 : 1))
        .clamp(1, 100)
        .toDouble();
int battleLosses(
  int troops,
  double base, {
  required bool won,
  required bool retreated,
  required int reduction,
}) {
  final factor =
      retreated
          ? reduction / 100
          : won
          ? (100 - reduction) / 100
          : 1.0;
  return (troops * base / 100 * factor).ceil().clamp(0, troops);
}

class WarPreview {
  WarPreview(
    GameState s,
    WarMission m,
    this.troops,
    Courtier leader,
    Courtier? deputy, {
    String tactic = 'balanced',
  }) {
    command = warCommand(leader, deputy, naval: m.naval);
    affection = warAffection(leader, deputy);
    withdrawal = withdrawalChance(affection);
    final n = s.warfare!.neighbors.firstWhere((n) => n.id == m.countryId);
    final terrain =
        m.kind == 'siege'
            ? 1 / (1.5 + n.fortification / 100)
            : ['defend', 'capital'].contains(m.kind)
            ? 1.35
            : 1.0;
    final tacticFactor =
        tactic == 'attack'
            ? 1.10
            : tactic == 'defend'
            ? .95
            : 1.0;
    final ours =
        troops *
        s.population!.readinessAt(
          m.kind == 'capital' ? 'capital' : m.countryId,
        ) /
        100 *
        (.8 + .004 * command) *
        terrain *
        tacticFactor;
    final theirs = m.enemyTroops * n.enemyQuality / 100;
    tacticalChance = (50 + 45 * (ours - theirs) / math.max(1, ours + theirs))
        .round()
        .clamp(5, 95);
    // Public final chance and execution use precisely the same two-stage roll.
    winChance = (100 - withdrawal) * tacticalChance / 100;
    final casualtyTactic =
        tactic == 'attack'
            ? 1.2
            : tactic == 'defend'
            ? .8
            : 1.0;
    base =
        (battleCasualtyBase(
                  troops: troops,
                  enemy: m.enemyTroops,
                  command: command,
                  siege: m.kind == 'siege',
                ) *
                casualtyTactic)
            .clamp(1, 100)
            .toDouble();
    cost = warMissionCost(s, m, troops);
    food = warMissionFood(troops, s, m);
  }
  final int troops;
  late final double command, affection, winChance, base;
  late final int withdrawal, tacticalChance, cost, food;
  int get winLossMin =>
      battleLosses(troops, base, won: true, retreated: false, reduction: 75);
  int get winLossMax =>
      battleLosses(troops, base, won: true, retreated: false, reduction: 50);
  int get defeatLoss =>
      battleLosses(troops, base, won: false, retreated: false, reduction: 0);
  int get retreatLossMin =>
      battleLosses(troops, base, won: false, retreated: true, reduction: 10);
  int get retreatLossMax =>
      battleLosses(troops, base, won: false, retreated: true, reduction: 25);
}

String? warDeployBlocked(
  GameState s,
  WarMission m,
  double ratio,
  Courtier? leader,
  Courtier? deputy,
) {
  if (s.warfare?.active?.id != m.countryId ||
      m.status != 'open' ||
      s.week > m.deadline) {
    return 'Nhiệm vụ đã đóng hoặc chiến tranh đã kết thúc.';
  }
  if (!warTroopRatios(m).contains(ratio)) {
    return 'Mức quân điều động không hợp lệ.';
  }
  final troops = warTroops(m, ratio);
  if (troops > missionAvailable(s, m)) {
    return 'Thiếu ${whole(troops - missionAvailable(s, m))} quân có thể điều động.';
  }
  if (leader == null) return 'Hãy chọn chủ tướng.';
  final blocked = warOfficerBlocked(s, leader);
  if (blocked != null) return blocked;
  if (deputy != null) {
    if (leader.id == deputy.id) return 'Chủ tướng và phó tướng phải khác nhau.';
    final reason = warOfficerBlocked(s, deputy);
    if (reason != null) return reason;
  }
  if (s.points < 1) return 'Cần 1 hành động.';
  if (s.treasury < warMissionCost(s, m, troops)) return 'Ngân khố không đủ.';
  if (s.grain < warMissionFood(troops, s, m)) return 'Kho lương không đủ.';
  return null;
}

bool tributeDue(GameState s, NeighborState n) {
  final t = n.treaty;
  return n.status == 'treaty' &&
      t != null &&
      !t.broken &&
      t.annualGold > 0 &&
      t.paidInstallments < t.installments &&
      t.nextDue <= s.week;
}

List<({NeighborState country, int amount})> tributeReceipts(GameState s) => [
  for (final n in s.warfare?.neighbors ?? <NeighborState>[])
    if (tributeDue(s, n) && n.treaty!.receiving && !n.treaty!.incomingWithheld)
      (country: n, amount: n.treaty!.annualGold),
];
List<({NeighborState country, int amount})> tributePayments(GameState s) => [
  for (final n in s.warfare?.neighbors ?? <NeighborState>[])
    if (tributeDue(s, n) && !n.treaty!.receiving)
      (country: n, amount: n.treaty!.annualGold),
];
int treatyDemandChance(NeighborState n, String tier) {
  if (tier == 'armistice') return n.advantage.abs() < 30 ? 95 : 70;
  final needed =
      tier == 'light'
          ? 30
          : tier == 'medium'
          ? 70
          : 90;
  if (n.advantage < needed) return 0;
  return (60 + (n.advantage - needed) * 2).clamp(5, 95);
}
