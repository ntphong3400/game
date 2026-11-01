import 'dart:math' as math;
import '../models/game_state.dart';
import 'population_rules.dart';

const garrisonNames = {
  'capital': 'Kinh Thành',
  'north': 'Bắc Ải',
  'west': 'Tây Ải',
  'south': 'Nam Ải',
};
const transferSizes = [2000, 5000, 10000];
const enemyFrontierCap = 40000;
String missionGarrison(WarMission m) =>
    m.kind == 'capital' ? 'capital' : m.countryId;
int missionAvailable(GameState s, WarMission m) =>
    s.population!.availableAt(missionGarrison(m));
bool liveMission(WarMission m) =>
    ['open', 'deployed', 'returning'].contains(m.status);
bool largeFrontierMission(String kind) =>
    ['defend', 'battle', 'naval', 'siege', 'capital'].contains(kind);
int reservedEnemy(GameState s, String country) => s.warfare!.missions
    .where((m) => m.countryId == country && liveMission(m))
    .fold(0, (n, m) => n + m.enemyTroops);
int enemyAvailable(GameState s, NeighborState n) =>
    math.max(0, n.enemyTroops - reservedEnemy(s, n.id));
double missionEnemyShare(String kind) => switch (kind) {
  'scout' => .10,
  'supply' => .15,
  'raid' => .20,
  'relieve' => .30,
  'defend' => .40,
  _ => .50,
};
int frontierMissionSize(GameState s, NeighborState n, String kind) {
  if (kind != 'capital' &&
      largeFrontierMission(kind) &&
      s.warfare!.missions.any(
        (m) =>
            m.countryId == n.id &&
            liveMission(m) &&
            largeFrontierMission(m.kind),
      )) {
    return 0;
  }
  final desired = (n.enemyTroops * missionEnemyShare(kind) / 100).ceil() * 100;
  return math.min(desired, enemyAvailable(s, n));
}

({int low, int high}) reinforcementRange(int endedYear) => (
  low: math.min(4000, 1000 + 200 * (math.max(1, endedYear) - 1)),
  high: math.min(5000, 2000 + 300 * (math.max(1, endedYear) - 1)),
);
bool frontierProtected(GameState s, NeighborState n) =>
    (n.status == 'treaty' && n.treaty?.broken != true) ||
    n.cooldownUntil > s.week ||
    n.defenseGraceThrough >= s.week;
int defensePenalty(double ratio) =>
    ratio >= 1
        ? 0
        : ratio >= .9
        ? 1
        : ratio >= .75
        ? 2
        : ratio >= .6
        ? 3
        : ratio >= .4
        ? 4
        : 6;

class FrontierDefense {
  FrontierDefense(GameState s, NeighborState n, {int troopChange = 0}) {
    final p = s.population!;
    final guards = p.deployments
        .where(
          (d) =>
              d.sourceGarrison == n.id &&
              s.warfare!.missions.any(
                (m) =>
                    m.id == d.missionId &&
                    m.kind == 'defend' &&
                    m.countryId == n.id &&
                    m.status == 'deployed',
              ),
        )
        .fold<int>(0, (total, d) => total + d.troops);
    troops = math.max(0, p.availableAt(n.id) + guards + troopChange);
    defense = troops * p.readinessAt(n.id) / 100 * commandMultiplier(s) * 1.35;
    situation =
        n.status == 'war'
            ? 1.15
            : n.status == 'tension'
            ? 1.0
            : .80;
    relation =
        n.relation >= 30
            ? .90
            : n.relation <= -30
            ? 1.10
            : 1.0;
    pressure = n.enemyTroops * n.enemyQuality / 100 * situation * relation;
    ratio = pressure <= 0 ? double.infinity : defense / pressure;
    protected = frontierProtected(s, n);
    protectionText =
        n.status == 'treaty'
            ? 'Hòa ước còn hiệu lực: không giảm ưu thế vì thiếu quân.'
            : n.defenseGraceThrough == s.week && n.cooldownUntil <= s.week
            ? 'Mùa chuẩn bị sau bảo hộ: không giảm ưu thế vì thiếu quân. Từ ${s.date(s.week + 1)} đánh giá phòng thủ trở lại.'
            : 'Bảo hộ hòa bình đến ${s.date(n.cooldownUntil)}; có một mùa chuẩn bị sau bảo hộ. Không giảm ưu thế vì thiếu quân.';
    penalty = protected ? 0 : defensePenalty(ratio);
    final causes = <String>[];
    if (ratio < 1) causes.add('thiếu sức phòng thủ');
    if (p.equipmentPercent < 70) causes.add('quân khí thấp');
    if (p.trainingAt(n.id) < 50) causes.add('huấn luyện thấp');
    if (p.moraleAt(n.id) < 50) causes.add('sĩ khí thấp');
    if (p.logistics < 80) causes.add('tiếp tế chưa đủ');
    reason = causes.join(', ');
  }
  late final int troops, penalty;
  late final double defense, pressure, ratio, situation, relation;
  late final bool protected;
  late final String reason, protectionText;
  String get label =>
      protected
          ? 'Được bảo hộ hòa bình'
          : ratio >= 1.2
          ? 'Dư sức phòng thủ'
          : ratio >= 1
          ? 'Đủ phòng thủ'
          : ratio >= .9
          ? 'Thiếu nhẹ'
          : ratio >= .75
          ? 'Thiếu lực lượng'
          : ratio >= .6
          ? 'Phòng tuyến yếu'
          : ratio >= .4
          ? 'Nguy cấp'
          : 'Gần như bỏ ngỏ';
  String get forecast =>
      protected
          ? protectionText
          : penalty == 0
          ? 'Dự kiến giữ nguyên ưu thế cuối mùa.'
          : 'Dự kiến ưu thế giảm $penalty cuối mùa — $reason.';
}

String? transferBlocked(GameState s, String from, String to, int count) {
  if (s.population == null || s.warfare == null) {
    return 'Lượt này chưa có quân đồn trú.';
  }
  if (!garrisonNames.containsKey(from) ||
      !garrisonNames.containsKey(to) ||
      from == to) {
    return 'Hãy chọn hai nơi đóng quân khác nhau.';
  }
  if (!transferSizes.contains(count)) {
    return 'Chỉ điều chuyển 2.000, 5.000 hoặc 10.000 quân.';
  }
  if (s.points < 1) return 'Cần 1 hành động.';
  if (count > s.population!.availableAt(from)) {
    return 'Không đủ quân rảnh tại ${garrisonNames[from]}.';
  }
  return null;
}

String transferWarning(GameState s, String from, int count) {
  final after = s.population!.availableAt(from) - count;
  if (from == 'capital') {
    return after < 10000
        ? 'Cảnh báo: Kinh Thành còn ${whole(math.max(0, after))} quân rảnh, dưới mức bảo vệ khuyến nghị 10.000.'
        : '';
  }
  final n = s.warfare!.neighbors.firstWhere((n) => n.id == from);
  final d = FrontierDefense(s, n, troopChange: -count);
  return d.protected || d.penalty == 0
      ? ''
      : 'Cảnh báo ${garrisonNames[from]}: ${d.forecast}';
}
